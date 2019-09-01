function [voltage, z_stage, OptSwitch] = galvo_labview(PointsCell, mode_in, k1, k2, l0, d)
%This function is for converting point coordinates to the controlling signals for the two galvos and z coordinates.  
%   Inputs:PointsCell is a 1*m Cell Array, in which m represent the layer
%   and each cell is a 4*h matrix, in which elements 1 to 3 represent the
%   coordinate,and element 4 represent whether this point is the end-point
%   and 1 is for the end. Mode 1 (mode_in¡Ý0) is for the trajectory scanning mode and
%   Mode 0£¨mode_in = -1£© is for the point-by-point scanning mode. k1,k2 represent the
%   zoom factors for y and x.l is the distance between the galvo and the
%   plant and d is the distance between the two galvos Outputs: voltage is
%   a 2*h matrix for labview to control the two galvos and z_stage for the
%   stage whose unit is mm and OptSwitch is for the laser switch in which 1
%   represents "open".

[~, Layer_TN] = size(PointsCell);
N_AllPoints = 0;
z_stage = zeros(1e8, 1);
OptSwitch = zeros(1e8, 1);
x_temp = zeros(1e8, 1);
y_temp = zeros(1e8, 1);

for i = 1:1:Layer_TN
    [~, temp__] = size(PointsCell{i});
    if temp__ == 0 
        continue;
    end
    z_stage(N_AllPoints + 1: N_AllPoints + temp__) = PointsCell{i}(3, :)';
    x_temp(N_AllPoints + 1:N_AllPoints + temp__) = PointsCell{i}(1, :)';
    y_temp(N_AllPoints + 1:N_AllPoints + temp__) = PointsCell{i}(2, :)';
    OptSwitch(N_AllPoints + find(PointsCell{i}(4, :) == 1)) = 1; 
    N_AllPoints = N_AllPoints + temp__; 
end
z_stage = z_stage(1:N_AllPoints)';
x_temp = x_temp(1:N_AllPoints)';
y_temp = y_temp(1:N_AllPoints)';
OptSwitch = OptSwitch(1:N_AllPoints)';

l = l0 - z_stage;
angle_2 = 0.5*atan(-l./y_temp);
angle_1 = 0.5*atan((-d./x_temp).*(l./(d.*sin(2.*angle_2)) + 1));

[~,angle_cols] = size(angle_2);
for k = 1:angle_cols    
    if(angle_1(1,k)<0)
        angle_1(1,k) = angle_1(1,k)+0.5*pi;% Considering that multiple solutions may exist, angle_1,angle_2 should be range in (0,0.5*pi) 
    end
    if(angle_2(1,k)<0)
        angle_2(1,k) = angle_2(1,k)+0.5*pi;
    end
end

d_angle_1 = -angle_1+0.25*pi;
d_angle_2 = angle_2-0.25*pi;
voltage_x = d_angle_1./k1;
voltage_y = d_angle_2./k2;
voltage= [voltage_x;voltage_y];



