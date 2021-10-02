function [data,ntrace,nsample]=GPRread(gprfilename)
fid = fopen(gprfilename);
IDver=fread(fid,1,'int32');
IDver=fread(fid,1,'int32');
fseek(fid,16,0);
ntrace=fread(fid,1,'int32');
nsample=fread(fid,1,'int32');
tracetime=fread(fid,1,'int32');
tracetime=fread(fid,1,'int32');
if IDver==1 
    lenzagtrace=36; 
else
    lenzagtrace=44;
end;
lenzag=(128+256+nsample)*4; %512+256*4+sample*4)/4     +44 ili 36
status=fseek(fid,lenzag+lenzagtrace,-1);
data=zeros(ntrace,nsample);
for i=1:ntrace
[num,countr]=fread(fid,nsample,'single');
data(i,:)=num;
status=fseek(fid,lenzagtrace,0);
end

% fseek(fid,0,-1);
% zagfile=fread(fid,128*4,'uchar');
% colorarr=fread(fid,256*4,'uchar');
% koefvyravn=fread(fid,nsample*4,'uchar');
% zagtrace2=fread(fid,11*4,'int8');
fclose(fid);
end