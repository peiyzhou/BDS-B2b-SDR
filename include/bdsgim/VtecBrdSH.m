% /*****************************************************************************
%  * Name        : VTECFromBroadSH
%  * Description : Obtains the vertical ionospheric TEC using BDGIM ionospheric mode	
%  * Parameters  :
%  *      NonBrdIonData* nonBrdData   I               BDGIM Non-Broadcast Ionospheric Parameters
%  *      BrdIonData* brdData			I               BDGIM Broadcast Ionospheric Parameters
%  *		double mjd					I	[MJD]		The calculate time (Modified Julian Day)
%  *		double lat					I	[arc]		The geomagnetic latitude of the Ionospheric Puncture Point (IPP)
%  *		double lon                  I	[arc]		The geomagnetic longitude of the Ionospheric Puncture Point (IPP) 
%  *		double *vtec			    O   [TECU]	    Ionospheric correction in TECU (in electrons per area unit)
%  *****************************************************************************/
function vtec = VtecBrdSH(nonBrdData, brdData, mjd, ipp_b, ipp_l,Init_mjd)
BRDPARANUM  =    9            ;%     // Number of broadcast ionospheric parameters
NONBRDNUM   =   17            ;%     // Number of non-broadcast one group

vtec_brd = 0.0;
vtec_A0 = 0.0;
vtec = 0.0;

% call BDGIM data
[nonBrdData,igroup] =  BrdCoefGroupIndex(mjd, nonBrdData,Init_mjd);

% if no data found return 
if (igroup == -1)
    return;
end

% lat/lon init
ipp_b1 = ipp_b;
ipp_l1 = ipp_l;

% VTEC from broadcast parameters
for ipar = 1:BRDPARANUM
    if(brdData.degOrd(ipar, 2) > brdData.degOrd(ipar, 1))
        return;
    end
    vtec_brd = vtec_brd + brdData.brdIonCoef(ipar) * ASLEFU(ipp_b1, ipp_l1, brdData.degOrd(ipar, 1), brdData.degOrd(ipar, 2));
end

% VTEC from non-broadcast parameters
for ipar = 1:NONBRDNUM
    if(nonBrdData.degOrd(ipar, 2) > nonBrdData.degOrd(ipar, 1))
        return;
    end
    vtec_A0 = vtec_A0 + nonBrdData.nonBrdCoef(ipar, igroup+1) * ASLEFU(ipp_b1, ipp_l1, nonBrdData.degOrd(ipar, 1), nonBrdData.degOrd(ipar, 2));
end

% combined
vtec = vtec_brd + vtec_A0;

% adjust based on A0
if (brdData.brdIonCoef(1) > 35.0)
    vtec = max(brdData.brdIonCoef(1) / 10.0, vtec);
elseif (brdData.brdIonCoef(1) > 20.0)
    vtec = max(brdData.brdIonCoef(1) / 8.0, vtec);
elseif (brdData.brdIonCoef(1) > 12.0)
    vtec = max(brdData.brdIonCoef(1) / 6.0, vtec);
else
    vtec = max(brdData.brdIonCoef(1) / 4.0, vtec);
end
end
