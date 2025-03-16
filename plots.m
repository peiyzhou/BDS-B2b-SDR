%% Generate plots for B2b-SDR
clear
clc
close all

fid=fopen("data\B2b_20M.bin", 'rb');

fseek(fid, 2*0, 'bof'); 

data  = fread(fid, 2*0.1*20e6, "float32")';
data1 = data(1:2:end);    
data2 = data(2:2:end);    
data = data1 + 1i .* data2;   

timeScale=0:1/20e6:0.1-1/20e6;

figure(101)
set(gcf,'unit','centimeters','position',[5 5 8.4 10]);
p = panel();
p.pack(2, 1);
p.de.margin = 5;

p(1, 1).select();
p(1, 1).margin = [5 5 2 3]; 
plot(1000 * timeScale,  real(data),'.');

grid minor;
box on
text (0,0,'Time domain plot (I)');
 ylabel('Amplitude');
set(gca,'XTickLabel',[])

p(2, 1).select();
p(2, 1).margin = [5 5 2 3]; 
plot(1000 * timeScale,  imag(data),'.');

grid minor;box on
text (0,0,'Time domain plot (Q)');
xlabel('Time (ms)'); ylabel('Amplitude');

figure(102)
set(gcf,'unit','centimeters','position',[5 5 8.4 7]);
p = panel();
p.pack(1, 1);
p.de.margin = 5;

p(1, 1).select();
p(1, 1).margin = [5 5 2 3]; 
[sigspec,freqv]=pwelch(data, 32768, 2048, 32768, 20e6,'twosided');
plot(([-(freqv(length(freqv)/2:-1:1));freqv(1:length(freqv)/2)])/1e6, ...
    10*log10([sigspec(length(freqv)/2+1:end);
    sigspec(1:length(freqv)/2)]));
grid on;
box on;
% title ('Frequency domain plot');
xlabel('Frequency (MHz)'); ylabel('Magnitude');

p.fontsize = 10;
p.fontname='Arial';
p.marginleft=14;
p.marginright=4;
p.marginbottom=15;
