function save_gif(im, filename)
for idx = 1:size(im, 2)   
    [A,map] = rgb2ind(frame2im(im(idx)),256);    
    if idx == 1       
        imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',1e-1);   
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',1e-1);  
    end
end
