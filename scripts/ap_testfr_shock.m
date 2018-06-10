function [theData, S] = ap_testfr_shock(thePath,listName,S,C,block,saveName,theData)

%% initialize rand.
rand('twister',sum(100*clock));
kbNum=S.kbNum;

%% Come up with response labels
if S.respMap == 1 || S.respMap == 3
    respCodes = {'F' 'TI' 'TI' 'TO' 'TO'};
    respCodes_conf = {'F' 'TI_Hi' 'TI_Lo' 'TO_Lo' 'TO_Hi'};
    labelReminder = 'response_mapping1.jpg';
elseif S.respMap == 2 || S.respMap == 4
    respCodes = {'F' 'TO' 'TO' 'TI' 'TI'};
    respCodes_conf = {'F' 'TO_Hi' 'TO_Lo' 'TI_Lo' 'TI_Hi'};
    labelReminder = 'response_mapping2.jpg';
end
respOpts = {'1', '2', '3', '4', '5'};
scanner_respOpts = {'1!', '2@', '3#', '4$', '6^'};

if S.scanner == 2
    theData.respOpts = respOpts;
else
    theData.respOpts = scanner_respOpts;
end

theData.respCodes = respCodes;
theData.respCodes_conf = respCodes_conf;

%% Read the input file
subDir = fullfile(thePath.orderfiles, S.subID);
wavDir = fullfile(thePath.orderfiles, S.subID, 'wav_files');
cd(subDir);
theList = read_table(listName);
theData.index = theList.col1;
theData.block = theList.col2;
theData.cond = theList.col3;
theData.shockCond = theList.col4;
theData.shockTrial = theList.col5;
theData.term = theList.col6;
theData.ForS = theList.col7;
theData.condID = theList.col8;
theData.wordID = theList.col9;
theData.wordName = theList.col10;
theData.imgID = theList.col1;
theData.imgName = theList.col12;
theData.imgFile = theList.col13;
theData.imgType = theList.col14;
theData.subType = theList.col15;
theData.numReps = theList.col16;

listLength = length(theData.index);


%% Trial Outline
stimTime = 4;
nullTime = .5;
frTime = 4; % verbal collection

leadIn = 5;
leadOut = 2;

%% Screen commands and device specification
Window = S.Window;
myRect = S.myRect;
Screen(Window,'TextSize', S.fontsize);
Screen('TextFont', Window, S.font);
Screen('TextStyle', Window, 1);

% for FR
fontsize_type = 18;
lengthLine = 40; % num characters in line

RETURN = 10;
DELETE = 8;

% get center and box points
xcenter = myRect(3)/2;
ycenter = myRect(4)/2;
yCoor_type = ycenter+200;

Screen(Window,'FillRect', S.screenColor);
Screen(Window,'Flip');

% Shock signaling
shockWarningTime = 4;
S.rect_frame = CenterRect([0 0 myRect(3) myRect(4)], Screen(S.screenNumber,'Rect'));

block_ind = find(theData.block==block, 1);
stressCond = theData.shockCond{block_ind} ;
switch stressCond
    case 'safe'
        rect_color = S.shockColor_col{2};
        text_shockCond = S.shockColor_txt{2};
    case 'threat' 
        rect_color = S.shockColor_col{1};
        text_shockCond = S.shockColor_txt{1};
end


%% Sound stuff
% Perform basic initialization of the sound driver:
InitializePsychSound;

% Open the default audio device [], with mode 2 (== Only audio capture),
% and a required latencyclass of zero 0 == no low-latency mode, as well as
% a frequency of 44100 Hz and 2 sound channels for stereo capture.
% This returns a handle to the audio device:
freq = 44100;
pahandle = PsychPortAudio('Open', [], 2, 0, freq, 2);

%% Remind subject about response options before starting

% Load reminder of key labels
cd(thePath.stim);
pic = imread(labelReminder);
labelRemind = Screen(Window,'MakeTexture', pic);

% Load blank
fileName = 'blank.jpg';
pic = imread(fileName);
blank = Screen(Window,'MakeTexture', pic);

% Print reminder
Screen(Window,'FillRect', S.screenColor);
message = ['TEST BLOCK ' num2str(block)];
DrawFormattedText(Window,message,'center',ycenter-400,S.textColor);
Screen(Window, 'DrawTexture', labelRemind);
Screen(Window,'Flip');
getKey('g',S.kbNum);

