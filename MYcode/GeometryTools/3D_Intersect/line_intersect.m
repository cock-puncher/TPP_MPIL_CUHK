function [flag, point] = line_intersect(p1, p2, z)
%This function reads two points' coordinates(represented by two column vector) 
% and a cut plane  z
% returns inersected points with regard to them when existing(flag == 1)

if z<min(p1(3),p2(3)) || z>max(p1(3),p2(3)) || p1(3) == p2(3)
    flag = 0;
    point = [0,0,0];
else 
    point = [(z-p1(3))/(p2(3)-p1(3))*(p2(1)-p1(1))+p1(1),(z-p1(3))/(p2(3)-p1(3))*(p2(2)-p1(2))+p1(2),z]';
    flag = 1;
end

