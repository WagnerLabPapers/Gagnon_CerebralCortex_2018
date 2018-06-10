
function theData = ap_pracStudy(thePath,listName,S,block,saveName)

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

listLength = length(theData.index);


%% Trial Outline
stimTime = 3;
nullTime = 9;

leadIn = 10;
leadOut = 10;

%% Screen commands and device specification
Window = S.Window;
myRect = S.myRect;

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
message = ['PRACTICE STUDY'];
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
for preall = 1:listLength
    if (theData.block(preall)==block)
        theData.onset(preall) = 0;
        theData.dur(preall) =  0;
        theData.stimResp{preall} = 'NR';
        theData.stimRT{preall} = 0;
        theData.isiResp{preall} = 'NR';
        theData.isiRT{preall} = 0;
        theData.picShown{preall} = 'blank';
        theData.wordShown{preall} = 'blank';
    end
end

% get ready screen
Screen(Window,'FillRect', S.screenColor);
message = ['PRACTICE\nSTUDY BLOCK ' num2str(block) '\n\n\n'... 
            'Get ready!'];
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
for Trial = 1:listLength
    if (theData.block(Trial)==block)
        
        goTime = goTime + stimTime;
        theData.onset(Trial) = GetSecs - startTime;
        
        keys = {'NR'};
        RT = 0;
        
        % Blank
        Screen(Window,'FillRect', S.screenColor);
        
        % Draw the word
        Screen(Window,'TextSize', 36);
        word = theData.wordName{Trial}(3:end);
        DrawFormattedText(Window,word,'center',ycenter-(imgheight(Trial)/2+50),S.textColor);
        theData.wordShown{Trial} = word;
        
        % Draw the image
        destRect = [xcenter-imgwidth(Trial)/2 ycenter-imgheight(Trial)/2 xcenter+imgwidth(Trial)/2 ycenter+imgheight(Trial)/2];
        Screen('DrawTexture',Window,imgPtrs(Trial),[],destRect);
        
%         % Draw the image name
%         Screen(Window,'TextSize', 22);
%         word = theData.imgName{Trial};
%         theData.picShown{Trial} = word;
%         a = find(word=='_');
%         word(a) = ' ';
%         DrawFormattedText(Window,word,'center',ycenter+(imgheight(Trial)/2+20),S.textColor);
%         
        % Flip
        Screen(Window,'Flip');
        
        % Collect responses during stimulus presentation
        [keys RT] = recordKeys(startTime,goTime,S.boxNum);
                
        if S.scanner == 2
            codedResp = codeBehavResp(keys, respCodes, respOpts, 'first');
        else
            codedResp = 'scanner';
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
        [keys RT] = recordKeys(startTime,goTime,S.boxNum);
        
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

Screen(Window,'FillRect', S.screenColor);
Screen(Window,'Flip');

Priority(0);

% calc results
rel = sum(cellfun(@(x) sum(strcmp('R',x)), theData.stimCodedResp));
unrel = sum(cellfun(@(x) sum(strcmp('UR',x)), theData.stimCodedResp));
nr = sum(cellfun(@(x) sum(strcmp('NR',x)), theData.stimCodedResp));

% display results
message = ['You failed to respond on ' num2str(ceil(nr/listLength*100)), '% of trials.\n', ...
    'You responded RELATED on ' num2str(ceil(rel/listLength*100)), '% of trials.\n', ...
    'You responded UNRELATED on ' num2str(ceil(unrel/listLength*100)), '% of trials.'];
Screen(Window,'FillRect', S.screenColor);
DrawFormattedText(Window,message,'center',ycenter-100,S.textColor);  
Screen(Window,'Flip');
getKey('g',S.kbNum);

end

