function [header,filepos] = ctx_scan(filepath)

% read the header of all trials of a cortex files and scan for position of
% data blocks
%
%   [header,filepos] = ctx_scan(filepath)
%
% INPUT
% filepath ... full path, if omitted a gui pops up
%
% OUTPUT
% header .... header data [14, n trials]
%                          1 length
%                          2 cond_no
%                          3 repeat_no
%                          4 block_no
%                          5 trial_no
%                          6 isi_size
%                          7 code_size
%                          8 eog_size
%                          9 epp_size
%                          10 eye_storage_rate
%                          11 kHz_resolution
%                          12 expected_response
%                          13 response
%                          14 response_error
%
% filepos ... file positions in bytes [7, n trials]
%             1 header start 
%             2 start of timecode block
%             3 start of eventcode block
%             4 start of eogcode block
%             5 start of eppcode block
%             6 start of next trial
%          
% alwin 08/07/04
% modified by Christian Brandt 01/05-2012

header = [];
filepos = [];
Error = false;

%_____________________________________________________
% open file
if nargin<1  || isempty(filepath);
    [fName,fPath] = uigetfile('*.*','open a CORTEX data file');
    if fName==0;return;end
    filepath = fullfile(fPath,fName);
else
    [~,fName,fExt] = fileparts(filepath);
    fName = [fName fExt];
end

[fid,msg] = fopen(filepath,'r');
if fid<0;disp(msg); error(['Can''t open file: ' filepath]); return; end

dispfilepath = strrep(fName,'_','\_');

%_____________________________________________________
% size of file
fseek(fid,0,'eof');
fBytes = ftell(fid);
fseek(fid,0,'bof');

%_____________________________________________________
% read file
fPos = ftell(fid);
while fPos<fBytes
    currHd = zeros(14,1).*NaN;
    
    %__________________________________________
    % read header
    currHdstartpos = ftell(fid);
    
    [temp,~] = fread(fid,1,'ushort');%length
    if(size(temp,1)==0);  Error=true; % disp(size(header));
    else currHd(1) = temp; end;
    
    [temp,~] = fread(fid,1,'short');%cond_no
    if(size(temp,1)==0);  Error=true; % disp(size(header));
    else currHd(2) = temp; end;
    
    [temp,~] = fread(fid,1,'ushort');%repeat_no
    if(size(temp,1)==0);  Error=true; % disp(size(header));
    else currHd(3) = temp; end;   
    
    [temp,~] = fread(fid,1,'ushort');%block_no
    if(size(temp,1)==0);  Error=true; % disp(size(header));
    else currHd(4) = temp; end;
    
    [temp,~] = fread(fid,1,'ushort');%trial_no
    if(size(temp,1)==0);  Error=true; % disp(size(header));
    else currHd(5) = temp; end;
    
    [temp,~] = fread(fid,1,'ushort');%isi_size
    if(size(temp,1)==0);  Error=true; % disp(size(header));
    else currHd(6) = temp; end;
    
    [temp,~] = fread(fid,1,'ushort');%code_size
    if(size(temp,1)==0);  Error=true; % disp(size(header));
    else currHd(7) = temp; end;
    
    [temp,~] = fread(fid,1,'ushort');%eog_size
    if(size(temp,1)==0);  Error=true; % disp(size(header));
    else currHd(8) = temp; end;
    
    [temp,~] = fread(fid,1,'ushort');%epp_size
    if(size(temp,1)==0);  Error=true; % disp(size(header));
    else currHd(9) = temp; end;
    
    [temp,~] = fread(fid,1,'char');%eye_storage_rate
    if(size(temp,1)==0);  Error=true; % disp(size(header));
    else currHd(10) = temp; end;
    
    [temp,~] = fread(fid,1,'char');%kHz_resolution
    if(size(temp,1)==0);  Error=true; % disp(size(header));
    else currHd(11) = temp; end;
    
    [temp,~] = fread(fid,1,'short');%expected_response
    if(size(temp,1)==0);  Error=true; % disp(size(header));
    else currHd(12) = temp; end;
    
    [temp,~] = fread(fid,1,'short');%response
    if(size(temp,1)==0);  Error=true; % disp(size(header));
    else currHd(13) = temp; end;
    
    [temp,~] = fread(fid,1,'short');%response_error
    if(size(temp,1)==0);  Error=true; % disp(size(header));
    else currHd(14) = temp; end;
    
    
%     [currHd(1),~] = fread(fid,1,'ushort');%length
%     [currHd(2),~] = fread(fid,1,'short');%cond_no
%     [currHd(3),~] = fread(fid,1,'ushort');%repeat_no
%     [currHd(4),~] = fread(fid,1,'ushort');%block_no
%     [currHd(5),~] = fread(fid,1,'ushort');%trial_no
%     
%     [currHd(6),~] = fread(fid,1,'ushort');%isi_size
%     [currHd(7),~] = fread(fid,1,'ushort');%code_size
%     [currHd(8),~] = fread(fid,1,'ushort');%eog_size
%     [currHd(9),~] = fread(fid,1,'ushort');%epp_size
%     
%     [currHd(10),~] = fread(fid,1,'char');%eye_storage_rate
%     [currHd(11),~] = fread(fid,1,'char');%kHz_resolution
%     
%     [currHd(12),~] = fread(fid,1,'short');%expected_response
%     [currHd(13),~] = fread(fid,1,'short');%response
%     [currHd(14),~] = fread(fid,1,'short');%response_error
    currArrstartpos = ftell(fid);
    
    %___________________________________________
    % jump to file end
    currDataArraySize = sum(currHd(6:9));
    fseek(fid,currDataArraySize,'cof');
    currArrendpos = ftell(fid);
    
    %___________________________________________
    % concatenate data
    filepos = cat(2,filepos,[ ...
            currHdstartpos; ... (1) Header blockstart
            currArrstartpos; ... (2) TimeStamps blockstart
            currArrstartpos + currHd(6); ... (3) EventCode blockstart
            currArrstartpos + sum(currHd(6:7)); ... (4) EPP blockstart
            currArrstartpos + sum(currHd([6 7 9])); ... (5) EOG blockstart
            currArrendpos]);
        
    fPos = currArrendpos;
    
    if(Error==false); header = cat(2,header,currHd); 
    else disp('Header file corrupted'); fPos=fBytes;
    end;
    
    

end
fclose(fid);
