function [gps_week, gps_sow, gps_dow] = mjd2gpst(mjd)

% SYNTAX:
%   [gps_week, gps_sow, gps_dow] = jd2gps(jd);
%
% INPUT:
%   jd = julian day
%
% OUTPUT:
%   gps_week = GPS week
%   gps_sow  = GPS seconds of week
%   gps_dow  = GPS day of week
%
% DESCRIPTION:
%   Conversion of julian day number to GPS week and
%	seconds of week.
jd=mjd+2400000.5; % mjd to jd;
deltat = jd - 2444244.5; % this is GPS-specific start date
gps_week = floor(deltat/7);
gps_dow  = floor(deltat - gps_week*7);
gps_sow  = (deltat - gps_week*7)*86400;
