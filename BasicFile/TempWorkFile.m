



addpath(genpath('H:\GitHub\NeuralynxAnalysis\'));
cd('H:\GitHub\NeuralynxAnalysis\');


cd('E:\Documents\GitHub\Matlab\BasicFile\');

%%
FName = 'C:\Dropbox\temp\TFT_2014-05-23_17-52-13\Events.Nev';
FName2 = 'C:\Dropbox\temp\TFT_2014-05-23_17-52-13\LFP1.ncs';
% 
FName = 'C:\Dropbox\temp\CRT_2014-05-23_17-37-02\Events.Nev';
FName2 = 'C:\Dropbox\temp\CRT_2014-05-23_17-37-02\LFP1.ncs';

[AutomaticEvents,ManualEvents] = NLX_ReadEventFile(FName);

StartEvent = 255;
StopEvent = 254;

[DividedEventfile] = NLX_DivideEventfile(AutomaticEvents,StartEvent,StopEvent);

[SampleArray,SampleRate] = NLX_CutCSCFile(FName2);




%% divide the CSC file based on events

for i=1:length(DividedEventfile)
  startTime = min(DividedEventfile{i}(:,1));
  stopTime = max(DividedEventfile{i}(:,1));
  WithinTime = (SampleArray(:,1)>startTime) & (SampleArray(:,1)<stopTime);
  splitCSCArray{i} = SampleArray( WithinTime,:);
end

figure
i=1;
startTime = min(DividedEventfile{i}(:,1));
plot(splitCSCArray{i}(:,1)-startTime,splitCSCArray{i}(:,2));
hold on
Event50 = (DividedEventfile{i}(:,2) == 50);
plot(DividedEventfile{i}(Event50,1)-startTime,DividedEventfile{i}(Event50,2),'.k');
plot(DividedEventfile{i}(~Event50,1)-startTime,DividedEventfile{i}(~Event50,2),'.r');
xlim([1,1000000]);
hold off

%% divide the Spike file based on events


        
   