%% Pre-load images

% Load fixation
fileName = 'fix.jpg';
pic = imread(fileName);
fix = Screen(Window,'MakeTexture', pic);

% Load empty box
fileName = 'catChoice.jpg';
pic = imread(fileName);
[catChoiceheight, catChoicewidth, crap] = size(pic);
catChoicePtr = Screen(Window,'MakeTexture', pic);

%% Get everything else ready

% preallocate shit:
trialcount = 0;
for preall = C.trial_start:listLength
    if (theData.block(preall)==block)
        theData.onset(preall) = 0;
        theData.dur(preall) =  0;
        theData.stimResp{preall} = 'NR';
        theData.stimRT{preall} = 0;
        theData.stimCodedResp{preall} = 'NR';
        theData.isiResp{preall} = 'NR';
        theData.isiRT{preall} = 0;
        theData.isiCodedResp{preall} = 'NR';
        theData.wordShown{preall} = 'blank';
        theData.corrResp{preall} = 'NR';
        theData.shock(preall) = 0;
        theData.shockEventTime(preall) = 0;
        theData.time_raw(preall) = 0;
        theData.cortSample{preall} = 0;
    end
end

% get ready screen
Screen(Window,'FillRect', S.screenColor);
message = ['Get ready!'];
DrawFormattedText(Window,message,'center','center',S.textColor);
Screen(Window,'Flip');

% get cursor out of the way
SetMouse(0,myRect(4));

% initiate experiment and begin recording time...
status = 1;
while 1
    getKey('g',S.kbNum);
    if S.scanner == 1
        [status, startTime] = startScan;
    else
        status = 0;
        S.boxNum = S.kbNum;
        startTime = GetSecs;
    end
    if status == 0 % status=0 when startScan is successful
        break
    end
end

%% Start task

Priority(MaxPriority(Window));
Screen(Window,'FillRect', S.screenColor);
Screen('FrameRect', Window, rect_color, S.rect_frame, S.border_width);
DrawFormattedText(Window,text_shockCond,'center','center',S.textColor);
Screen(Window,'Flip');
recordKeys(startTime,shockWarningTime,kbNum);

goTime = 0;

% Show fixation (lead-in)
goTime = goTime + leadIn;
Screen(Window,'FillRect', S.screenColor);
Screen('FrameRect', Window, rect_color, S.rect_frame, S.border_width);
Screen(Window, 'DrawTexture', fix);
Screen(Window,'Flip');
recordKeys(startTime,goTime,kbNum);

cd(S.subData); % for saving data

% Loop through stimulus trials
for Trial = C.trial_start:listLength
% for Trial = C.trial_start:2 % for testing ONLY!!!!
    if (theData.block(Trial)==block)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % do we need to collect cortisol?
        if S.cort == 1
            % are we done sampling?
            if S.samples_taken < length(S.cort_times)
                currTime = GetSecs - S.sessionStart;
                % have we reached time to sample?
                if currTime > S.next_sample
                    % collect sample
                    Screen(Window,'FillRect', S.screenColor);
                    Screen(Window,'TextSize', S.fontsize);
                    frame_text = CenterRect([0 0 myRect(3) myRect(4)], Screen(S.screenNumber,'Rect'));
                    Screen('FrameRect', Window, [255 0 0], frame_text, S.border_width);
                    message = 'Please collect your saliva.';
                    DrawFormattedText(Window,message,'center','center',S.textColor);
                    Screen(Window,'Flip');
                    
                    theData.cortSample{Trial} = currTime; % save the time info!
                    
                    [~, ~] = recordKeys(GetSecs, S.cort_sample_time, S.boxNum);
                    
                    message = 'DONE! Press g to continue.';
                    DrawFormattedText(Window,message,'center','center',S.textColor);
                    Screen(Window,'Flip');
                    getKey('g',S.kbNum);
                    
                    % what to sample next
                    S.samples_taken = S.samples_taken + 1;
                    
                    % increment next sample
                    S.next_sample = increment_cort_sample(S.cort_times, S.samples_taken);
                end
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Jitter the shock randomly, this picks random between 1-2
        if strcmp(theData.shockCond(Trial),'threat') && S.shock_on && theData.shockTrial(Trial) == 1
            theData.shockEventTime(Trial) = randi([1 2],1,1);
