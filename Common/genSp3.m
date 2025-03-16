function genSp3(ts,te,eph,ephPPP,settings)
%Function generate standard SP3 file with precise ephemeris from PPP-B2b.
%
% genSp3(ts,te,eph,ephPPP,settings)
%
%   Inputs:
%       ts            - start time of sp3
%       te            - end time of sp3
%       eph           - received CNAV3 ephemerides of all IGSO/MEO SV (structure array).
%       ephPPP        - received PPP-B2b ephemerides of all GEO SV (structure array).
%       settings      - Receiver settings. Provides information about
%                       sampling and intermediate frequencies and other
%                       parameters including the list of the satellites to
%                       be acquired.
%   Outputs:
%       None
%--------------------------------------------------------------------------
%                         BDS-B2b SDR  
% Updated by Peiyuan Zhou based on Li et al. (2019) Design and 
% implementation of an open‑source BDS‑3 B1C/B2a SDR receiver. GPS
% Solutions, 23:60.
%--------------------------------------------------------------------------
%This program is free software; you can redistribute it and/or
%modify it under the terms of the GNU General Public License
%as published by the Free Software Foundation; either version 2
%of the License, or (at your option) any later version.
%
%This program is distributed in the hope that it will be useful,
%but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%GNU General Public License for more details.
%
%You should have received a copy of the GNU General Public License
%along with this program; if not, write to the Free Software
%Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
%USA.
%--------------------------------------------------------------------------

%% open and check file
fidsp3=fopen(settings.Sp3file,"w");
if fidsp3<0
    disp('Open sp3 file error.');
    return;
end

%% set time and output sp3 file header
wn=unique([eph.WN]);
mjd=bdt2mjd(wn, ts);
tint=settings.Sp3Interval;
satlist=[eph.PRN];
allephppp=[ephPPP.b2b];
geolist=unique([allephppp.PRN]);
outputSp3(fidsp3,0,[mjd tint]);
        
%% output sp3 file body 
usePPPB2b=ephPPP(geolist(1)).b2b;% always use the first available GEO satellites
[b2bcorr_orb,b2bcorr_clk,b2bcorr_bia]=applyMaskcode(usePPPB2b); % apply mask code
for t=ts:te
    if mod(t,tint)~=0
        continue;
    end
    mjd=bdt2mjd(wn, t);

    %  Since no IODC/IODE exists in B2B CNAV3, no iodn check is performed
    [satPositions, satClkCorr] = satpos(0,t*ones(length(satlist),1), satlist, eph); 
                                    
    [satPositions1, ~] = satpos(0,(t+0.001)*ones(length(satlist),1), satlist, eph); 
    satVelocities=(satPositions1-satPositions)/0.001;
    epoch_first=1;
    for isat=1:length(satlist)
        dorb=b2bcorr_orb(b2bcorr_orb(:,3)==(satlist(isat)),:);
        if isempty (dorb)
            continue;
        end
        er=satPositions(:,isat)./norm(satPositions(:,isat));
        ec=cross(satPositions(:,isat),satVelocities(:,isat));
        ec=ec./norm(ec);
        ea=cross(ec,er);
        satPositions(:,isat)=satPositions(:,isat)-[er ea ec]*dorb(1,6:8)';%

        % check IOD Corr and IODSSR of clk & orb
        dclks=b2bcorr_clk(b2bcorr_clk(:,2)==dorb(1,2)&b2bcorr_clk(:,4)==satlist(isat)&b2bcorr_clk(:,5)==dorb(1,5),:);

        % also apply the code bias
        bia=b2bcorr_bia(b2bcorr_bia(:,3)==satlist(isat),11);

        if isempty (dclks)||isempty (bia)
            continue;
        end

        % use the nearest clk, note sec of day are used for PPP-B2b corrections
        [~, closestIndex] = findClosestFromNegative(dclks(:,1)+86400*floor(ts/86400), ts);
        satClkCorr(isat)=satClkCorr(isat)-dclks(closestIndex,6)/settings.c-bia(1)/settings.c;

        outputSp3(fidsp3,satlist(isat),[epoch_first mjd satPositions(:,isat)' satClkCorr(isat)]);
        epoch_first=0;
    end
end

fclose(fidsp3); % close sp3 file