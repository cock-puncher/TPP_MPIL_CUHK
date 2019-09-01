function points_out = hilbert_fill(points, fill_velocity, order)%����һ������켣��Ԫ��contour,Hilbert���ߵĽ���order(�������̶ȣ�orderԽ�����̶�Խ��)

points_out_Hilbert = [];
points_out_contour = [];

%����ƽ�����������е��x,y����ֱ��Ϊ2������
pos_x = [points(1,:) points(4,:)];
pos_y = [points(2,:) points(5,:)];

%����ƽ�����߶ε���ʼ�㡢��ֹ���x,y����ֱ��Ϊ4������
pos_start_x = points(1,:);
pos_start_y = points(2,:);
pos_end_x = points(4,:);
pos_end_y = points(5,:);

plot(pos_x,pos_y,'.')
hold on;

%��ȡ�����켣��x,y������ֵ����������һ���ܰ����������������Σ�Hilbert�����ڴ��������ڲ�����
x_max = max(pos_x);
x_min = min(pos_x);
y_max = max(pos_y);
y_min = min(pos_y);

square_length = max(x_max-x_min,y_max-y_min);%����ܹ������������εı߳�

%�Ӵ˴���ʼΪ����Hilbert���ߵ��㷨��A-D��AA-DD��Ϊ���ڵ����ľ����������Hilbert���ߵĸ�������洢�ھ���A��
A = zeros(0,1);
B = zeros(0,1);
C = zeros(0,1);
D = zeros(0,1);
north = [ 0  1];
east  = [ 1  0];
south = [ 0 -1];
west  = [-1  0];

%��������ĵ�������order��������
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

%�������ź�ƽ�Ʊ任�������ɵ�Hilbert���������֮ǰ���ɵ������ⲿ����������
A = [0 0; cumsum(A)];
A(:,1) = A(:,1).*square_length/(2^order-1)+x_min;
A(:,2) = A(:,2).*square_length/(2^order-1)+y_min;

INTERSECTIONS = [];%[];%���ڴ洢ֱ�ߺ�������������

[~,line_cols] = size(pos_start_x);

%��ѭ���Ƚ������ϸ���ɢ����ֱ�����ӣ�����һϵ��ˮƽ�ߣ�ʹ���������ཻ������������꣬���洢��INTERSECTIONS������
for k=1:line_cols
    K = (pos_end_y(1,k)-pos_start_y(1,k))/(pos_end_x(1,k)-pos_start_x(1,k));%�߶�б��
    B = pos_start_y(1,k)-K*pos_start_x(1,k);%�߶νؾ�

    y_A = unique(A(:,2));%��ȡHilbert�����и������п��ܵ�yֵ��������Ϊһϵ��ˮƽ��y=k��kֵ
    [y_A_rows,~]= size(y_A);

    %��forѭ��������������ˮƽ���������Ľ��㣬��ΪHilbert���������������н���
    for l=1:y_A_rows
        if pos_end_x(1,k) == pos_start_x(1,k)
            x_j = pos_start_x(1,k);
        else
            x_j = (y_A(l,1)-B)/K;
        end

        if (x_j-pos_start_x(1,k))*(x_j-pos_end_x(1,k))<-1e-8||(y_A(l,1)-pos_start_y(1,k))*(y_A(l,1)-pos_end_y(1,k))<-1e-8       
            %plot(x_j,y_A(l,1),'c-o')%��ͼ�л�������,��"o"��ʾ
           % hold on
            INTERSECTIONS = [INTERSECTIONS; x_j y_A(l,1)];%�洢����ϣ������������������������  
        end
    end
end

%��ѭ���ж�Hilbert�����и����Ƿ��������ڣ�����������⣬���ھ���A��ɾ���õ㣬���켣�������õ��������
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
            X_J = [X_J, INTERSECTIONS(m,1)];%����Hilbert������һ��Ϊ(x0,y0),X_J���ڴ洢ֱ��y=y0�������Ľ���
        end
    end
    
    [~, X_J_cols] = size(X_J);
    
    pos_judge = 1;
    tangency_judge = mod(X_J_cols,2);%�жϽ����Ƿ���켣����
    
    if tangency_judge == 0
    for n = 1:X_J_cols
        pos_judge = pos_judge*(A(j,1)-X_J(1,n));%����X_J�����ж�Hilbert������һ���������ڻ���������
    end
    else
        pos_judge = 1;%������У�ɾ��ϣ�����������ϵĸõ�
    end
    
    if pos_judge>0
        A(j,:)=[];%ɾ��������ĵ�
        j = j-1;
    end
end
 
plot(A(:,1), A(:,2))%�������յ�Hilbert���·��
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

%%%y����ע�Ͳ��ֿ����������ɹ켣���Ƶ�GIF��ͼ

% [rows_A,cols_A] = size(A);
% figure %�½�һ��ͼ
% 
% axis([-40 40 -40 40])%����x�ᣨ��0��5����y��ķ�Χ����0��2��
% 
% for i=1:rows_A
%     if i==1
%         plot(pos_x,pos_y,'.')
%   
%     else 
%      plot([A(i-1,1) A(i,1)],[A(i-1,2) A(i,2)],'r');
%     end
%     axis([-40 40 -40 40])
%     picname=[num2str(i) '.fig'];%������ļ�������i=1ʱ��picname=1.fig
% 
%     hold on % д�������ʱ������ǰ����ֳ��
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
%    %set(gcf,'outerposition',get(0,'screensize'));% matlab�������
% 
%     frame=getframe(gcf);  
% 
%     im=frame2im(frame);%����gif�ļ���ͼ�������index����ͼ��  
% 
%     [I,map]=rgb2ind(im,20);          
% 
%     if i==1
%         imwrite(I,map,'baidujingyan.gif','gif', 'Loopcount',inf,'DelayTime',0.2);%��һ�α��봴����
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
