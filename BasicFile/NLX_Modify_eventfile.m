function NLX_Modify_eventfile(EventFileName,OutputFilename)
% This function can either add or modify an event in a neuralynx event
% file. Unless you specify a output filename the function will save the
% file as "new_EventFileName". If you do not input a EventFileName it will
% let you browse to select one.
%
% If you select to create a new event it will use the selected event as a
% default value and just change the text and add 10 to the timestamp.
%
% This function requires 'Nlx2MatEV' and Mat2NlxEV


%% settings (do not touch)
AppendFile = 0; % do not appent to the original file
ExtractMode = 1; % extract entire file
FieldSelectionIn = [1 1 1 1 1]; % what fields should be loaded
FieldSelectionOut = [1 1 1 1 1 1]; % what fields should be saved
ExtractHeader = 1; % extract the file header
ExtractModeArray = 1; % not used with ExtractMode = 1;

%% select file
 if nargin<2 || isempty(EventFileName);
    [fName,fPath] = uigetfile('*.nev','open a event data file','MultiSelect','off');  
    if (fName==0) % if no filename is returned we exit the program
        return
    end
    EventFileName = fullfile(fPath,fName);
    OutputFilename = fullfile(fPath,['New_',fName]);
 end
 
%% open file
[TimeStamps, EventIDs, Ttls, Extras, EventStrings, Header] = Nlx2MatEV( EventFileName, FieldSelectionIn,ExtractHeader,ExtractMode,ExtractModeArray);

%% show all user event so user can select whtch one to modify

% make an array containing all the positions of the original array
PositionArray = 1:length(TimeStamps);

% Removes internal neuralynx events from the eventfile (very very fast)
BadEvents = strncmp('RecID:', EventStrings, 5); % files from setup 2
EventStringsShort = EventStrings(~BadEvents);
PositionArray = PositionArray(~BadEvents);

BadEvents = strncmp('Digital Lynx Parallel Input Port TTL', EventStringsShort, 10); % files from setup 3
EventStringsShort = EventStringsShort(~BadEvents);
PositionArray = PositionArray(~BadEvents);

 % generate a list of events for selecting start and stop points
 EventStringsShort = ['Start of File';EventStringsShort;'End of file'];
 PositionArray = [1,PositionArray,length(TimeStamps)];
 % Select event
 [Selection1,ok] = listdlg('PromptString','Select event to modify:',...
                'SelectionMode','single',...
                'ListString',EventStringsShort);  

 if (ok)
    Position = PositionArray(Selection1); % the position of the new/modifyed event

    choice = questdlg('Do you want to create a new event or just modify the existing event?', ...
     'Selection', ...
     'Create New','Modify','Cancel','Cancel');    

    switch choice
        case 'Create New'
          CreateEvent = true;    
          dlg_title = 'Create event';  
        case 'Modify'
          CreateEvent = false;    
          dlg_title = 'Modify event';
        case 'Cancel'
          ok = false;  
          return;
    end

    %% modify the event
    

    prompt = {'What should the new event be'};
    
    num_lines = 1;
    EventStr = EventStringsShort(Selection1);
    answer = inputdlg(prompt,dlg_title,num_lines,EventStr);
    
    if(CreateEvent)  
        EventStrings = AddPostToArray(EventStrings,Position,answer);
        TimeStamps = AddPostToArray(TimeStamps,Position,TimeStamps(Position)+10); % give it a slightly different timestamp
        EventIDs = AddPostToArray(EventIDs,Position,4); % add it as a manual event no matter what the original event was
        Ttls = AddPostToArray(Ttls,Position);
        Extras = AddPostToArray(Extras,Position);
    else
        if ~isempty(answer);    
            EventStrings(Position) = answer;
        else
             disp('error no input found');
        end
    end


%% save new event file
    if(ok)
        NumRecs = length(TimeStamps);
        Mat2NlxEV( OutputFilename, AppendFile, ExtractMode, ExtractModeArray, NumRecs, FieldSelectionOut, TimeStamps, EventIDs, Ttls, Extras, EventStrings, Header );
        disp(['File Created: ' OutputFilename]);
        disp('Remember to rename New_Events.nev to Events.nev if you need to use it with Alexs programs');
    end
 end
end % end of function


%% Supporting functions

function [OutputArray] = AddPostToArray(inputArray,Position,Value)
% Adds new 'value' to an array at 'position'. The value has to be the
% correct type for the inputArray

 if nargin<3 || isempty(Value);
  Value = inputArray(Position); 
 end

    c=false(1,length(inputArray)+1); % make an boolean array one longer than original
    c(Position) = true; % select the position to input the value
    OutputArray = inputArray;
    if( (size(inputArray,1)>1) && (size(inputArray,2)>1) ) % if the array is a matrix instead of a vector
        OutputArray(:,length(OutputArray)+1) = OutputArray(:,1);
        OutputArray(:,~c) = inputArray(:,:);
        OutputArray(c) = Value;         
    else
        OutputArray(length(inputArray)+1) = inputArray(1);
        OutputArray(~c) = inputArray;
        OutputArray(c) = Value;
    end
end
