function[time_arr,event_arr,eog_arr,epp_arr,eppnum,channel,header,trial]  = readcortepp (name)
trial=0;

fid = fopen(name, 'rb');
if fid == -1
    disp(['File not found: ', pwd ,'\', name]);
end

hd=zeros(1,13);
max_epp=1;
max_eog=1;
max_time=1;
while ( ~feof (fid))
   length2 = fread(fid, 1, 'uint16');
   if (isempty(length2)~=1)
      hd(1,1:8)= (fread(fid, 8, 'uint16'))';
      hd(1,5)=hd(1,5)/4;
      if hd(1,5)>max_time
         max_time=hd(1,5);
      end;
      hd(1,6)=hd(1,6)/2;
      hd(1,7)=hd(1,7)/2;
      if hd(1,7)>max_eog
         max_eog=hd(1,7);
      end;
      hd(1,8)=hd(1,8)/2;
      if hd(1,8)>max_epp
         max_epp=hd(1,8);
      end;
      % 'unsigned char' = 'uchar'
      % 'unsigned short'= 'uint16'
      % 'unsigned long' = 'ulong'
      % 'short' = 'short'
      
      hd(1,9:10) = (fread(fid, 2, 'uchar'))';
      hd(1,11:13)= (fread(fid, 3, 'uint16'))';
      time_arr  = (fread (fid,(hd(1,5)) , 'ulong')); 
      event_arr = (fread (fid,(hd(1,6)), 'uint16'));
      epp = fread (fid,(hd(1,8)), 'uint16');
      eog_arr = fread (fid,(hd(1,7)), 'uint16');

      trial=trial+1;
   end; 
end;
fclose(fid);
fid = fopen(name, 'rb');
time_arr =zeros(max_time, trial);
event_arr=zeros(max_time, trial);
epp_arr =zeros(max_epp, trial);
eog_arr=zeros(max_eog,trial);
%sizeepp=size(epp_arr)
eppnum=zeros(1,trial);
channel =zeros(max_epp, trial);
header=zeros(13,trial);
trial=0;
while ( ~feof (fid))
   length2 = fread(fid, 1, 'uint16');
   if (isempty(length2)~=1)
      hd(1,1:8)= (fread(fid, 8, 'uint16'))';
      hd(1,5)=hd(1,5)/4;
      hd(1,6)=hd(1,6)/2;
      hd(1,7)=hd(1,7)/2;
      hd(1,8)=hd(1,8)/2;
      eppnum(1,trial+1)=hd(1,8);
      hd(1,9:10) = (fread(fid, 2, 'uchar'))';
      hd(1,11:13)= (fread(fid, 3, 'uint16'))';
      if hd(1,5)>0
         time_arr(1:(hd(1,5)),trial+1)   = (fread (fid,(hd(1,5)) , 'ulong')); 
      end;
      if hd(1,6)>0
         event_arr(1:(hd(1,6)),trial+1) = (fread (fid,(hd(1,6)), 'uint16'));
      end;
      epp = fread (fid,hd(1,8), 'uint16');
%       hd(1,7)
%       trial
%       size(eog_arr)
      eog_arr(1:(hd(1,7)),trial+1) = fread (fid,(hd(1,7)), 'short');
      chan=bitshift(epp,-12);
      channel(1:hd(1,8),trial+1)=chan;
      epp=bitset(epp,13,0);
      epp=bitset(epp,14,0);
      epp=bitset(epp,15,0);
      epp=bitset(epp,16,0);
      epp_arr(1:hd(1,8),trial+1) = epp-2048;
      %eog_arr(1:hd(1,7),trial+1) = eog_arr(1:hd(1,7),trial+1);
      header(1:13,trial+1)=hd(1,1:13)';
      trial=trial+1;
   end; 
end;
