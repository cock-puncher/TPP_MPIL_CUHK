function contour_tree = hierarchy_contours(sort_contour)
%

hierarchy = zeros(length(sort_contour));

i = 1;
while i <= length(sort_contour)
    temp = ver2tra(sort_contour{i}, 0);
    if ~isempty(temp)
        line_contour{i} = temp(1:6, :);
        i = i + 1;
    else
        sort_contour = [sort_contour(1:i-1);sort_contour(i+1:end)];
    end
end
    
for i = 1:length(sort_contour)
    point = sort_contour{i}(:, 1);
    for j = 1:size(line_contour, 2)
        if j ~= i && hierarchy(i, j) == 0
            select = line_contour{j}(:, (((line_contour{j}(2, :) - point(2)) .* ...
                (line_contour{j}(5, :) - point(2))) <= 0));
            select = select(:, select(2, :) ~= select(5, :));
            select = select(:, select(1, :) + (point(2) - select(2, :)) ./ (select(5, :) - ...
                select(2, :)) .* (select(4, :) - select(1, :)) <= point(1));
            select_twice = select(:, ((select(2, :) - point(2)) .* (select(5, :) - point(2))) == 0);
            select_twice = reshape(select_twice, 12, []);
            select_twice = select_twice(:, ((select_twice(2, :) - select_twice(5, :)) .* ...
                (select_twice(8, :) - select_twice(11, :))) >= 0);
            if rem(size(select, 2) - size(select_twice, 2), 2) == 1
                hierarchy(i, j) = -1;
                hierarchy(j, i) = 1;
            end
        end
    end
end

contour_tree = Tree();
for i = 1:length(sort_contour)
    high = find(hierarchy(i, :) == -1);
    if isempty(high) == false
        [~, pos] = max(sum(hierarchy(:, high), 1));
        contour_tree = contour_tree.add_leaf(sort_contour{i}, high(pos) + 1);
    else
        contour_tree = contour_tree.add_leaf(sort_contour{i}, 1);
    end
end

end

