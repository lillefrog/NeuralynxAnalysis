
addpath(genpath('E:\doc\GitHub\NeuralynxAnalysis\'));



%% TFT monitor setup
eventFilename = 'E:\JonesRawData\PEN312\NLX_control\2014-06-07_07-24-14\Events.Nev';
LFP_fileName = 'E:\JonesRawData\PEN312\NLX_control\2014-06-07_07-24-14\LFP17.ncs';
spikeFileName = 'E:\JonesRawData\PEN312\NLX_control\2014-06-07_07-24-14\GRCJDRU1.517 ON_GRCJDRU1.517 OFFSE17_cb.NSE';
cortexFilename = 'E:\JonesRawData\PEN312\Cortex\140528\GRCJDRU1.517';


%% Read the files and extract the data

% Read the NLX event file and cut out the part related to our experiment
[automaticEvents,manualEvents] = NLX_ReadEventFile(eventFilename);
manualStartEvent = 'grcjdru1.517 on';
manualStopEvent = 'grcjdru1.517 off';
[cutEventfile] = NLX_CutEventfile(automaticEvents,manualEvents,manualStartEvent,manualStopEvent);
clear manualStartEvent manualStopEvent manualEvents automaticEvents

% Split the event file up in trials
startTrialEvent = 255;
stopTrialEvent = 254;
[dividedEventfile] = NLX_DivideEventfile(cutEventfile,startTrialEvent,stopTrialEvent);
clear startTrialEvent stopTrialEvent cutEventfile

% Read the NSE spike file
CELL_NUMBER = 4;
[spikeArray] = NLX_ReadNSEFileShort(spikeFileName);
isSelectedCell = (spikeArray(:,2)==CELL_NUMBER);
spikeArray = spikeArray(isSelectedCell,:);
dividedSpikeArray = NLX_DivideSpikeArray(spikeArray,dividedEventfile);
clear spikeArray isSelectedCell

% read the cortex file and align the data
[ctxData] = CTX_Read2Struct(cortexFilename);

% [SampleArray,SampleRate] = NLX_ReadCSCFile(LFP_fileName);
% [dividedSampleArray] = NLX_DivideCSCArray(SampleArray,DividedEventfile);


%% Analyze 
