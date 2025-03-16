 function outputSp3(fid,opt,data)
%Function Write orbits to SP3 file.
%
% outputSp3(fid,opt,data)
%
%   Inputs:
%       fid            - file hander
%       opt            - data type flag, 0 for header section; others for satellite record
%       data           - SV satellite orbit and clock information.
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

% write file 
if opt==0 % header
    % data： mjd sod interval
    [gps_week, gps_sow, ~] = mjd2gpst(data(1)+data(2)/86400+14);
    [year, month, day, hour, minute, second] = mjd2date(data(1)+data(2)/86400);
    fprintf(fid,"#dP%4d %2d %2d %2d %2d %10.8f     %5d d+D  BDCS  PPP-B2b\n",year, month, day, hour, minute, second,86400/data(3));
    fprintf(fid,"## %4d %15.8f   %12.8f %5d 0.0000000000000\n",gps_week,gps_sow,data(3),data(1));
    fprintf(fid,"+  116   G01G02G03G04G05G06G07G08G09G10G12G13G14G15G16G17G18\n");
    fprintf(fid,"+        G19G20G21G22G23G24G25G26G27G28G29G30G31G32R01R02R03\n");
    fprintf(fid,"+        R04R05R07R08R09R11R12R13R14R15R16R17R18R19R20R21R22\n");
    fprintf(fid,"+        R24E01E02E03E04E05E07E08E09E11E12E13E14E15E18E19E21\n");
    fprintf(fid,"+        E24E25E26E27E30E31E33E36C06C07C08C09C10C11C12C13C14\n");
    fprintf(fid,"+        C16C19C20C21C22C23C24C25C26C27C28C29C30C32C33C34C35\n");
    fprintf(fid,"+        C36C37C38C39C40C41C42C43C44C45C46J01J02J03  0  0  0\n");
    fprintf(fid,"++         5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5\n");
    fprintf(fid,"++         5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5\n");
    fprintf(fid,"++         5  5  5  5  5  5  5  5  5  5  5  5  6  5  5  5  5\n");
    fprintf(fid,"++         5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5\n");
    fprintf(fid,"++         5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5\n");
    fprintf(fid,"++         5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5\n");
    fprintf(fid,"++         5  5  5  5  5  5  5  5  5  5  5  9  5  5  0  0  0\n");
    fprintf(fid,"%%c M  cc GPS ccc cccc cccc cccc cccc ccccc ccccc ccccc ccccc\n");
    fprintf(fid,"%%c cc cc ccc ccc cccc cccc cccc cccc ccccc ccccc ccccc ccccc\n");
    fprintf(fid,"%%f  1.2500000  1.025000000  0.00000000000  0.000000000000000\n");
    fprintf(fid,"%%f  0.0000000  0.000000000  0.00000000000  0.000000000000000\n");
    fprintf(fid,"%%i    0    0    0    0      0      0      0      0         0\n");
    fprintf(fid,"%%i    0    0    0    0      0      0      0      0         0\n");
    fprintf(fid,"/* PPP-B2b precise ephemeris by BDS-B2b SDR in APC frame     \n"); 

else % body
    [year, month, day, hour, minute, second] = mjd2date(data(2)+data(3)/86400);
    if data(1)==1 % first record of this epoch, output time info
        fprintf(fid,"*  %4d %2d %2d %2d %2d %11.8f\n",year, month, day, hour, minute, second);
    end
    if opt>63
        fprintf(fid,"PG%02d%14.6f%14.6f%14.6f%14.6f\n",opt-63,data(4)/1000,data(5)/1000,data(6)/1000,data(7)*1e6);
    else
        fprintf(fid,"PC%02d%14.6f%14.6f%14.6f%14.6f\n",opt,data(4)/1000,data(5)/1000,data(6)/1000,data(7)*1e6);
    end
end