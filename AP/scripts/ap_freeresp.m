function theData = ap_freeresp(thePath,listName,S,block,saveName,theData)

%% initialize rand.
rand('twister',sum(100*clock));
kbNum=S.kbNum;


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
theData.imgID = theList.col11;
theData.imgName = theList.col12;
theData.imgFile = theList.col13;
theData.imgType = theList.col14;
theData.subType = theList.col15;
theData.numReps = theList.col16;

listLength = length(theData.index);


%% Trial Outline
stimTime = 4;
nullTime = 1;

leadIn = 5;
leadOut = 5;

%% Screen commands and device specification
S.textColorResp = 255;
fontsize_type = 18;
lengthLine = 40; % num characters in line

RETURN = 10;
DELETE = 8;

Window = S.Window;
myRect = S.myRect;
Screen(Window,'TextSize', 36);
Screen('TextFont', Window, 'Helvetica');
Screen('TextStyle', Window, 1);

% get center and box points
xcenter = myRect(3)/2;
ycenter = myRect(4)/2;
yCoor_type = ycenter+200;

Screen(Window,'FillRect', S.screenColor);
Screen(Window,'Flip');

% Shock signaling
shockWarningTime = 4;
S.rect_frame = CenterRect([0 0 myRect(3) myRect(4)], Screen(S.screenNumber,'Rect'));


% directions based on stress group
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
labelReminder = 'response_freeresp.jpg';
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
for Trial = 1:listLength
    string_gen = '';
    string_spec = '';
    FlushEvents ('keyDown');
    ListenChar(2);
    
    if (theData.block(Trial)==block)
        
        goTime = goTime + stimTime;
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
        

        % Collect responses during stimulus presentation
        numReturns = 0;
        while 1
        typedInput = GetChar;
        switch(abs(typedInput))
            case{RETURN},
                break;
            case {DELETE},
                if ~isempty(string_spec);
                    string_spec= string_spec(1:length(string_spec)-1);
                    Screen('TextSize',Window);
                    DrawFormattedText(Window,string_spec,'center',yCoor_type,S.textColorResp);
                end;
            otherwise, % all other keys
                string_spec= [string_spec typedInput];
                Screen('TextSize',Window);
        %                     DrawFormattedText(Window,string_spec,'center',yCoor_type,S.textColorResp);

                % new line if too long!
                if length(string_spec)-(numReturns*lengthLine) > lengthLine
                    numReturns = numReturns +1;
                    string_spec = [string_spec '\n'];
                    DrawFormattedText(Window,string_spec,'center',yCoor_type,S.textColorResp);
                else
                    DrawFormattedText(Window,string_spec,'center',yCoor_type,S.textColorResp);
                end;

        end;

            %draw word & rec again
            Screen('FrameRect', Window, rect_color, S.rect_frame, S.border_width);
            DrawFormattedText(Window,word,'center',ycenter-(catChoiceheight/2+50),S.textColor);
            Screen('DrawTexture',Window,catChoicePtr,[],destRect);
            
            Screen('Flip', Window);
            FlushEvents(['keyDown']);
         end
         
        
        
        RT = GetSecs - theData.onset(Trial);
        keys = string_spec;
        
        if RT < 0.001 % so that RTs of 0 will stand out if they get averaged accidentally
            RT = 999;
        end
        
        theData.stimResp{Trial} = keys;
        theData.stimRT{Trial} = RT;
        theData.corrResp{Trial} = theData.cond{Trial};
        
        % Present fixation during ITI
        goTime = 0; % added to start over, since stim time isnt fixed...
        goTime = goTime + nullTime;
        Screen(Window,'FillRect', S.screenColor);
        Screen(Window, 'DrawTexture', fix);
        Screen('FrameRect', Window, rect_color, S.rect_frame, S.border_width);
        Screen(Window,'Flip');

        % Collect responses during ITI
        [keys RT] = recordKeys(startTime,goTime,S.boxNum);
        
        if RT < 0.001 % so that RTs of 0 will stand out if they get averaged accidentally
            RT = 999;
        end
        
        theData.isiResp{Trial} = keys;
        theData.isiRT{Trial} = RT;
        
        % Record trial duration
        theData.dur(Trial) = (GetSecs - startTime) - theData.onset(Trial); % duration from stim onset
        
        % Save to mat file
        matName = [saveName '.mat'];
        cmd = ['save ' matName];
        eval(cmd);
    end
end

% Affective State questions, via analog scale
S.Questgroup = ['block',num2str(block)]; % version of questionnaires
S.QuestscaFlag = 0; % Have runQuest close screen and clear vars when done? (NO)
S.affectstate_params = {'ShockBlockparams'}; % for end of block assessment
[theData.Questp,theData.Questsession,theData.Questpars] = ...
    runQuestionnaires(S.affectstate_params,S.study_name,S.subID,S.Questgroup,...
    S.screenNumber,S,S.QuestscaFlag,thePath);

% Show fixation (lead-out)
goTime = 0; %reset again
goTime = goTime + leadOut;
Screen(Window,'FillRect', S.screenColor);
Screen(Window, 'DrawTexture', fix);
Screen(Window,'Flip');
recordKeys(startTime,goTime,kbNum);

Screen(Window,'FillRect', S.screenColor);
Screen(Window,'Flip');

Priority(0);
end

