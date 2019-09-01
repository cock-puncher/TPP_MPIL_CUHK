function points_out = hilbert_fill(points, fill_velocity, order)%输入一个代表轨迹的元胞contour,Hilbert曲线的阶数order(代表填充程度，order越大填充程度越高)

points_out_Hilbert = [];
points_out_contour = [];

%将该平面轮廓中所有点的x,y坐标分别存为2个矩阵
pos_x = [points(1,:) points(4,:)];
pos_y = [points(2,:) points(5,:)];

%将该平面中线段的起始点、终止点的x,y坐标分别存为4个矩阵
pos_start_x = points(1,:);
pos_start_y = points(2,:);
pos_end_x = points(4,:);
pos_end_y = points(5,:);

plot(pos_x,pos_y,'.')
hold on;

%获取轮廓轨迹的x,y坐标最值，用于作出一个能包含该轮廓的正方形，Hilbert曲线在此正方形内部生成
x_max = max(pos_x);
x_min = min(pos_x);
y_max = max(pos_y);
y_min = min(pos_y);

square_length = max(x_max-x_min,y_max-y_min);%求出能够包含该正方形的边长

%从此处开始为计算Hilbert曲线的算法，A-D，AA-DD均为用于迭代的矩阵，最后生成Hilbert曲线的各点坐标存储在矩阵A中
A = zeros(0,1);
B = zeros(0,1);
C = zeros(0,1);
D = zeros(0,1);
north = [ 0  1];
east  = [ 1  0];
south = [ 0 -1];
west  = [-1  0];

%根据输入的迭代次数order计算曲线
for n = 1:order
    
    AA = [B ; north ; A ; east  ; A ; south ; C];
    BB = [A ; east  ; B ; north ; B ; west  ; D];
    CC = [D ; west  ; C ; south ; C ; east  ; A];
    DD = [C ; south ; D ; west  ; D ; north ; B];

    A = AA;
    B = BB;
    C = CC;
    D = DD;
end

%坐标缩放和平移变换，将生成的Hilbert曲线填充至之前生成的轮廓外部的正方形中
A = [0 0; cumsum(A)];
A(:,1) = A(:,1).*square_length/(2^order-1)+x_min;
A(:,2) = A(:,2).*square_length/(2^order-1)+y_min;

INTERSECTIONS = [];%[];%用于存储直线和轮廓交点坐标

[~,line_cols] = size(pos_start_x);

%此循环先将轮廓上各离散点用直线连接，生成一系列水平线，使其与轮廓相交，求出交点坐标，并存储在INTERSECTIONS矩阵中
for k=1:line_cols
    K = (pos_end_y(1,k)-pos_start_y(1,k))/(pos_end_x(1,k)-pos_start_x(1,k));%线段斜率
    B = pos_start_y(1,k)-K*pos_start_x(1,k);%线段截距

    y_A = unique(A(:,2));%获取Hilbert曲线中各点所有可能的y值，将其作为一系列水平线y=k的k值
    [y_A_rows,~]= size(y_A);

    %此for循环计算所有上述水平线与轮廓的交点，即为Hilbert曲线与轮廓的所有交点
    for l=1:y_A_rows
        if pos_end_x(1,k) == pos_start_x(1,k)
            x_j = pos_start_x(1,k);
        else
            x_j = (y_A(l,1)-B)/K;
        end

        if (x_j-pos_start_x(1,k))*(x_j-pos_end_x(1,k))<-1e-8||(y_A(l,1)-pos_start_y(1,k))*(y_A(l,1)-pos_end_y(1,k))<-1e-8       
            %plot(x_j,y_A(l,1),'c-o')%在图中画出交点,用"o"表示
           % hold on
            INTERSECTIONS = [INTERSECTIONS; x_j y_A(l,1)];%存储所有希伯尔特曲线与轮廓交点坐标  
        end
    end
end

