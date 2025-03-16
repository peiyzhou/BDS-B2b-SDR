% /*****************************************************************************
% * Description : Set the period term of the non-broadcast perdTable for BDGIM model
% * Parameters  : 
% *              NonBrdIonData* nonBrdData   I    BDGIM Non-Broadcast Ionospheric Parameters
% *****************************************************************************/
function nonBrdData = SetNonBrdCoefPeriod(nonBrdData)
PI = 3.1415926535898;

% non-broadcast parameters
nonBrdData.omiga = zeros(1, 13); % 

% day period
nonBrdData.omiga(1) = 0.0;
nonBrdData.omiga(2) = 2*PI;
nonBrdData.omiga(3) = 2*PI/0.5;
nonBrdData.omiga(4) = 2*PI/0.33;
% semi-month period
nonBrdData.omiga(5) = 2*PI/14.6;
% month period
nonBrdData.omiga(6) = 2*PI/27.0;
% one-third year period
nonBrdData.omiga(7) = 2*PI/121.6;
% semi-year period
nonBrdData.omiga(8) = 2*PI/182.51;
% year period
nonBrdData.omiga(9) = 2*PI/365.25;
% solar period
nonBrdData.omiga(10) = 2*PI/4028.71;
nonBrdData.omiga(11) = 2*PI/2014.35;
nonBrdData.omiga(12) = 2*PI/1342.90;
nonBrdData.omiga(13) = 2*PI/1007.18;
end