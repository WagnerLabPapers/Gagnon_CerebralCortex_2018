function [p,Questsession,Questpars] = runQuestionnaires(paramFiles,study,subID,group,screenNum,boxNum,screenParams,clearFlag,thePath)
% Possible inputs to runQuest (run Self-Report Measure):
%     1) paramFiles - parameter files that you have already saved for your Quest(s) (e.g., {'BFIparams','NFCparams'})
%     2) study - initials that will identify your study (e.g., ABC or '')
%     3) subID - subject number/ID (e.g., 005 or '')
%     4) group - individual sub-group within experiment if counterbalancing, etc. (e.g., A or '')
%     5) screenNum - 0 (default) to use screen on primary computer (e.g., laptop) or 1 to use external monitor
%     6) screenParams - a structure containing a 'w' and 'myRect' field
%     describing an already open PTB window (e.g., if calling this function from an already running PTB script)
%     7) clearFlag - 1 (default) to clear variables and command window and
%     close screen when done; change to 0 if, e.g., calling from already running PTB script
%
% Possible outputs from runQuest (automatically saved to *.mat and also transcribed to *.xls)
%     1) p - structure containing experimental parameters for overall
%     runQuest session
%     2) Questsession - array of structures containing results for each of the individual Quest tasks run
%     3) Questsession - array of structures containing parameters for each of the individual Quest tasks run


    %%% EXAMPLE calls to runQuest:
    %   runQuest({'genericQuestparams'},'myStudy','mySubID','myGroup');
    %   runQuest({'BFIparams','NFCparams'},'myStudy','mySubID','myGroup');

%% CHANGE THIS if not calling function with paramFiles defined:    
    
    defaultParamFiles = {'genericQuest_discreteParams','genericQuest_analogParams'};
 
    
[c] = getColors;

%% Set a few defaults:

if ~exist('paramFiles','var')
    p.paramFiles = defaultParamFiles;
else
    p.paramFiles = paramFiles;
end

if ~exist('screenNum','var')
    p.screenNum = 0;
else
    p.screenNum = screenNum;
end

%% Ask for any variables not provided:

if ~exist('study','var')
    p.study = input('What are the study''s initials? (e.g., ABC): ','s');
else
    p.study = study;
end

if ~exist('subID','var')
    p.subID = input('What is the subject #? (e.g., 005): ','s');
else
    p.subID = subID;
end
if ~exist('group','var')   
    p.group = input('Which group is the subject in? ','s');
    disp(' ');
    disp(['You chose subID ',p.subID,' and group ',p.group]);
else
    p.group = group;
end

if ~exist('clearFlag','var')   
    clearFlag = 1;
else
    p.clearFlag = clearFlag;
end
 

rand('twister', sum(100*clock));
p.deviceNum = -1;
% p.deviceNum = boxNum;

p.date = datestr(now,'mm-dd-yy');
p.startTime = datestr(now,'HH:MM:SS.FFF PM');
p.startCodeSecs = GetSecs;


    % Make a few adjustments for font differences for Mac vs PC
if ispc
    p.pcFontAdj = 8;        % Decrease font size by this many points on PC's
    p.LjustMult = 0.05;     % multiplier for x resolution to left-justify
else
    p.pcFontAdj = 0;        % Decrease font size by this many points on PC's
    p.LjustMult = 0.1;     % multiplier for x resolution to left-justify
end

%% Set up output file

    % leave out underscores for empty variables:
if ~isempty(p.study) under1 = '_'; else under1 = ''; end
if ~isempty(p.subID) under2 = '_'; else under2 = ''; end
if ~isempty(p.group) under3 = '_'; else under3 = ''; end

p.alloutfile = [p.study,under1,p.subID,under2,p.group,under3,date];   % ALL results files will save here

% setup D struct, to store data...
D.expName     = {}; % experiment name
D.groupName   = {}; % group name (e.g., 'A' or 'B')
D.Date        = {}; % date
D.subjectID      = {}; % subject ID
D.questionLabel  = {};  % e.g., q1, q2,... or Happy, Sad,...
D.rawRating        = [];    % rating given by participant
D.isReversed       = [];    % is this question supposed to be reverse-coded? (0/1)
D.adjustedRating   = [];    % rating adjusted for reverse-coding
D.respRT           = [];    % response RT
D.subScaleName    = {};        % Quest sub-scale name (e.g., A, B,... or Neurot, Open,...)
D.subScaleNum     = [];        % Quest sub-scale number (e.g., 1, 2, 3,...)
D.promptNum       = [];        % Prompt number (e.g., 1, 2, 3,...)
    

%% Set up screen, etc.
if ~exist('screenParams','var') || ~isfield(screenParams,'Window') || isempty(screenParams.Window)
    Screen('Preference', 'SkipSyncTests',1);
    Screen('Preference', 'VisualDebuglevel', 3);
    Screen('Preference', 'SuppressAllWarnings', 1);

    if ~exist('res','var')
        ScrSize = get(0,'Screensize');
        res=ScrSize(3:4);
    end
    if ((res(1)==1680) && (res(2)<1050))
        res(2)=1050;
    elseif ((res(1)==1440) && (res(2)<900))
        res(2)=900;
    elseif ((res(1)==1024) && (res(2)<768))
        res(2)=768;
    elseif ((res(1)==800) && (res(2)<600))
        res(2)=600;
    end

    [w,myRect]=Screen('OpenWindow',p.screenNum,0,...
        [0 0 res(1) res(2)]);
    p.w = w; p.myRect = myRect; 
