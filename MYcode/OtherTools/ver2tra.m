function trajectory = ver2tra(vertices, velocity)
%This function reads a vertice matix

if size(vertices, 2) > 2
    trajectory = zeros(7, size(vertices, 2));
    trajectory(1:3, :) = vertices;
    trajectory(4:6, :) = [vertices(:, 2:size(vertices, 2)), vertices(:, 1)];
    trajectory(7, :) = velocity;
else
    trajectory = [];
end

end

