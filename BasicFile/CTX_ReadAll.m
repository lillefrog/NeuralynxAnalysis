function [data]  = CTX_ReadAll(fileName)
% Basic function for reading all data from a cortex data file and returning
% them in a structure contaning
% data(trial).time_arr  = Timestamps for all the events in the event array
% data(trial).event_arr  = event codes for all the events in the trial
% 
% [time_arr,event_arr,eog_arr,epp_arr,eppnum,channel,header,trial]  = readcortepp (Fname);

fileId = fopen(fileName, 'rb');
if fileId == -1
    %disp(['File not found: ', fileName]);
    error('FileChk:FileNotFound',['File not found: ', fileName]);
end


header=zeros(1,13);
trial=0;

while ( ~feof (fileId))
   length2 = fread(fileId, 1, 'uint16');
   if (isempty(length2)~=1)
      header(1,1:8)= (fread(fileId, 8, 'uint16'))';
      header(1,5)=header(1,5)/4;
      header(1,6)=header(1,6)/2;
      header(1,7)=header(1,7)/2;
      header(1,8)=header(1,8)/2;
      eppnum(1,trial+1)=header(1,8);
      data(trial+1).eppnum = eppnum(1,trial+1);
      header(1,9:10) = (fread(fileId, 2, 'uchar'))';
      header(1,11:13)= (fread(fileId, 3, 'uint16'))';
      if header(1,5)>0
         time_arr(1:(header(1,5)),trial+1)   = (fread (fileId,(header(1,5)) , 'ulong')); 
         data(trial+1).time_arr = time_arr(1:(header(1,5)),trial+1);
      end;
      if header(1,6)>0
         event_arr(1:(header(1,6)),trial+1) = (fread (fileId,(header(1,6)), 'uint16'));
         data(trial+1).event_arr = event_arr(1:(header(1,6)),trial+1);
      end;
      epp = fread (fileId,header(1,8), 'uint16');
      chan=bitshift(epp,-12);
      channel(1:header(1,8),trial+1)=chan;
      data(trial+1).channel = chan;
      epp=bitset(epp,13,0);
      epp=bitset(epp,14,0);
      epp=bitset(epp,15,0);
      epp=bitset(epp,16,0);
      
      epp_arr(1:header(1,8),trial+1) = epp-2048;
      eog_arr(1:(header(1,7)),trial+1) = fread (fileId,(header(1,7)), 'short');
      data(trial+1).eog_arr = eog_arr(1:(header(1,7)),trial+1);


      % header(1:13,trial+1)=header(1,1:13)';
      data(trial+1).header = header(1,1:13)';
      trial=trial+1;
   end; 
end;
