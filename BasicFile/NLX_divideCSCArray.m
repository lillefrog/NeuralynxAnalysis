function [dividedSampleArray] = NLX_divideCSCArray(SampleArray,DividedEventfile)
% Split a CSC file by events in a divided event file 

for i=1:length(DividedEventfile)
  startTime = min(DividedEventfile{i}(:,1));
  stopTime = max(DividedEventfile{i}(:,1));
  WithinTime = (SampleArray(:,1)>startTime) & (SampleArray(:,1)<stopTime);
  splitCSCArray{i} = SampleArray( WithinTime,:);
end

dividedSampleArray = splitCSCArray;