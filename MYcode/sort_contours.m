function contour_trajectory = sort_contours(contour_table)
%This function reads a contour matix and sort it according to the
% connection relationship

% parameter
DELTA_SAME_POINT = 1e-6;

% load the contours
len = size(contour_table, 2);
if length(unique(round(1e6 * contour_table))) <= 3
    contour_trajectory = [];
    return;
end
contour_table = [reshape(contour_table, 3, len * 2); ...
    reshape([1:len;1:len], 1, len * 2); ones(1, len * 2)];
[~, index] = sortrows(round(contour_table, 8)', [1, 2]');
contour_table(:, 1:2 * len) = contour_table(:, index);

% generate contour trajectory
for contour_trajectory_num = 1:len
    temp = find(contour_table(5, :) ~= -1e6, 1);
    if isempty(temp)
        break;
    end
    contour_trajectory{contour_trajectory_num} = zeros(3, len + 1);
    contour_trajectory{contour_trajectory_num}(:, 1) = contour_table(1:3, temp);
    for j = 1:len
        contour_table(5, temp) = -1e6;
        for k = 1:len * 2
            if temp ~= k && contour_table(4, temp) == contour_table(4, k)
                contour_trajectory{contour_trajectory_num}(:, j + 1) = contour_table(1:3, k);
                temp = k;
                contour_table(5, temp) = -1e6;
                break;
            end
        end
        if temp > 1 && norm(contour_table(1:2, temp) - contour_table(1:2, temp - 1)) ...
                < DELTA_SAME_POINT && contour_table(5, temp - 1) ~= -1e6
            temp = temp - 1;
        elseif temp < 2 * len && norm(contour_table(1:2, temp) - contour_table(1:2, temp + 1)) ...
                < DELTA_SAME_POINT && contour_table(5, temp + 1) ~= -1e6
            temp = temp + 1;
        else
           contour_trajectory{contour_trajectory_num} = ...
               contour_trajectory{contour_trajectory_num}(:, 1:j);
           break;
        end     
    end
end
end

