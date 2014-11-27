function [selectedEventArray] = NLX_SelectEvents(manualEvents,promtText)
% This function takes a array of manual events and asks the user to select
% one or more of them. All the selected events are returned in and array
% of events.
%
%
% Input: 
%  manualEvents : events from the NLX_ReadEventFile function (N,3 of cell)
%  promtText :  you can add a promt text if you want but if not it will just
%               use the default "Select events:"
%
% output:
%  selectedEventArray: same as input execpt only containing the selected
%  events


if nargin<2 || isempty(promtText);
    promtText = 'Select events:';
end

EventStrings = manualEvents(:,3);

% Select events
[Selection1,ok1] = listdlg('PromptString',promtText,...
                'SelectionMode','multiple',...
                'ListString',EventStrings); 

% make sure that the dialog is closed before ending           
drawnow;

selectedEventArray = manualEvents(Selection1,:);               

