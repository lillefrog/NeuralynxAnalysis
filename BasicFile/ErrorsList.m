%% Errors
% list of errors I use



% FileChk:FileNotFound
% the file is not found
error('FileChk:FileNotFound',['cortex file not found: ',ctxFileName]);


% FileChk:DataNotFound
% the file is found but the data is corrupted or missing
error('FileChk:DataNotFound',['OnEvent not found in ',ctxFileName]);