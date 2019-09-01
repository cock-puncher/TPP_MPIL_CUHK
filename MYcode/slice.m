function contour_set = slice(facet_table, thick, range_min, range_max)
%This function takes in facet matrix and output a cell consisted of contour matrixs
% Compute contours where z=z_i plane intersects with model surface

% establish  a waiting bar
h = waitbar(0,'Slicing: Please wait...');
% compute contours
facet_list = List(facet_table);
len = length(facet_table);
z_order = [max(facet_table([3 6 9],:)), min(facet_table([3 6 9],:))];
z_order = sortrows([z_order; [1:len,1:len]]',1)';
z_pos = 1;
slice_num = 1;
for i = range_min(3):thick:range_max(3)
    while z_order(1, z_pos) <= i
        facet_pos = z_order(2, z_pos);
        if facet_list.is_in(facet_pos) == false
            % add facet into list
            [~, facet_list] = facet_list.add_tail(facet_pos);
        else 
            % remove facet from list  
            [~, facet_list] = facet_list.remove(facet_pos);
        end
        z_pos = z_pos + 1;
    end
    % traverse the list and contruct a sliced bmp
    intersect = @(facet, z)tri_intersect(facet, z);
    contour = facet_list.traverse(intersect, i);
    contour_set{slice_num} = contour;
    slice_num = slice_num + 1;
    % add waiting bar
    waitbar((i - range_min(3)) / (range_max(3) - range_min(3)), h);
end

close(h);

end

