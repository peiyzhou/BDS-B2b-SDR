function settings = initSettings()
%Functions initializes and saves settings. Settings can be edited inside of
%the function, updated from the command line or updated using a dedicated
%GUI - "setSettings".  
%
%All settings are described inside function code.
%
%settings = initSettings()
%
%   Inputs: none
%
%   Outputs:
%       settings     - Receiver settings (a structure). 
%
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

%% Processing settings ==============================================
% Number of milliseconds to be processed used 48000 + any transients (see
% below - in Nav parameters) to ensure nav subframes are provided
settings.msToProcess        = 30000;        %[ms]
% Number of channels to be used for signal processing
settings.numberOfChannels   = 15;
% Move the starting point of processing. Can be used to start the signal
% processing at any point in the data record (e.g. for long records). fseek
% function is used to move the file read point, therefore advance is byte
% based only. 
settings.skipNumberOfBytes     = 4;
%% Raw signal file name and other parameter =========================
% This is a "default" name of the data file (signal record) to be used in
% the post-processing mode
settings.fileName           = '.\data\B2b_20M.bin';
% Data type used to store one sample
settings.dataType           = 'float32';
% File Types
%1 - 8 bit real samples S0,S1,S2,...
%2 - 8 bit I/Q samples I0,Q0,I1,Q1,I2,Q2,...                      
settings.fileType           = 2;
% Intermediate, sampling 
settings.IF                 = 0;         % [Hz]
settings.samplingFreq       = 20e6;        % [Hz]
%% Code parameter setting
% Define number of chips in a code period and code frequencies of B2b
settings.codeLength           = 10230;         % [chip] 
settings.codeFreqBasis        = 10.23e6;       % [Hz]
%% Acquisition settings =============================================
% Skips acquisition in the script postProcessing.m if set to 1
settings.skipAcquisition    = 0;
% List of satellites to look for (https://www.csno-tarc.cn/en/system/constellation).
settings.acqSatelliteList   = [19:46,59:61];         % [PRN numbers]
% Band around IF to search for satellite signal. Depends on max Doppler.
% It is single sideband, so the whole search band is tiwce of it.
settings.acqSearchBand      = 5000;            % [Hz]
% Non-coherent integration times after 1ms coherent integration
settings.acqNonCohTime      = 15;              %[ms]
% Threshold for the signal presence decision rule
settings.acqThreshold       = 5;
% Frequency search step for coarse acquisition
settings.acqSearchStep      = 500;             % [Hz]

%% Tracking loops settings ==========================================
% Code tracking loop parameters
settings.dllDampingRatio         = 0.7;
settings.dllNoiseBandwidth       = 2;          % [Hz]  
settings.dllCorrelatorSpacing    = 0.5;        % [chips]
% Carrier tracking loop parameters
settings.pllDampingRatio         = 0.7;
settings.pllNoiseBandwidth       = 15;         % [Hz]
% Integration time for DLL and PLL 
settings.intTime                 = 0.001;      % [s]
% Enable/disable use of pilot channel for tracking
settings.pilotTRKflag        = 1;              % 0 - Off
                                               % 1 - On
%% Navigation solution settings =====================================
% Period for calculating pseudoranges and position
settings.navSolPeriod       = 500;            % [ms]

% Elevation mask to exclude signals from satellites at low elevation
settings.elevationMask      = 5;              %[degrees 0 - 90]
% Enable/dissable use of tropospheric correction
settings.useTropCorr        = 1;              % 0 - Off
                                              % 1 - On：conventional Saas
settings.useIonoCorr        = 0;              % 0 - Off
                                              % 1 - On：BDSGIM
% True position of the antenna in UTM system (if known). Otherwise enter
% all NaN's and mean position will be used as a reference .
settings.truePosition.E     = nan;
settings.truePosition.N     = nan;
settings.truePosition.U     = nan;

% use PPP-B2b for navigation solution or not
settings.PPP_B2b            = 1;
settings.Sp3file            = '.\data\out.sp3';     % use '' to disable sp3 output
settings.Sp3Interval        = 5;                    % Sp3 output epoch intervals [s]

%% Plot settings ====================================================
% Enable/disable plotting of the tracking results for each channel
settings.plotTracking       = 1;             % 0 - Off
                                             % 1 - On
settings.plotNavigation     = 1;                                             
%% Constants ========================================================
settings.c                  = 299792458;   % The speed of light, [m/s]
settings.startOffset        = 90.802;      % [ms] Initial sign. travel time
%% CNo Settings =====================================================
% Number of correlation values used to compute each C/No point
settings.CNoInterval = 200;
%% BDS-3 B2b carrier frequency ======================================
settings.carrFreqBasis    = 1207.14e6;      % [Hz]
