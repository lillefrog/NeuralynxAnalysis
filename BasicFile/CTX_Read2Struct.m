function [data]  = CTX_Read2Struct(fileName)
% Basic function for reading all data from a cortex data file and returning
% them in a structure contaning:
%
% data(trial).correctTrial  = Timestamps for all the events in the event array
% data(trial).condition  = event codes for all the events in the trial
% data(trial).block = block number
% data(trial).cycle = cycle number
% data(trial).EOGSampleRate = sample rate for the EOG recording in Hz
% data(trial).actualResponse = Code indicating the actual response 
% data(trial).expectedResponse = you can add the expected response in the stt code and it will be returned here.
% data(trial).hasSpikes = code indicating that the corresponding NLF file contains spikes (false until proven othervise)
% data(trial).eventArray = The full event array (timestamp,event code)
% data(trial).EOGArray = Eye tracking data (X value ; Y value ; X value ..)
% data(trial).EPPArray = EPP data (X value ; Y value ; X value ..)
%
% The data size including EPP and EOG data is around 20Mb for 1000 trials
% but this of course varies a lot 
%
% Requirements:
% ctx_read and ctx_scan

% TODO:
% I could include some more error checking in case the file exist but
% is currupted or the wrong file type
%


%% make sure the file exist

 if nargin<1 || isempty(fileName);
    [fName,filePath] = uigetfile('*.*','open a cortex data file','MultiSelect','off'); 
    fileName = fullfile(filePath,fName);
 end

if ~exist(fileName,'file')
    error('FileChk:FileNotFound',['Cortex file not found: ', strrep(fileName,'\','/') ]);
end


%% use Alwins basic function to read the data
[EVT,EOG,EPP,rawHEAD] = ctx_read(fileName,[1,1,1]);


%% organize the data

clear data % adressing a struct that already exist is very dangerous so I clear it

% initialize the data array
nTrials = length(EVT);
data(nTrials,1) = struct( 'correctTrial', [], 'condition', [], 'block', [], 'cycle', [], 'EOGSampleRate', [], 'eventArray', []);

% go trough all the trials and add the data
for trial = 1:nTrials
    data(trial).expectedResponse = (rawHEAD(12,trial));
    data(trial).actualResponse = (rawHEAD(13,trial)); % these have to be added in the stt else they just contain rubbish
    data(trial).correctTrial = (rawHEAD(14,trial)==0); % these have to be added in the stt else they just contain rubbish
    data(trial).condition = rawHEAD(2,trial);
    data(trial).block = rawHEAD(4,trial); 
    data(trial).cycle = rawHEAD(3,trial); % repeat number
    data(trial).EOGSampleRate = 1000/rawHEAD(10,trial);
    data(trial).eventArray = EVT{trial};
    data(trial).EOGArray = EOG{trial};
    data(trial).EPPArray = EPP{trial};
    data(trial).hasSpikes = false; % as a default there are no spikes unless proven othervise
end


