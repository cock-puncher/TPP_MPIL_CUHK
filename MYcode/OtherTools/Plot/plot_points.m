function varargout = plot_points(points, fig_num, varargin)
%This function display a model in the form of 3D discrete point cloud.
% Input: points is a 3*n matrix, where a column is a point's coordinate.
% figure(fig_num) is the figure will be opened and plotted. Varargin{1/2}
% is for saving gif. Varargin{1} is matrix saving fig frames and
% varargin{2} saves the next available varargin{1} position for frame
% storage.
% Output: varargout{1} is the next available varargin{1} position.

if nargin > 2
    im = varargin{1};
    im_num = varargin{2};
end

scatter3(points(1, :), points(2, :), points(3, :), 1, points(3, :), '.');
hold on;
if nargin > 2
    im(im_num) = getframe(fig_num); % save gif
    im_num = im_num + 1;
end

if nargout > 0
    if nargin > 2 
        varargout{1} = im_num;
        varargout{2} = im;
    else
        varargout{1} = 0;
        varargout{2} = 0;
    end
end

end

