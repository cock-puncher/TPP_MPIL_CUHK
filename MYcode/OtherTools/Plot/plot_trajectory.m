function varargout = plot_trajectory(trajectory, fig_num, varargin)
%This function display a model in the form of 2D-line filling trajectory.
% Input: trajectory is a 6/7*n matrix, where a column is the line endpoints'
% coordinate. Figure(fig_num) is the figure which will be plotted on. 
% Varargin{1/2} is for saving gif. Varargin{1} is matrix saving fig frames 
% and varargin{2} saves the next available varargin{1} position for frame
% storage.
% Output: varargout{1} is the next available varargin{1} position.

if nargin > 2
    im = varargin{1};
    im_num = varargin{2};
end

for j = 1:size(trajectory, 2)
    line(trajectory([1 4], j), trajectory([2 5], j));
    hold on;
    if nargin > 2
        im(im_num) = getframe(fig_num); % save gif
        im_num = im_num + 1;
    end
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

