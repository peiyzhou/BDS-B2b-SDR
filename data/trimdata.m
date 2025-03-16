clear
clc
close all

%% trim data
rawf="B2b_20M.bin";
outf="B2b_20M_out.bin";

fidr=fopen(rawf,"rb");
fidw=fopen(outf,"wb");

for i=1:72
    fprintf("the %d block\n",i)
    [data, count] = fread(fidr, 20e6, "float32");
    fwrite(fidw, data, "float32");
end
fclose("all");