function [result] = NLX_CutOneChannelRawFile()
% This function cuts a Neuralynx raw file and extracts only one channel. It
% can not work on multi channel files so don't even try! Only one channel
% of data will be saved correctly.

ChannelNumber = 16; % Channel to extract, first channel is ch 0.

addpath('E:\doc\Matlabfiler\Neuralynx'); % files downloaded from Neuralyx web page
addpath(genpath('E:\doc\GitHub\NeuralynxAnalysis\'));
addpath(genpath('E:\doc\GitHub\grcjdru1_Analysis\'));

% get the Filenames
[fName,fPath] = uigetfile('*.nrd','open a Neuralynx raw file','MultiSelect','off');  
InputFilename = fullfile(fPath,fName);
OutputFilename = fullfile(fPath,['cut_1Ch_',fName]);
eventFilename = fullfile(fPath,'Events.nev');

% Load the events
[~,manualEvents] = NLX_ReadEventFile(eventFilename);
[selectedEvents] = NLX_SelectEvents(manualEvents,'Select the first and last event you want to include');

% start timer
tic;

% Load the data
FieldSelectionFlags = [1 1];
HeaderExtractionFlag = 1;
ExtractMode = 4; % 1 extract all % 4 extract timestamps area
ExtractionModeVector = [selectedEvents{1,1} selectedEvents{end,1}];

disp(InputFilename);
disp('Reading the raw data, This takes a lot of time');
[Timestamps, Samples, Header] = Nlx2MatNRD( InputFilename, ChannelNumber,FieldSelectionFlags, HeaderExtractionFlag,ExtractMode, ExtractionModeVector );

% duration of the file loading
readTime = toc/60; 

disp(['Done reading in ',num2str(readTime),' min']);

dataSize = whos('Timestamps', 'Samples', 'Header')


% Try to save the data
ChannelNumber = 0;
AppendToFileFlag = 0;
ExportMode = 1; % export all
ExportModeVector = 1; % should have no effect
FieldSelectionFlags = [1 1 1];

disp('Writing the raw data, This takes a lot of time');
Mat2NlxNRD(OutputFilename, ChannelNumber, AppendToFileFlag, ExportMode,ExportModeVector, FieldSelectionFlags, Timestamps, Samples, Header);

writeTime = (toc/60)-readTime;
disp(['Done writing in ',num2str(writeTime),' min']);

result.done = true;
result.readTime = readTime;
result.writeTime = writeTime;
result.dataSize = dataSize;



