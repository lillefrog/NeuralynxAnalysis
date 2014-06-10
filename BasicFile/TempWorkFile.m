
addpath(genpath('E:\doc\GitHub\NeuralynxAnalysis\'));



%% TFT monitor setup
eventFilename = 'E:\JonesRawData\PEN312\NLX_control\2014-06-07_07-24-14\Events.Nev';
LFP_fileName = 'E:\JonesRawData\PEN312\NLX_control\2014-06-07_07-24-14\LFP17.ncs';
spikeFileName = 'E:\JonesRawData\PEN312\NLX_control\2014-06-07_07-24-14\GRCJDRU1.517 ON_GRCJDRU1.517 OFFSE17_cb.NSE';
spikeFileName = 'E:\JonesRawData\PEN312\NLX_control\2014-06-07_07-24-14\SE17x.NSE';


%% Read the files and extract the data

% Read the NLX event file and cut out the part related to our experiment
[automaticEvents,manualEvents] = NLX_ReadEventFile(eventFilename);
manualStartEvent = 'grcjdru1.517 on';
manualStopEvent = 'grcjdru1.517 off';
[cutEventfile] = NLX_CutEventfile(automaticEvents,manualEvents,manualStartEvent,manualStopEvent);

% Split the event file up in trials
startTrialEvent = 255;
stopTrialEvent = 254;
[dividedEventfile] = NLX_DivideEventfile(cutEventfile,startTrialEvent,stopTrialEvent);

% Read the NSE spike file
[spikeArray] = NLX_ReadNSEFileShort(spikeFileName);
selectedCell = (spikeArray(:,2)==4);
spikeArray = spikeArray(selectedCell,:);


dividedSpikeArray = NLX_DivideSpikeArray(spikeArray,dividedEventfile);

% [SampleArray,SampleRate] = NLX_ReadCSCFile(LFP_fileName);
% [dividedSampleArray] = NLX_DivideCSCArray(SampleArray,DividedEventfile);


%% Analyze 
