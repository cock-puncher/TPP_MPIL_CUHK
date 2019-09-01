function [range_min, range_max, facet_table, compact_heights] = readSTL(filename, contour_layer)
% This function reads an STL file in binary format into matrixes X, Y and
% Z, and C.  C is optional and contains color rgb data in 5 bits.  
%
% USAGE: [range_min, range_max, facet_table, index_table] = readSTL(filename);

if nargout > 4
    error('Too many output arguments')
end

fid = fopen(filename, 'r'); %Open the file, assumes STL Binary format.
if fid == -1 
    error('File could not be opened, check name or path.')
end

ftitle = strsplit(fgetl(fid)); % Read file title

disp(['  STL Title: ', ftitle{2}]);

% Establish an index table of facets
MAX_FACETS = 1e7;
facet_table = zeros(9,MAX_FACETS);
compact_heights = zeros(2, 1e6);
heights_num = 1;

range_min = 1e6*ones(1,3);
range_max = -1e6*ones(1,3);
vertices = zeros(3,3);

for i=1:MAX_FACETS
    % read normal vector
    line = strsplit(fgetl(fid));
    if fgetl(fid) == -1
        facet_table = facet_table(:, 1:i-1);
        disp(['  Facets: ', num2str(i-1)]);
        break;
    end
    normal = zeros(3, 1);
    for k = 1:3
        normal(k) = str2num(line{3+k});
    end
    % read vertices' coordinate
    for j = 1:3
        line = strsplit(fgetl(fid));
        for k = 1:3
            vertices(j, k) = str2num(line{2+k});
        end
    end
    % register height z for facet facing upward
    val = abs(dot(normal, [0, 0, 1])) / norm(normal);
    layers = ceil(1 / tan(acos(val)));
    if layers > contour_layer
        compact_heights(:, heights_num:heights_num+2) = [vertices(1:3, 3)'; layers * ones(1, 3)];
        heights_num = heights_num + 3;
    end
    fgetl(fid);
    fgetl(fid);
    max_val = max(vertices);
    min_val = min(vertices);
    % fill in facet_table
    range_min = min(min_val,range_min);
    range_max = max(max_val,range_max);
    facet_table(:, i) = reshape(vertices',9,1)';
end

compact_heights = compact_heights(:, 1:heights_num-1);

fclose(fid);

end

