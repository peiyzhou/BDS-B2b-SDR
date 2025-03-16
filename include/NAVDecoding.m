function [eph, ephPPP,firstSubFrame,TOW] = NAVDecoding(I_P_InputBits)
% findPreambles finds the first preamble occurrence in the bit stream of
% each channel. The preamble is verified by check of the spacing between
% preambles (6sec) and parity checking of the first two words in a
% subframe. At the same time function returns list of channels, that are in
% tracking state and with valid preambles in the nav data stream.
%
%[eph, firstSubFrame,TOW] = NAVDecoding(I_P_InputBits)
%
%   Inputs:
%       I_P_InputBits   - output from the tracking function
%
%   Outputs:
%       firstSubframe   - Starting positions of the first message in the
%                       input bit stream I_P_InputBits in each channel.
%                       The position is CNAV bit(20ms before convolutional decoding)
%                       count since start of tracking. Corresponding value will
%                       be set to inf if no valid preambles were detected in
%                       the channel.
%       TOW             - Time Of Week (TOW) of the first message(in seconds).
%                       Corresponding value will be set to inf if no valid preambles
%                       were detected in the channel.
%       eph             - SV ephemeris.
%
%--------------------------------------------------------------------------
%                         BDS-B2b SDR  
% Updated by Peiyuan Zhou based on Li et al. (2019) Design and 
% implementation of an open‑source BDS‑3 B1C/B2a SDR receiver. GPS
% Solutions, 23:60.
%--------------------------------------------------------------------------
%
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


%--- Initialize ephemeris structute  --------------------------------------
% This is in order to make sure variable 'eph' for each SV has a similar
% structure when only one or even none of the three requisite messages
% is decoded for a given PRN.
eph = eph_structure_init();
ephPPP= ephPPP_structure_init();
iephPPP=1; % PPP-B2b msg count
% Starting positions of the first message in the input stream trackResults.I_P
firstSubFrame = inf;

% TOW of the first message
TOW = inf;

%% Bit and frame synchronization ====================================
% Set parameters and allocate veriable space ------------------------------
% Preamble search can be delayed to a later point in the tracking results
% to avoid noise due to tracking loop transients
searchStartOffset = 0;

% Generate the preamble pattern. The preamble is 
% [1 1 1 0 1 0 1 1 1 0 0 1 0 0 0 0], and the antipodal 
% form of the preamble pattern is: 
preamble_bits = [-1 -1 -1 1 -1 1 -1 -1 -1 1 1 -1 1 1 1 1];

% "Upsample" the preamble - make 5 vales per one bit. The preamble must be
% found with precision of a sample.
preamble_ms = kron(preamble_bits, ones(1,1)); % disabled here

% Correlate tracking output with preamble ---------------------------------
% Read output from tracking. It contains the navigation bits. The start
% of record is skiped here to avoid tracking loop transients.
bits = I_P_InputBits(1 + searchStartOffset : end);

% Now threshold the output and convert it to -1 and +1
bits(bits > 0)  =  1;
bits(bits <= 0) = -1;

% Correlate tracking output with the preamble
tlmXcorrResult = xcorr(bits, preamble_ms);

% Find all starting points off all preamble like patterns -----------------
clear index
xcorrLength = (length(tlmXcorrResult) +  1) /2;

% Find at what index/ms the preambles start 
index = find(abs(tlmXcorrResult(xcorrLength : xcorrLength * 2 - 1)) > 15.5)';

%Creates a cyclic redundancy code (CRC) detector System object
crcDet = comm.CRCDetector([24 23 18 17 14 11 10 7 6 5 4 3 1 0]);

%% B-CNAV3 decoding =================================================
for i = 1:size(index) % For each occurrence
    % Ensure the search for i has the number of a whole message(300)
    if ((length(bits) - index(i) +1) >= 1000 )
        % Search every possible preamble pattern. This can allow decoding
        % every message even when the data bit stream has only one message
        % without bit error.
        navBits = bits(index(i):index(i)+1000-1);
        
        % Group every 10 I_P to a row for corresponding bit
        % I_P_group = reshape(temp_bits,5,[])';
        
        % Wipe off the 2nd code and form data bits
        % navBits = sum(I_P_group .* repmat(secondCode,1000,1),2)';
        
        % Now threshold the output and convert it to -1 and +1
        navBits(navBits > 0)  =  1;
        navBits(navBits <= 0) = -1;
        
        % Correct polarity of the all data bits according to preamble bits
        if(~isequal(navBits(1:16),preamble_bits))
            navBits = -navBits;
        end
        
        % Skip the first 24 bits of preamble
        navBits = navBits(17:end);
        
        % --- LDPC decoding -----------------------------------------------
        % No LDPC decoding is performed temporarily,take it directly.
        % Here should the LDPC decoding be sadded ...
        decodedNavBits = navBits;
        
        %--- To do CRC-24Q check for current frame ------------------------
        % Convert to "0" and "1" format
        NavDataLogic = decodedNavBits < 0.5;
        PRN=bin2dec(num2str(NavDataLogic(1:6)));% skip 12 symbols
        if (PRN < 1) || (PRN >63)
            return
        end
        NavDataLogicSkip=NavDataLogic(13:13+486-1);
        % CRC-24Q check
        [~,frmError] = step(crcDet,NavDataLogicSkip');
        
        % Decode ephemeris message by message  ----------------------------
        if (~frmError)
            % Convert from decimal to binary.The function ephemeris expects
            % input in binary form. In Matlab, it is a string array
            % containing only "0" and "1" characters.
            navBitsBin = dec2bin(NavDataLogicSkip);
            
            % Ephemeris decoding
            if PRN<59 % B2B-I for IGSO/MEO
                eph = ephemeris(navBitsBin',eph,PRN);
                % Just save for first message. firstSubFrame is the starting
                % positions of the first message in the input bit stream
                % dataBits.
                if isinf(firstSubFrame)
                    firstSubFrame = index(i) + searchStartOffset;
                    TOW = eph.SOW;
                end
            else % PPP-B2B-I for GEO
                ephPPP(iephPPP) = ephemerisPPP(navBitsBin',PRN);
                iephPPP=iephPPP+1;
            end 
        end % if CRC is OK ...
    end
end   
