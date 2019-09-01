function trajectory = parallel_fill(contour_set, fill_velocity, solid_line_dis, repeat, compact_dis, direction)
%This function generate lines to follow the contour and use parallel lines to
% fill model's solid part defined by a contour matrix

% parameter
DELTA_SAME_POINT = 1e-6;

% set the direction of parallel lines
if direction == 1
    contour_set([1, 2, 4, 5], :) = contour_set([2, 1, 5, 4], :);
end

% load the contours
contour_table = contour_set;
len = size(contour_table, 2);
if length(unique(round(1e6 * contour_table))) <= 3
    trajectory = [];
    return;
end
contour_table = [reshape(contour_table, 3, len * 2); ...
    reshape([1:len;1:len], 1, len * 2); ones(1, len * 2)];
[~, index] = sortrows(round(contour_table, 8)', [1, 2]');
contour_table(:, 1:2 * len) = contour_table(:, index);

% generate lines to fill the solid part
y_order = contour_table([1,4],:);
contour_list = List(contour_set);
y_pos = 1;
solid_num = 1;
MAX_SOLID = 1e4;
pos = [];
for i = 1:repeat
    pos = [pos, floor(y_order(1,1))+(i-1)*compact_dis:solid_line_dis:y_order(1,length(y_order))];
end
pos = sort(pos);    
for j = pos
    while y_pos <= length(y_order) && y_order(1, y_pos) <= j
        contour_pos = y_order(2, y_pos);
        if contour_list.is_in(contour_pos) == false
            % add contour into list
            [~, contour_list] = contour_list.add_tail(contour_pos);
        else 
            % remove contour from list  
            [~, contour_list] = contour_list.remove(contour_pos);
        end
        y_pos = y_pos + 1;
    end
    % traverse the list and compute lines to fill the solid part
    intersect = @(contour, y)contour_intersect(contour, y);
    result = contour_list.traverse(intersect, j)';
    if isempty(result) == false
        result = sortrows(result, 2)';
        solid_set{solid_num} = List(result).add_all();
        % plot solid lines
%             figure(2);
%             for k=1:length(result)/2
%                 line(result(1, k*2-1:k*2), result(2, k*2-1:k*2));
%             end
%             hold on;
       solid_num = solid_num + 1;
    end
end

% connect solid lines in the form like zigzag    
clear contour_list
if exist('solid_set') == false
    trajectory = [];
    return;
end   
solid_trajectory_num = 1;
solid_list = List(1:length(solid_set));
solid_list = solid_list.add_all();
temp_pos = 1;
temp_row_pos = 1;
dir = 2;
point = [-1e6, -1e6]';
while solid_list.is_empty() == false
    % find the nearest solid line among the nearby rows
    temp_row = solid_set{solid_list.data_table(temp_pos)};
    disfun = @(solid, point)norm(solid(1:2) - point);
    [distance, solid_pos] = temp_row.traverse(disfun, point);
    [~, temp_row_pos] = min(distance);
    temp_row_pos = solid_pos(temp_row_pos);
    % add solid line into trajectory
    solid_trajectory{solid_trajectory_num}(:, 1) = temp_row.data_table(:, ...
        temp_row_pos);
    if rem(temp_row_pos, 2) == 1
        temp_row_next_pos = temp_row_pos + 1;
    else
        temp_row_next_pos = temp_row_pos - 1;
    end
    solid_trajectory{solid_trajectory_num}(:, 2) = temp_row.data_table(:, ...
         temp_row_next_pos);
    % remove the added solid line from the list
    [dir, next_temp_pos] = solid_list.walk(temp_pos, dir);
    [~, temp_row] = temp_row.remove(temp_row_pos);
    [~, solid_set{solid_list.data_table(temp_pos)}] = temp_row.remove(temp_row_next_pos);
    if solid_set{solid_list.data_table(temp_pos)}.is_empty() == true
        if dir == 0
           [dir, next_temp_pos] = solid_list.walk(temp_pos, dir);
        end
        [~, solid_list] = solid_list.remove(temp_pos);
    end
    hold on;
    % set the end point of this solid line for the next loop
    point = solid_trajectory{solid_trajectory_num}([1 2], 2);
    solid_trajectory_num = solid_trajectory_num + 1;
    temp_pos = next_temp_pos;
end

% save trajectory
trajectory_num = 1;
trajectory = fill_velocity * ones(7, 1e4);
for i = 1:size(solid_trajectory, 2)
    j = 1;
    while j < size(solid_trajectory{i}, 2)
        trajectory(1:3, trajectory_num) = solid_trajectory{i}(1:3, j);
        trajectory(4:6, trajectory_num) = solid_trajectory{i}(1:3, j + 1);
        j = j + 1;
        trajectory_num = trajectory_num + 1;
    end
end 
trajectory = trajectory(:, 1:trajectory_num-1);

if direction == 1
    trajectory([1, 2, 4, 5], :) = trajectory([2, 1, 5, 4], :);
end
end

