
function localizer_run(subID,thePath)

%% Inputs

taskType = input('Prac(1), Task(2)? ');
    
block = input('Enter block number: ');

S.respMap = input('Response mapping (1-4)? ');

taskType_lab = {'PRACTICE', 'TASK'};

S.scanner = input('inside scanner(1) or outside(2)? ');


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


S.study_name = 'Localizer';
S.subID = subID;

%% Set input device (keyboard or buttonbox)
[~, hostname] = system('hostname');
hostname = hostname(1:end-1); % remove weird extra stuff
if S.scanner == 1
    S.boxNum = getBoxNumber;  % buttonbox
    S.kbNum = getKeyboardNumber(hostname); % keyboard
elseif S.scanner == 2
    S.boxNum = getKeyboardNumber(hostname);  % keyboard
    S.kbNum = getKeyboardNumber(hostname); % keyboard
end

%% Set up subj-specific data directory
S.subData = fullfile(thePath.data, [subID]);
if ~exist(S.subData)
   mkdir(S.subData);
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

%% Some other stuff
[c] = getColors;
S.border_col = c.darkgray;


S.sessionStart = GetSecs;


%% Run Experiment Scripts
switch taskType
    
    % Run Practice
    case 1
        listName = [subID '_locList_prac.txt'];
        saveName = [subID '_localizer_prac'];    
        
        S.restTime = 3; % between block rest
        S.leadIn = 1;
        S.leadOut = 1;
        
        % Run practice
        try
            localizer_task(thePath,listName,S,1,saveName,struct);
        catch err
            outputError(thePath.data, S.subData, err);
        end
        
    % Run Task
    case 2
        listName = [subID '_locList.txt'];
        cat_saveName = [subID '_localizer_cat']; % combines test data across blocks

        for block_num = block:2
            saveName = [subID '_block' num2str(block_num) '_localizer'];

            % Load in data from prev blocks
            try
                if block_num > 1
                    load(cat_saveName);
                    prevData = getPrevData(localizerData, block_num);
                else
                    prevData = struct;
                end        
            catch err
                outputError(thePath.data, S.subData, err);
            end

            S.restTime = 10.5; % between block rest
            S.leadIn = 12;
            S.leadOut = 12;
            
            % Run test
            try
                localizerData(block_num) = localizer_task(thePath,listName,S,block_num,saveName,prevData);
            catch err
                outputError(thePath.data, S.subData, err);
            end

            % Save out concatenated data
            save(cat_saveName, 'localizerData');
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
