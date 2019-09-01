function trajectory = solve_trajectory(contour_set, fill_velocity, type, varargin)
%This function generate lines to follow the contour and fill model's solid
% part defined by a contour matrix

if strcmp(type, 'parallel_lines')
    parameter = varargin{1};
    trajectory = parallel_fill(contour_set, fill_velocity, parameter(1), parameter(2), parameter(3), 0);
elseif strcmp(type, 'hilbert_curve')
    parameter = varargin{1};
    trajectory = hilbert_fill(contour_set, fill_velocity, parameter(1));
elseif strcmp(type, 'square')
    parameter = varargin{1};
    trajectory = square_fill(contour_set, fill_velocity, parameter(1), parameter(2), parameter(3));
else
    trajectory = [];
end

end