%         else
%             theData.shockEventTime(Trial) = 0;
        end
        
        goTime = stimTime; % set for variable RT to free response!
        stim_startTime = GetSecs;
        theData.time_raw(Trial) = stim_startTime; 
        theData.onset(Trial) = GetSecs - startTime;
        
        keys = {'NR'};
        RT = 0;
        
        % Blank
        Screen(Window,'FillRect', S.screenColor);
        Screen('FrameRect', Window, rect_color, S.rect_frame, S.border_width);
        
        % Display empty box prompting category choice
        destRect = [xcenter-catChoicewidth/2 ycenter-catChoiceheight/2 xcenter+catChoicewidth/2 ycenter+catChoiceheight/2];
        Screen('DrawTexture',Window,catChoicePtr,[],destRect);
        
        % Draw word
        word = theData.wordName{Trial}(3:end);
        DrawFormattedText(Window,word,'center',ycenter-(catChoiceheight/2+50),S.textColor);
        
        theData.wordShown{Trial} = word;
        Screen(Window,'Flip');
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Send shock, if shock on, and threat block, and correct trial
        if strcmp(theData.shockCond(Trial),'threat') && S.shock_on &&  theData.shockEventTime(Trial) == 1
            if theData.shockTrial(Trial) == 1
                [time0, ~, ~] = trigger_shock();
                theData.shock(Trial) = time0 - startTime;
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Collect responses during stimulus presentation
        [keys, RT] = recordKeys(stim_startTime,goTime,S.boxNum);
        
        if S.scanner == 2
            codedResp = codeBehavResp(keys, respCodes, respOpts, 'last');
            codedResp_conf = codeBehavResp(keys, respCodes_conf, respOpts, 'last');
        elseif S.scanner == 1
            codedResp = 'scanner';
            codedResp_conf = 'scanner';
        end
         
        if RT < 0.001 % so that RTs of 0 will stand out if they get averaged accidentally
            RT = 999;
        end
        
        theData.stimResp{Trial} = keys;
        theData.stimRT{Trial} = RT;
        theData.stimCodedResp{Trial} = codedResp;
        theData.stimCodedResp_conf{Trial} = codedResp_conf;
        corrResp = strread(theData.cond{Trial},'%s','delimiter','_');
        theData.corrResp{Trial} = corrResp(1);
        
        if strcmp(theData.corrResp{Trial}, theData.stimCodedResp{Trial})
            theData.acc{Trial} = 1;
        else
            theData.acc{Trial} = 0;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Send shock, if shock on, and threat block, and correct trial
        if strcmp(theData.shockCond(Trial),'threat') && S.shock_on &&  theData.shockEventTime(Trial) == 2
            if theData.shockTrial(Trial) == 1
                [time0,sp,err] = trigger_shock();
                theData.shock(Trial) = time0 - startTime;
            end
        end
            
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Present TYPE! during ITI
        Screen(Window,'FillRect', S.screenColor);
        Screen('FrameRect', Window, rect_color, S.rect_frame, S.border_width);
        Screen('DrawTexture',Window,catChoicePtr,[],destRect);
        DrawFormattedText(Window,word,'center',ycenter-(catChoiceheight/2+50),S.textColor);
        DrawFormattedText(Window,'Describe','center','center',S.textColor);
        
        goTime = nullTime;
        isi_startTime = GetSecs; % for fr with shock
        Screen(Window,'Flip');
        
        % Collect responses during iti
        [keys, RT] = recordKeys(isi_startTime,goTime,S.boxNum);
        
        if S.scanner == 2
            codedResp = codeBehavResp(keys, respCodes, respOpts, 'first');
            codedResp_conf = codeBehavResp(keys, respCodes_conf, respOpts, 'first');
        elseif S.scanner == 1
            codedResp = 'scanner';
            codedResp_conf = 'scanner';
        end
        
        if RT < 0.001 % so that RTs of 0 will stand out if they get averaged accidentally
            RT = 999;
        end
        
        theData.isiResp{Trial} = keys;
        theData.isiRT{Trial} = RT;
        theData.isiCodedResp{Trial} = codedResp;
        theData.isiCodedResp_conf{Trial} = codedResp_conf;
        
        % Record trial duration
        theData.dur(Trial) = (GetSecs - startTime) - theData.onset(Trial); % duration from stim onset
        
        %% Collect FR
        trialname = [num2str(Trial), '.wav'];
        
        Screen(Window,'FillRect', S.screenColor);
        Screen('FrameRect', Window, rect_color, S.rect_frame, S.border_width);
        Screen('DrawTexture',Window,catChoicePtr,[],destRect);
        DrawFormattedText(Window,'Describe','center','center',S.textColor);
        DrawFormattedText(Window,word,'center',ycenter-(catChoiceheight/2+50),S.textColor);
        
        fr_startTime = GetSecs;
        Screen('Flip', Window);
        
        goTime = fr_startTime + frTime;
        
        % Collect Audio
        soundCapture(pahandle,['wav_files/', trialname], 0, frTime); %record audio
        KbWait([],2,goTime);
        
