function points = tri_intersect(facet, z)
% This function reads an triangle facet and cut plane represented by z
% returns two points where tri facet intersects with cut plane in a form of 4-column vector
points = zeros(6, 1);
points_pos = 0;
for i = 1:3
    for j = i+1:3
        [flag, point] = line_intersect(facet(i*3-2:i*3), facet(j*3-2:j*3), z);
        if flag == 1
            points(points_pos*3+1:points_pos*3+3, 1) = point;
            points_pos = points_pos + 1;
        end
        if points_pos == 2
            break;
        end
    end
    if points_pos == 2
        break;
    end
end
end

