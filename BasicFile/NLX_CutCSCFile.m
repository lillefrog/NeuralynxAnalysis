function [SampleArray,SampleRate] = NLX_CutCSCFile(FName,TStart,TStop)
% Reads continuously sampled files from Neuralynx .ncs files and returns a
% array of timestamps and samples.
%
% Input:
%  FName : Filename of a .ncs data file
%  TStart : Timestamp telling us where to start reading
%  TStop : Timestamp telling us where to stop reading 
% 
% Output:
%  SampleArray : array of timestamps in yS and Samples in yV (A lot of the timestamps are interpolated)
%  SampleRate : sample rate for the first sample in the file (Should be the same for all samples but that is not guaranteed)

 % if no filename is given ask for one
 if nargin<1 || isempty(FName);
    [fileName,filePath] = uigetfile('*.*','open a .ncs data file','MultiSelect','off'); 
    FName = fullfile(filePath,fileName);
 end
 
 % make sure that the file exist
 if ~exist(FName,'file')
    error('FileChk:FileNotFound',['CSC file not found: ',FName]);
 end
 
 % if there are no start and stop time supplied we set them to read
 % all possible timestamps
 if nargin<2 ; 
    TStart = 0; % lowest possible time
    TStop = 2^62; % Higest possible timestamp
 end
  
 % Set how and what to read from the file
 FieldSelection(1) = 1; % TimeStamps
 FieldSelection(2) = 0; % ChanNum
 FieldSelection(3) = 1; % SampleFrequencies
 FieldSelection(4) = 1; % NumberValidSamples
 FieldSelection(5) = 1; % Samples
 GetHeader = 1;
 ExtractMode = 4;

 % read the file
 [TimeStamps, SampleFrequencies, NumberValidSamples, Samples, NlxHeader] = Nlx2MatCSC(FName,FieldSelection,GetHeader,ExtractMode,[TStart,TStop]);

 % read the voltage setting from the header
 VoltPosition = strncmp(NlxHeader,'-ADBitVolts',10);
 ADBitVolts = str2double( NlxHeader{VoltPosition}(12:end) );
 
 % neuralynx only saves one timestamp for each 512 samples so we have to
 % interpolate the remaining timestamps. 
 NumberOfSamples = 1; 
 Data=zeros(length(TimeStamps)*NumberValidSamples(1),2); % initialize dataset
 for i = 1:length(TimeStamps)
    TimeStamps(i);
    Samp = Samples(1:NumberValidSamples(i),i) * 1e6 * ADBitVolts; % convert the sample to yV
    TimePrSample = 1000000/SampleFrequencies(i);
    TimeStampInterpolated = round(TimeStamps(i) + ((0:NumberValidSamples(i)-1)'*TimePrSample)); % Interpolate timestamps
    Data(NumberOfSamples:(NumberOfSamples+NumberValidSamples(i)-1),:) = [TimeStampInterpolated,Samp];
    NumberOfSamples = NumberOfSamples+NumberValidSamples(i);
 end

 % select the outputs
 SampleArray = Data;
 SampleRate = SampleFrequencies(1);

