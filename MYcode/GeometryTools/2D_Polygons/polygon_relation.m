function [flag, varargout] = polygon_relation(contour1, contour2)
%This function distinguishes relationship between polygons which defined by 
% their vertices array in connected order and output the union polygon
% vertice array if polygon1 intersects with polygon2.
% Input: contour1/2 is the vertice array of polygon 1/2 sorted in the manner
% of tail to head. All the vertice array is defined as a 3*n matrix, in which
% a column expresses a vertice.
% Ouput: type is the relationship with two polygons where 1 represents
% polygon1 contains polygon2, 2 represents polygon2 contains polygon1, 3
% represents polygon1 intersects with polygon2, 4 represents polygon1
% separates from polygon2 and 5 represents polygon1 is equal to polygon2. 
% If polygon1 intersects with polygon2, extra varargout{1} is the vertice 
% array of the dif polygons(Polygon1 - Polygon2). Otherwise varargout{1} is 
% set to [].

if nargout > 1
    varargout{1} = [];
end

[x, y] = polyclip(contour1(1, :)', contour1(2, :)', contour2(1, :)', ...
    contour2(2, :)', 1);

if isempty(x)
    flag = 4;
    return;
else
    x = x{1};
    y = y{1};
    if range(diff(x)./diff(y)) < 1e-6
        flag = 4;
        return;
    end
end


[temp1, ~] = polyclip(x, y, contour1(1, :)', contour1(2, :)', 2);
[temp2, ~] = polyclip(x, y, contour2(1, :)', contour2(2, :)', 2);
if isempty(temp1) && isempty(temp2)
    flag = 5;
elseif isempty(temp1)
    flag = 2;
elseif isempty(temp2)
    flag = 1;   
else
    flag = 3;
    [x, y] = polyclip(contour1(1, :)', contour1(2, :)', contour2(1, :)', ...
        contour2(2, :)', 1);
    varargout{1} = [x{1}, y{1}, contour1(3, 1) * ones(size(x{1}))]';
end

end

