function [data]  = CTX_ReadAll(fileName)
% Basic function for reading all data from a cortex data file and returning
% them in a structure contaning
% data(trial).time_arr  = Timestamps for all the events in the event array
% data(trial).event_arr  = event codes for all the events in the trial
% 
% [time_arr,event_arr,eog_arr,epp_arr,eppnum,channel,header,trial]  = readcortepp (Fname);

fileId = fopen(fileName, 'rb');
if fileId == -1
    error('FileChk:FileNotFound',['Cortex file not found: ', strrep(fileName,'\','/') ]);
end


header=zeros(1,13);
trial=0; 

while ( ~feof (fileId))
   headerLength = fread(fileId, 1, 'uint16');
   if (isempty(headerLength)~=1)
      header(1,1:8)= (fread(fileId, 8, 'uint16'))'; 
      if (headerLength~=26) % This all assumes the header is 26 long
          disp('Cortex header corrupted: Length not 26')
          showMyHeader(header);
          break;
      end
      header(1,5)=header(1,5)/4; % ISI size 
      header(1,6)=header(1,6)/2; % Code size
      header(1,7)=header(1,7)/2; % EOG size
      header(1,8)=header(1,8)/2; % EPP size
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
      %chan=bitshift(epp,-12);
      %channel(1:header(1,8),trial+1)=chan;
      %data(trial+1).channel = chan;
      data(trial+1).channel = bitshift(epp,-12);
      epp=bitset(epp,13,0);
      epp=bitset(epp,14,0);
      epp=bitset(epp,15,0);
      epp=bitset(epp,16,0);
      
      epp_arr(1:header(1,8),trial+1) = epp-2048;
      eog_arr(1:(header(1,7)),trial+1) = fread(fileId,(header(1,7)), 'short'); % Read EOG
      data(trial+1).eog_arr = eog_arr(1:(header(1,7)),trial+1);

      data(trial+1).header = header(1,1:13)';
      trial=trial+1;
   end; 
end;


function showMyHeader(header)
% function for displaying the first part of the header in case it is
% corrupted. This might help evaluating the problem
          myText = sprintf ([...
            'Condition: ',num2str(header(1,1)),'\n',...
            'Repeat no: ',num2str(header(1,2)),'\n',...
            'Block no : ',num2str(header(1,3)),'\n',...
            'Trial no : ',num2str(header(1,4)),'\n',...
            'ISI size : ',num2str(header(1,5)),'\n',...
            'Code size: ',num2str(header(1,6)),'\n',...
            'EOG size : ',num2str(header(1,7)),'\n',...
            'EPP size : ',num2str(header(1,8)),'\n',...
          ]);        
          disp(myText);
          