
function ap_run(subID,thePath)

%% if script crashes, change to correct trial
C.trial_start = 1; % 1 normally, but # if start at trial > 1
C.restart = 0; % 0 if fine, 1 if crash, and restart block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Inputs

taskType = input('S(1), T(2), PracS(3), PracT(4), FreeResp(5), Quest(6)? ');
    
block = input('Enter block number: ');

if (taskType == 1) || (taskType == 2) || (taskType == 3) || (taskType == 4) || (taskType == 5)
    S.respMap = input('Response mapping (1-4)? ');
end
taskType_lab = {'STUDY', 'TEST', 'PRACTICE STUDY', 'PRACTICE TEST', 'FREE RESPONSE', 'QUESTIONNAIRES'};

S.scanner = input('inside scanner(1) or outside(2)? ');

% Cortisol analysis
S.cort = input('collecting cort(1) or not(2)? ');

if S.cort == 1
    
    % how long to collect sample for
    S.cort_sample_time = 2*60; % 2 minutes
    
    % when to sample, in seconds relative to task start time
    if taskType == 1 % study
        S.cort_times = [20*60];
        S.samples_taken = 0;
        S.next_sample = increment_cort_sample(S.cort_times, S.samples_taken);
    elseif taskType == 5 % test free response
        S.cort_times = [20*60, 40*60, 60*60];
        S.samples_taken = 0;
        S.next_sample = increment_cort_sample(S.cort_times, S.samples_taken);
    else
        S.cort_times = [];
        S.samples_taken = 0;
        S.next_sample = increment_cort_sample(S.cort_times, S.samples_taken);
    end
end    

% Stress or Control Group
S.stressGroup = input('control(1) or stress(2)? ');

S.xptr = input('What are the experimenter''s initials? (e.g., SG): ','s');
if strcmpi(S.xptr,'SG')
    S.emailRecipient = {'stephanie.a.gagnon@gmail.com'};
    S.email = 1;
elseif strcmpi(S.xptr,'AA')
    S.emailRecipient = {'stephanie.a.gagnon@gmail.com'};
    S.email = 1;
else
    S.emailRecipient = {'stephanie.a.gagnon@gmail.com'};
    S.email = 0;
end

% Set up email
try
    if S.email == 1
        setupEmail;
    end
catch
    disp('Can''t send email!');
end



S.study_name = 'AssocPlace';
S.subID = subID;

%% Set input device (keyboard or buttonbox)
[d, hostname]=system('hostname');
if S.scanner == 1
    S.boxNum = getBoxNumber;  % buttonbox
    S.kbNum = getKeyboardNumber(hostname(1:end-1)); %getKeyboardNumberWendyo; % keyboard
elseif S.scanner == 2
    S.boxNum = getKeyboardNumber(hostname(1:end-1));  % keyboard
    S.kbNum = getKeyboardNumber(hostname(1:end-1)); % keyboard
end

%% Set up subj-specific data directory
S.subData = fullfile(thePath.data, [subID]);
S.wavData = fullfile(S.subData, ['wav_files']);
if ~exist(S.subData)
   mkdir(S.subData);
end
% same for wav file (for free response)
if ~exist(S.wavData)
   mkdir(S.wavData);
end
cd(S.subData);

%% Screen commands
S.screenNumber = max(Screen('Screens'));
S.screenColor = 224; 
S.textColor = 0;
S.textColorResp = 0;
S.endtextColor = 0;
S.font = 'Kannada Sangam MN';

if S.scanner == 2
    S.fontsize = 36;
    S.border_width = 30; % border of colored rectangle
elseif S.scanner == 1
    S.fontsize = 48;
    S.border_width = 80; % border of colored rectangle
end

[S.Window, S.myRect] = Screen(S.screenNumber, 'OpenWindow', S.screenColor, [], 32);
Screen('TextSize', S.Window, S.fontsize);
Screen('TextFont', S.Window, S.font);
Screen('TextStyle', S.Window, 1);
S.on = 1;  % Screen now on

%% Some other stuff (for shock)
[c] = getColors;
S.shockColor_col = {c.orange, c.teal};
S.shockColor_lab = {'ORANGE', 'TEAL'};

% directions based on stress group
if S.stressGroup == 2 %stress
    S.shock_on = 1;
    S.shockColor_txt = {'Shock Possible','No Shock'};
    S.shockColor_col = Shuffle(S.shockColor_col); % randomize whether shock is orange or teal
else
    S.shockColor_txt = {'Orange Block','Teal Block'};
    S.shock_on = 0;
