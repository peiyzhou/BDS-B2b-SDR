function [eph] = ephemerisPPP(navBitsBin,PRN)
%Function decodes PPP-B2b ephemerides from the given bit stream. The stream
%(array) in the parameter BITS must contain 486 bits. The first element in
%the array must be the first bit of a subframe.
%
%
%[eph] = ephemerisPPP(navBitsBin,eph)
%
%   Inputs:
%       navBitsBin  - bits of the navigation messages.Type is character array
%                   and it must contain only characters '0' or '1'.
%       eph         - The ephemeris for each PRN is decoded message by message.
%                   To prevent lost of previous decoded messages, the eph sturcture
%                   must be passed onto this function.
%       PRN         - requested SV PRN.
%   Outputs:
%       eph         - SV ephemeris

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

%% Preparation for date message decoding ============================
if length(navBitsBin) < 486
    error('The parameter BITS must contain 486 bits!');
end

% Check if the parameters are strings
if ~ischar(navBitsBin)
    error('The parameter BITS must be a character array!');
end

% 'bits' should be row vector for 'bin2dec' function.
[a, b] = size(navBitsBin);
if a > b
    navBitsBin = navBitsBin';
end

% Decode the message id
MesType = bin2dec(navBitsBin(1:6));
eph = ephPPP_structure_init();

%%  Decode messages based on the message id =========================
% The task is to select the necessary bits and convert them to decimal
% numbers. For more details on message contents please refer to BDS-3
% ICD (BDS-SIS-ICD-PPP-B2b-1.0).
switch MesType
    % Message type 10 in conjunction with message type 11 provides users
    % the requisite data to calculate SV position.
    case 1  %--- It is Message Type 1 -----------------------------------
        % It contains Clock, IONO & Group Delay
        eph.idValid = 1;
        eph.PRN=PRN;
        % time epoch
        eph.t  = bin2dec(navBitsBin(7:23));
        eph.iodssr=bin2dec(navBitsBin(28:29));
        eph.iodp=bin2dec(navBitsBin(30:33));

        eph.mask=zeros(255,1);
        % orbit corrections --------------------------------------
        ibit=34;
        for isat=1:255
            eph.mask(isat,:)=bin2dec(navBitsBin(ibit));
            ibit=ibit+1;
        end
    case 2 %--- It is Message Type 2 ------------------------------------
        % It contains Clock, IONO & Group Delay
        eph.idValid = 2;
        eph.PRN=PRN;
        % time epoch
        eph.t  = bin2dec(navBitsBin(7:23));
        eph.iodssr=bin2dec(navBitsBin(28:29));
        eph.dorb=zeros(6,8);
        % orbit corrections --------------------------------------
        ibit=30;
        for isat=1:6
            eph.dorb(isat,:)=[bin2dec(navBitsBin(ibit:ibit+8)) bin2dec(navBitsBin(ibit+9:ibit+18)) bin2dec(navBitsBin(ibit+19:ibit+21))...
                twosComp2dec(navBitsBin(ibit+22:ibit+36))*0.0016 twosComp2dec(navBitsBin(ibit+37:ibit+49))*0.0064 twosComp2dec(navBitsBin(ibit+50:ibit+62))*0.0064...
                bin2dec(navBitsBin(ibit+63:ibit+65)) bin2dec(navBitsBin(ibit+66:ibit+68)) ];
            ibit=ibit+69;
        end
        
    case 3 %--- It is Message Type 3 ------------------------------------
        eph.idValid = 3;
        eph.PRN=PRN;
        % time epoch
        eph.t  = bin2dec(navBitsBin(7:23));
        eph.iodssr=bin2dec(navBitsBin(28:29));
        nsat_bia=bin2dec(navBitsBin(30:34));

        eph.bia=zeros(nsat_bia,17);
        % code bias corrections --------------------------------------
        ibit=35;
        for isat=1:nsat_bia
            satslot=bin2dec(navBitsBin(ibit:ibit+8));
            nbia=bin2dec(navBitsBin(ibit+9:ibit+12));
            ibit=ibit+13;
            eph.bia(isat,1)=satslot;
            for ibia=1:nbia
                sigtype=bin2dec(navBitsBin(ibit:ibit+3));
                eph.bia(isat,sigtype+2)=twosComp2dec(navBitsBin(ibit+4:ibit+15))*0.017;
                ibit=ibit+16;
            end    
        end
    case 4 %--- It is Message Type 4 ------------------------------------
        eph.idValid = 4;
        eph.PRN=PRN;
        % time epoch
        eph.t  = bin2dec(navBitsBin(7:23));
        eph.iodssr=bin2dec(navBitsBin(28:29));
        eph.iodp=bin2dec(navBitsBin(30:33));
        eph.subtype1=bin2dec(navBitsBin(34:38));
        eph.C0=zeros(23,2);
        % clk corrections --------------------------------------
        ibit=39;
        for isat=1:23
            eph.C0(isat,1:2)=[bin2dec(navBitsBin(ibit:ibit+2)) twosComp2dec(navBitsBin(ibit+3:ibit+17))*0.0016];
            ibit=ibit+18;
        end
    otherwise % Other message types include: ------------------------------
        % Not decoded at the moment.
        eph.idValid = MesType;
        % PRN
        eph.PRN  = PRN;
        % SOW
        if isempty(eph.t)
            eph.t  = 0;
        end
        
end % switch MesType ...
