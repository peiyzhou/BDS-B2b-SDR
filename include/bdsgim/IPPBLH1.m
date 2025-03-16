% /*****************************************************************************
% * Description : calculate the XYZ, L, B and elevation of the IPP (accurate)
% *					source code: BERNESE 5.0
% * Parameters  :
% *		double *sta		  I		station xyz	[m]			
% *		double *sat		  I		satellite xyz [m]
% *		double Hion	      I		ionosphere single layer height [m]
% *		double *IPPXYZ	  O		xyz of IPP  [m]
% *		double *IPP_B	  O		geographic latitude of the IPP [radian]
% *		double *IPP_L	  O		geographic longitude  of the IPP [radian]
% *		double *IPP_E	  O		elevation of the IPP [radian]
% *		double *sat_ele	  O		elevation of satellite-station [radian]
% * return: int
% % *****************************************************************************/
function [IPPXYZ, IPP_B,IPP_L,  IPP_E, sat_ele] = IPPBLH1(sta, sat, Hion, sat_ele)
EARTH_RADIUS = 6378137.0; 
PI = 3.1415926535898;

% ckeck sta sat
if norm(sta) < 1e-6 || norm(sat) < 1e-6
    error('Station or satellite position vector is zero.');
end

% distance calculation
DS = norm(sat - sta);
R1 = norm(sta);
R2 = EARTH_RADIUS + Hion;
R3 = norm(sat);
zenith = PI - acos((R1^2 + DS^2 - R3^2) / (2 * R1 * DS));
sat_ele = PI / 2 - zenith;

% zenith
zenith1 = asin(R1 / R2 * sin(zenith));
alpha = zenith - zenith1;
sta_ipp = sqrt(R1^2 + R2^2 - 2 * R1 * R2 * cos(alpha));

% IPP pos
IPPXYZ = sta + sta_ipp * (sat - sta) / DS;

IPP_L = atan2(IPPXYZ(2), IPPXYZ(1));
IPP_B = atan(IPPXYZ(3) / sqrt(IPPXYZ(1)^2 + IPPXYZ(2)^2));
IPP_E = PI / 2 - zenith1;
end
