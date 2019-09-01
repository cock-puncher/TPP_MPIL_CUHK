function point_set = sample(trajectory, varargin)
%This function read a 7*n matrix(trajectory matrix) and output a 4*m sample points matrix 
% mode == 1(galvo trajectory scan mode):
% Sample points based on light spot velocity set in the 7th row of trajectory matrix and
% time interval dt along trajectory lines specifed by trajectory matrix
% mode == 2-(galvo trajectory scan mode):
% Sample points based on light spot velocity set in the 7th row of trajectory matrix and
% time interval dt along trajectory lines specifed by trajectory matrix

point_set = zeros(4, 1e5);
point_set_num = 1;
line = ones(3, 2);
if nargin < 3
    dt = 1 / varargin{1};
    for i = 1:size(trajectory, 2)
        line(:, 1) = trajectory(1:3, i);
        line(:, 2) = trajectory(4:6, i);
        dir_vec = (line(:, 2) - line(:, 1))/ norm(line(:, 1) - line(:, 2));
        sample_num = floor(norm(line(:, 1) - line(:, 2)) / (trajectory(7, i) * dt));
        if sample_num < 1
            continue;
        end
        line(:, 2) = line(:, 1) + sample_num * trajectory(7, i) * dt * dir_vec;
        for j = 1:3
            sample_point = interp1([0, sample_num * trajectory(7, i) * dt], line(j, :), ...
                (0:sample_num) * trajectory(7, i) * dt);
            point_set(j, point_set_num:(point_set_num + sample_num)) = sample_point;
        end
        if i == size(trajectory, 2) || sum(trajectory(4:6, i) ~= trajectory(1:3, i + 1))
            point_set(4, point_set_num + sample_num) = 1;
        end
        point_set_num = point_set_num + sample_num + 1;
    end
else
    points_map = varargin{1};
    offset = varargin{2};
    delta = varargin{3};
    n = size(points_map, 1);
    for i = 1:size(trajectory, 2)
        line(1:2, 1) = trajectory(1:2, i) / delta + 1 - offset;
        line(1:2, 2) = trajectory(4:5, i) / delta + 1 - offset;
        if all(line(1:2, 1) == line(1:2, 2))
            continue;
        end
        if line(1, 1) < line(1, 2)
            x_search = ceil(line(1, 1)):floor(line(1, 2));
        else
            x_search = ceil(line(1, 2)):floor(line(1, 1));
        end
        if line(2, 1) < line(2, 2)
            y_search = ceil(line(2, 1)):floor(line(2, 2));
        else
            y_search = ceil(line(2, 2)):floor(line(2, 1));
        end
        if (isempty(x_search) && line(2, 1) == line(2, 2)) || ( ...
                isempty(y_search) && line(1, 1) == line(1, 2)) 
            continue;
        end
        if length(x_search) > length(y_search) || (length(x_search) == ...
                length(y_search) && line(1, 1) ~= line(1, 2))
            sample_point = interp1(line(1, 1:2)', line(2, 1:2)', x_search);
%             index = find(abs(sample_point - round(sample_point)) < 1e-3);
            x_pos = round(x_search);
            y_pos = round(sample_point);
        else
            sample_point = interp1(line(2, 1:2)', line(1, 1:2)', y_search);
%             index = find(abs(sample_point - round(sample_point)) < 1e-3);
            x_pos = round(sample_point);
            y_pos = round(y_search);
        end
        index = find(points_map(n * (y_pos - 1) + x_pos) ~= 1);
        if isempty(index)
            continue;
        end
        x_pos = x_pos(index);
        y_pos = y_pos(index);
        points_map(n * (y_pos - 1) + x_pos) = 1;
        point_set(1:2, point_set_num:(point_set_num + length(x_pos) - 1)) = ...
            delta * ([x_pos;y_pos] - 1 + offset);
        point_set(3, point_set_num:(point_set_num + length(x_pos) - 1)) = trajectory(3, i);
        point_set_num = point_set_num + length(x_pos);
%         ori_vec = (trajectory(4:6, i) - trajectory(1:3, i));
%         len = norm(line(1:2, 1) - line(1:2, 2));
%         num = len / 1e-2;
%         dir_vec = 1e-2 * (line(1:2, 2) - line(1:2, 1)) / len;
%         for j = 0:num
%             temp_pos = line(1:2, 1) + j * dir_vec;
%             temp_near = round(temp_pos);
%             if norm(temp_pos - temp_near) < 5e-3 && points_map(temp_near(1), temp_near(2)) == 0
%                 points_map(temp_near(1), temp_near(2)) = 1;
%                 point = trajectory(1:3, i) + ori_vec / num * j;
%                 point_set(1:3, point_set_num) = point;
%                 point_set_num = point_set_num + 1;
%             end
%         end
    end
end
 point_set = point_set(:, 1:point_set_num-1);
    
                
    
    

