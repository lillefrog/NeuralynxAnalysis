function [automaticEvents,manualEvents] = NLX_ReadEventFile(fName)
% Reads the event file 'Events.Nev' for neuralynx analysis and return two lists.
% One contaning all the automaticly generated events that Neuralynx saves
% whenever it recives a TTL signal from cortec. And one contaning all the
% events generated by the user manually entering events in Neuralynx.
% All automatic events with the TTL code of 0 is removed since they are
% used as resets and don't actually encode anything.
%
% Input:
%  fName : Filename of a neuralynx events file (.nev)
%
% Output:
%  automaticEvents :    array of automaticly generated events consisting of a
%                       timestamp and TTL code
%  manualEvents:        CELL array containing timestamp, event_ID and EventString
%



% If no filename is supplied, ask for one
 if nargin<1 || isempty(fName);
    [fileName,filePath] = uigetfile('*.*','open a Event.Nev data file','MultiSelect','off'); 
    fName = fullfile(filePath,fileName);
 end

if ~exist(fName,'file')
    error('FileChk:FileNotFound',['Event file not found: ',strrep(fName,'\','/')]);
end
 
% Read the file
[timeStamps, event_ID, nTTLs, eventStrings, Header] = Nlx2MatEV( fName, [1 1 1 0 1],1,1,1); % [timeStamps, EventIDs, nTTLs, Extras, eventStrings, Header]

% Timestamps : the time of the event in NLX time
% EventIDs : Type of event, is 0 for all automatic events and 4 for manual
% nTTLs : Neuralynx TTL signal, code sent from cortex
% Extras : Codes that can be assigned later never used until now
% eventStrings : Cell contaning the original saved string
% Header : The header from the NEV file

% rotate the data arrays
timeStamps = timeStamps';
event_ID = event_ID';
nTTLs = nTTLs';

%% work on the automatic data (Events generated by Neuralynx)
automatic = (event_ID<2); % select all automatic events (it seems they can be coded with 0 or 1)
data = [timeStamps,event_ID,nTTLs]; % combine data into one array
automaticEvents = data(automatic,[1,3]); % Extract all automatic events
zeroEvents = (automaticEvents(:,2)==0); % Select all event that has 0 as the TTL code
automaticEvents = automaticEvents(~zeroEvents,:); % Remove all zero events

%% Work on the manual data (Events generated by manually entering events);
mandata = data(~automatic,1:2);  % Get all events that are not automatic
manualEvents = num2cell(mandata); % Convert them to cells so we can add the strings
manualStr = eventStrings(~automatic); % Select the coresponding strings
manualEvents = [manualEvents,manualStr]; % combine them in one cell array


