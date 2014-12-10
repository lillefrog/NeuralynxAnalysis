function [testOut]=Read_NRD_File_CB(InputFilename,EventFilename,OutputFilename)
% Cut a rawfile at specific events and save it with Outputfilename
% This program can be run in two modes
% 1. without any inputs 
%   Read_NRD_File_CB();
%   in this case it will open dialogs asking for all the needed files
% 2. with filenames as inputs
%   Read_NRD_File_CB('C:\folder\InputFilename.nrd','C:\folder\Events.nev','C:\folder\OutputFilename.nrd');
%
% Just before cutting it will tell you how long it will take, this is of
% course only an estimate and can be much slower if the files are on a
% network drive or other slow connection. If you cancle the operation there
% it will write a command to screen that will run the cut later if you
% execute it.



%% setup

BatchProcessing = false; % if true this supresses all diaglog boxes


 if nargin<2 || isempty(InputFilename) || isempty(EventFilename);
    [fName,fPath] = uigetfile('*.*','open a CORTEX data file','MultiSelect','on');  
    InputFilename = fullfile(fPath,fName);
    EventFilename = fullfile(fPath,'Events.nev');
    OutputFilename = fullfile(fPath,['Cut_',fName]);
 end

if nargin==5
    % 
end
 
 
Block8bit = 4; % used to convert blockSize to 8bit size for function that use 8bit instead of 32bit 
 
%% Read Event file

if ~(exist(EventFilename, 'file') == 2)  % Check if we can create the output file
    error('No Event file found in directory');
end
    
[TimeStamps, ~, ~, ~, EventStrings, ~] = Nlx2MatEV(EventFilename, [1 1 1 1 1],1,1,1);

EndTime = TimeStamps(end);
FirstTime = TimeStamps(1);

% Removes internal neuralynx events from the eventfile (very very fast)
BadEvents = strncmp('RecID:', EventStrings, 5); % files from setup 2
EventStrings = EventStrings(~BadEvents);
TimeStamps = TimeStamps(~BadEvents);

BadEvents = strncmp('Digital Lynx Parallel Input Port TTL', EventStrings, 10); % files from setup 3
EventStrings = EventStrings(~BadEvents);
TimeStamps = TimeStamps(~BadEvents);

% generate a list of events for selecting start and stop points
EventStrings = ['Start of File';EventStrings;'End of file'];
TimeStamps   = [FirstTime,TimeStamps,EndTime]; %% start time is not zero !!!!!!!!!!!!!!!!!



%% Select what part of the file you want to copy

% Select start event
[Selection1,ok1] = listdlg('PromptString','Select start point:',...
                'SelectionMode','single',...
                'ListString',EventStrings); 
StartTime = TimeStamps(Selection1);               

% Select stop event
[Selection2,ok2] = listdlg('PromptString','Select end point:',...
                'SelectionMode','single',...
                'ListString',EventStrings);            
StopTime = TimeStamps(Selection2);               
   
testOut = OutputFilename;
disp(EventStrings(Selection1));
disp(EventStrings(Selection2));


% Exit if the user press cancel          
if ~(ok1 && ok2) 
    disp('Abort by user');
    return;
end          


%% My read function

% deinitions
HeaderSize = 16*1024;

% Open files
InputFile = fopen(InputFilename, 'rb', 'ieee-le');