else
    p.w = screenParams.Window; p.myRect = screenParams.myRect; 
    w = screenParams.Window; myRect = screenParams.myRect;
    p.black = 0;
    p.grey = 224;
    p.Dirs.quest_dataDir = [thePath.data,'/Quest/'];
    p.screenNumber = screenParams.screenNumber;
end

p.res = p.myRect(3:4);
p.centerX = p.myRect(3)/2; % x center of main window
p.centerY = p.myRect(4)/2; % y center of main window
p.analogScaleEnds = [(p.res(1)*.115),(p.res(1)*.885)]; % [x_start x_end y_start y_end]


% HideCursor;
% ListenChar(2);

Screen(w,'FillRect', 224);
Screen('Flip',w);

p.startSecs = GetSecs;

% HideCursor;


%% Run task(s)

for Questind = 1:length(p.paramFiles)
    Questsession(Questind).totalTaskTime = [];
        % If name of params file is longer than 6 chars (e.g., NFCparams),
        % use start of filename - otherwise use full filename
    if length(p.paramFiles{Questind})>6
        Questname = p.paramFiles{Questind}(1:end-6);
    else
        Questname = p.paramFiles{Questind};
    end
    tmpD = D;
    curFID  = fopen(fullfile(p.Dirs.quest_dataDir,[p.alloutfile '_',Questname,'.xls']), 'a');
    writeHeaderToFile(tmpD, curFID);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    taskStart = GetSecs - p.startSecs;

    % Obtain experimental parameters from relevant params file:
    Questpars(Questind).myQuestparams = eval([p.paramFiles{Questind},'(w,myRect,p,1)']);
    %     Questpars(Questind).myQuestparams = genericQuestparams(w,myRect,p,1);
    Questsession(Questind).myQuestresults = runGenericTask(w,p.deviceNum,Questpars(Questind).myQuestparams,p);

    taskEnd = GetSecs - p.startSecs;
    Questsession(Questind).totalTaskTime = [Questsession(Questind).totalTaskTime (taskEnd-taskStart)];
    
    % Save to mat file:
    save(fullfile(p.Dirs.quest_dataDir,p.alloutfile),'Questsession','Questpars','p');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for trial=1:length(Questsession(Questind).myQuestresults.Rating)
        tmpD.expName{trial}     = p.study; % experiment name
        tmpD.groupName{trial}   = p.group; % group name (e.g., 'A' or 'B')
        tmpD.Date{trial}        = p.date; % date
        tmpD.subjectID{trial}      = p.subID; % subject ID
        tmpD.questionLabel{trial}  = Questpars(Questind).myQuestparams.Qlabels{trial};  % e.g., q1, q2,... or Happy, Sad,...
        tmpD.rawRating(trial)        = Questsession(Questind).myQuestresults.Rating(trial);    % rating given by participant
        tmpD.isReversed(trial)       = Questpars(Questind).myQuestparams.Qreverse(trial)>0;    % is this question supposed to be reverse-coded? (0/1)
        tmpD.adjustedRating(trial)   = abs(Questpars(Questind).myQuestparams.Qreverse(trial)-tmpD.rawRating(trial));    % rating adjusted for reverse-coding
        tmpD.respRT(trial)          = Questsession(Questind).myQuestresults.RT(trial);    % response RT
        tmpD.subScaleName{trial}    = Questpars(Questind).myQuestparams.QsubscaleNames{trial};        % Quest sub-scale name (e.g., A, B,... or Neurot, Open,...)
        tmpD.subScaleNum(trial)     = Questpars(Questind).myQuestparams.QsubscaleNums(trial);        % Quest sub-scale number (e.g., 1, 2, 3,...)
        if iscell(Questpars(Questind).myQuestparams.prompt)
            tmpD.promptNum(trial)    = Questpars(Questind).myQuestparams.promptInds(trial);        % Prompt number (e.g., 1, 2, 3,...)
        else
            tmpD.promptNum(trial)    = 1;
        end
        
        % Save to excel:
        writeTrialToFile(tmpD, trial, curFID);
    end

    fclose(curFID);

end

%% Clean up and clear out:

if p.clearFlag
    for xyz=1:4
        ShowCursor;
    end
    ListenChar;

    fclose('all');
    sca;
    clear all;
    sca
end

return


%% function writeHeaderToFile(D, fid)
% =========================================================================
function writeHeaderToFile(D, fid)

h = fieldnames(D);

for i=1:length(h)
    fprintf(fid, '%s\t', h{i});
end
fprintf(fid, '\n');
% =========================================================================


%% function writeTrialToFile(D, trial, fid)
% =========================================================================
function writeTrialToFile(D, trial, fid)

h = fieldnames(D);
for i=1:length(h)
    data = D.(h{i})(trial);
    if isnumeric(data)   
        fprintf(fid, '%s\t', num2str(data));
    elseif iscell(data)
        fprintf(fid, '%s\t', char(data));
    else
        error('wrong format!')
    end
end     
fprintf(fid, '\n');
% =========================================================================

% subMat = [Questsession(Questind).myQuestresults.Rating' Questpars(Questind).myQuestparams.Qreverse Questpars(Questind).myQuestparams.Qsubscales];
% subCell = [Questpars(Questind).myQuestparams.Qlabels mat2cell(subMat,ones(size(subMat,1),1),ones(size(subMat,2),1))];
