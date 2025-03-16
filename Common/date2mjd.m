% ZPY Created 2017-09-06 
function [mjd,mjdnoround] = date2mjd(date)
if length(date)<6
    mjd=0;
    return;
end
% SYNTAX:
%   [jd, mjd] = date2jd(date);
%
% INPUT:
%   date = date [year, month, day, hour, min, sec]
%
% OUTPUT:
%   jd  = julian day
%   mjd = modified julian day
%
% DESCRIPTION:
%   Conversion from date to julian day and modified julian day.

year  = date(:,1);
month = date(:,2);
day   = date(:,3);
hour  = date(:,4);
min   = date(:,5);
sec   = date(:,6);

pos = find(month <= 2);
year(pos)  = year(pos) - 1;
month(pos) = month(pos) + 12;

%julian day
jd = floor(365.25*(year+4716)) + floor(30.6001*(month+1)) + day + hour/24 + min/1440 + sec/86400 - 1537.5;

%modified julian day
tmp=(jd - 2400000.5);
mjd(1) = floor(tmp);
mjd(2)=86400*(tmp-mjd(1) );
mjdnoround=mjd;
tmp2=mjd(2)-round(mjd(2));
if abs(tmp2)<0.001
    mjd(2)=round(mjd(2));
end