function [b2bcorr_orb,b2bcorr_clk,b2bcorr_bia]=applyMaskcode(b2bdata)
%Function apply mask code & generate formatted PPP-B2b corrections inluding 
% orbit, clock, and code bias
%
%[b2bcorr_orb,b2bcorr_clk,b2bcorr_bia]=applyMaskcode(b2bdata)
%
%   Inputs:
%       b2bdata      - PPP-B2b ephemeris structure.
%   Outputs:
%       b2bcorr_orb  - PPP-B2b orbit corrections
%       b2bcorr_clk  - PPP-B2b clock corrections
%       b2bcorr_bia  - PPP-B2b bias corrections

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
ndata=length(b2bdata);
b2bcorr_orb=zeros(255*10,10);iorb=1;
b2bcorr_bia=zeros(255*10,19);ibia=1;
b2bcorr_clk=zeros(255*20,6);iclk=1;

%% first get mask code
for i=ndata:-1:1
    if b2bdata(i).idValid==1
        satslots=[(1:255)' b2bdata(i).mask];
        satslots(satslots(:,2)==0,:)=[];
        break;
    end
end
nsub=ceil(length(satslots(:,1))/23)*23;
satslots=[satslots;zeros(nsub-length(satslots(:,1)),2)];
%% generate other corrections
for i=1:ndata
    if b2bdata(i).idValid==2
        for j=1:length(b2bdata(i).dorb(:,1))
            b2bcorr_orb(iorb,:)=[b2bdata(i).t b2bdata(i).iodssr b2bdata(i).dorb(j,:)];
            iorb=iorb+1;
        end
    elseif b2bdata(i).idValid==3
        for j=1:length(b2bdata(i).bia(:,1))
            b2bcorr_bia(ibia,:)=[b2bdata(i).t b2bdata(i).iodssr b2bdata(i).bia(j,:)];
            ibia=ibia+1;
        end
    elseif b2bdata(i).idValid==4   
        subtype=b2bdata(i).subtype1;
        for j=1:length(b2bdata(i).C0(:,1))
            b2bcorr_clk(iclk,:)=[b2bdata(i).t b2bdata(i).iodssr b2bdata(i).iodp  satslots(subtype*23+j,1) b2bdata(i).C0(j,:)];
            iclk=iclk+1;
        end
    end

end
b2bcorr_orb=b2bcorr_orb(1:iorb-1,:);
b2bcorr_orb(b2bcorr_orb(:,3)==0,:)=[];
b2bcorr_clk=b2bcorr_clk(1:iclk-1,:);
b2bcorr_clk(b2bcorr_clk(:,4)==0,:)=[];
b2bcorr_bia=b2bcorr_bia(1:ibia-1,:);