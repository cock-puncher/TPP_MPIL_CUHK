%%
clc
clear
close

%% parameters you may need to set
stlfp = 'models/gate.STL'; % input file path of the model
% ImageFolder = 'models/vase_model/'; % output folder,a foloder will be created in current directory to save images
% ImageName = 'spiral_model'; % output file name

% for printing configuration
% 3D printer modes: 'galva_point', 'galva_trajectory', 'DMD_point'
mode = 'galva_point'; 
thick = 0.15; % thickness of slices [mm]
% fill pattern and corresponding parameter: 'hilbert_curve'-order, 
% 'parallel_lines' - line distance [mm], line amount [mm]
% 'square' - line distance [mm], line amount [mm]
fill_pattern = 'square'; 
fill_parameter = [10, 7];
% wall configuration & 
contour_distance = 0.15; %% distance of every two parallel contour wall
contour_layer = 10; %% layer number of contour wall
contour_velocity = 30; %% velocity when printing models contour
% other parameters
fill_velocity = 30; %% velocity when printing filling trajectory
compact_line_distance = 0.15; %% the closed distance of two spots

% for device parameter
k1 = 0.018325;
k2 = 0.018325;
l = 285;
d = 10;
fHz = 200;
CoreNum = 4;

% %% set folder to save files of this model
% originalDir = pwd;
% mkdir(ImageFolder);
% cd(ImageFolder);
% mkdir('sliced bmps/');
% mkdir('DMD_points/');
% mkdir('trajectory/');
% cd(originalDir);
 
%% STL loading and scaling
disp('STL loading ...');
tic
[range_min, range_max, facet_table, compact_heights] = readSTL(stlfp, ...
    contour_layer);
disp(['Time consumed is ', num2str(toc)]);
ModelSize = range_max - range_min;
disp(['Original ModelSize(x*y*z) is ', num2str(ModelSize(1)), 'mm * ', ...
    num2str(ModelSize(2)), 'mm * ', num2str(ModelSize(3)), 'mm']);
scaleFactor = 0.5;%input('input a scaleFactor(input 1 means no scale):');
% plot_facets(facet_table, 1);
facet_table([1 4 7], :) = (facet_table([1 4 7], :) - (range_max(1) + range_min(1)) / 2) * scaleFactor;
facet_table([2 5 8], :) = (facet_table([2 5 8], :) - (range_max(2) + range_min(2)) / 2) * scaleFactor;
facet_table([3 6 9], :) = (facet_table([3 6 9], :) - range_min(3)) * scaleFactor;
compact_heights(1,:) = (compact_heights(1, :) - range_min(3)) * scaleFactor;
range_max = [max(max(facet_table([1 4 7], :))), max(max(facet_table([2 5 8], :))), ...
    max(max(facet_table([3 6 9], :)))];
range_min = [min(min(facet_table([1 4 7], :))), min(min(facet_table([2 5 8], :))), ...
    min(min(facet_table([3 6 9], :)))];
ModelSize = range_max - range_min;
disp(['New ModelSize(x*y*z) is ', num2str(ModelSize(1)), 'mm * ', ...
    num2str(ModelSize(2)), 'mm * ', num2str(ModelSize(3)), 'mm']);

%% slice the model and save the contours
disp('Slicing ...');
tic
contour_set = slice(facet_table, thick, range_min, range_max);
disp(['Time consumed is ', num2str(toc)]);

%% compute light spot trajectory and convert to points cloud 
disp('Trajectory generating ...');
slice_num = length(contour_set);
trajectory_set = cell(slice_num, 1);
points_set = cell(slice_num, 1);
if strcmp(mode, 'galva_trajectory') == false
    dim = ceil(range_max(1:2) / thick) - floor(range_min(1:2) / thick) + 1;
    points_map = zeros(dim(1), dim(2));
    offset = floor(range_min(1:2) / thick);
    delta = thick;
end
tic
MyPar = parpool('local', CoreNum);
layers = contour_layer * ones(slice_num, 1);
compact_heights = sortrows(compact_heights', 2)';
max_layers = ceil(max(ModelSize(1:2)) / contour_distance);
compact_heights(2, compact_heights(2, :) > max_layers) = max_layers;
layers(ceil(compact_heights(1, :) / thick) + 1) = compact_heights(2, :);
layers(floor(compact_heights(1, :) / thick) + 1) = compact_heights(2, :);
parfor i = 1:double(slice_num)
    %% compute trajectory
    if isempty(contour_set{i})
        continue;
    end
    % scan the contours and buld the wall
    sort_contour = sort_contours(contour_set{i});
    if isempty(sort_contour)
        continue;
    end
    contour_tree = hierarchy_contours(sort_contour);
%     plot_contour_tree(contour_tree, 3);
%     clf(3);
    [contour_trajectory, contour_set{i}] = offset_contours(contour_tree, ...
        contour_distance, layers(i), contour_velocity);
    fill_trajectory = solve_trajectory(contour_set{i}, fill_velocity, ...
        fill_pattern, [fill_parameter, compact_line_distance]);
    trajectory_set{i} = [contour_trajectory, fill_trajectory];
    %% dotlinize the line
    if isempty(trajectory_set{i}) == true
        continue;
    end
    if strcmp(mode, 'galva_trajectory')
        points_set{i} = sample(trajectory_set{i}, fHz);
    else
        points_set{i} = sample(trajectory_set{i}, points_map, offset', delta);
    end 
end
delete(MyPar);
%% plot
% for j = 1:double(slice_num)
%     figure(2);
%     if isempty(trajectory_set{j}) == false
%         trajectory = trajectory_set{j};
%         clf(2);
%         plot_trajectory(trajectory, 2);
%     end
% end  
% im_num = 1;
% im = struct('cdata',[],'colormap',[]);
% figure(3);
% for i = 1:double(slice_num)
%     if isempty(points_set{i}) == false
%         point = points_set{i};
%         axis(reshape([range_min;range_max], 1, 6));
%         hold on;
%         [im_num, im] = plot_points(point, 3, im, im_num);
%     end
% end
% points_set(cellfun(@isempty, points_set)) = [];
disp(['Time consumed is ', num2str(toc)]);

%% convert to hardware signals
disp('Signal generating ...');
tic
if strcmp(mode, 'galva_trajectory')
    [voltage, z_stage, OptSwitch] = galvo_labview(points_set', -1, k1, k2, l, d);
elseif strcmp(mode, 'galva_point')
    [voltage, z_stage, OptSwitch] = galvo_labview(points_set', 1, k1, k2, l, d);
else
    point_num = 1;
    for i = 1:length(points_set)
        if isempty(points_set{i}) == true
            continue;
        end
        point_matrix(:, point_num:point_num+size(points_set{i}, 2)-1) = points_set{i}(1:3, :);
        point_num = point_num + size(points_set{i}, 2);
    end
    TrajectoryByPoints_3000_40X_water_780nm_303(point_matrix, strcat(ImageFolder, 'DMD_points/'), 'A');
end
disp(['Time consumed is ', num2str(toc)]);


