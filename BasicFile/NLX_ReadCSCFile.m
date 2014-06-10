function [sampleArray,sampleRate] = NLX_ReadCSCFile(fName,tStart,tStop)
% Reads continuously sampled files from Neuralynx .ncs files and returns a
% array of timestamps and samples.
%
% Input:
%  fName : Filename of a .ncs data file
%  tStart : Timestamp telling us where to start reading
%  tStop : Timestamp telling us where to stop reading 
% 
% Output:
%  sampleArray : array of timestamps in yS and Samples in yV (A lot of the timestamps are interpolated)
%  sampleRate : sample rate for the first sample in the file (Should be the same for all samples but that is not guaranteed)

 % if no filename is given ask for one
 if nargin<1 || isempty(fName);
    [fileName,filePath] = uigetfile('*.*','open a .ncs data file','MultiSelect','off'); 
    fName = fullfile(filePath,fileName);
 end
 
 % make sure that the file exist
 if ~exist(fName,'file')
    error('FileChk:FileNotFound',['CSC file not found: ', strrep(fName,'\','/') ]);
 end
 
 % if there are no start and stop time supplied we set them to read
 % all possible timestamps
 if nargin<2 ; 
    tStart = 0; % lowest possible time
    tStop = 2^62; % Higest possible timestamp
 end
  
 % Set how and what to read from the file
 FieldSelection(1) = 1; % TimeStamps
 FieldSelection(2) = 0; % ChannelNumber
 FieldSelection(3) = 1; % SampleFrequencies
 FieldSelection(4) = 1; % NumberValidSamples
 FieldSelection(5) = 1; % Samples
 GetHeader = 1;
 ExtractMode = 4;

 % read the file
 [timeStamps, sampleFrequencies, numberValidSamples, samples, nlxHeader] = Nlx2MatCSC(fName,FieldSelection,GetHeader,ExtractMode,[tStart,tStop]);

 % read the voltage setting from the header
 voltPosition = strncmp(nlxHeader,'-ADBitVolts',10);
 ADBitVolts = str2double( nlxHeader{voltPosition}(12:end) );
 
 % neuralynx only saves one timestamp for each 512 samples so we have to
 % interpolate the remaining timestamps. 
 CurrentNumberOfsamples = 1; 
 data=zeros(length(timeStamps)*numberValidSamples(1),2); % initialize dataset
 for i = 1:length(timeStamps)
    timeStamps(i);
    samplesInYVolt = samples(1:numberValidSamples(i),i) * 1e6 * ADBitVolts; % convert the sample to yV
    timePrSample = 1000000/sampleFrequencies(i);
    timeStampInterpolated = round(timeStamps(i) + ((0:numberValidSamples(i)-1)'*timePrSample)); % Interpolate timestamps
    data(CurrentNumberOfsamples:(CurrentNumberOfsamples+numberValidSamples(i)-1),:) = [timeStampInterpolated,samplesInYVolt];
    CurrentNumberOfsamples = CurrentNumberOfsamples+numberValidSamples(i);
 end

 % select the outputs
 sampleArray = data;
 sampleRate = sampleFrequencies(1); % we assume that all the sample rates are the same as the first one

