number = 24246536;

x=rand([1, number], 'single'); %������CPU�ϵ�һ��10x10�������ʼ������
y=rand([1, number], 'single');

tic
GX=gpuArray(x);      %��GPU��ʼ����GX�����ҽ�X��ֵ����GX
GY=gpuArray(y);
angle_1 = 0.5*atan(-l./GX);
angle_2 = 0.5*atan((-d./GY).*(l./(d.*sin(2.*angle_1)) + 1));
angle1=gather(angle_1);
angle2=gather(angle_2);
toc

tic
angle_3 = 0.5*atan(-l./x);
angle_4 = 0.5*atan((-d./y).*(l./(d.*sin(2.*angle_3)) + 1));
toc