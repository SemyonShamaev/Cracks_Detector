function GPRwrite(newgprfilename,data)
s=load('param_gpr.mat');
fid2=fopen(newgprfilename,'w');
fwrite(fid2,s.zagfile,'uchar');
fwrite(fid2,s.colorarr,'uchar');
nsample=size(data,2);
for i=1:nsample
    fwrite(fid2,s.koef,'uchar');
end
ntrace=size(data,1);
for i=1:ntrace
    fwrite(fid2,s.zagtrace2,'uint8');
    fwrite(fid2,data(i,:),'single');
end
fseek(fid2,24,-1);
fwrite(fid2,ntrace,'int32');
fwrite(fid2,nsample,'int32');
fclose(fid2);
end