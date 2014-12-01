function [num] = CTX_event2num(event)
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
    % default CTX events 
    case 'NOCODE'                      ; num =    0; 
    case 'SPIKE1'                      ; num =    1; 
    case 'SPIKE2'                      ; num =    2; 
    case 'REWARD'                      ; num =    3; 
    case 'BAR_UP'                      ; num =    4; 
    case 'BAR_LEFT'                    ; num =    5; 
    case 'BAR_RIGHT'                   ; num =    6; 
    case 'BAR_DOWN'                    ; num =    7; 
    case 'FIXATION_OCCURS'             ; num =    8; 
    case 'START_INTER_TRIAL'           ; num =    9;
    case 'END_INTER_TRIAL'            ; num =    10;
    case 'START_WAIT_FIXATION'        ; num =    11; 
    case 'END_WAIT_FIXATION'          ; num =    12;
    case 'START_WAIT_LEVER'           ; num =    13;
    case 'END_WAIT_LEVER'             ; num =    14;
    case 'START_PRE_TRIAL'            ; num =    15;
    case 'END_PRE_TRIAL'              ; num =    16;
    case 'START_POST_TRIAL'           ; num =    17;
    case 'END_POST_TRIAL'             ; num =    18;
    case 'START_PAUSE'                ; num =    19;
    case 'END_PAUSE'                  ; num =    20;
    case 'START_RANDOM_PAUSE'         ; num =    21;
    case 'END_RANDOM_PAUSE'           ; num =    22;
    case 'TURN_TEST0_ON'              ; num =    23;
    case 'TURN_TEST0_OFF'             ; num =    24;
    case 'TURN_TEST1_ON'              ; num =    25;
    case 'TURN_TEST1_OFF'             ; num =    26;
    case 'TURN_TEST2_ON'              ; num =    27;
    case 'TURN_TEST2_OFF'             ; num =    28;
    case 'TURN_TEST3_ON'              ; num =    29;
    case 'TURN_TEST3_OFF'             ; num =    30;
    case 'TURN_TEST4_ON'              ; num =    31;
    case 'TURN_TEST4_OFF'             ; num =    32;
    case 'TURN_TEST5_ON'              ; num =    33;
    case 'TURN_TEST5_OFF'             ; num =    34;
    case 'TURN_FIXSPOT_ON'            ; num =    35;
    case 'TURN_FIXSPOT_OFF'           ; num =    36;
    case 'START_FIXSPOT_DIM'          ; num =    37;
    case 'START_UP_LEVER'             ; num =    38;
    case 'END_UP_LEVER'               ; num =    39;
    case 'START_LEFT_LEVER'           ; num =    40;
    case 'END_LEFT_LEVER'             ; num =    41;
    case 'START_RIGHT_LEVER'          ; num =    42;
    case 'END_RIGHT_LEVER'            ; num =    43;
    case 'START_EYE1'                 ; num =    44;
    case 'END_EYE1'                   ; num =    45;
    case 'START_EYE2'                 ; num =    46;
    case 'END_EYE2'                   ; num =    47;
    case 'TURN_TEST6_ON'              ; num =    48;
    case 'TURN_TEST6_OFF'             ; num =    49;
    case 'TURN_TEST7_ON'              ; num =    50;
    case 'TURN_TEST7_OFF'             ; num =    51;
    case 'TURN_TEST8_ON'              ; num =    52;
    case 'TURN_TEST8_OFF'             ; num =    53;
    case 'TURN_TEST9_ON'              ; num =    54;
    case 'TURN_TEST9_OFF'             ; num =    55;
    case 'START_SCROLL_BITMAP_TEST0'  ; num =    56; 
    case 'END_SCROLL_BITMAP_TEST0'    ; num =    57; 
    case 'START_SCROLL_BITMAP_TEST1'  ; num =    58; 
    case 'END_SCROLL_BITMAP_TEST1'    ; num =    59;
    case 'START_SCROLL_BITMAP_TEST2'  ; num =    60; 
    case 'END_SCROLL_BITMAP_TEST2'    ; num =    61;
    case 'START_SCROLL_BITMAP_TEST3'  ; num =    62; 
    case 'END_SCROLL_BITMAP_TEST3'    ; num =    63;
    case 'START_SCROLL_BITMAP_TEST4'  ; num =    64; 
    case 'END_SCROLL_BITMAP_TEST4'    ; num =    65;
    case 'START_SCROLL_BITMAP_TEST5'  ; num =    66; 
    case 'END_SCROLL_BITMAP_TEST5'    ; num =    67;
    case 'START_SCROLL_BITMAP_TEST6'  ; num =    68; 
    case 'END_SCROLL_BITMAP_TEST6'    ; num =    69;
    case 'START_SCROLL_BITMAP_TEST7'  ; num =    70; 
    case 'END_SCROLL_BITMAP_TEST7'    ; num =    71;
    case 'START_SCROLL_BITMAP_TEST8'  ; num =    72; 
    case 'END_SCROLL_BITMAP_TEST8'    ; num =    73;
    case 'START_SCROLL_BITMAP_TEST9'  ; num =    74; 
    case 'END_SCROLL_BITMAP_TEST9'    ; num =    75;
    case 'START_SCROLL_SCREEN_TEST0'  ; num =    76; 
    case 'END_SCROLL_SCREEN_TEST0'    ; num =    77;
    case 'START_SCROLL_SCREEN_TEST1'  ; num =    78; 
    case 'END_SCROLL_SCREEN_TEST1'    ; num =    79;
    case 'START_SCROLL_SCREEN_TEST2'  ; num =    80; 
    case 'END_SCROLL_SCREEN_TEST2'    ; num =    81;
    case 'START_SCROLL_SCREEN_TEST3'  ; num =    82; 
    case 'END_SCROLL_SCREEN_TEST3'    ; num =    83;
    case 'START_SCROLL_SCREEN_TEST4'  ; num =    84; 
    case 'END_SCROLL_SCREEN_TEST4'    ; num =    85;
    case 'START_SCROLL_SCREEN_TEST5'  ; num =    86; 
    case 'END_SCROLL_SCREEN_TEST5'    ; num =    87;
    case 'START_SCROLL_SCREEN_TEST6'  ; num =    88; 
    case 'END_SCROLL_SCREEN_TEST6'    ; num =    89;
    case 'START_SCROLL_SCREEN_TEST7'  ; num =    90; 
    case 'END_SCROLL_SCREEN_TEST7'    ; num =    91;
    case 'START_SCROLL_SCREEN_TEST8'  ; num =    92; 
    case 'END_SCROLL_SCREEN_TEST8'    ; num =    93;
    case 'START_SCROLL_SCREEN_TEST9'  ; num =    94; 
    case 'END_SCROLL_SCREEN_TEST9'    ; num =    95;
    case 'REWARD_GIVEN'               ; num =    96;
    case 'START_EXTRA_LEVER'          ; num =    97;
    case 'END_EXTRA_LEVER'            ; num =    98;
    case 'BAR_EXTRA'                  ; num =    99;
    case 'START_EYE_DATA'             ; num =   100;
    case 'END_EYE_DATA'               ; num =   101;
    % 102 Old Spike Code
    % 103 Old Spike Code
    
    % custom CTX events       
    case 'TRIALPARAM_START'          ; num =  300;
    case 'TRIALPARAM_END'            ; num =  301;
    case 'STIMPARAM_START'           ; num =  302;
    case 'STIMPARAM_END'             ; num =  303;
    case 'STIM_SWITCH'               ; num =  304;
    case 'REWARDPARAM_START'         ; num =  305;
    case 'REWARDPARAM_END'           ; num =  306;
    case 'CUE_ON'                    ; num = 4000;
    case 'STIM_ON'                   ; num = 4001;
    case 'TEST_DIMMED'               ; num = 4002;
    case 'DIST_DIMMED'               ; num = 4003;
    case 'DIST1_DIMMED'              ; num = 4004;
    case 'DIST2_DIMMED'              ; num = 4005;
    case 'DIMMING1'                  ; num = 4006;
    case 'DIMMING2'                  ; num = 4007;
    case 'DIMMING3'                  ; num = 4008;
    case 'MICRO_STIM'                ; num = 4009;
    case 'FIXSPOT_OFF'               ; num = 4010;	
    case 'BAR_RELEASE_BEFORE_TEST'   ; num = 5000;
    case 'EARLY_BAR_RELEASE'         ; num = 5001;
    case 'BAR_RELEASE_ON_TEST'       ; num = 5002;
    case 'BAR_RELEASE_ON_DIST'       ; num = 5003;
    case 'LATE_BAR_RELEASE_ON_TEST'  ; num = 5004;
    case 'LATE_BAR_RELEASE_ON_DIST'  ; num = 5005;
    case 'SACCADE_ONSET'             ; num = 5006;        
    case 'BROKE_FIXATION'            ; num = 6000;
    case 'PARAMBASE'                 ; num =10000;

    otherwise
        error(['Event ', event, ' not found']);
end