% /*****************************************************************************
% * Description : different ionospheric mapping functions 
% * Parameters  : int type	I
% *					type = 0: none mapping function, return 1.0
% *					type = 1: SLM mapping function
% *					type = 2: MSLM mapping function by CODE (Schaer)
% *					type = 3: Klobuchar mapping function
% *				double ipp_elev  I    Ionospheric puncture point elevation
% *				double sat_elev  I    satellite elevation
% *				double Hion      I    Ionospheric layer height
% * return: double IMF    mapping function factor
% *****************************************************************************/
function IMF = IonMapping(type, ipp_elev, sat_elev, Hion)
RE = 6378000.0; % m
PI = 3.1415926535898;
IMF=0;
% if Hion<10，set to 400000
if Hion < 10
    Hion = 400000;
end

% mapping function
switch type
    case 0
        % cons
        IMF = 1.0;
    case 1
        % SLM
        IMF = 1 / sin(ipp_elev);
    case 2
        % MSLM
        IMF = 1 / sqrt(1 - (RE * sin(0.9782 * (PI / 2 - sat_elev)) / (RE + Hion))^2.0);
    case 3
        % Klobuchar
        IMF = 1 + 16 * (0.53 - sat_elev / PI)^3.0;
    otherwise
        error('Cannot find this kind of mapping model! The model type is %d.', type);
end
end