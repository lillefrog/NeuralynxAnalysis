



addpath(genpath('H:\GitHub\NeuralynxAnalysis\'));


FName = 'C:\Dropbox\temp\TFT_2014-05-23_17-52-13\Events.Nev';

[AutomaticEvents,ManualEvents] = NLX_ReadEventFile(FName);



%% Divide eventfile

StartEvent = 255;
StopEvent = 254;

StartEventArr = find(AutomaticEvents(:,3) == StartEvent);
StopEventArr = find(AutomaticEvents(:,3) == StopEvent);

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
    disp('Warning: The number of start and stop events are unequal, some trials will be lost');
end

TRIAL = 0;
for i = 1:length(StartEventArr)
    NextStop = find(StopEventArr(:)>StartEventArr(i),1,'first');
    if ((i<length(StartEventArr)) && (StartEventArr(i+1)<StopEventArr(NextStop)))   % if the next end trial are after the next start trial
        disp(['SkipTrial: ',num2str(i)]);
    elseif isempty(NextStop)   % if there is no next end trial
        disp(['SkipTrial: ',num2str(i)]);
    else
        TRIAL = TRIAL + 1;
        MyData{TRIAL} = AutomaticEvents(StartEventArr(i):StopEventArr(NextStop),:);
    end
end
        
   


Z = [StartEventArr,StopEventArr];

% function [NLXFile] = NLX_LoadAndCutCSCFile(NLXFileName,TimeStart,TimeStop);
% 
% function NLX_GetTimestampFromEvent(EventList,EventName);