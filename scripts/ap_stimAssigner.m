function ap_stimAssigner(subID,thePath)

%% Makes the stim list for each subject
% This script calls up the basic list of all the stimuli that specifies the
% info for each word and img stimulus (kind, name, ID#, etc), and then
% creates a unique pairing of stimuli for each subject.  The ID of each
% INDIVIDUAL stimulus (e.g., indoor#22) never changes across subjects (making item
% analyses easier), but once the stims are paired for each subject, there
% is a name that refers to that condition (e.g., indoor-Scene # 15) that can
% be used for tracking an item WITHIN subject but has no meaning across
% subjects.  

%% initialize randomness  
rand('twister',sum(100*clock));

%% Some info about block & trial counts (for sub/subsubtype distribution)
% how many blocks are there
blockinfo.study.num = 6;

% how many trials per cond per block
blockinfo.study.indoorpair = 14;
blockinfo.study.outdoorpair = 14;

% how to counterbalance within conditions
indoor_by_subtype = 0;
outdoor_by_subtype = 1;


%% load up the stim list

[NUMERIC,TXT,RAW] = xlsread('inputlist.xls');

% Below things are grouped according to what should be paraShuffled together

% words (rows 2-301)
wordID = TXT(2:253,1);
wordName = TXT(2:253,2);

% indoors (rows 2-121)
indoorID = TXT(2:121,3);
indoorName = TXT(2:121,4);
indoorFile = TXT(2:121,5);

% Scenes (rows 2-121)
outdoorID = TXT(2:121,6);
outdoorName = TXT(2:121,7);
outdoorFile = TXT(2:121,8);
creator = TXT(2:121,9);


%% paraShuffle each of the sets

% the words
[wordID, wordName] = paraShuffle(wordID, wordName);

% the indoor
[indoorID, indoorName, indoorFile] = paraShuffle(indoorID, indoorName, indoorFile);

% the outdoor
[outdoorID, outdoorName, outdoorFile, creator] = paraShuffle(outdoorID, outdoorName, outdoorFile, creator);


%% Make sure Condition subtypes are equally dispersed into blocks
if outdoor_by_subtype == 1
    outdoor_subtype = creator;
    outdoor_subsubtypes = 2;
    outdoor_subsublabels = {'manmade', 'natural'};
    outdoor_num_persubtype = (blockinfo.study.num * blockinfo.study.outdoorpair)/2;

    % get current indices for each subtype (rows=diff levels, columns=ind into level)
    subsub_ind = [];
    for i=1:outdoor_subsubtypes
        subsub_ind{i}= find(strcmp(outdoor_subsublabels{i}, outdoor_subtype));
    end
    
    %select top # per sub type
    for i=1:outdoor_subsubtypes
        subsub_ind{i} = subsub_ind{i}(1:outdoor_num_persubtype);
    end
    
    % set up ordering based on number of subtypes
    trialmat(1, :) = 1:1:(blockinfo.study.num * blockinfo.study.outdoorpair);
    temp = [];
    for i=1:outdoor_subsubtypes
        temp = [temp; repmat(i,length(subsub_ind{i}),1)];
    end
    trialmat(2,:) = paraShuffle(temp);   


    % reorder indices based on subtype
    counters(1:outdoor_subsubtypes) = 1;
    ind_reordered = [];
    for i=1:(blockinfo.study.num * blockinfo.study.outdoorpair)
        cond = trialmat(2,i);
        ind_reordered(i) = subsub_ind{cond}(counters(cond));
        counters(cond) = counters(cond) + 1;
        clear cond;
    end

    % pull correct info from indoor structures
    for i=1:(blockinfo.study.num * blockinfo.study.outdoorpair)
        outdoorID_by_subtype(i) = outdoorID(ind_reordered(i));
        outdoorName_by_subtype(i) = outdoorName(ind_reordered(i));
        outdoorFile_by_subtype(i) = outdoorFile(ind_reordered(i));
        creator_by_subtype(i) = creator(ind_reordered(i));
    end
    
    clear trialmat outdoor_subsubtypes outdoor_subsublabels subsub_ind counters
end


%% Add number of reps each trial
trialmat(1, :) = 1:1:(blockinfo.study.num * blockinfo.study.outdoorpair);
temp = [];
num_typesReps = 2;
stim_perRep = length(trialmat)/num_typesReps;
reps = [2;4];
for i=1:stim_perRep
    temp = [temp; repmat(reps,1,1)];
end
trialmat(2,:) = temp;
clear temp

%% Assign specific stims to conditions and create pairs
if outdoor_by_subtype == 1
    for a = 1:(blockinfo.study.num * blockinfo.study.outdoorpair)
        WO.condID{a} = ['WO_' num2str(a)];
        WO.wordID(a) = wordID(a);
        WO.wordName(a) = wordName(a);
        WO.imgID(a) = outdoorID_by_subtype(a);
        WO.imgName(a) = outdoorName_by_subtype(a);
        WO.imgFile(a) = outdoorFile_by_subtype(a);
        WO.imgType{a} = ['outdoor'];
        WO.subType(a) = creator_by_subtype(a);
        WO.numReps(a) = paraShuffle(trialmat(2,a));
        WO.combType{a} = ['WO_' num2str(WO.numReps(a))];
        clear a;
    end
else
    for a = 1:(blockinfo.study.num * blockinfo.study.outdoorpair)
        WO.condID{a} = ['WO' num2str(a)];
        WO.wordID(a) = wordID(a);
        WO.wordName(a) = wordName(a);
        WO.imgID(a) = outdoorID(a);
        WO.imgName(a) = outdoorName(a);
        WO.imgFile(a) = outdoorFile(a);
        WO.imgType{a} = ['outdoor'];
        WO.numReps(a) = paraShuffle(trialmat(2,a));
        WO.combType{a} = ['WO_' num2str(WO.numReps(a))];
        clear a;
    end
end

for a = 1:(blockinfo.study.num * blockinfo.study.outdoorpair)
    WI.condID{a} = ['WI_' num2str(a)];
    WI.wordID(a) = wordID(a+(blockinfo.study.num * blockinfo.study.outdoorpair));
    WI.wordName(a) = wordName(a+(blockinfo.study.num * blockinfo.study.outdoorpair));
    WI.imgID(a) = indoorID(a);
    WI.imgName(a) = indoorName(a);
    WI.imgFile(a) = indoorFile(a);
    WI.imgType{a} = ['indoor'];
    WI.subType{a} = ['indoor'];
    WI.numReps(a) = paraShuffle(trialmat(2,a));
    WI.combType{a} = ['WI_' num2str(WI.numReps(a))];
    clear a;
end
    
for a = 1:(blockinfo.study.num * blockinfo.study.outdoorpair)
    F.condID{a} = ['F_' num2str(a)];
    F.wordID(a) = wordID(a+2*(blockinfo.study.num * blockinfo.study.outdoorpair));
    F.wordName(a) = wordName(a+2*(blockinfo.study.num * blockinfo.study.outdoorpair));
    clear a;
end

clear trialmat

cd(thePath.orderfiles);
subDir = fullfile(thePath.orderfiles, [subID]);
if ~exist(subDir)
   mkdir(subDir);
end
cd(subDir);
eval(['save ' subID '_stims WI WO F']);
cd(thePath.scripts);






