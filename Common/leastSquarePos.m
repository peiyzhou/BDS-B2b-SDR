function [pos,el, az, dop] = leastSquarePos(tmjd, satpos,obs,bds_ion, settings)
%Function calculates the Least Square Solution.
%
%[pos, el, az, dop] = leastSquarePos(satpos, obs, settings);
%
%   Inputs:
%       satpos      - Satellites positions (in ECEF system: [X; Y; Z;] -
%                   one column per satellite)
%       obs         - Observations - the pseudorange measurements to each
%                   satellite corrected by SV clock error
%                   (e.g. [20000000 21000000 .... .... .... .... ....]) 
%       bdsalpha     broadcast ionospheric parameters from BDSGIM
%       settings    - receiver settings
%
%   Outputs:
%       pos         - receiver position and receiver clock error 
%                   (in ECEF system: [X, Y, Z, dt]) 
%       el          - Satellites elevation angles (degrees)
%       az          - Satellites azimuth angles (degrees)
%       dop         - Dilutions Of Precision ([GDOP PDOP HDOP VDOP TDOP])
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

%=== Initialization =======================================================
nmbOfIterations = 10;

dtr     = pi/180;
pos     = zeros(4, 1);   % center of earth
X       = satpos;
nmbOfSatellites = size(satpos, 2);

A       = zeros(nmbOfSatellites, 4);
omc     = zeros(nmbOfSatellites, 1);
az      = zeros(1, nmbOfSatellites);
el      = az;

%=== Iteratively find receiver position ===================================
for iter = 1:nmbOfIterations

    for i = 1:nmbOfSatellites
        if iter == 1
            %--- Initialize variables at the first iteration --------------
            Rot_X = X(:, i);
            trop = 2;
            ion=0;
        else
            %--- Update equations -----------------------------------------
            rho2 = (X(1, i) - pos(1))^2 + (X(2, i) - pos(2))^2 + ...
                   (X(3, i) - pos(3))^2;
            traveltime = sqrt(rho2) / settings.c ;

            %--- Correct satellite position (due to earth rotation) --------
            % Convert SV position at signal transmitting time to position 
            % at signal receiving time. ECEF always changes with time as 
            % earth rotates.
            Rot_X = e_r_corr(traveltime, X(:, i));
            
            %--- Find the elevation angel of the satellite ----------------
            [az(i), el(i), ~] = topocent(pos(1:3, :), Rot_X - pos(1:3, :));

            if (settings.useTropCorr == 1)
                %--- Calculate tropospheric correction --------------------
                trop = tropo(sin(el(i) * dtr), ...
                             0.0, 1013.0, 293.0, 50.0, 0.0, 0.0, 0.0);
           
            else
                % Do not calculate or apply the tropospheric corrections
                trop = 0;
            end
            if (settings.useIonoCorr  == 1)
                %--- Calculate ionospheric correction --------------------
                ion = IonBdsBrdModel(tmjd, pos(1:3, :), X(:, i), bds_ion,1207.14e6,0);
           
            else
                % Do not calculate or apply the ionospheric corrections
                ion = 0;
            end
        end % if iter == 1 ... ... else 

        %--- Apply the corrections ----------------------------------------
        omc(i) = ( obs(i) - norm(Rot_X - pos(1:3), 'fro') - pos(4) - trop-ion ); 

        %--- Construct the A matrix ---------------------------------------
        A(i, :) =  [ (-(Rot_X(1) - pos(1))) / norm(Rot_X - pos(1:3), 'fro') ...
                     (-(Rot_X(2) - pos(2))) / norm(Rot_X - pos(1:3), 'fro') ...
                     (-(Rot_X(3) - pos(3))) / norm(Rot_X - pos(1:3), 'fro') ...
                     1 ];
    end % for i = 1:nmbOfSatellites

    % These lines allow the code to exit gracefully in case of any errors
    if rank(A) ~= 4
        pos     = zeros(1, 4);
        dop     = inf(1, 5);
        fprintf('Cannot get a converged solotion! \n');
        return
    end

    %--- Find position update (in the least squares sense)-----------------
    x   = A \ omc;
    
    %--- Apply position update --------------------------------------------
    pos = pos + x;
    
end % for iter = 1:nmbOfIterations

%--- Fixing resulut -------------------------------------------------------
pos = pos';

%=== Calculate Dilution Of Precision ======================================
if nargout  == 4
    %--- Initialize output ------------------------------------------------
    dop     = zeros(1, 5);
    
    %--- Calculate DOP ----------------------------------------------------
    Q       = inv(A'*A);
    [phi, lambda, ~] = cart2geo(pos(1), pos(2), pos(3), 6);% BDCS LLH

    % for calculation of HDOP and VDOP
    T=[     -sind(lambda)          cosd(lambda)               0;...
       -sind(phi)*cosd(lambda) sind(phi)*sind(lambda) cosd(phi);...
        cosd(phi)*cosd(lambda) cosd(phi)*sind(lambda) sind(phi)];
    Qp=T*Q(1:3,1:3)*T';

    dop(1)  = sqrt(trace(Q));                       % GDOP    
    dop(2)  = sqrt(Q(1,1) + Q(2,2) + Q(3,3));       % PDOP
    dop(3)  = sqrt(Qp(1,1) + Qp(2,2));              % HDOP
    dop(4)  = sqrt(Qp(3,3));                        % VDOP
    dop(5)  = sqrt(Q(4,4));                         % TDOP
end  % if nargout  == 4
