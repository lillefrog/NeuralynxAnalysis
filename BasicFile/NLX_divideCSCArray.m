function [dividedSampleArray] = NLX_DivideCSCArray(sampleArray,dividedEventfile)
% Split a CSC file by events in a divided event file 

 nTrials = length(dividedEventfile);
 dividedSampleArray = cell(1,nTrials); % initialize

 % get the start and stop times from each event trial and use them to
 % select any continous sampled data within that time frame. Any other data
 % is ignored.
 for i=1:nTrials
  startTime = min(dividedEventfile{i}(:,1));
  stopTime = max(dividedEventfile{i}(:,1));
  withinTime = (sampleArray(:,1)>startTime) & (sampleArray(:,1)<stopTime);
  dividedSampleArray{i} = sampleArray( withinTime,:);
end