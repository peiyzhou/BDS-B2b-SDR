%% BDSGIM demonstrator in MATLAB
%  Rewritten by Peiyuan Zhou based on: ftp://ftp.gipp.org.cn/product/bdgim/bdgim_c.rar.gz
%  Also ref to BDS ICD
clear
clc
close all

%% constants
BRDPARANUM  =    9            ;%     // Number of broadcast ionospheric parameters
PERIODNUM   =   13           ;%      // Number of forecast period for every non-broadcast parameters
TRISERINUM  =  (PERIODNUM*2-1)  ;%   // Trigonometric series number 
NONBRDNUM   =   17            ;%     // Number of non-broadcast one group
MAXGROUP    =   12          ;%       // 12 groups non-broadcast coefficient every day


LAT_POLE = 80.27;
LON_POLE = -72.58;
Hion_bdgim = 400000.0; 
EARTH_RADIUS = 6378137.0; 
Init_mjd = 0.0;
FREQ1_BDS    =   1575420000.0;

%% variable init
sat_xyz = [-34342443.2642, 24456393.0586, 12949.4754];
sta_xyz = [-2159945.3149, 4383237.1901, 4085412.3177];

% time
year = 2020; month = 11; day = 5; hour = 17; min = 0; second = 0.0;

% UTC->MJD
mjdData = UTC2MJD(year, month, day, hour, min, second);
mjd = mjdData.mjd;

% BDSGIM params
brdPara = [13.82642069, -1.78004616, 5.17200000 ...
           3.13030940, -4.58961329, 0.32483867 ...
           -0.07802383, 1.24312590, 0.37763627];

% call BDGIM function
ion_delay=zeros(2880,1);
for i=1:2880
    ion_delay(i) = IonBdsBrdModel(floor(mjd)+(i-1)*30/86400, sta_xyz, sat_xyz, brdPara,FREQ1_BDS,Init_mjd);
    % display
    fprintf('The ionosphere delay in B1C: %7.2f [m]\n', ion_delay(i))
end


%% compare results
ion_delay_ref=load("ion.txt"); % from original C source code
figure;
plot(ion_delay-ion_delay_ref)
