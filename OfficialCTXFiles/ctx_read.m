function [EVT,EOG,EPP,rawHEAD] = ctx_read(filepath,readflags,trialindex,filepos)

% read data from a cortex file
%
% [EVT,EOG,EPP,rawHEAD] = ctx_read(filepath,readflags,trialindex,filepos)
%
% INPUT
% filepath ..... complete path of the cortex file
% [readflags] .... 3 element vector of 1/0 [EVT,EOG,EPP]
% [trialindex] ... indices of trials to read, do not apply for the header data
% [filepos] ...... pos matrix as given by ctx_scan.m, if omitted ctx_scan.m
%                is called
% OUTPUT
% EVT .... event data
% EOG .... eog data block
% EPP .... epp data block
% rawHEAD ... all header data (see ctx_scan.m)
%                               1 length 2 cond_no 3 repeat_no 4 block_no 5 trial_no 6 isi_size
%                               7 code_size 8 eog_size 9 epp_size 10 eye_storage_rate 11 kHz_resolution 
%                               12 expected_response 13 response 14 response_error

% alwin 08/07/04
% modified christian 10/06 - 2014

EVT = [];EOG = []; EPP = [];rawHEAD = [];

if nargin<1 || isempty(filepath);
    [fName,fPath] = uigetfile('*.*','open a CORTEX data file');
    if fName==0;
        return;
    end
    filepath = fullfile(fPath,fName);
end

if ~exist(filepath,'file')
    error('FileChk:FileNotFound',['Cortex file not found: ', strrep(fileName,'\','/') ]);
end

%_____________________________________________________
% check input
if nargin<4
    % scan file if needed
    [rawHEAD,filepos] = ctx_scan(filepath);
    
    if isempty(filepos)
      return;
    end
    
    if nargin<3
      trialindex = [];
      if nargin<2
        readflags = logical([1 1 1]);
      end;
    end;
end

if isempty(trialindex)
  trialindex = 1:size(filepos,2);
end
TrialNum = length(trialindex);
   
%_____________________________________________________
% allocate event vector
% filepos row    2 start of timecode block
%                3 start of eventcode block
%                4 start of eogcode block
TimeCodeNum = diff(filepos([2 3],trialindex),1,1)./4;
EventCodeNum = diff(filepos([3 4],trialindex),1,1)./2;




if ~isequal(TimeCodeNum,EventCodeNum)
   EventCodeNum = TimeCodeNum;
   disp([filepath, ' reading error, number of time codes and event codes are not equal']);
   disp('overwriting Event code numbers!');
end
EVT = cell(1,TrialNum);


%_____________________________________________________
% open file

[fid,msg] = fopen(filepath,'r');
if fid<0
    disp(msg);
    error(['Can''t open file: ' filepath]);
end

%_____________________________________________________
% read data

for i = 1:TrialNum
    
    % read events
    if readflags(1) 
        fseek(fid,filepos(2,trialindex(i)),'bof');
        currTimeCode = fread(fid,TimeCodeNum(i),'int');% 4 bytes 
        if ftell(fid)~=filepos(3,trialindex(i));
            error('ctx reading error');
        end
        currEventCode = fread(fid,EventCodeNum(i),'short');% 2 bytes
        EVT{i} = cat(2,currTimeCode,currEventCode);
    end
       
    % read eog
    if readflags(2)      
        fseek(fid,filepos(5,trialindex(i)),'bof');
        EOGNum = (filepos(6,trialindex(i))-filepos(5,trialindex(i)))./2;
        EOG{i} = fread(fid,EOGNum,'short');       
    end
        
    % read epp
    if readflags(3)
        fseek(fid,filepos(4,trialindex(i)),'bof');
        EPPNum = (filepos(5,trialindex(i))-filepos(4,trialindex(i)))./2;
        EPP{i} = fread(fid,EPPNum,'short');    
    end
end

fclose(fid);