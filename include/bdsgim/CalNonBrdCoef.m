% /*****************************************************************************
% * Description : Calculate the non-broadcast BDGIM parameters at the first compute epoch every day
% * Parameters : 
% *		double mjd		            I		the compute epoch [in mjd]
% *       NonBrdIonData* nonBrdData   I       BDGIM Non-Broadcast Ionospheric Parameters
% *****************************************************************************/
function [nonBrdData,Init_mjd,igroup] = CalNonBrdCoef(mjd,nonBrdData, Init_mjd)
PERIODNUM   =   13           ;%      // Number of forecast period for every non-broadcast parameters
NONBRDNUM   =   17            ;%     // Number of non-broadcast one group
    % check mjd
    if (mjd >= Init_mjd && (mjd - Init_mjd) < 1.0)
        return;
    end

    dmjd = 2.0 / 24.0; % in units of d
    igroup = 1;

    % iterate MJD
    for tmjd = floor(mjd):dmjd:floor(mjd) + 1 - dmjd
        % set nonbroadcast parameters
        for icoef = 1:NONBRDNUM
            coef = 0.0;
            ipar = 1;
            for n = 1:PERIODNUM
                if nonBrdData.omiga(n) == 0
                    coef = nonBrdData.perdTable(icoef, ipar);
                    ipar = ipar + 1;
                else
                    coef = coef + nonBrdData.perdTable(icoef, ipar) * cos(nonBrdData.omiga(n) * (tmjd + dmjd / 2.0));
                    ipar = ipar + 1;
                    coef = coef + nonBrdData.perdTable(icoef, ipar) * sin(nonBrdData.omiga(n) * (tmjd + dmjd / 2.0));
                    ipar = ipar + 1;
                end
            end
            nonBrdData.nonBrdCoef(icoef, igroup) = coef;
        end
        igroup = igroup + 1;
    end

    Init_mjd = floor(mjd);
end