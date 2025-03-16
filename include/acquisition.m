function acqResults = acquisition(longSignal, settings)
%Function performs cold start acquisition on the collected "data". It
%searches for B2b signals of all satellites, which are listed in field
%"acqSatelliteList" in the settings structure. Function saves code phase
%and frequency of the detected signals in the "acqResults" structure.
%
%acqResults = acquisition(longSignal, settings)
%
%   Inputs:
%       longSignal    - (=20+X+1) ms of raw signal from the
%                       front-end.The first 20+X ms segment is in order
%                       to include at least the first Xms of a CM code;
%                       The last 1ms is to make sure the index does not
%                       exceeds matrix dimensions of 10ms long.
%       settings      - Receiver settings. Provides information about
%                       sampling and intermediate frequencies and other
%                       parameters including the list of the satellites to
%                       be acquired.
%   Outputs:
%       acqResults    - Function saves code phases and frequencies of the
%                       detected signals in the "acqResults" structure. The
%                       field "carrFreq" is set to 0 if the signal is not
%                       detected for the given PRN number.

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

%% Acquisition initialization =======================================
%--- Varaibles for coarse acquisition -------------------------------------
% Find number of samples per spreading code
samplesPerCode = round(settings.samplingFreq / ...
    (settings.codeFreqBasis / settings.codeLength));
% Find sampling period
ts = 1 / settings.samplingFreq;
% Find phase points of 2ms local carrier wave (1ms for local duplicate,
% the other 1ms for zero padding)
phasePoints = (0 : (samplesPerCode * 2 -1)) * 2 * pi * ts;
% Number of the frequency bins for the specified search band
numberOfFreqBins = round(settings.acqSearchBand * 2 / settings.acqSearchStep) + 1;
% Carrier frequency bins to be searched
coarseFreqBin = zeros(1, numberOfFreqBins);

%--- Initialize acqResults ------------------------------------------------
% Carrier frequencies of detected signals
acqResults.carrFreq     = zeros(1, max(settings.acqSatelliteList));
% PRN code phases of detected signals
acqResults.codePhase    = zeros(1, max(settings.acqSatelliteList));
% Correlation peak ratios of the detected signals
acqResults.peakMetric   = zeros(1, max(settings.acqSatelliteList));

%--- Varaibles for fine acquisition ---------------------------------------
% Number of the frequency bins for fine acquisition: use 400Hz fine
% acquisition band, and 25Hz step
NumOfFineBins = round(settings.acqSearchStep / 25) + 1;

% Carrier frequencies of the frequency bins
FineFrqBins     = zeros(1, NumOfFineBins);

% Search results of all frequency bins
FineResult = zeros(1,NumOfFineBins);
% At least 10ms signal is sued for fine frequency estimation
fineSigLen = max(10,settings.acqNonCohTime);
% Coherent integration for each code
sumPerCode1 = zeros(1,fineSigLen);
sumPerCode2 = zeros(1,fineSigLen);
%--- Find phase points of the local carrier wave -------------------
finePhasePoints = (0 : (fineSigLen*samplesPerCode-1)) * 2 * pi * ts;

%--- Input signal power for GLRT statistic calculation --------------------
sigPower = sqrt(var(longSignal(1:samplesPerCode)) * samplesPerCode);

