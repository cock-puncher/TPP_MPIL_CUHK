function point = contour_intersect(contour, y)
%UNTITLED4 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
point = [0, 0, contour(3)]';
if y < min(contour([1 4])) || y > max(contour([1 4])) || contour(4) == contour(1)
    point = [];
else 
    point(2) = (y - contour(1)) / (contour(4) - contour(1)) * (contour(5) - ...
        contour(2)) + contour(2);
    point(1) = y;
end
end

