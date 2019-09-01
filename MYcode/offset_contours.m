function [trajectory, new_contours] = offset_contours(contour_tree, delta, layer, verlocity)
%This function reads a contour matix and sort it according to the
% connection relationship

trajectory_num = 1;
trajectory = zeros(7, 1e6);
queue = contour_tree.get_children(1);
while ~isempty(queue)
    new_queue = [];
    for i = 1:length(queue)
        new_queue = [new_queue, contour_tree.get_children(queue(i))];
        contour = ver2tra(contour_tree.get_data(queue(i)), verlocity);
        trajectory(:, trajectory_num:trajectory_num+size(contour, 2)-1) = contour;
        trajectory_num = trajectory_num + size(contour, 2); 
    end
    queue = new_queue;
end

for layer_num = 1:layer
%     plot_contour_tree(contour_tree, 3);
%     clf(3);
    old_trajectory_num = trajectory_num; 
    queue = contour_tree.get_children(1);
    while ~isempty(queue)
        new_queue = []; % storage contours' ptr at the next depth
        depth = contour_tree.get_depth(queue(1));
        if rem(depth, 2) == 0
            % process outer contour
            for i = 1:length(queue)
                % find the parent contour
                parent = contour_tree.get_parent(queue(i));
                % find the slave contours
                children = contour_tree.get_children(queue(i));
                child_contour = cell(length(children), 1);
                for j = 1:length(children)
                    child_contour{j} = contour_tree.get_data(children(j));
                end
                % offset the outer contour
                contour = contour_tree.get_data(queue(i));
                [cell_x, cell_y] = polyout(contour(1, :), contour(2, :), -delta, 'm', 2);
                if isempty(cell_x)
                    continue;
                end
                offset_contour = cell(length(cell_x), 1);
                % remove the outer contour from the tree
                [contour_tree, ~] = contour_tree.remove(queue(i));
                % modify the contour_tree based on relationship bewteen the offset
                % contour and the slave contours
                in_tree = zeros(length(child_contour), 1);
                j = 1;
                while j <= length(offset_contour)
                    %%compute the relationship bewteen offset polygon and
                    %%inside polygons
                    if j <= length(cell_x)
                        offset_contour{j} = [cell_x{j}'
                                       cell_y{j}'
                                       contour(3, 1) * ones(1, length(cell_x{j}))];
                    end
                    relate = zeros(length(child_contour), 1);
                    for k = 1:length(child_contour)
                        relate(k) = polygon_relation(child_contour{k}, offset_contour{j});
                    end
                    %%SEE in the program guide
                    if ~isempty(find(relate == 1, 1))
                        j = j + 1;
                        continue;
                    elseif ~isempty(find(relate == 3, 1))
                        in_polygons = find(relate == 3);
                        out_polygons{1} = offset_contour{j};
                        for h = 1:length(in_polygons)
                            out_num = 1;
                            for g = 1:length(out_polygons)
                                poly_in = child_contour{in_polygons(h)};
                                poly_out = out_polygons{g};
                                [x, y] = polyclip(poly_out(1, :)', poly_out(2, :)', ...
                                    poly_in(1, :)', poly_in(2, :)', 0);
                                if isempty(x)
                                    continue;
                                end
                                for f = 1:length(x)
                                    if isempty(x{f})
                                        continue;
                                    end
                                    new_out_polygons{out_num} = ...
                                      [x{f}'
                                       y{f}'
                                       contour(3, 1) * ones(1, length(x{f}))];
                                    out_num = out_num + 1;
                                end
                            end
                            out_polygons = new_out_polygons;
                        end
                        offset_contour = [offset_contour; out_polygons'];
                    else
                        in_polys = find(relate == 2);
                        in_tree(in_polys) = 1;
                        in_polys = children(in_polys);
                        [contour_tree, ptr] = contour_tree.add_leaf(offset_contour{j}, parent);
                        trajectory(:, trajectory_num:trajectory_num+size(offset_contour{j}, 2)-1) = ...
                                ver2tra(offset_contour{j}, verlocity);
                        trajectory_num = trajectory_num + size(offset_contour{j}, 2); 
                        contour_tree = contour_tree.modify(ptr, 'children', in_polys);
                        for k = 1:length(in_polys)
                            contour_tree = contour_tree.modify(in_polys(k), 'parent', ptr);
                        end
                    end
                    j = j + 1;
                end
                % adjust the depth of polygons escaping
                escape_polys = children(in_tree == 0);
                for j = 1:length(escape_polys)
                    adopt_child = contour_tree.get_children(escape_polys(j));
                    temp = contour_tree.get_children(parent);
                    contour_tree = contour_tree.modify(parent, 'children', [temp, adopt_child]);
                    for k = 1:length(adopt_child)
                        contour_tree = contour_tree.modify(adopt_child(k), 'parent', parent);
                    end
                end    
                new_queue = [new_queue, children(in_tree ~= 0)];    
            end
        else
            % process inner contour
            i = 1;
            while i <= length(queue)
                % find the parent contour
                parent = contour_tree.get_parent(queue(i));
                parent_contour = contour_tree.get_data(parent);
                % find the slave contours
                cousin = contour_tree.get_children(parent);
                cousin = cousin(cousin ~= queue(i));
                for j = 1:length(cousin)
                    cousin_contour{j} = contour_tree.get_data(cousin(j));
                end
                % find child contours
                child = contour_tree.get_children(queue(i));
                % offset the inner contour
                contour = contour_tree.get_data(queue(i));
                [cell_x, cell_y] = polyout(contour(1, :), contour(2, :), delta, 'm', 2);
                offset_contour = [cell_x{1}'
                                  cell_y{1}'
                                  contour(3, 1) * ones(1, length(cell_x{1}))];
                % modify the contour_tree based on relationship bewteen the offset
                % contour and the parent/cousin contours
                if polygon_relation(offset_contour, parent_contour) ~= 2
                    i = i + 1;
                    continue;
                end
                contour_tree = contour_tree.modify(queue(i), 'data', offset_contour);
                % union with its cousin contours
                if exist('cousin_contour','var')
                    for j = 1:length(cousin_contour)
                        relate = polygon_relation(offset_contour, cousin_contour{j});
                        if relate ~= 4
                           [cell_x, cell_y] = polyclip(offset_contour(1, :)', offset_contour(2, :)', ...
                                    cousin_contour{j}(1, :)', cousin_contour{j}(2, :)', 3);
                           offset_contour = [cell_x{1}'
                                            cell_y{1}'
                                            contour(3, 1) * ones(1, length(cell_x{1}))];
                           contour_tree = contour_tree.modify(queue(i), 'data', offset_contour);
                           union_child = [child, contour_tree.get_children(cousin(j))];
                           contour_tree = contour_tree.modify(queue(i), 'children', union_child);
                           contour_tree = contour_tree.remove(cousin(j));
                           queue = queue(queue ~= cousin(j));
                        end
                    end
                end
                trajectory(:, trajectory_num:trajectory_num+size(offset_contour, 2)-1) = ...
                            ver2tra(offset_contour, verlocity);
                trajectory_num = trajectory_num + size(offset_contour, 2);
                new_queue = [new_queue, child];
                i = i + 1;
            end
        end
        queue = new_queue;
    end
    if trajectory_num == old_trajectory_num
        break;
    end
end
trajectory = trajectory(:, 1:trajectory_num-1);

queue = contour_tree.get_children(1);
contour_num = 1;
new_contours = zeros(7, 1e6);
while ~isempty(queue)
    new_queue = [];
    for i = 1:length(queue)
        new_queue = [new_queue, contour_tree.get_children(queue(i))];
        contour = ver2tra(contour_tree.get_data(queue(i)), verlocity);
        new_contours(:, contour_num:contour_num+size(contour, 2)-1) = contour;
        contour_num = contour_num + size(contour, 2); 
    end
    queue = new_queue;
end
new_contours = new_contours(1:6, 1:contour_num-1);

end