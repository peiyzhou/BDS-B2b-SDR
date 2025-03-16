function B2bTable = makeB2bTable(PRN,settings)
%Function generates PRN codes for all satellites based on the settings
%provided in the structure "settings". The codes are digitized at the
%sampling frequency specified in the settings structure.
%One row in the "B2bTable" is one PRN code. The row number is the PRN
%number of the code.
%
%B2bTable = makeB2bTable(PRN,settings)
%
%   Inputs:
%       PRN             - requested satellite PRN
%       settings        - receiver settings
%   Outputs:
%       B2bTable       - an array of arrays (matrix) containing B2b codes
%                       for all satellite PRN-s
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

%--- Find number of samples per spreading code ----------------------------
samplesPerCode = round(settings.samplingFreq / ...
    (settings.codeFreqBasis / settings.codeLength));

%--- Find time constants --------------------------------------------------
ts = 1/settings.samplingFreq;   % Sampling period in sec
tc = 1/settings.codeFreqBasis;  % B2b chip period in sec


%--- Generate B2b data code for given PRN -----------------------------------
B2bCode = generateB2bCode(PRN,settings);

%=== Digitizing =======================================================

%--- Make index array to read B2b code values -------------------------
% The length of the index array depends on the sampling frequency -
% number of samples per millisecond (because one B2b code period is one
% millisecond).
codeValueIndex = ceil((ts * (1:samplesPerCode)) / tc);

%--- Correct the last index (due to number rounding issues) -----------
codeValueIndex(end) = settings.codeLength;

%--- Make the digitized version of the B2b code -----------------------
% The "upsampled" code is made by selecting values form the B2b code
% chip array (caCode) for the time instances of each sample.
B2bTable = B2bCode(codeValueIndex);
