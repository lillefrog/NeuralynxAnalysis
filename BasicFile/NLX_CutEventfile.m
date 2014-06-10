function [cutEventfile] = NLX_CutEventfile(automaticEvents,manualEvents,manualStartEvent,manualStopEvent)
% Cut the automatic event file based on two manual events. 

if nargin<3 
  % if there are no selected events we ask for some
  % Select start event
  [selection1,ok1] = listdlg('PromptString','Select start event:',...
                'SelectionMode','single',...
                'ListString',manualEvents(:,3)); 
  startTime = manualEvents(selection1,1);           

  % Select stop event
  [selection2,ok2] = listdlg('PromptString','Select end event:',...
                'SelectionMode','single',...
                'ListString',manualEvents(:,3));            
  stopTime = manualEvents(selection2,1);
else
  % If there are events we get the timestamps from those  
  startTime = getBestFitTimestamp(manualEvents,manualStartEvent);
  stopTime = getBestFitTimestamp(manualEvents,manualStopEvent);
  
  % It happens that the same event is entered twice so we have to fix that
  startTime = startTime{1}; % get the first start time if there is more than one
  stopTime = stopTime{end}; % get the last stop time if there is more than one
end

% select the events that is within the timestamps
withinTime = (automaticEvents(:,1)>startTime) & (automaticEvents(:,1)<stopTime);
cutEventfile = automaticEvents( withinTime,:);
  
  
  
  
function [timestamp] = getBestFitTimestamp(manualEvents,targetEvent)
  % Search trough the manual events for the best fit and returns the timestamp 
  % for that event. Since these events are entered manually they often
  % contain minor errors like a extra trailing space or a , instead of . so
  % there is a lot of code dedicated to get around those errors
  % 
  % The function returns a cell array of the timestamps for all events that
  % fit the search function

 %targetEvent = 'grcjdru1,,,517 ON'; 
 
 % remove any trailing spaces that oftent disrupt this function
 tempEvents = deblank(manualEvents(:,3));
 tempTargetEvent = deblank(targetEvent);
 
 % check if there is a perfect fit
 pos =  strcmp(tempEvents,tempTargetEvent);
 
 if any(pos)
   perfectFit = true;
 else
   % check if there is a case insesitive fit  
   pos =  strcmpi(tempEvents,tempTargetEvent);
   perfectFit = false;
 end
 
 % Check if there is a fit if we remove special caracters
 if ~any(pos)
     tempEvents = strrep(tempEvents , '.' , ' '); % remove .
     tempTargetEvent = strrep(tempTargetEvent , '.' , ' '); % remove .
     tempEvents = strrep(tempEvents , ',' , ' '); % remove ,
     tempTargetEvent = strrep(tempTargetEvent , ',' , ' '); % remove ,
   pos =  strcmpi(tempEvents,tempTargetEvent);
 end
 
 % my last attempt is to remove all spaces in the event names
 if ~any(pos)
     tempEvents = strrep(tempEvents , ' ' , ''); % remove all spaces
     tempTargetEvent = strrep(tempTargetEvent , ' ' , ''); % remove all spaces
   pos =  strcmpi(tempEvents,tempTargetEvent);
 end
 
 % calculate the return if we have a fit
 if any(pos)
   timestamp = manualEvents(pos,1);
 else    
     % If we stille don't have a fit we give up and raise a error
     error('FileChk:FileNotFound',['Event not found: ',targetEvent]);
 end
 
 % warn the user if we didn't have a perfect fit
 if (perfectFit==false)
     temp = manualEvents(pos,3);
     disp(['WARNING: The event ''',targetEvent,''' was not found ''',temp{1},''' was used instead']);
 end  