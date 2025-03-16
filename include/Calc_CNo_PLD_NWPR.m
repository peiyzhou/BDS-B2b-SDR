function [CNo, PllDetector]= Calc_CNo_PLD_NWPR(trackResults,settings,loopCnt)
%Calculate CNo using the Narrow-band Wide-band Power Ratio Method, and the PLL lock detector
%output
%
%[CNo, PllDetector]= Calc_CNo_PLD_NWPR(trackResults,settings,loopCnt)
%
%   Inputs:
%       trackResults      - Correlation values
%       settings          - Receiver settings
%       loopCnt           - Iteration index for C/No calculation
%   Outputs:
%       CNo               - Estimated C/No for the given values of I and Q
%                           CNo(1) is for data channel,CNo(21) is for pilot
%                           channel, and CNo(2) is for whole B2b signal  
%       PllDetector       - PLL lock detector output for data and pilot
%                            channels
%
%--------------------------------------------------------------------------
% 
% Written by Peiyuan Zhou
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

CNo = 0;
PllDetector = zeros(1,2);
% Integration time for each correlation point
T = settings.intTime;
%% ---- C/No and PLL detector output estimations for data channel -----
% Data-channel prompt correlation values
I_P = trackResults.I_P(loopCnt - settings.CNoInterval + 1 : loopCnt);
Q_P = trackResults.Q_P(loopCnt - settings.CNoInterval + 1 : loopCnt);

% ----------------------- CNo extimation for data channel -----------------
% Calculate Wide-band Power
W = I_P.^2 + Q_P.^2;

% Calculate Narrow-band Power
N = (sum(I_P))^2 + (sum(Q_P))^2;
Nm=
% Calculate the mean and variance of the Power
Zm = mean(W);
Zv = var(W);
% Calculate the average carrier power
Pav = sqrt(Zm^2 - Zv);
% Calculate the variance of the noise
Nv = 0.5 * (Zm - Pav);
%  C/No estimation for data channel
DataCNo = abs((1/T) * Pav / (2 * Nv));
CNo = 10*log10(DataCNo);