% Perform search for all listed PRN numbers ...
fprintf('(');
for PRN = settings.acqSatelliteList
    
    %% Coarse acquisition ===========================================
    
    % Generate PRN code and sample them according to the sampling freq.
    B2bTable  = makeB2bTable(PRN,settings);
    
    % generate local code duplicate to do correlate
    localB2bCode = [B2bTable, zeros(1,samplesPerCode)];
    % Search results of all frequency bins and code shifts (for one satellite)
    results = zeros(numberOfFreqBins, samplesPerCode*2);
    
    %--- Perform DFT of PRN code ------------------------------------------
    B2bFreqDom = conj(fft(localB2bCode));
    
    %--- Make the correlation for all frequency bins
    for freqBinIndex = 1:numberOfFreqBins
        
        %--- Generate carrier wave frequency grid  -----------------------
        coarseFreqBin(freqBinIndex) = settings.IF - settings.acqSearchBand + ...
            settings.acqSearchStep * (freqBinIndex - 1);
        
        %--- Generate local sine and cosine -------------------------------
        sigCarr = exp(1i * coarseFreqBin(freqBinIndex) * phasePoints);
        
        %--- Do correlation -----------------------------------------------
        for nonCohIndex = 1: settings.acqNonCohTime
            % Take 2ms vectors of input data to do correlation
            signal = longSignal((nonCohIndex - 1) * samplesPerCode + ...
                1 : (nonCohIndex + 1) * samplesPerCode);
            % "Remove carrier" from the signal
            I      = real(sigCarr .* signal);
            Q      = imag(sigCarr .* signal);
            
            %--- Convert the baseband signal to frequency domain --------------
            IQfreqDom = fft(I + 1i*Q);
            
            %--- Multiplication in the frequency domain (correlation in time
            %domain)
            convB2b = IQfreqDom .* B2bFreqDom;
            
            %--- Perform inverse DFT and store correlation results ------------
            cohRresult = abs(ifft(convB2b)) ;
            % Non-coherent integration
            results(freqBinIndex, :) = results(freqBinIndex, :) + cohRresult;
        end % nonCohIndex = 1: settings.acqNonCohTime
    end % frqBinIndex = 1:numberOfFreqBins
    
    %% Look for correlation peaks for coarse acquisition ============
    % Find the correlation peak and the carrier frequency
    [~, acqCoarseBin] = max(max(results, [], 2));
    % Find code phase of the same correlation peak
    [peakSize, codePhase] = max(max(results));
    % Store GLRT statistic
    acqResults.peakMetric(PRN) = peakSize/sigPower/settings.acqNonCohTime;
    
    %% Fine resolution frequency search =============================
    % If the result is above threshold, then there is a signal ...
    if acqResults.peakMetric(PRN) > settings.acqThreshold
        %--- Indicate PRN number of the detected signal -------------------
        fprintf('%02d ', PRN);

        %--- Generate B2b codes sequence -------------------
        % fineSigLen ms long
        B2bCode = generateB2bCode(PRN,settings);

        % Sampling index
        codeValueIndex = floor((ts * (1:fineSigLen*samplesPerCode)) / ...
            (1/settings.codeFreqBasis));
        
        % Sampled data and pilot codes
        longB2bCode = B2bCode((rem(codeValueIndex, settings.codeLength) + 1));

        % Incoming signal of fineSigLen ms length
        sigFineACQ = longSignal(codePhase:codePhase + fineSigLen*samplesPerCode -1);

        %--- Search different frequency bins -------------------------------
        for FineBinIndex = 1 : NumOfFineBins
            
            % Carrier frequencies of the frequency bins
            FineFrqBins(FineBinIndex) = coarseFreqBin(acqCoarseBin) -...
                settings.acqSearchStep/2 + 25 * (FineBinIndex - 1);
            % Generate local sine and cosine
            sigCarr20cm = exp(1i*FineFrqBins(FineBinIndex) * finePhasePoints);
            
            % Wipe off B2b code and carrier from incoming signals to
            % produce baseband signal.
            basebandSig1 = longB2bCode .* sigCarr20cm .* sigFineACQ;
            
          
            % Non-coherent integration for each code
            for index = 1:fineSigLen
                sumPerCode1(index) = sum( basebandSig1( samplesPerCode * ...
                    (index-1)+1:samplesPerCode*index ) );
                
            end
            
            FineResult(FineBinIndex) = sum(abs(sumPerCode1)) + sum(abs(sumPerCode2));
        end % FineBinIndex = 1 : NumOfFineBins
        
        % Find the fine carrier freq. -------------------------------------
        % Corresponding to the largest noncoherent power
        [~,maxFinBin] = max(FineResult);
        acqResults.carrFreq(PRN) = FineFrqBins(maxFinBin);
        
        % Code phase acquisition result
        acqResults.codePhase(PRN) = codePhase;
        
        %signal found, if IF = 0 just change to 1 Hz to allow processing
        if(acqResults.carrFreq(PRN) == 0)
            acqResults.carrFreq(PRN) = 1;
        end
    else
        %--- No signal with this PRN --------------------------------------
        fprintf('. ');
    end   % if (peakSize/secondPeakSize) > settings.acqThreshold
    
end    % for PRN = satelliteList

%=== Acquisition is over ==================================================
fprintf(')\n');
