% /*****************************************************************************
% * Name:  UTC2MJD
% * Description :  calculate MJD from UTC 
% *	Return mjd
% *****************************************************************************/
function mjdata = UTC2MJD(year, month, day, hour, min, second)

mjdata.mjd = 0;
mjdata.daysec = 0;

if year < 80
    year = year + 2000;
elseif year >= 80 && year <= 1000
    year = year + 1900;
end

hourn = hour + min / 60.0 + second / 3600.0;

if month <= 2
    year = year - 1;
    month = month + 12;
end

m_julindate = floor(365.25 * year) + floor(30.6001 * (month + 1)) + day + hourn / 24.0 + 1720981.5;

mjdata.mjd = m_julindate - 2400000.5;

% day of sec
mjdata.daysec = hour * 3600.0 + min * 60.0 + second;

if mjdata.daysec == 86400.0
    mjdata.daysec = 0.0;
end
end

    