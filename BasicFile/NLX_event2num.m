function [num] = NLX_event2num(event)
% Function for converting NLX text events to integers, Theses events are
% defined in the cortex files (mostly AL_CODES.STT and AT_CODES.STT) so it
% is possible to redifine these and if you do that this code will of course
% not work.
%
% input
% event = string containing the name of the event f.eks. 'NLX_RECORD_START' 
%
% output 
% num = integer between 0 and 255. returns -1 if the event is not found


%%

num =  -1;

switch event
    % custom NLX events       
    case 'NLX_RECORD_START'  ; num =    2;       
    case 'NLX_SUBJECT_START' ; num =    4; 
    case 'NLX_STIM_ON'       ; num =    8;   
    case 'NLX_EVENT_3'       ; num =   11; 
    case 'NLX_EVENT_4'       ; num =   12;
    case 'NLX_EVENT_5'       ; num =   13;
    case 'NLX_EVENT_6'       ; num =   14;
    case 'NLX_EVENT_7'       ; num =   15;
    case 'NLX_STIM_OFF'      ; num =   16;  
    case 'NLX_TESTDIMMED'    ; num =   17;
    case 'NLX_DISTDIMMED'    ; num =   18;
    case 'NLX_BARRELEASED'   ; num =   19;
    case 'NLX_CUE_ON'        ; num =   20;
    case 'NLX_CUE_OFF'       ; num =   21;
    case 'NLX_DIST1DIMMED'   ; num =   22;
    case 'NLX_DIST2DIMMED'   ; num =   23;
    case 'NLX_SACCADE_START' ; num =   24;  
    case 'NLX_FIXSPOT_OFF'	 ; num =   29;  
    case 'NLX_SUBJECT_END'   ; num =   32;     
    case 'NLX_RECORD_END'    ; num =   64; 
    case 'NLX_TARG_REL'      ; num =  104; 
    case 'NLX_DIST_REL_RF'   ; num =  105; 
    case 'NLX_DIST_REL_OUT1' ; num =  106; 
    case 'NLX_DIST_REL_OUT2' ; num =  107; 
    case 'NLX_NO_RELEASE'    ; num =  108;
    case 'NLX_FIX_BREAK'     ; num =  109;
    case 'NLX_EARL_REL'      ; num =  110; 
    case 'NLX_READ_DATA'     ; num =  128;   
    case 'NLX_STIMPARAM_END'    ; num =  250;   
    case 'NLX_STIMPARAM_START'  ; num =  251; 
    case 'NLX_TRIALPARAM_END'   ; num =  252;
    case 'NLX_TRIALPARAM_START' ; num =  253;        
    case 'NLX_TRIAL_END'        ; num =  254; 
    case 'NLX_TRIAL_START'      ; num =  255; 
  
    otherwise
        error(['Event ', event, ' not found']);
end



