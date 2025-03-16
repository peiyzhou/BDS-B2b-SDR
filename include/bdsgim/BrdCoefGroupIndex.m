% /*****************************************************************************
% * Description : find BDGIM non-broadcast coefficients group according to the mjd, and set the non-broadcast parameter
% *		for BDGIM  model
% * Parameters  :
% *		double mjd		            I		the compute epoch (in mjd)
% *       NonBrdIonData* nonBrdData   I       BDGIM Non-Broadcast Ionospheric Parameters
% * return :    
% *		int group		O		the session group of the current epoch
% *
% % *****************************************************************************/
function [nonBrdData,igroup] = BrdCoefGroupIndex(mjd, nonBrdData,Init_mjd)
    dmjd = 2.0 / 24.0; % time interval in d
    igroup=-1;
    % calculation of non broadcast parameters
    if (mjd < Init_mjd || mjd > Init_mjd + 1.0)
        [nonBrdData,Init_mjd] = CalNonBrdCoef(mjd, nonBrdData, Init_mjd);
    end

    % set SH intervals
    for tmjd = floor(Init_mjd):dmjd:floor(Init_mjd) + 1 - dmjd
        if (mjd >= tmjd && mjd <= tmjd + dmjd)
            igroup = igroup + 1;
            break;
        else
            igroup = igroup + 1;
        end
    end

    % maximum groups of 12
    if (igroup > 11)
        igroup = -1;
    end
end
