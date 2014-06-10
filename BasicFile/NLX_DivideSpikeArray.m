function [dividedSpikeArray] = NLX_DivideSpikeArray(spikeArray,dividedEventfile)
% Split a Spike file by events in a divided event file 

 nTrials = length(dividedEventfile);
 dividedSpikeArray = cell(1,nTrials); % initialize

 % get the start and stop times from each event trial and use them to
 % select any continous sampled data within that time frame. Any other data
 % is ignored.
 for i=1:nTrials
  startTime = min(dividedEventfile{i}(:,1));
  stopTime = max(dividedEventfile{i}(:,1));
  withinTime = (spikeArray(:,1)>startTime) & (spikeArray(:,1)<stopTime);
  dividedSpikeArray{i} = spikeArray( withinTime,:);
end