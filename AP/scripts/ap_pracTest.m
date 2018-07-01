function theData = ap_pracTest(thePath,listName,S,block,saveName)

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


%% Read the input file
subDir = fullfile(thePath.orderfiles, S.subID);
cd(subDir);
theList = read_table(listName);
theData.index = theList.col1;
theData.block = theList.col2;
theData.cond = theList.col3;
theData.term = theList.col4;
theData.ForS = theList.col5;
theData.condID = theList.col6;
theData.wordID = theList.col7;
theData.wordName = theList.col8;
theData.imgID = theList.col9;
theData.imgName = theList.col10;
theData.imgFile = theList.col11;
theData.imgType = theList.col12;
theData.subType = theList.col13;

listLength = length(theData.index);


%% Trial Outline
stimTime = 4;
nullTime = 8;

leadIn = 10;
leadOut = 10;

%% Screen commands and device specification
Window = S.Window;
myRect = S.myRect;

% get center and box points
xcenter = myRect(3)/2;
ycenter = myRect(4)/2;

% get cursor out of the way
SetMouse(0,myRect(4));

Screen(Window,'FillRect', S.screenColor);
Screen(Window,'Flip');

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
message = ['PRACTICE\nTEST BLOCK ' num2str(block)];
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
[catChoiceheight catChoicewidth crap] = size(pic);
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
goTime = 0;

% Show fixation (lead-in)
goTime = goTime + leadIn;
Screen(Window,'FillRect', S.screenColor);
Screen(Window, 'DrawTexture', fix);
Screen(Window,'Flip');
recordKeys(startTime,goTime,kbNum);

cd(S.subData); % for saving data

% Loop through stimulus trials
for Trial = 1:listLength
    if (theData.block(Trial)==block)
        
        goTime = goTime + stimTime;
        theData.onset(Trial) = GetSecs - startTime;
        
        keys = {'NR'};
        RT = 0;
        
        % Blank
        Screen(Window,'FillRect', S.screenColor);
        
        % Display empty box prompting category choice
        destRect = [xcenter-catChoicewidth/2 ycenter-catChoiceheight/2 xcenter+catChoicewidth/2 ycenter+catChoiceheight/2];
        Screen('DrawTexture',Window,catChoicePtr,[],destRect);
        
        % Draw word
        word = theData.wordName{Trial}(3:end);
        DrawFormattedText(Window,word,'center',ycenter-(catChoiceheight/2+50),S.textColor);
        
        theData.wordShown{Trial} = word;
        Screen(Window,'Flip');
        
        % Collect responses during stimulus presentation
        [keys RT] = recordKeys(startTime,goTime,S.boxNum);
        
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
        
        theData.stimResp{Trial} = keys;
        theData.stimRT{Trial} = RT;
        theData.stimCodedResp{Trial} = codedResp;
        theData.corrResp{Trial} = theData.cond{Trial};
        theData.stimCodedResp_conf{Trial} = codedResp_conf;
        corrResp = strread(theData.cond{Trial},'%s','delimiter','_');
        theData.corrResp{Trial} = corrResp(1);
        
        % Present fixation during ITI
        goTime = goTime + nullTime;
        Screen(Window,'FillRect', S.screenColor);
        Screen(Window, 'DrawTexture', fix);
        Screen(Window,'Flip');
        
        % Collect responses during stimulus presentation
        [keys RT] = recordKeys(startTime,goTime,S.boxNum);
        
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
        
        % Save to mat file
        matName = [saveName '.mat'];
        cmd = ['save ' matName];
        eval(cmd);
    end
end

% Show fixation (lead-out)
goTime = goTime + leadOut;
Screen(Window,'FillRect', S.screenColor);
Screen(Window, 'DrawTexture', fix);
Screen(Window,'Flip');
recordKeys(startTime,goTime,kbNum);

% % Affective State questions, via analog scale
% S.Questgroup = ['block',num2str(block)]; % version of questionnaires
% S.QuestscaFlag = 0; % Have runQuest close screen and clear vars when done? (NO)
% S.affectstate_params = {'ShockBlockparams'}; % for end of block assessment
% [theData.Questp,theData.Questsession,theData.Questpars] = ...
%     runQuestionnaires(S.affectstate_params,S.study_name,S.subID,S.Questgroup,...
%     S.screenNumber,S,S.QuestscaFlag,thePath);

Screen(Window,'FillRect', S.screenColor);
Screen(Window,'Flip');

Priority(0);
end

