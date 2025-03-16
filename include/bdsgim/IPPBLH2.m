% /*****************************************************************************
% * Description : calculate latitude, longitude and elevaiton of the IPP (approximate) according to user latitude ,longitude and satellite elevation, azimuth
% * Parameters  :
% *		double lat_u		I		user latitude  [unit: radian]
% *		double lon_u		I		user longitude  [unit: radian]
% *		double hion		    I		ionospheric single layer height [in meter]
% *		double sat_ele	    I		satellite elevation [in radian]
% *		double sat_azimuth  I	    satellite azimuth [in radian]
% *		double &ipp_b       O		latitude of the ipp [in radian]
% *		double &ipp_l	    O		longitude of the ipp [in radian]
% *		double &ipp_e	    O		elevation of  the IPP [in radian]
% * return: int
% *****************************************************************************/
function [ipp_b, ipp_l, ipp_e] = IPPBLH2(lat_u, lon_u, hion, sat_ele, sat_azimuth)
EARTH_RADIUS = 6378137; % m
PI = 3.1415926535898;

phiu = PI/2 - sat_ele - asin(EARTH_RADIUS * cos(sat_ele) / (EARTH_RADIUS + hion));

ipp_b = asin(sin(lat_u) * cos(phiu) + cos(lat_u) * sin(phiu) * cos(sat_azimuth));

temp1 = sin(phiu) * sin(sat_azimuth) / cos(ipp_b);
temp2 = (cos(phiu) - sin(lat_u) * sin(ipp_b)) / (cos(lat_u) * cos(ipp_b));

ipp_l = lon_u + atan2(temp1, temp2);

ipp_e = asin(EARTH_RADIUS * cos(sat_ele) / (EARTH_RADIUS + hion));
end
