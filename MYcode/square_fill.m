function trajectory = square_fill(contour_set, fill_velocity, solid_line_dis, repeat, compact_dis)
%This function generate lines to follow the contour and use parallel lines to
% fill model's solid part defined by a contour matrix

trajectory1 = parallel_fill(contour_set, fill_velocity, solid_line_dis, repeat, compact_dis, 0);
trajectory2 = parallel_fill(contour_set, fill_velocity, solid_line_dis, repeat, compact_dis, 1);

trajectory = [trajectory1, trajectory2];

end

