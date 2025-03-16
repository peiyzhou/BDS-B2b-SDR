function eph= ephPPP_structure_init()
% This is in order to make sure variable 'eph' for each SV has a similar
% structure when only one or even none of the three requisite messages
% is decoded for a given PRN.
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

% Flags for message data decoding. 0 indicates decoding fail, 1 is 
% successful decoding. 
eph.idValid = 0;
% PRN
eph.PRN  = [];
eph.t  = [];
%% Message type 1 ==================================================
eph.mask=[];

%% Message type 2 ==================================================
eph.iodp=[];
eph.dorb=[];

%% Message type 3 ==================================================
eph.iodssr=[];
eph.nsat_bia=[];
eph.bia=[];

%% Message type 4 ==================================================
eph.iodp=[];
eph.subtype1=[];
eph.C0=[];