%         % Collect responses during stimulus presentation
%         string_spec = '';
%         FlushEvents ('keyDown');
%         ListenChar(2);
%         fr_startTime = GetSecs;
%         
%         numReturns = 0;
%         while 1
%             typedInput = GetChar;
%             switch(abs(typedInput))
%                 case{RETURN},
%                     break;
%                 case {DELETE},
%                     if ~isempty(string_spec);
%                         string_spec= string_spec(1:length(string_spec)-1);
%                         Screen('TextSize',Window);
%                         DrawFormattedText(Window,string_spec,'center',yCoor_type,S.textColorResp);
%                     end;
%                 otherwise, % all other keys
%                     string_spec= [string_spec typedInput];
%                     Screen('TextSize',Window);
%             %                     DrawFormattedText(Window,string_spec,'center',yCoor_type,S.textColorResp);
% 
%                     % new line if too long!
%                     if length(string_spec)-(numReturns*lengthLine) > lengthLine
%                         numReturns = numReturns +1;
%                         string_spec = [string_spec '\n'];
%                         DrawFormattedText(Window,string_spec,'center',yCoor_type,S.textColorResp);
%                     else
%                         DrawFormattedText(Window,string_spec,'center',yCoor_type,S.textColorResp);
%                     end;
% 
%             end;
% 
%                 %draw word & rec again
%                 Screen('FrameRect', Window, rect_color, S.rect_frame, S.border_width);
%                 DrawFormattedText(Window,word,'center',ycenter-(catChoiceheight/2+50),S.textColor);
%                 Screen('DrawTexture',Window,catChoicePtr,[],destRect);
%                 DrawFormattedText(Window,'Describe','center','center',S.textColor);
% 
%                 Screen('Flip', Window);
%                 FlushEvents(['keyDown']);
%          end
%          
%         RT = GetSecs - fr_startTime;
%         keys = string_spec;
%         
%         if RT < 0.001 % so that RTs of 0 will stand out if they get averaged accidentally
%             RT = 999;
%         end   
% 
%         theData.frResp{Trial} = keys;
%         theData.frRT{Trial} = RT;

        theData.frResp{Trial} = 'audio';
        theData.frRT{Trial} = frTime;

        
        % Save to mat file
        matName = [saveName '.mat'];
        cmd = ['save ' matName];
        eval(cmd);
    end
end

% Show fixation (lead-out)
goTime = 0; %reset again; this is unneccesary, but keep for formatting fmri version
goTime = goTime + leadOut;
Screen(Window,'FillRect', S.screenColor);
Screen(Window, 'DrawTexture', fix);
Screen(Window,'Flip');
currTime = GetSecs;
recordKeys(currTime,goTime,kbNum);

% Turn off sound
PsychPortAudio('Close', pahandle);

% Affective State questions, via analog scale
S.Questgroup = ['block',num2str(block)]; % version of questionnaires
S.QuestscaFlag = 0; % Have runQuest close screen and clear vars when done? (NO)
S.affectstate_params = {'ShockBlockparams', 'CanliArousalparams'}; % for end of block assessment
[theData.Questp,theData.Questsession,theData.Questpars] = ...
    runQuestionnaires(S.affectstate_params,S.study_name,S.subID,S.Questgroup,...
    S.screenNumber,S.boxNum,S,S.QuestscaFlag,thePath);


Screen(Window,'FillRect', S.screenColor);
Screen(Window,'Flip');

Priority(0);
end

