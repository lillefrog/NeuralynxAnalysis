function  [DividedEventfile] = NLX_DivideEventfile(EventFile,StartEvent,StopEvent)
% Takes an automatic event file from NLX_ReadEventFile and divides
% all the events based on a start and stop event. Only event
% preceded by a start event and followed by a stop event will be included.
% Events before the first start event and after the last stop event will be
% discarded. If there is a start or stop event missing the data belonging
% to that trial will also be ignored.
%
% Input:
%  EventFile : Event file from NLX_ReadEventFile (N*2 array of double)
%  StartEvent : TTL code for the start of a trial (often 255) 
%  StopEvent : TTL code for the End of a trial (often 254)
%
% Output:
%  DividedEventfile : A cell array contaning event arrays

% Find all the start and stop events
StartEventArr = find(EventFile(:,2) == StartEvent);
StopEventArr = find(EventFile(:,2) == StopEvent);

% Trow an error if there are no start or stop events
if isempty(StartEventArr)
    disp(['warning: Start event not found! (EventCode = ' ,num2str(StartEvent), ')'] );
    error('ResultChk:IncompleteData',['warning: Start event not found! (EventCode = ' ,num2str(StartEvent), ')']);
end

if isempty(StopEventArr)
    disp(['warning: Stop event not found! (EventCode = ' ,num2str(StopEvent), ')'] );
    error('ResultChk:IncompleteData',['warning: Stop event not found! (EventCode = ' ,num2str(StopEvent), ')']);
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
        disp(['SkipTrial: ',num2str(i)]);
    elseif isempty(NextStop)   % if there is no next end trial
        disp(['SkipTrial: ',num2str(i)]);
    else
        TRIAL = TRIAL + 1;
        DividedEventfile{TRIAL} = EventFile(StartEventArr(i):StopEventArr(NextStop),:);
    end
end