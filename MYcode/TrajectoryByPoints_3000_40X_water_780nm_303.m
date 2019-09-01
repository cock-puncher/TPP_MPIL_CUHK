function TrajectoryByPoints_3000_40X_water_780nm_303(Points, Path_File,suffixChar) 
%%
% 'Points' is an array with a dimension of Num*3. All the points need to be
% fabricated are contained in the 'Points' array.
%% Initial parameters

% wavelength, nm
wl = 780*10^-9; 

%radius of light spot on DMD
wf_r = 4*10^-3;

% spherical wavefront, for beam shaping, you can replace it by other functions
% P, optical power, equals to 1/f, unit m^-1
fi = @(x,y,P) pi*(x.^2+y.^2).*(-P)./wl;

% control the width of the fringes
q = 1;

% pixels of the DMD
m = 1024; n = 768;

% size of a pixel, um
pSize = 13.68*10^-6;

[row,col] = meshgrid(1:m,1:n);

% original point where x=0, y=0, z=0
% u, v, P are x and y diretion's spatial frequency of DMD pattern, and  optical power, respectively
u0 = 0.1;
v0 = 0;
P0 = 0;


%% scanning trajactories 2
% under the system in 303, the x scan range is (0 um ,50 um), y scan range is (-63 um ,63 um),z scan range is (-40 um ,40 um)

% The unit is micron for the positions.
 [Num, ~] = size(Points);

disp('---PICTURE WRITING START---'); 
 
bigPic = zeros(768 * 3000, 128, 'uint8');

% [ModeNum,dim]=size(Zer);

pic_cnt_total = 0;
pic_cnt_pack = 0;
pack_num = 1;
last_pack_num = mod(Num, 3000);
total_pack = ceil(Num / 3000);

%suffixChar = 'C';
% [ModeNum,dim]=size(Zer);
% for Mode= 1:ModeNum

for t=1:Num
        x = Points(t,1);
        y = Points(t,2);
        z = Points(t,3);
% accordingly parameters under optical settng: 54 mm scan lens; 175 mm tube
% lens, 40X water immersion

        
        u = x/124.41;
        v = y/124.41;
        P = z/12.7;

% desired grating spatial frequency for X and Y direction
        FreX = u+u0;
        FreY = v+v0;

% calculate grating period for X0 and Y0 direction
        FreX0 = (FreX-FreY)/2;
        FreY0 = (FreX+FreY)/2;

% tilted phase 
        X0 = col*FreX0;
        Y0 = row*FreY0;

        XY = (X0+ Y0);

% computer spherical wavefront
        A = fi((row-(m+1)/2)*pSize,(col-(n+1)/2)*pSize,P+P0);
%         A = 0;

% [theta,r] = cart2pol((row-(m+1)/2)*pSize/wf_r,(col-(n+1)/2)*pSize/wf_r);
%  
% cor = Zer(Mode,3)*zernfun(Zer(Mode,1),Zer(Mode,2),r,theta,'norm');
% add titled phase & Zernike wavefront modes
%         C = (A+cor)/(2*pi)+ XY;

        C = A/(2*pi)+ XY;
        M = C-floor(C);
        Mf = abs(M);

% according to the Lee Holography
        Mf(Mf < q/2) = 0;
        Mf(Mf >= q/2) = 1;
        R = 1-Mf;

% transfer to DLP4100 required mode
       stride=128;
       im = uint8(zeros(n,stride));
        for i=1:stride
               im(:,i)=128*R(:,8*i-7)+64*R(:,8*i-6)+32*R(:,8*i-5)+16*R(:,8*i-4)+8*R(:,8*i-3)+4*R(:,8*i-2)+2*R(:,8*i-1)+R(:,8*i);
        end

% save each binary patterns as bmp file, each file is around 96 KB
        pic_cnt_total = pic_cnt_total + 1;
        
        pic_cnt_pack = pic_cnt_pack + 1;
        
        bigPic(((pic_cnt_pack - 1) * 768 + 1) : pic_cnt_pack * 768, :) = im;
        
        if pic_cnt_pack == 3000
            
            imwrite(bigPic, strcat(Path_File, num2str(pack_num), suffixChar, '.bmp'));
            
            disp(['The ', num2str(pack_num), ' pack has been finished, with ', num2str(total_pack - pack_num), ' packs remained.']);
            
            pic_cnt_pack = 0;
            
            pack_num = pack_num + 1;
            
            bigPic = zeros(768 * 3000, 128, 'uint8');
            
        end
       
        
      % imwrite(im,strcat(num2str(10000+t),'.bmp'));   
end      
% end
 bigPic((last_pack_num * 768 + 1) : ((last_pack_num + 1) * 768), :) = zeros(768, 128, 'uint8')+255;


% for image
%  if last_pack_num ~= 0
 bigPic = bigPic(1 : ((last_pack_num+1)* 768), :);



imwrite(bigPic, strcat(Path_File, num2str(pack_num), suffixChar, '.bmp'));
% end

disp('---PICTURE WRITING FINISHED---');
%% Mr.Geng's code