end

if C.restart == 0
    S.sessionStart = GetSecs;
end

%% Run Experiment Scripts
switch taskType
    
    % Run Study
    case 1
        for block_num = block:12 % added to loop through all for behav
            listName = [subID '_studyList.txt'];
            saveName = [subID '_block' num2str(block_num) '_study'];
            cat_saveName = [subID '_study_cat']; % combines test data across blocks

            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Load in data from prev blocks, or curr block if restart
            if C.restart == 0 || block_num > block
                % Load in data from prev blocks
                try
                    if block_num > 1
                        load(cat_saveName);
                        prevData = getPrevData(studyData, block_num);
                    else
                        prevData = struct;
                    end        
                catch err
                    outputError(thePath.data, S.subData, err);
                end  
            elseif C.restart == 1 && block_num == block % restart!
                % Load in data from current block
                try
                    blockData = load(saveName);
                    prevData = blockData.theData;
                    S.sessionStart = blockData.S.sessionStart;
                    
                    if S.cort == 1
                        S.samples_taken = blockData.S.samples_taken;
                        S.next_sample = blockData.S.next_sample;
                    end
                catch err
                    outputError(thePath.data, S.subData, err);
                end           
                
            end   
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Run study
            try
                [studyData(block_num), S] = ap_study_behav(thePath,listName,S,C,block_num,saveName,prevData);
            catch err
                outputError(thePath.data, S.subData, err);
            end
            
            % Save out concatenated data
            save(cat_saveName, 'studyData');
            
            Screen('Close'); % help comp memory
            
            % Save subj to group file after first study block
            if block_num == 1
                cd(thePath.data);
                dataFile =fopen([S.study_name,'_subids.txt'], 'a');
                fprintf(dataFile,([subID,'\n']));
            end
            
            % Send email
            try
                if S.email == 1
                    sendmail(S.emailRecipient,[S.study_name ' Subject ',num2str(S.subID),' - Session completed'],...
                        ['Subject ',num2str(S.subID),' completed session ', ...
                        taskType_lab{taskType}, ' (Block ', num2str(block_num), ...
                        ') in ',num2str((GetSecs-S.sessionStart)/60),' minutes.']);
                end
            catch
                disp('Can''t send email');
            end
        end    

    % Run Test
    case 2
        listName = [subID '_testList.txt'];
        cat_saveName = [subID '_test_cat']; % combines test data across blocks
        
        for block_num = block:6
            saveName = [subID '_block' num2str(block_num) '_test'];       

