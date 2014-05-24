function [data]  = CTX_ReadAll(FileName)
% Basic function for reading all data from a cortex data file and returning
% them in a structure contaning
% data(trial).time_arr  = Timestamps for all the events in the event array
% data(trial).event_arr  = event codes for all the events in the trial
% 
% [time_arr,event_arr,eog_arr,epp_arr,eppnum,channel,header,trial]  = readcortepp (Fname);

fid = fopen(FileName, 'rb');
if fid == -1
    disp(['File not found: ', FileName]);
    error(['File not found: ', FileName]);
end


hd=zeros(1,13);
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
      data(trial+1).eppnum = eppnum(1,trial+1);
      hd(1,9:10) = (fread(fid, 2, 'uchar'))';
      hd(1,11:13)= (fread(fid, 3, 'uint16'))';
      if hd(1,5)>0
         time_arr(1:(hd(1,5)),trial+1)   = (fread (fid,(hd(1,5)) , 'ulong')); 
         data(trial+1).time_arr = time_arr(1:(hd(1,5)),trial+1);
      end;
      if hd(1,6)>0
         event_arr(1:(hd(1,6)),trial+1) = (fread (fid,(hd(1,6)), 'uint16'));
         data(trial+1).event_arr = event_arr(1:(hd(1,6)),trial+1);
      end;
      epp = fread (fid,hd(1,8), 'uint16');
      chan=bitshift(epp,-12);
      channel(1:hd(1,8),trial+1)=chan;
      data(trial+1).channel = chan;
      epp=bitset(epp,13,0);
      epp=bitset(epp,14,0);
      epp=bitset(epp,15,0);
      epp=bitset(epp,16,0);
      
      epp_arr(1:hd(1,8),trial+1) = epp-2048;
      eog_arr(1:(hd(1,7)),trial+1) = fread (fid,(hd(1,7)), 'short');
      data(trial+1).eog_arr = eog_arr(1:(hd(1,7)),trial+1);


      header(1:13,trial+1)=hd(1,1:13)';
      data(trial+1).header = hd(1,1:13)';
      trial=trial+1;
   end; 
end;
