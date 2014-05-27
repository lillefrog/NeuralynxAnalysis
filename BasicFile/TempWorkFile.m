



addpath(genpath('H:\GitHub\NeuralynxAnalysis\'));


FName = 'C:\Dropbox\temp\TFT_2014-05-23_17-52-13\Events.Nev';
[AutomaticEvents,ManualEvents] = NLX_ReadEventFile(FName);



function [NLXFile] = NLX_LoadAndCutCSCFile(NLXFileName,TimeStart,TimeStop);

function NLX_GetTimestampFromEvent(EventList,EventName);