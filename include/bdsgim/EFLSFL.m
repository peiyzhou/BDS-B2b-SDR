% /*****************************************************************************
% * Description : Transform earth-fixed latitude/longitude into sun-fixed or/and geomagnetic latitude/longitude
% * Parameters  :
% *		double mjd		I		the calculate epoch
% *		double *lat		I		input latitude (in arc.)
% *		double *lon		I		input longitude (in arc)
% *		int geomag		I		change into geomagnetic frame
% *		int sunframe		I		change into sun-fixed frame
% *		double *lat1		O		output latitude (in arc.)
% *		double *lon1	O		output longitude (in arc.)
% *****************************************************************************/
function [lat1, lon1] = EFLSFL(mjd, lat, lon, geomag, sunframe)
% ICD constants
LAT_POLE = 80.27;
LON_POLE = -72.58;
PI = 3.1415926535898;

% varibales
Bp = LAT_POLE;
Lp = LON_POLE;

if geomag
    % geomagnetic
    lat1 = asin(sin(Bp*PI/180)*sin(lat) + cos(Bp*PI/180)*cos(lat)*cos(lon-Lp*PI/180));
    sinlon1 = (cos(lat)*sin(lon-Lp*PI/180)) / cos(lat1);
    coslon1 = -(sin(lat) - sin(Bp*PI/180)*sin(lat1)) / (cos(Bp*PI/180)*cos(lat1));
    lon1 = atan2(sinlon1, coslon1);
else
    % raw
    lat1 = lat;
    lon1 = lon;
end

if sunframe
    % sun-fixed 
    SUNLON = PI * (1.0 - 2.0 * (mjd - floor(mjd)));
    sinlon2 = sin(SUNLON-Lp*PI/180);
    coslon2 = sin(Bp*PI/180)*cos(SUNLON-Lp*PI/180);
    SUNLON = atan2(sinlon2, coslon2);
    lon1 = lon1 - SUNLON;
    lon1 = atan2(sin(lon1), cos(lon1));
end
end