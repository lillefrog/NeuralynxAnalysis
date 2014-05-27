


function [NLXFile] = NLX_LoadAndCutCSCFile(NLXFileName,TimeStart,TimeStop);
addpath(genpath('H:\GitHub\NeuralynxAnalysis\'));

[AutomaticEvents,ManualEvents] = NLX_ReadEventFile(FName);



function NLX_GetTimestampFromEvent(EventList,EventName);