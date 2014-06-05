function  [dividedEventfile] = NLX_DivideEventfile(eventFile,startEvent,stopEvent)
% Takes an automatic event file from NLX_ReadEventFile and divides
% all the events based on a start and stop event. Only event
% preceded by a start event and followed by a stop event will be included.
% Events before the first start event and after the last stop event will be
% discarded. If there is a start or stop event missing the data belonging
% to that trial will also be ignored.
%
% Input:
%  eventFile : Event file from NLX_ReadEventFile (N*2 array of double)
%  startEvent : TTL code for the start of a trial (often 255) 
%  stopEvent : TTL code for the End of a trial (often 254)
%
% Output:
%  dividedEventfile : A cell array contaning event arrays

% Find all the start and stop events
StartEventArr = find(eventFile(:,2) == startEvent);
StopEventArr = find(eventFile(:,2) == stopEvent);

% Trow an error if there are no start or stop events
if isempty(StartEventArr)
    disp(['warning: Start event not found! (EventCode = ' ,num2str(startEvent), ')'] );
    error('ResultChk:IncompleteData',['warning: Start event not found! (EventCode = ' ,num2str(startEvent), ')']);
end

if isempty(StopEventArr)
    disp(['warning: Stop event not found! (EventCode = ' ,num2str(stopEvent), ')'] );
    error('ResultChk:IncompleteData',['warning: Stop event not found! (EventCode = ' ,num2str(stopEvent), ')']);
end


% check if there are equal numbers of start and stop events
if (size(StartEventArr)~=size(StopEventArr))
    % here we only trow a warning since we still have data
    disp('Warning: The number of start and stop events are unequal, some trials will be lost');
end

% Divide the data 
TRIAL = 0;
for i = 1:length(StartEventArr)
    NextStop = find(StopEventArr(:)>StartEventArr(i),1,'first');
    if ((i<length(StartEventArr)) && (StartEventArr(i+1)<StopEventArr(NextStop)))   % if the next end trial are after the next start trial
        disp(['Trial Number: ',num2str(i),'is missing a stop event, Trial Skipped']);
    elseif isempty(NextStop)   % if there is no next end trial
        disp(['Trial Number: ',num2str(i),'is missing a stop event, Trial Skipped']);
    else
        TRIAL = TRIAL + 1;
        dividedEventfile{TRIAL} = eventFile(StartEventArr(i):StopEventArr(NextStop),:);
    end
end