%             % if crash out of block early, and need to restart at next
%             % block
%             try
%                 if block_num > 1
%                     % If there's been a successful cat_test save
%                     if block_num > 2
%                         load(cat_saveName); % testData from other blocks
%                     end
%                         
%                     % theData from crashed block
%                     prev_savename = [subID '_block' num2str(block_num-1) '_test'];       
%                     load(prev_savename);
%                     
%                     % fill in testData w/crashed block
%                     testData(block_num-1) = theData;
%                     
%                     prevData = getPrevData(testData, block_num);
%                 else
%                     prevData = struct;
%                 end        
%             catch err
%                 outputError(thePath.data, S.subData, err);
%             end
            
            % Load in data from prev blocks
            try
                if block_num > 1
                    load(cat_saveName);
                    prevData = getPrevData(testData, block_num);
                else
                    prevData = struct;
                end        
            catch err
                outputError(thePath.data, S.subData, err);
            end

            % Run test
            try
                testData(block_num) = ap_test(thePath,listName,S,block_num,saveName,prevData);
            catch err
                outputError(thePath.data, S.subData, err);
            end

            % Save out concatenated data
            save(cat_saveName, 'testData');
        end
        
    % Run Practice Study
    case 3
        listName = [subID '_prac_studyList.txt'];
        saveName = [subID '_prac_study'];
        
        % Run practice
        try
            ap_pracStudy(thePath,listName,S,block,saveName);
        catch err
            outputError(thePath.data, S.subData, err);
        end
        
    % Run Practice Test
    case 4
        listName = [subID '_prac_testList.txt'];
        saveName = [subID '_prac_test'];
        
        % Run practice
        try
            ap_pracTest(thePath,listName,S,block,saveName);
        catch err
            outputError(thePath.data, S.subData, err);
        end
    % Free Response Test
    case 5
        
        % If its the first block, get the time stamp for onset of verbal
        % and physio recordings
        if block == 1 && C.restart == 0
            [S.Window, S.myRect] = Screen(S.screenNumber, 'OpenWindow', S.screenColor, [], 32);
            Screen('TextSize', S.Window, S.fontsize);
            Screen('TextFont', S.Window, S.font);
            Screen('TextStyle', S.Window, 1);
            S.on = 1;  % Screen now on
            
            % Get physio start
            message = 'Experimenter: G to start PHYSIO recording';
            DrawFormattedText(S.Window,message,'center','center',S.textColor);
            Screen(S.Window,'Flip');
            getKey('g',S.kbNum);
            S.physioStart = GetSecs;
            
        end
        
        for block_num = block:6
            
            % add for troubleshooting freeze
            Screen('CloseAll');
            [S.Window, S.myRect] = Screen(S.screenNumber, 'OpenWindow', S.screenColor, [], 32);
            Screen('TextSize', S.Window, S.fontsize);
            Screen('TextFont', S.Window, S.font);
            Screen('TextStyle', S.Window, 1);
            S.on = 1;  % Screen now on
            
            listName = [subID '_testList.txt'];
            saveName = [subID '_block' num2str(block_num) '_freeresp'];       
            cat_saveName = [subID '_freeresp_cat']; % combines test data across blocks

            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Load in data from prev blocks, or curr block if restart
            if C.restart == 0 || block_num > block
                % Load in data from prev blocks
                try
                    if block_num > 1
                        load(cat_saveName);
                        prevData = getPrevData(freerespData, block_num);
                    else
                        prevData = struct;
                    end        
                catch err
                    outputError(thePath.data, S.subData, err);
                end  
            elseif C.restart == 1 && block_num == block % restart!
                % Load in data from current block
                try
                    blockData = load(saveName);
                    prevData = blockData.theData;
                    S.sessionStart = blockData.S.sessionStart;
                    S.physioStart = blockData.S.physioStart;
                    
                    if S.cort == 1
                        S.samples_taken = blockData.S.samples_taken;
                        S.next_sample = blockData.S.next_sample;
                    end
                catch err
                    outputError(thePath.data, S.subData, err);
                end           
                
            end   
            %%%%%%%%%%%%%%%%%%%%%%%%%%%


%             prevData = struct; % if crashes

            % Run test
            try
                [freerespData(block_num), S] = ap_testfr_shock(thePath,listName,S,C,block_num,saveName,prevData);
            catch err
                outputError(thePath.data, S.subData, err);
            end

            % Save out concatenated data
            save(cat_saveName, 'freerespData');
            
            % Send email
            try
                if S.email == 1
                    sendmail(S.emailRecipient,[S.study_name ' Subject ',num2str(S.subID),' - Session completed'],...
                        ['Subject ',num2str(S.subID),' completed session ', ...
                        taskType_lab{taskType}, ', Block ', num2str(block_num), ...
                        ' in ',num2str((GetSecs-S.sessionStart)/60),' minutes.']);
                end
            catch
                disp('Can''t send email');
            end
        end

    % questionnaires
    case 6
        try
            % Trait/State Questionnaires
            S.Questgroup = ['post',num2str(1)]; % version of questionnaires
            S.QuestscaFlag = 0; % Have runQuest close screen and clear vars when done? (NO)
            S.questionnaire_params = {'BISBASparams','SMMparams','STAI_Tparams'}; % for end of block assessment
            [theData.Questp,theData.Questsession,theData.Questpars] = ...
                runQuestionnaires(S.questionnaire_params,S.study_name,num2str(S.subID),S.Questgroup,...
                S.screenNumber,S.boxNum,S,S.QuestscaFlag,thePath);
        catch err
           %open file
           cd(thePath.data)
           fid = fopen('logFile.txt','a+');
           % write the error to file
           % first line: message
           fprintf(fid, '%s', err.getReport('extended', 'hyperlinks','off'))

           % close file
           fclose(fid)                    
        end
end

Screen('TextSize', S.Window, S.fontsize);
Screen('TextFont', S.Window, S.font);
message = 'Press g to exit';
DrawFormattedText(S.Window,message,'center','center',S.endtextColor);
Screen(S.Window,'Flip');

% Send email
try
    if S.email == 1
        sendmail(S.emailRecipient,[S.study_name ' Subject ',num2str(S.subID),' - Session completed'],...
            ['Subject ',num2str(S.subID),' completed session ', taskType_lab{taskType},' in ',num2str((GetSecs-S.sessionStart)/60),' minutes.']);
    end
catch
    disp('Can''t send email');
end

pause;
clear screen;
Screen('Close')
cd(thePath.scripts);
