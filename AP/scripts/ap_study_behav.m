function [theData, S] = ap_study_behav(thePath,listName,S,C,block,saveName,theData)

%% initialize rand.
rand('twister',sum(100*clock));
kbNum=S.kbNum;

%% Come up with response labels
if S.respMap == 1 || S.respMap == 3
    respCodes = {'R' 'UR'};
    labelReminder = 'study_response_mapping1.jpg';
elseif S.respMap == 2 || S.respMap == 4
    respCodes = {'UR' 'R'};
    labelReminder = 'study_response_mapping2.jpg';
end
respOpts = {'2','3'};

theData.respOpts = respOpts;
theData.respCodes = respCodes;

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
theData.repType = theList.col14;
theData.repCount = theList.col15;

listLength = length(theData.index);


%% Trial Outline
stimTime = 3;
nullTime = 9;

leadIn = 10;
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

%% Pre-load images 
cd(thePath.stim);
pic = imread(labelReminder);
labelRemind = Screen(Window,'MakeTexture', pic);

% Load fixation
fileName = 'fix.jpg';
pic = imread(fileName);
[fixHeight fixWidth crap] = size(pic);
fix = Screen(Window,'MakeTexture', pic);

% Load blank
fileName = 'blank.jpg';
pic = imread(fileName);
blank = Screen(Window,'MakeTexture', pic);

% Print reminder
Screen(Window,'FillRect', S.screenColor);
message = ['STUDY BLOCK ' num2str(block)];
DrawFormattedText(Window,message,'center',ycenter-400,S.textColor);
Screen(Window, 'DrawTexture', labelRemind);
Screen(Window,'Flip');
getKey('g',S.kbNum);

% Load the stim pictures for the current block
for n = 1:listLength
    if (theData.block(n)==block)
        picname = theData.imgFile{n};  % This is the filename of the image
        pic = imread(picname);
        [imgheight(n) imgwidth(n) crap] = size(pic);
        imgPtrs(n) = Screen('MakeTexture',Window,pic);
    end
end

%% Get everything else ready

% preallocate shit:
trialcount = 0;
for preall = C.trial_start:listLength
    if (theData.block(preall)==block)
        theData.onset(preall) = 0;
        theData.dur(preall) =  0;
        theData.stimResp{preall} = 'NR';
        theData.stimRT{preall} = 0;
        theData.isiResp{preall} = 'NR';
        theData.isiRT{preall} = 0;
        theData.picShown{preall} = 'blank';
        theData.wordShown{preall} = 'blank';
        theData.cortSample{preall} = 0;
    end
end

% get ready screen
Screen(Window,'FillRect', S.screenColor);
message = ['Get ready!'];
DrawFormattedText(Window,message,'center',ycenter-100,S.textColor);  
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

% Show fixation (lead-in)
goTime = 0;
goTime = goTime + leadIn;
destRect = [xcenter-fixWidth/2 ycenter-fixHeight/2 xcenter+fixWidth/2 ycenter+fixHeight/2];
Screen(Window,'FillRect', S.screenColor);
Screen(Window, 'DrawTexture', fix,[],destRect);
Screen(Window,'Flip');
recordKeys(startTime,goTime,kbNum);

cd(S.subData); % for saving data

% Loop through stimulus trials
for Trial = C.trial_start:listLength
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
        
        
        goTime = stimTime; % if behavioral/cort being collected!
        stim_startTime = GetSecs;
        
        theData.time_raw(Trial) = stim_startTime;
        theData.onset(Trial) = GetSecs - startTime;
        
        
        keys = {'NR'};
        RT = 0;
        
        % Blank
        Screen(Window,'FillRect', S.screenColor);
        
        % Draw the word
        Screen(Window,'TextSize', S.fontsize);
        word = theData.wordName{Trial}(3:end);
        DrawFormattedText(Window,word,'center',ycenter-(imgheight(Trial)/2+50),S.textColor);
        theData.wordShown{Trial} = word;
        
        % Draw the image
        destRect = [xcenter-imgwidth(Trial)/2 ycenter-imgheight(Trial)/2 xcenter+imgwidth(Trial)/2 ycenter+imgheight(Trial)/2];
        Screen('DrawTexture',Window,imgPtrs(Trial),[],destRect);
        theData.picShown{Trial} = theData.imgName{Trial};
        
        % Flip
        Screen(Window,'Flip');
        
        % Collect responses during stimulus presentation
        [keys RT] = recordKeys(stim_startTime,goTime,S.boxNum);
                
        if S.scanner == 2
            codedResp = codeBehavResp(keys, respCodes, respOpts, 'last');
        else
            codedResp = 'scanner'; % just to hurry up when scanning
        end
        
        if RT < 0.001 % so that RTs of 0 will stand out if they get averaged accidentally
            RT = 999;
        end
        
        theData.stimResp{Trial} = keys;
        theData.stimRT{Trial} = RT;
        theData.stimCodedResp{Trial} = codedResp;
        
        % Present fixation during ITI
        goTime = goTime + nullTime;
        destRect = [xcenter-fixWidth/2 ycenter-fixHeight/2 xcenter+fixWidth/2 ycenter+fixHeight/2];
        Screen(Window,'FillRect', S.screenColor);
        Screen(Window, 'DrawTexture', fix,[],destRect);
        Screen(Window,'Flip');
        
        % Collect responses during fixation
        [keys RT] = recordKeys(stim_startTime,goTime,S.boxNum);
        RT = RT + stimTime;

        if S.scanner == 2
            codedResp = codeBehavResp(keys, respCodes, respOpts, 'first');
        else
            codedResp = 'scanner';
        end
        
        if RT < 0.001 % so that RTs of 0 will stand out if they get averaged accidentally
            RT = 999;
        end
        
        theData.isiResp{Trial} = keys;
        theData.isiRT{Trial} = RT;
        theData.isiCodedResp{Trial} = codedResp;
        
        % Record trial duration
        theData.dur(Trial) = (GetSecs - stim_startTime) - theData.onset(Trial); % duration from stim onset
        
        % Save to mat file 
        matName = [saveName '.mat'];
        cmd = ['save ' matName];
        eval(cmd);
    end
end

% Show fixation (lead-out)
goTime = leadOut;
Screen(Window,'FillRect', S.screenColor);
Screen(Window, 'DrawTexture', fix);
Screen(Window,'Flip');
recordKeys(stim_startTime,goTime,kbNum);

Screen(Window,'FillRect', S.screenColor);
Screen(Window,'Flip');

Priority(0);
end