%此循环判断Hilbert曲线中各点是否在轮廓内，如果在轮廓外，则在矩阵A中删除该点，即轨迹中跳过该点进行连接
j=0;
while 1
    [A_rows,~] = size(A);
    j = j+1;
    
    if j>A_rows
        break;
    end
    
    [rows_INTERSECTIONS,~]= size(INTERSECTIONS);
    X_J = [];
    
  
    for m = 1:rows_INTERSECTIONS
        if A(j,2)==INTERSECTIONS(m,2)
            X_J = [X_J, INTERSECTIONS(m,1)];%假设Hilbert曲线上一点为(x0,y0),X_J用于存储直线y=y0与轮廓的交点
        end
    end
    
    [~, X_J_cols] = size(X_J);
    
    pos_judge = 1;
    tangency_judge = mod(X_J_cols,2);%判断交线是否与轨迹相切
    
    if tangency_judge == 0
    for n = 1:X_J_cols
        pos_judge = pos_judge*(A(j,1)-X_J(1,n));%根据X_J可以判断Hilbert曲线上一点在轮廓内还是轮廓外
    end
    else
        pos_judge = 1;%如果相切，删除希伯尔特曲线上的该点
    end
    
    if pos_judge>0
        A(j,:)=[];%删除轮廓外的点
        j = j-1;
    end
end
 
plot(A(:,1), A(:,2))%绘制最终的Hilbert填充路径
hold on;
axis([-50 50 -50 50]);

[A_rows,~] = size(A);
for i = 1:A_rows-1
    outside_line_judge = sqrt((A(i,1)-A(i+1,1))^2+(A(i,2)-A(i+1,2))^2);
    if outside_line_judge<=1.1*square_length/(2^order)
        points_out_Hilbert = [points_out_Hilbert, [A(i,1);A(i,2);points(3,1);A(i+1,1);A(i+1,2);points(3,1);25]];
    end
end

[~,points_cols] = size(points); 
for i = 1:points_cols-1
    points_out_contour = [points_out_contour, [points(1,i);points(2,i);points(3,i);points(4,i);points(5,i);points(6,i);25]];
end

points_out = [points_out_contour, points_out_Hilbert];

end

%%%y以下注释部分可以用于生成轨迹绘制的GIF动图

% [rows_A,cols_A] = size(A);
% figure %新建一张图
% 
% axis([-40 40 -40 40])%定义x轴（从0到5）和y轴的范围（从0到2）
% 
% for i=1:rows_A
%     if i==1
%         plot(pos_x,pos_y,'.')
%   
%     else 
%      plot([A(i-1,1) A(i,1)],[A(i-1,2) A(i,2)],'r');
%     end
%     axis([-40 40 -40 40])
%     picname=[num2str(i) '.fig'];%保存的文件名：如i=1时，picname=1.fig
% 
%     hold on % 写后面的字时，不把前面的字冲掉
% 
%     saveas(gcf,picname)
% 
% end
% 
% 
% stepall=rows_A;
% 
% for i=1:stepall
% 
%     picname=[num2str(i) '.fig'];
% 
%     open(picname)
% 
%    %set(gcf,'outerposition',get(0,'screensize'));% matlab窗口最大化
% 
%     frame=getframe(gcf);  
% 
%     im=frame2im(frame);%制作gif文件，图像必须是index索引图像  
% 
%     [I,map]=rgb2ind(im,20);          
% 
%     if i==1
%         imwrite(I,map,'baidujingyan.gif','gif', 'Loopcount',inf,'DelayTime',0.2);%第一次必须创建！
%     elseif i==stepall
%         imwrite(I,map,'baidujingyan.gif','gif','WriteMode','append','DelayTime',0.1);
%     else
%         imwrite(I,map,'baidujingyan.gif','gif','WriteMode','append','DelayTime',0.1);
%     end
% 
%     close all
% 
% end
% end
% 
