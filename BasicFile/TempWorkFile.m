



addpath(genpath('H:\GitHub\NeuralynxAnalysis\'));
cd('E:\Documents\GitHub\Matlab\BasicFile\');

%%
FName = 'C:\Dropbox\temp\TFT_2014-05-23_17-52-13\Events.Nev';

[AutomaticEvents,ManualEvents] = NLX_ReadEventFile(FName);

StartEvent = 255;
StopEvent = 254;

[DividedEventfile] = NLX_DivideEventfile(AutomaticEvents,StartEvent,StopEvent);


FName2 = 'C:\Dropbox\temp\TFT_2014-05-23_17-52-13\CSC1.ncs';


[SampleArray,SampleRate] = NLX_CutCSCFile(FName2);

%% divide the CSC file based on events



[SampleArray,SampleRate] = NLX_CutCSCFile(FName2);



%% divide the Spike file based on events


        
   


