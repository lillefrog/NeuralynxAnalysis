function [data]  = CTX_Read2Struct(fileName)
% Basic function for reading all data from a cortex data file and returning
% them in a structure contaning:
%
% data(trial).correctTrial  = Timestamps for all the events in the event array
% data(trial).condition  = event codes for all the events in the trial
% data(trial).block = block number
% data(trial).cycle = cycle number
% data(trial).EOGSampleRate = sample rate for the EOG recording in Hz
% data(trial).eventArray = The full event array (timestamp,event code)
% data(trial).EOGArray = Eye tracking data (X value ; Y value ; X value ..)
% data(trial).EPPArray = EPP data (X value ; Y value ; X value ..)
%
% The data size including EPP and EOG data is around 20Mb for 1000 trials
% but this of course varies a lot 


% make sure the file exist
if ~exist(fileName,'file')
    error('FileChk:FileNotFound',['Cortex file not found: ', strrep(fileName,'\','/') ]);
end

% use Alwins basic function to read the data
[EVT,EOG,EPP,rawHEAD] = ctx_read(fileName,[1,1,1]);

% organize the data

clear data

nTrials = length(EVT);
data(nTrials,1) = struct( 'correctTrial', [], 'condition', [], 'block', [], 'cycle', [], 'EOGSampleRate', [], 'eventArray', []);

for trial = 1:nTrials
    data(trial).correctTrial = (rawHEAD(14,trial)==0);
    data(trial).condition = rawHEAD(2,trial);
    data(trial).block = rawHEAD(4,trial);
    data(trial).cycle = rawHEAD(3,trial);
    data(trial).EOGSampleRate = 1000/rawHEAD(10,trial);
    data(trial).eventArray = EVT{trial};
    data(trial).EOGArray = EOG{trial};
    data(trial).EPPArray = EPP{trial};
end


