function theData = ap_test(thePath,listName,S,block,saveName,theData)

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
scanner_respOpts = {'1!', '2@', '3#', '4$', '5%'};

if S.scanner == 2
    theData.respOpts = respOpts;
else
    theData.respOpts = scanner_respOpts;
end

theData.respCodes = respCodes;
theData.respCodes_conf = respCodes_conf;

%% Read the input file
subDir = fullfile(thePath.orderfiles, S.subID);
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
% nullTime = 5;
iti_listName = 'iti_list_jitter_exponential_mean5_sd1.txt';
itiList = read_table(fullfile(thePath.orderfiles, iti_listName));
itiList = Shuffle(itiList.col1);

leadIn = 8; % plus 4 seconds for shockWarning
leadOut = 10;

%% Screen commands and device specification
Window = S.Window;
myRect = S.myRect;
Screen(Window,'TextSize', S.fontsize);
Screen('TextFont', Window, S.font);
Screen('TextStyle', Window, 1);

% get center and box points
xcenter = myRect(3)/2;
ycenter = myRect(4)/2;

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
[catChoiceheight, catChoicewidth, ~] = size(pic);
catChoicePtr = Screen(Window,'MakeTexture', pic);

%% Get everything else ready

% preallocate shit:
trialcount = 0;
for preall = 1:listLength
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
        [startTime,~,status,~] = trigger_scanner;
        goTime = 0;
        fprintf('Status = %d\n', status);
    else
        status = 0;
        S.boxNum = S.kbNum;
        startTime = GetSecs;
        goTime = 0;
    end
    
    if status == 0 % status=0 when startScan is successful
        break
    else
        message = 'Trigger failed, "g" to retry';
        DrawFormattedText(Window, message, 'center', 'center', S.textColor);
        Screen(Window, 'Flip');
    end
end

%% Start task
Priority(MaxPriority(Window));

% Show shock/color warning
goTime = goTime + shockWarningTime;
Screen(Window,'FillRect', S.screenColor);
Screen('FrameRect', Window, rect_color, S.rect_frame, S.border_width);
DrawFormattedText(Window,text_shockCond,'center','center',S.textColor);
Screen(Window,'Flip');
recordKeys(startTime,goTime,kbNum);

% Show fixation (lead-in)
goTime = goTime + leadIn;
Screen(Window,'FillRect', S.screenColor);
Screen('FrameRect', Window, rect_color, S.rect_frame, S.border_width);
Screen(Window, 'DrawTexture', fix);
Screen(Window,'Flip');
recordKeys(startTime,goTime,kbNum);

cd(S.subData); % for saving data

trial_counter = 0; % use this to get appropriate ITI
% Loop through stimulus trials
for Trial = 1:listLength
% for Trial = 1:1% for troubleshooting only!!
    if (theData.block(Trial)==block)
        trial_counter = trial_counter + 1;
        
        % Jitter the shock randomly, this picks random between 1-2
        if strcmp(theData.shockCond(Trial),'threat') && S.shock_on && theData.shockTrial(Trial) == 1
            theData.shockEventTime(Trial) = randi([1 2],1,1);
        end
        
        keys = {'NR'};
        RT = 0;
        
        
        %% Show stimulus
        
        % Set up screen
        % Blank
        Screen(Window,'FillRect', S.screenColor);
        Screen('FrameRect', Window, rect_color, S.rect_frame, S.border_width);

        
        % Draw word
        word = theData.wordName{Trial}(3:end);
        DrawFormattedText(Window,word,'center',ycenter-(catChoiceheight/2+50),S.textColor);
        
        theData.wordShown{Trial} = word;
        
        % Start!
        ons_start = GetSecs;
        theData.onset(Trial) = GetSecs - startTime;
        Screen(Window,'Flip');
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Send shock, if shock on, and threat block, and correct trial
        if strcmp(theData.shockCond(Trial),'threat') && S.shock_on &&  theData.shockEventTime(Trial) == 1
            if theData.shockTrial(Trial) == 1
                goTime = goTime + 2; % lag for trigger
                [time0, ~, ~] = trigger_shock();
                theData.shock(Trial) = time0 - startTime;
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        % Collect responses during stimulus presentation
        goTime = goTime + stimTime;
        [keys, RT] = recordKeys(startTime,goTime,S.boxNum);
        
        %% Code response
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
                goTime = goTime + 2; % lag for trigger
                [time0,sp,err] = trigger_shock();
                theData.shock(Trial) = time0 - startTime;
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        %% Present fixation during ITI
        Screen(Window,'FillRect', S.screenColor);
        Screen('FrameRect', Window, rect_color, S.rect_frame, S.border_width);
        Screen(Window, 'DrawTexture', fix);
        Screen(Window,'Flip');
        
        % Collect responses during iti
        goTime = goTime + itiList(trial_counter);
        [keys, RT] = recordKeys(startTime,goTime,S.boxNum);
        
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
        
        %% Save trial
        % Record trial duration
        theData.dur(Trial) = (GetSecs - startTime) - theData.onset(Trial); % duration from stim onset
        
        % Save to mat file
        matName = [saveName '.mat'];
        cmd = ['save ' matName];
        eval(cmd);
    end
end

% Show fixation (lead-out)
% goTime = 0; %reset again
goTime = goTime + leadOut;
Screen(Window,'FillRect', S.screenColor);
Screen(Window, 'DrawTexture', fix);
Screen(Window,'Flip');
recordKeys(startTime,goTime,kbNum);

% Affective State questions, via analog scale
S.Questgroup = ['block',num2str(block)]; % version of questionnaires
S.QuestscaFlag = 0; % Have runQuest close screen and clear vars when done? (NO)

S.affectstate_params = {'fMRIShockBlockparams', 'fMRICanliArousalparams'}; % for end of block assessment
try                      
    [theData.Questp,theData.Questsession,theData.Questpars] = ...
        runQuestionnaires(S.affectstate_params,S.study_name,S.subID,S.Questgroup,...
        S.screenNumber,S.boxNum,S,S.QuestscaFlag,thePath);
catch err
    outputError(thePath.data, S.subData, err);
end  

Screen(Window,'FillRect', S.screenColor);
Screen(Window,'Flip');

Priority(0);
end

