function [SpikeArray] = NLX_ReadNSEFileShort(spikeFileName,onTime,offTime)
% Reads spike files from Neuralynx .nse files and returns a
% array of timestamps and cells.
%
% Input:
%  spikeFileName : Filename of a .nse data file
%  tStart : Timestamp telling us where to start reading
%  tStop : Timestamp telling us where to stop reading 
% 
% Output:
%  sampleArray : array of timestamps in yS and cell numbers from classification
%  sampleRate : sample rate for the first sample in the file (Should be the same for all samples but that is not guaranteed)

 % if no filename is given ask for one
 if nargin<1 || isempty(spikeFileName);
    [fileName,filePath] = uigetfile('*.*','open a .ncs data file','MultiSelect','off'); 
    spikeFileName = fullfile(filePath,fileName);
 end
 
 % make sure that the file exist
 if ~exist(spikeFileName,'file')
    error('FileChk:FileNotFound',['NSE file not found: ', strrep(spikeFileName,'\','/') ]);
 end
 
 % if there are no start and stop time supplied we set them to read
 % all possible timestamps
 if nargin<2 ; % no times are given Read all 
   ExtractMode = 1;
   TimeArray = [];
 else  % read spikes within timestamps
   ExtractMode = 4; 
   TimeArray = [onTime,offTime];
 end
  
 % Set how and what to read from the file
 FieldSelection(1) = 1; % TimeStamps
 FieldSelection(2) = 0; % sc Numbers
 FieldSelection(3) = 1; % Cell Number
 FieldSelection(4) = 0; % Params
 FieldSelection(5) = 0; % Data points
 GetHeader = 0;

[TimeStamps_SC,  CellNumbers] = Nlx2MatSpike(spikeFileName, FieldSelection,  GetHeader, ExtractMode, TimeArray );


SpikeArray =[ TimeStamps_SC' , CellNumbers' ];