% read header
ByteHeader = fread(InputFile, HeaderSize, 'uint8=>uint8'); 
  
  % Clean up the header
  Header2 = char(ByteHeader(1:400))';
  NewStr = strrep(Header2,'######## ',' -');
  NewStr = strrep(NewStr,'## ','-');
  NewStr = strrep(NewStr,'\','\\');
  NewStr = strrep(NewStr,char(10),'');
  Header = sprintf(NewStr) % Show header
 % testOut = Header;


  % skip past the header
  fseek(InputFile, HeaderSize, 'bof');
  % read a single block
  SampleData = fread(InputFile, 500, 'uint32=>uint32');
  % find the first 5 start codes in the data
  BlockStartIndex = find((SampleData(1:(end-1))==2048) & (SampleData(2:(end-0))==1), 5);
  % Find anything before the first start code and call it junk
  junk = BlockStartIndex(1) - 1;
  % Find the offset of the data excluding the junk
  Dataoffset  = HeaderSize + junk * Block8bit;
  % find the number of channels by calculating the distance between start
  % codes (there are 18 non data channels in each block)
  blockSize = (BlockStartIndex(2) - BlockStartIndex(1));
  disp('blockSize');
  disp(blockSize);
  disp('Dataoffset');
  disp(Dataoffset);
  
  
  NumberOfChannels = blockSize - 18;
  disp(['Number of channels: ',num2str(NumberOfChannels)]);
  
  % go to the start of the data
  fseek(InputFile, Dataoffset, 'bof');
  % read one block
  buf = fread(InputFile, blockSize, 'uint32=>uint32');

  disp(' ');
  disp('---- First sample ----');
  disp(['start code ',num2str(buf(1))]); % Start identifier (2048)
  disp(['Type code  ',num2str(buf(2))]);  % type (1)
  disp(['Data Size  ',num2str(buf(3))]);  % size (usually NumberOfChannels+10);
  disp(['timestamp high ',num2str(buf(4))]);  % timestamp high
  disp(['timestamp low  ',num2str(buf(5))]); % timestamp low
  disp(['Status code    ',num2str(buf(6))]); % status
  disp(['paralell port  ',num2str(buf(7))]); % paralell port
  TimestampFirst = GetTimestampAtPos(InputFile, Dataoffset);
  disp(['Time ',num2str(TimestampFirst)]);
  disp('---- End First sample ----');
  
  if (StartTime == 0)
      StartTime = TimestampFirst;
  end;
  

  % check the file size
  fseek(InputFile, 0, 'eof');
  SamplesInFile = floor((ftell(InputFile)-Dataoffset)/(blockSize*4));
  disp(' ');
  disp(['Number of Samples ',num2str(SamplesInFile)]);
  
  % go to the end of the file
  SampleOffset = (SamplesInFile-2)*blockSize*Block8bit;
  
  fseek(InputFile, Dataoffset + SampleOffset, 'bof');
  buf = fread(InputFile, blockSize*2, 'uint32=>uint32'); % read two bloks to make sure we have enough
  offset = FindBlockOffset(buf);
  if (offset ~= 0)
      fseek(InputFile, Dataoffset + SampleOffset + offset , 'bof');
      buf = fread(InputFile, blockSize, 'uint32=>uint32');
  end
      
  
  disp(' ');
  disp('---- Last sample ----');
  disp(['start code ',num2str(buf(1))]); % Start identifier (2048)
  disp(['Type code  ',num2str(buf(2))]);  % type (1)
  disp(['Data Size  ',num2str(buf(3))]);  % size (usually NumberOfChannels+10);
  disp(['timestamp high ',num2str(buf(4))]);  % timestamp high
  disp(['timestamp low  ',num2str(buf(5))]); % timestamp low
  disp(['Status code    ',num2str(buf(6))]); % status
  disp(['paralell port  ',num2str(buf(7))]); % paralell port
  TimestampLast = GetTimestampAtPos(InputFile, -501); 
  disp(['Time ',num2str(TimestampLast)]);
  disp('---- End Last sample ----');
  disp(' ');
  
  % get duration from timestamps
  SampleRate = 32556;
  DurationTime = (TimestampLast - TimestampFirst)/1000000;
  DurationReal = SamplesInFile/SampleRate; 
  disp(['Recording time from Timestamps ', num2str(DurationTime),' sec']);
  disp(['Recording Duration from samples ', num2str(DurationReal),' sec']);
  disp(['SampleRate ', num2str(SampleRate),' Hz']);
  

 %% Find the correct place to cut the file (NEW)
 
  MaxAttemps = 200;
  FileLength = ftell(InputFile);
  disp(['FileLength ',num2str(FileLength)]);
  SamplesInFile = floor((FileLength-Dataoffset)/(blockSize*4));
  disp(['SamplesInFile ',num2str(SamplesInFile)]);
  Position = 0 ; % initial position
  
 %% Find StartPosition
  
  Flexibility = 1000; % how many samples will we accept as inaccuracy
  attemps = 1;
  Stepsize =  floor(SamplesInFile/50);
  CrossedThreshold = false;
  TimeLowEnough = false;
  TimeHighEnough = false;
  
  
  CurrentTimestamp = GetTimestampAtPos(InputFile, (Position*blockSize*Block8bit) + Dataoffset); % read the timestamp
  LastPositionInFile = (SamplesInFile-2);
  while ~( TimeHighEnough && TimeLowEnough ) 
      
      % current time stamp is too small
      if (CurrentTimestamp < (StartTime-Flexibility))    
          Position = Position + Stepsize;
          TimeHighEnough = false;
      else
          TimeHighEnough = true;
          if (CrossedThreshold)
              Stepsize = ceil(Stepsize/2);
              CrossedThreshold = false;
          end
      end
      
      % current time stamp is too big
      if (CurrentTimestamp > StartTime) 
          Position = Position - Stepsize;
          TimeLowEnough = false;
      else
          TimeLowEnough = true;
          CrossedThreshold = true;
      end
        
      % Check that we don't try to read outside the file
      if(Position > LastPositionInFile) 
          Position = LastPositionInFile;
          disp('read outside file');
      end
      if(Position < Dataoffset) 
          Position = Dataoffset;
          disp('read before file');
      end
      
      % read the current timestamp
      CurrentTimestamp = GetTimestampAtPos(InputFile, (Position*blockSize*Block8bit) + Dataoffset); % read the timestamp   

      % Make sure we don't end in a infinite loop
      if (attemps > MaxAttemps)
          disp('could not find start time in file');
          break;
      end
      if (Stepsize==1)
          break;
      end;
           
      attemps = attemps +1;
  end    
  
  StartPosition = Position-1;
  CurrentTimestamp = GetTimestampAtPos(InputFile, (StartPosition*blockSize*Block8bit) + Dataoffset); % read the timestamp   

  
  disp(['attemps ',num2str(attemps)]);
  StartTimeOffset = (StartTime-CurrentTimestamp)/1000000;
  disp(['Start early ',num2str(StartTimeOffset)]);
  
  
  %% Find EndPosition
  Flexibility = 1000; % how many samples will we accept as inaccuracy
  attemps = 1;
  Stepsize =  floor(SamplesInFile/50);
  CrossedThreshold = false;
  TimeLowEnough = false;
  TimeHighEnough = false;
  
  Position = StartPosition ;%+ floor((StopTime-StartTime)*(32000/1000000));
  CurrentTimestamp = GetTimestampAtPos(InputFile, (Position*blockSize*Block8bit) + Dataoffset); % read the timestamp   
  
  while ~( TimeHighEnough && TimeLowEnough ) 
      
      % current time stamp is too small
      if (CurrentTimestamp < StopTime)    
          Position = Position + Stepsize;
          TimeHighEnough = false;
      else
          TimeHighEnough = true;
          if (CrossedThreshold)
              Stepsize = ceil(Stepsize/2);
              CrossedThreshold = false;
          end
      end
      
      % current time stamp is too big
      if (CurrentTimestamp > StopTime + Flexibility) 
          Position = Position - Stepsize;
          TimeLowEnough = false;
      else
          TimeLowEnough = true;
          CrossedThreshold = true;
      end
        
      % Check that we don't try to read outside the file
      if(Position > LastPositionInFile) 
          Position = LastPositionInFile;
          disp('read outside file');
      end
      if(Position < 0) 
          Position = 0;
          disp('read before file');
      end
      
      % read the current timestamp
      CurrentTimestamp = GetTimestampAtPos(InputFile, (Position*blockSize*Block8bit)+ Dataoffset); % read the timestamp   
      
      % Make sure we don't end in a infinite loop
      if (attemps > MaxAttemps)
          disp('could not find end time in file');
          break;
      end
      if (Stepsize==1)
          break;
      end;
           
      attemps = attemps +1;
  end 
  
  
  StopPosition = Position;
  CurrentTimestamp = GetTimestampAtPos(InputFile, (StopPosition*blockSize*Block8bit)+ Dataoffset); % read the timestamp   
  
  StartTimeOffset = (CurrentTimestamp-StopTime)/1000000;
  disp(['End Late ',num2str(StartTimeOffset)]);
  disp(['attemps ',num2str(attemps)]);
  
  disp(['file Length in samples ',num2str(StopPosition-StartPosition)]);
  LengthInBytes = (StopPosition-StartPosition)*blockSize*Block8bit;
  disp(['file Length in Mbytes ',num2str(LengthInBytes/(1024*1024))]);
  
  
   testOut = ['NLX_CutRawFileSimple(''' ,  InputFilename ,''', ''', OutputFilename ,''', ', num2str(StartPosition) ,', ', num2str(StopPosition) ,');'     ];

 disp(testOut);
 
 
 %% Write new file


if (BatchProcessing == false)
EstimatedRunTime = (LengthInBytes /(1024*1024*1024)) * (91/60) ; % 40 sec/GB
disp(['EstimatedRunTime ', num2str(EstimatedRunTime)]);
reply = questdlg(['Cutting this file will take a estimated ' num2str(EstimatedRunTime,3) ' min are you sure that you want to continue?'],...
         'Cut the file','Yes','No','No');
     if (strcmp(reply,'Yes'))
         WriteFile = true;
     else
         WriteFile = false;
     end
else
     WriteFile = true;
end


if (WriteFile && (~isempty(OutputFilename)) )
    if ~(exist(OutputFilename, 'file') == 2)  % Check if we can create the output file 
        % Open files
        InputFile = fopen(InputFilename, 'rb', 'ieee-le');
        OutputFile = fopen(OutputFilename, 'a', 'ieee-le');

        % Copy Header
        buf = fread(InputFile, HeaderSize,'uint8');
        fwrite(OutputFile,buf,'uint8');

        % Skip to the needed part of the file
        
        SkipInitialBytes = (StartPosition*blockSize*Block8bit)+ Dataoffset;
        CopyBytes = (StopPosition-StartPosition)*blockSize*Block8bit;
        fseek(InputFile, SkipInitialBytes,'cof');

        % Copy file in bites
        BiteSize =  1024*1024*1;  % 1  megabyte of data
        nrBites = double(round(CopyBytes / BiteSize)); % stupid but needed by matlab
        h = waitbar(0,'Initializing waitbar...');
        BITE = 0;
        TimerCounter = 1;
        duration = zeros(10,1);
        while (~feof(InputFile) && ((BITE*BiteSize) <= CopyBytes));   % copy until end of file or until the stop event
            tic
            buf = fread(InputFile,BiteSize);
            fwrite(OutputFile,buf);
            BITE=BITE+1;
            duration(TimerCounter) = toc;
            BitesLeft = nrBites - BITE;
            TimeLeft = int16((BitesLeft*mean(duration))/60);
            TimerCounter = TimerCounter + 1;
            if (TimerCounter == 11)
                TimerCounter = 1;
            end
            waitbar(BITE/nrBites,h,sprintf('%d of %d MB done. %d min left...',BITE,nrBites,TimeLeft))   % Update progress bar
            if ~ishandle(h) % check if the user closed the progress bar
                disp('Aborted by user');
                break;
            end
        end
        if ishandle(h) % if the progress bar still exist
            close(h); % Close progress bar
        end
        % Close files
        fclose(InputFile);
        fclose(OutputFile);
    else
        disp(['Output File already exists "',OutputFilename,'"']);
    end
end 



end
 


function timestamp = GetTimestampAtPos(InputFile, PositionInFile)
% positive values are counted from the start of the file
% negative values count back from the end of the file

      
      if (PositionInFile < 0)
          err = fseek(InputFile, PositionInFile,'eof');
      else
          err = fseek(InputFile, PositionInFile,'bof');
      end
          
                                   % go to the estimated position
      if (err == -1) 
        disp(['GetTimestampAtPos says: could not go to position ',num2str(PositionInFile)]) 
      end
      buf = fread(InputFile, 500 , 'uint32=>uint32');             % read 500 bytes just to make sure that we have enough                           % find the start of the block
      timestamp = GetTimestamp(buf);
      timestamp = double(timestamp);
end


function  timestamp = GetTimestamp(block)
 % return the first timestamp found in block as a uint64
 if~(size(block) == 0)
     correction = FindBlockOffset(block);
     ByteBlock = typecast(uint32(block),'uint8');
     ByteBlock = ByteBlock(correction+(1:24));
     NewBlock = typecast(ByteBlock,'uint32');
     timestamp = typecast(uint32([NewBlock(5) NewBlock(4)]), 'uint64');
 else
     error('GetTimestamp says: input is size 0, aborted');
 end
end


function offset = FindBlockOffset(block)
% returns 0 if the block is correct else it attemps 
% to return a correction that will give correct readings


Byte = typecast(block,'uint8'); % we read at byte level to make sure that we find byte error too

% we look for 2048 and 1 converted from uint32 to uint8 (0800 and 1000)
offset = find(    (Byte(1:(end-7))==0) ... 
                & (Byte(2:(end-6))==8) ...
                & (Byte(3:(end-5))==0) ...
                & (Byte(4:(end-4))==0) ...
                & (Byte(5:(end-3))==1) ...
                & (Byte(6:(end-2))==0) ...
                & (Byte(7:(end-1))==0) ...
                & (Byte(8:(end-0))==0) ...
               , 1,'first');
            
            
if (size(offset,1)==0)
    disp(Byte);
    error('FindBlockOffset says : No Start code found in block');
    
else
    offset=offset-1;
    if (mod(offset,4)~=0) % do we have a byte level error     
        disp('FindBlockOffset says : Byte mismatch in file');
    end
end
            
            
end

%%  
% 

% function crc = neuralynx_crc(dat, dim)
% 
% nchans   = size(dat,1);
% nsamples = size(dat,2);
% 
% crc = zeros(1,nsamples,class(dat));
% 
%  for i=1:nchans
%   crc = bitxor(crc, dat(i,:));
%  end
% end