function [eph] = ephemeris(navBitsBin,eph,PRN)
%Function decodes ephemerides and TOW from the given bit stream. The stream
%(array) in the parameter BITS must contain 288 bits. The first element in
%the array must be the first bit of a subframe.
%
%
%[eph] = ephemeris(navBitsBin,eph)
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

% Pi used in the BDS ICDs
bdsPi = 3.1415926535898;


% Decode the message id
MesType = bin2dec(navBitsBin(1:6));

%%  Decode messages based on the message id =========================
% The task is to select the necessary bits and convert them to decimal
% numbers. For more details on message contents please refer to BDS-3
% ICD (BDS-SIS-ICD-B2b-1.0).
switch MesType
    % Message type 10 in conjunction with message type 11 provides users
    % the requisite data to calculate SV position.
    case 10  %--- It is Message Type 10 -----------------------------------
        % It contains first part of ephemeris parameters
        eph.idValid(1) = 10;
        % PRN
        eph.PRN  = PRN;
        % SOW
        if isempty(eph.SOW)
            eph.SOW  = bin2dec(navBitsBin(7:26));
        end
        rev=bin2dec(navBitsBin(27:30));
       
        % Ephemeris data reference time of week
        eph.t_oe        = bin2dec(navBitsBin(31:41)) * 300;
        % Satellite type
        SatType     = bin2dec(navBitsBin(42:43));
        if (SatType == 1)
            eph.SatType = 'GEO';
        elseif (SatType == 2)
            eph.SatType = 'IGSO';
        elseif (SatType == 3)
            eph.SatType = 'MEO';
        end
        % Semi-major axis difference at reference time
        eph.deltaA      = twosComp2dec(navBitsBin(44:69)) * 2^(-9) ;
        % Change rate in semi-major axis
        eph.ADot        = twosComp2dec(navBitsBin(70:94)) * 2^(-21);
        % Mean Motion difference from computed value at reference time
        eph.delta_n_0   = twosComp2dec(navBitsBin(95:111)) * 2^(-44)* bdsPi;
        % IRate of mean motion difference from computed value
        eph.delta_n_0Dot= twosComp2dec(navBitsBin(112:134)) * 2^(-57)* bdsPi;
        % Mean anomaly at reference time
        eph.M_0         = twosComp2dec(navBitsBin(135:167)) * 2^(-32) * bdsPi;
        % Eccentricity
        eph.e           = bin2dec(navBitsBin(168:200))* 2^(-34);
        % Argument of perigee
        eph.omega       = twosComp2dec(navBitsBin(201:233))* 2^(-32) * bdsPi;

        % Longitude of Ascending Node of Orbit Plane at Weekly Epoch
        eph.omega_0     = twosComp2dec(navBitsBin(234:266))* 2^(-32) * bdsPi;
        % Inclination angle at reference time
        eph.i_0         = twosComp2dec(navBitsBin(267:299))* 2^(-32) * bdsPi;
        % Rate of right ascension difference
        eph.omegaDot  = twosComp2dec(navBitsBin(300:318)) * 2^(-44) * bdsPi;
        % Rate of inclination angle
        eph.i_0Dot      = twosComp2dec(navBitsBin(319:333)) * 2^(-44) * bdsPi;
        % Amplitude of the sine harmonic correction term to the angle of inclination
        eph.C_is        = twosComp2dec(navBitsBin(334:349)) * 2^(-30);
        % Amplitude of the cosine harmonic correction term to the angle of inclination
        eph.C_ic        = twosComp2dec(navBitsBin(350:365)) * 2^(-30);
        % Amplitude of the sine correction term to the orbit radius
        eph.C_rs        = twosComp2dec(navBitsBin(366: 389)) * 2^(-8);
        % Amplitude of the cosine correction term to the orbit radius
        eph.C_rc        = twosComp2dec(navBitsBin(390:413)) * 2^(-8);
        % Amplitude of the sine harmonic correction term to the argument of latitude
        eph.C_us        = twosComp2dec(navBitsBin(414:434)) * 2^(-30);
        % Amplitude of the cosine harmonic correction term to the argument of latitude
        eph.C_uc        = twosComp2dec(navBitsBin(435:455)) * 2^(-30);


        % DIF
        eph.DIF  = bin2dec(navBitsBin(456));
        % SIF
        eph.SIF  = bin2dec(navBitsBin(457));
        % AIF
        eph.AIF  = bin2dec(navBitsBin(458));
        eph.SISMA=bin2dec(navBitsBin(459:462));

    case 30 %--- It is Message Type 30 ------------------------------------
        % It contains Clock, IONO & Group Delay
        eph.idValid(2) = 30;
        % PRN
        eph.PRN  = PRN;

        % SOW
        if isempty(eph.SOW)
            eph.SOW  = bin2dec(navBitsBin(7:26));
        end
        % Week No.
        eph.WN  = bin2dec(navBitsBin(27:39));
        rev=bin2dec(navBitsBin(40:43));
       
        % Clock Data Reference Time of Week
        eph.t_oc        = bin2dec(navBitsBin(44:54)) * 300;
        % SV Clock Bias Correction Coefficient
        eph.a_0        = twosComp2dec(navBitsBin(55:79)) * 2^(-34);
        % SV Clock Drift Correction Coefficient
        eph.a_1        = twosComp2dec(navBitsBin(80:101)) * 2^(-50);
        % SV Clock Drift Rate Correction Coefficient
        eph.a_2        = twosComp2dec(navBitsBin(102:112)) * 2^(-66);
       
        
        % Group delay differential of the B2b I componet
        eph.T_GDB2bi        = twosComp2dec(navBitsBin(113:124)) * 2^(-34);
        

        % The ionospheric parameters
        eph.alpha1      = bin2dec(navBitsBin(125:134)) * 2^(-3);
        eph.alpha2      = twosComp2dec(navBitsBin(135:142)) * 2^(-3);
        eph.alpha3      = bin2dec(navBitsBin(143:150)) * 2^(-3);
        eph.alpha4      = bin2dec(navBitsBin(151:158)) * 2^(-3);
        eph.alpha5       = bin2dec(navBitsBin(159:166)) * 2^(-3);
        eph.alpha6       = twosComp2dec(navBitsBin(167:174)) * 2^(-3);
        eph.alpha7       = twosComp2dec(navBitsBin(175:182)) * 2^(-3);
        eph.alpha8       = twosComp2dec(navBitsBin(183:190)) * 2^(-3);
        eph.alpha9       = twosComp2dec(navBitsBin(192:198)) * 2^(-3);
        
        % BDT-UTC ------------------------------------------
        eph.A_0UTC        = twosComp2dec(navBitsBin(199:214)) * 2^(-35);
        eph.A_1UTC        = twosComp2dec(navBitsBin(215:227)) * 2^(-51);
        eph.A_2UTC        = twosComp2dec(navBitsBin(228:234)) * 2^(-68);
        eph.delta_t_LS    = twosComp2dec(navBitsBin(235:242));
        eph.t_ot          = bin2dec(navBitsBin(243:258)) * 2^(4);
        eph.WN_ot         = bin2dec(navBitsBin(259:271));
        eph.WN_LSF        = bin2dec(navBitsBin(272:284));
        eph.DN            = bin2dec(navBitsBin(285:287));
        eph.delta_t_LSF   = twosComp2dec(navBitsBin(288:295));

        % EOP
        eph.t_eop          = bin2dec(navBitsBin(296:311)) * 2^(4);
        eph.pmx         = twosComp2dec(navBitsBin(312:332))* 2^(-20);
        eph.pmx_dot        = twosComp2dec(navBitsBin(333:347))* 2^(-21);
        eph.pmy            = twosComp2dec(navBitsBin(348:368))* 2^(-20);
        eph.pmy_dot   = twosComp2dec(navBitsBin(369:383))* 2^(-21);
        eph.ut1            = twosComp2dec(navBitsBin(384:414))* 2^(-24);
        eph.ut1_dot   = twosComp2dec(navBitsBin(415:433))* 2^(-25);

        % SISA
        eph.t_op=bin2dec(navBitsBin(434:444)) * 2^(4);
        eph.sisai_ocb=bin2dec(navBitsBin(445:449));
        eph.sisai_oc1=bin2dec(navBitsBin(450:452));
        eph.sisai_oc2=bin2dec(navBitsBin(453:455));
        eph.sisioe=bin2dec(navBitsBin(456:460));
        % HS
        eph.HS  = bin2dec(navBitsBin(461:462));
        
    case 40 %--- It is Message Type 40 ------------------------------------
        % SOW
        if isempty(eph.SOW)
            eph.SOW  = bin2dec(navBitsBin(7:26));
        end
        % It contains Clock & Reduced Almanac
        eph.idValid(3) = 40;
        % ORN NO.
        eph.PRN  = PRN;
        
        % BGTO --------------------------------------
        % GNSS ID
        eph.GNSS_ID   = bin2dec(navBitsBin(27:29));
        eph.WN_0BGTO   = bin2dec(navBitsBin(30:42));
        eph.t_0BGTO   = bin2dec(navBitsBin(43:58))* 2^(4);
        eph.A_0BGTO   = twosComp2dec(navBitsBin(59:74))* 2^(-35);
        eph.A_1BGTO   = twosComp2dec(navBitsBin(75:87))* 2^(-51);
        eph.A_2BGTO   = twosComp2dec(navBitsBin(88:94))* 2^(-68);
        % Other terms not decoded at the moment...
        
    otherwise % Other message types include: ------------------------------
        % Mainly Reduced & Midi Almanac,UTC parameters and so on
        % Not decoded at the moment.
        eph.idValid(8) = MesType;
        % PRN
        eph.PRN  = PRN;
        % SOW
        if isempty(eph.SOW)
            eph.SOW  = bin2dec(navBitsBin(7:26));
        end
        
end % switch MesType ...
