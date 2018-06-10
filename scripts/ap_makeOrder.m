function ap_makeOrder(subID,thePath)

%% About this script
% This script will make the condition ordering for the AssocPlace task and assign the
% specific stims as well.  It will output the final lists and the only
% input it draws from is the list of the  stims that is specific to
% each subject and is created from a different script

%% initialize rand.
rand('twister',sum(100*clock));

%% Create the list composition: # of blocks & items/conditions per block

snum = subID;

% how many blocks are there
blockinfo.study.num = 6;
blockinfo.test.num = 6;

% how many UNIQUE trials per cond per block
blockinfo.study.indoorpair = 14 + 7; %addreps
blockinfo.study.outdoorpair = 14 + 7;
blockinfo.test.indoorcue = 14;
blockinfo.test.outdoorcue = 14;
blockinfo.test.foil = 14;

% items per cell
itemsPerCell.study = (blockinfo.study.indoorpair + ...
    blockinfo.study.outdoorpair)*blockinfo.study.num;
itemsPerCell.test = (blockinfo.test.indoorcue + ...
    blockinfo.test.outdoorcue + ...
    blockinfo.test.foil)*blockinfo.test.num;

% what are the conditions (using labels) that appear in each study block
conditions.study.block1 = {'WI' 'WO'};
conditions.study.block2 = {'WI' 'WO'};
conditions.study.block3 = {'WI' 'WO'};
conditions.study.block4 = {'WI' 'WO'};
conditions.study.block5 = {'WI' 'WO'};
conditions.study.block6 = {'WI' 'WO'};

% compute total trials per study block
for a = 1:blockinfo.study.num
    blockinfo.study.size(a) = blockinfo.study.indoorpair + blockinfo.study.outdoorpair;
    clear a;
end

% what are the conditions (using labels) that appear in each test block
% include indoor/outdoor by #reps at encoding
conditions.test.block1 = {'TI_2' 'TO_2' 'TI_4' 'TO_4' 'F'};
conditions.test.block2 = {'TI_2' 'TO_2' 'TI_4' 'TO_4' 'F'};
conditions.test.block3 = {'TI_2' 'TO_2' 'TI_4' 'TO_4' 'F'};
conditions.test.block4 = {'TI_2' 'TO_2' 'TI_4' 'TO_4' 'F'};
conditions.test.block5 = {'TI_2' 'TO_2' 'TI_4' 'TO_4' 'F'};
conditions.test.block6 = {'TI_2' 'TO_2' 'TI_4' 'TO_4' 'F'};

% compute  total trials per test block
for a = 1:blockinfo.test.num
    blockinfo.test.size(a) = blockinfo.test.indoorcue + blockinfo.test.outdoorcue + blockinfo.test.foil;
    clear a;
end

%% create condition ordering for study blocks

% Makes a vector for each block with the appropriate number of each
% condition label and then shuffles that vector

for c = 1:blockinfo.study.num
    TooManyRepeats = .5;
    while TooManyRepeats > 0;
        tempcon = eval(['conditions.study.block' num2str(c)]);
        g = ['block' num2str(c) '.study.conditions'];
        eval([g ' = [];']);
        for d = 1:blockinfo.study.indoorpair % (same trials per cond for either cond)
            eval([g ' = [' g ' tempcon];'])
        end
        eval([g ' = paraShuffle(' g ');']);
        eval(['f = length(' g ');']);
        % make a redundant variable that represents the current block (post
        % paraShuffle) so that it's easier to refer to it
        h = eval([g]);
        repcount = 0;
        for e = 1:f
            currcond = eval(['block' num2str(c) '.study.conditions{' num2str(e) '}']);
            eval(['block' num2str(c) '.study.term{' num2str(e) '} = h{e};']);
            currterm = eval(['block' num2str(c) '.study.term{' num2str(e) '}']);
            if strcmp(currcond(2),'I')
                eval(['block' num2str(c) '.study.ForS(' num2str(e) ') = 1;']);
            elseif strcmp(currcond(2),'O')
                eval(['block' num2str(c) '.study.ForS(' num2str(e) ') = 2;']);
            end
            
            if e > 1
                eval(['tmpj = block' num2str(c) '.study.ForS(' num2str(e) ');']);
                eval(['tmpk = block' num2str(c) '.study.ForS(' num2str(e-1) ');']);
                j=tmpj; % stupid hack for dealing with lack of j/k in the workspace
                k=tmpk;
                if j == k
                    repcount = repcount + 1;
                    eval(['block' num2str(c) '.study.repcount(' num2str(e) ') = ' num2str(repcount) ';']);
                else
                    repcount = 0;
                    eval(['block' num2str(c) '.study.repcount(' num2str(e) ') = ' num2str(repcount) ';']);
                end
            end
            
        end
          
        % the below number can be changed to limit the # of indoor or Scene
        % Repeats that are allowed.  M = 2 means there can only be 3 indoors
        % or Scenes in a Row
        
        eval(['m = max(block' num2str(c) '.study.repcount);']);
        
        if m > 2
            TooManyRepeats = 1;
        else
            TooManyRepeats = 0;
        end
    end
    clear c d e f g h j k m currterm currcond tempcon;
end

%% create condition ordering for test blocks

% Makes a vector for each block with the appropriate number of each
% condition label and then shuffles that vector

for c = 1:blockinfo.study.num
    TooManyRepeats = .5;
    while TooManyRepeats > 0;
        g = ['block' num2str(c) '.test.conditions'];
        eval([g ' = [];']); 
        % first create vector of targets
        targs = eval(['conditions.test.block' num2str(c)]);
        targs = targs(1:4); % #of non foils
        for d = 1:blockinfo.test.indoorcue/2 % (same trials per cond for either cond)
            eval([g ' = [' g ' targs];'])
        end
        % then add foils
        foils = eval(['conditions.test.block' num2str(c)]);
        foils = foils(5);
        startTrial = length(block1.test.conditions) + 1;
        endTrial = startTrial + blockinfo.test.foil - 1;
        for d = startTrial:endTrial
            eval([g ' = [' g ' foils];'])
        end
        % paraShuffle order
        eval([g ' = paraShuffle(' g ');']);
        eval(['f = length(' g ');']);
        % make a redundant variable that represents the current block (post
        % paraShuffle) so that it's easier to refer to it
        h = eval([g]);
        repcount = 0;
        for e = 1:f
            currcond = eval(['block' num2str(c) '.test.conditions{' num2str(e) '}']);
            eval(['block' num2str(c) '.test.term{' num2str(e) '} = h{e};']);
            currterm = eval(['block' num2str(c) '.test.term{' num2str(e) '}']);
            if strcmp(currcond,'TI_2')
                eval(['block' num2str(c) '.test.ForS(' num2str(e) ') = 1;']);
            elseif strcmp(currcond,'TO_2')
                eval(['block' num2str(c) '.test.ForS(' num2str(e) ') = 2;']);
            elseif strcmp(currcond,'TI_4')
                eval(['block' num2str(c) '.test.ForS(' num2str(e) ') = 3;']);
            elseif strcmp(currcond,'TO_4')
                eval(['block' num2str(c) '.test.ForS(' num2str(e) ') = 4;']);
            elseif strcmp(currcond,'F')
                eval(['block' num2str(c) '.test.ForS(' num2str(e) ') = 5;']);
            end
            
            if e > 1
                eval(['tmpj = block' num2str(c) '.test.ForS(' num2str(e) ');']);
                eval(['tmpk = block' num2str(c) '.test.ForS(' num2str(e-1) ');']);
                j=tmpj; % stupid hack for dealing with lack of j/k in the workspace
                k=tmpk;
                if j == k
                    repcount = repcount + 1;
                    eval(['block' num2str(c) '.test.repcount(' num2str(e) ') = ' num2str(repcount) ';']);
                else
                    repcount = 0;
                    eval(['block' num2str(c) '.test.repcount(' num2str(e) ') = ' num2str(repcount) ';']);
                end
            end
            
        end
          
        % the below number can be changed to limit the # of indoor or
        % outdoor/rep
        % Repeats that are allowed.  M = 2 means there can only be 3 indoors
        % or outdoors in a Row
        
        eval(['m = max(block' num2str(c) '.test.repcount);']);
        
        if m > 2
            TooManyRepeats = 1;
        else
            TooManyRepeats = 0;
        end
    end
    clear c d e f g h j k m currterm currcond tempcon;
end

%% Make a single list of trials for both study and test

% Study
TrialCount = 0;
for a = 1:blockinfo.study.num
    eval(['currblock = block' num2str(a) '.study;']);
    for b = 1:length(currblock.conditions)
        TrialCount = TrialCount + 1;
        theOrder.study.index(TrialCount) = TrialCount;
        theOrder.study.block(TrialCount) = a;
        theOrder.study.cond(TrialCount) = currblock.conditions(b);
        theOrder.study.term(TrialCount) = currblock.term(b);
        if currblock.ForS(b) == 1
            theOrder.study.ForS{TrialCount} = 'Indoor';
        elseif currblock.ForS(b) == 2
            theOrder.study.ForS{TrialCount} = 'Outdoor';
        end
        theOrder.study.repcount(TrialCount) = currblock.repcount(b);
    end
end
clear a b;

% Test
TrialCount = 0;
for a = 1:blockinfo.study.num
    eval(['currblock = block' num2str(a) '.test;']);
    for b = 1:length(currblock.conditions)
        TrialCount = TrialCount + 1;
        theOrder.test.index(TrialCount) = TrialCount;
        theOrder.test.block(TrialCount) = a;
        theOrder.test.cond(TrialCount) = currblock.conditions(b);
        theOrder.test.term(TrialCount) = currblock.term(b);
        if (currblock.ForS(b) == 1 ||  currblock.ForS(b) == 3)
            theOrder.test.ForS{TrialCount} = 'Indoor';
        elseif (currblock.ForS(b) == 2 ||  currblock.ForS(b) == 4)
            theOrder.test.ForS{TrialCount} = 'Outdoor';
        end
        theOrder.test.repcount(TrialCount) = currblock.repcount(b);
    end
end
clear a b;

%% Study list: Assign specific stimuli to each condition

% load up the stims that were made by am_stimAssigner
subDir = fullfile(thePath.orderfiles, [subID]);
cd(subDir);
eval(['load ' subID '_stims.mat']);

% hacky insert repeats into study lists
WO_reps = WO;
WI_reps = WI;
insert = @(a, x, n)cat(2,  x(1:n), a, x(n+1:end));

allcons = {'WI' 'WO'};
for p = 1:length(allcons)
    currcon = allcons{p};
    ind = 1;
    eval(['currcon_struc =' currcon '_reps;']);
        
    for i =1:length(currcon_struc.numReps)

        if currcon_struc.numReps(ind) == 4
            currcon_struc.numReps = insert(currcon_struc.numReps(ind), currcon_struc.numReps, ind); %insert rep after i
            currcon_struc.condID = insert(currcon_struc.condID(ind), currcon_struc.condID, ind); %insert rep after i
            currcon_struc.wordID = insert(currcon_struc.wordID(ind), currcon_struc.wordID, ind); %insert rep after i
            currcon_struc.wordName = insert(currcon_struc.wordName(ind), currcon_struc.wordName, ind); %insert rep after i
            currcon_struc.imgID = insert(currcon_struc.imgID(ind), currcon_struc.imgID, ind); %insert rep after i
            currcon_struc.imgName = insert(currcon_struc.imgName(ind), currcon_struc.imgName, ind); %insert rep after i
            currcon_struc.imgFile = insert(currcon_struc.imgFile(ind), currcon_struc.imgFile, ind); %insert rep after i
            currcon_struc.imgType = insert(currcon_struc.imgType(ind), currcon_struc.imgType, ind); %insert rep after i
            currcon_struc.subType = insert(currcon_struc.subType(ind), currcon_struc.subType, ind); %insert rep after i
            currcon_struc.combType = insert(currcon_struc.combType(ind), currcon_struc.combType, ind); %insert rep after i


            ind = ind + 1; % increment once to skip new item
        end

        ind = ind+1; % increment to next item
    end
    
    %now save actual condition
    eval([currcon '_reps = currcon_struc;']);
    
    clear currcon_struc
end

% The below makes a list of the condition ID numbers for each condition
% that is shuffled within block 
allcons = {'WI' 'WO'};
nTrialsBlock = blockinfo.study.indoorpair; %including reps
nBlocks = blockinfo.study.num;
for p = 1:length(allcons)
    currcon = allcons{p};
    eval([currcon '_IDs = [];']);
    for q = 1:nBlocks 
        eval([currcon '_IDs = [' currcon '_IDs paraShuffle( ((q-1)*' num2str(nTrialsBlock) ' +1) : q* ' num2str(nTrialsBlock) ')];']);
    end
    clear currcon;
end

% below is a counter for each condition that keeps track of what the next
% item from each condition number list should be.  NOTE: when 
% wordIndoor_counter is at 5, it doesn't mean that it will pull 
% wordIndoor_condID(5); this is because for each condition, the ID numbers 
% are shuffled (within block), so when wordIndoor_counter is at 5, it will 
% pull the 5th number from this shuffled vector.
WI_counter = 1;
WO_counter = 1;

% now assign the items
TotalTrialsStudy = sum(blockinfo.study.size);
for c = 1:TotalTrialsStudy
    currcon = theOrder.study.cond{c};
    currcounter = [currcon '_counter'];
    e = eval([currcounter]); % where we are in the counter
    d = eval([currcon '_IDs(e);']);
    theOrder.study.condID(c) = eval([currcon '_reps.condID(' num2str(d) ');']);
    theOrder.study.wordID(c) = eval([currcon '_reps.wordID(' num2str(d) ');']);
    theOrder.study.wordName(c) = eval([currcon '_reps.wordName(' num2str(d) ');']);
    theOrder.study.imgID(c) = eval([currcon '_reps.imgID(' num2str(d) ');']);
    theOrder.study.imgName(c) = eval([currcon '_reps.imgName(' num2str(d) ');']);
    theOrder.study.imgFile(c) = eval([currcon '_reps.imgFile(' num2str(d) ');']);
    theOrder.study.imgType(c) = eval([currcon '_reps.imgType(' num2str(d) ');']);
    theOrder.study.subType(c) = eval([currcon '_reps.subType(' num2str(d) ');']);
    theOrder.study.repType(c) = eval([currcon '_reps.numReps(' num2str(d) ');']);

%     theOrder.study.subsubType(c) = eval([currcon '.subsubType(' num2str(d) ');']);
    eval([currcounter ' = ' currcounter ' + 1;']);
    clear d e;
end


%% Now duplicate and reshuffle for second cycle through

% Makes a vector for each block with the appropriate number of each
% condition label and then shuffles that vector
% for c = 1+blockinfo.study.num:blockinfo.study.num*2
for c = 1:blockinfo.study.num
    TooManyRepeats = .5;
    while TooManyRepeats > 0;
        tempcon = eval(['conditions.study.block' num2str(c)]);
        g = ['block' num2str(c) '.study.conditions'];
        eval([g ' = [];']);
        for d = 1:blockinfo.study.indoorpair % (same trials per cond for either cond)
            eval([g ' = [' g ' tempcon];'])
        end
        eval([g ' = paraShuffle(' g ');']);
        eval(['f = length(' g ');']);
        % make a redundant variable that represents the current block (post
        % paraShuffle) so that it's easier to refer to it
        h = eval([g]);
        repcount = 0;
        for e = 1:f
            currcond = eval(['block' num2str(c) '.study.conditions{' num2str(e) '}']);
            eval(['block' num2str(c) '.study.term{' num2str(e) '} = h{e};']);
            currterm = eval(['block' num2str(c) '.study.term{' num2str(e) '}']);
            if strcmp(currcond(2),'I')
                eval(['block' num2str(c) '.study.ForS(' num2str(e) ') = 1;']);
            elseif strcmp(currcond(2),'O')
                eval(['block' num2str(c) '.study.ForS(' num2str(e) ') = 2;']);
            end
            
            if e > 1
                eval(['tmpj = block' num2str(c) '.study.ForS(' num2str(e) ');']);
                eval(['tmpk = block' num2str(c) '.study.ForS(' num2str(e-1) ');']);
                j=tmpj; % stupid hack for dealing with lack of j/k in the workspace
                k=tmpk;
                if j == k
                    repcount = repcount + 1;
                    eval(['block' num2str(c) '.study.repcount(' num2str(e) ') = ' num2str(repcount) ';']);
                else
                    repcount = 0;
                    eval(['block' num2str(c) '.study.repcount(' num2str(e) ') = ' num2str(repcount) ';']);
                end
            end
            
        end
          
        % the below number can be changed to limit the # of indoor or Scene
        % Repeats that are allowed.  M = 2 means there can only be 3 indoors
        % or Scenes in a Row
        
        eval(['m = max(block' num2str(c) '.study.repcount);']);
        
        if m > 2
            TooManyRepeats = 1;
        else
            TooManyRepeats = 0;
        end
    end
    clear c d e f g h j k m currterm currcond tempcon;
end


TrialCount = itemsPerCell.study; % start at 252
%for a = 1+blockinfo.study.num:blockinfo.study.num*2
for a = 1:blockinfo.study.num
    eval(['currblock = block' num2str(a) '.study;']);
    for b = 1:length(currblock.conditions)
        TrialCount = TrialCount + 1;
        theOrder.study.index(TrialCount) = TrialCount;
        theOrder.study.block(TrialCount) = a+nBlocks;
        theOrder.study.cond(TrialCount) = currblock.conditions(b);
        theOrder.study.term(TrialCount) = currblock.term(b);
        if currblock.ForS(b) == 1
            theOrder.study.ForS{TrialCount} = 'Indoor';
        elseif currblock.ForS(b) == 2
            theOrder.study.ForS{TrialCount} = 'Outdoor';
        end
        theOrder.study.repcount(TrialCount) = currblock.repcount(b);
    end
end
clear a b;


% The below makes a list of the condition ID numbers for each condition
% that is shuffled within block 
allcons = {'WI' 'WO'};
nTrialsBlock = blockinfo.study.indoorpair; %including reps
nBlocks = blockinfo.study.num;
for p = 1:length(allcons)
    currcon = allcons{p};
    eval([currcon '_IDs = [];']);
    for q = 1:nBlocks 
        eval([currcon '_IDs = [' currcon '_IDs paraShuffle( ((q-1)*' num2str(nTrialsBlock) ' +1) : q* ' num2str(nTrialsBlock) ')];']);
    end
    clear currcon;
end


% now assign the items
WI_counter = 1;
WO_counter = 1;

TotalTrialsStudy = sum(blockinfo.study.size);
for c = 1:TotalTrialsStudy
    currcon = theOrder.study.cond{c+TotalTrialsStudy};
    currcounter = [currcon '_counter'];
    e = eval([currcounter]); % where we are in the counter
    d = eval([currcon '_IDs(e);']);
    theOrder.study.condID(c+TotalTrialsStudy) = eval([currcon '_reps.condID(' num2str(d) ');']);
    theOrder.study.wordID(c+TotalTrialsStudy) = eval([currcon '_reps.wordID(' num2str(d) ');']);
    theOrder.study.wordName(c+TotalTrialsStudy) = eval([currcon '_reps.wordName(' num2str(d) ');']);
    theOrder.study.imgID(c+TotalTrialsStudy) = eval([currcon '_reps.imgID(' num2str(d) ');']);
    theOrder.study.imgName(c+TotalTrialsStudy) = eval([currcon '_reps.imgName(' num2str(d) ');']);
    theOrder.study.imgFile(c+TotalTrialsStudy) = eval([currcon '_reps.imgFile(' num2str(d) ');']);
    theOrder.study.imgType(c+TotalTrialsStudy) = eval([currcon '_reps.imgType(' num2str(d) ');']);
    theOrder.study.subType(c+TotalTrialsStudy) = eval([currcon '_reps.subType(' num2str(d) ');']);
    theOrder.study.repType(c+TotalTrialsStudy) = eval([currcon '_reps.numReps(' num2str(d) ');']);
%     theOrder.study.subsubType(c) = eval([currcon '.subsubType(' num2str(d) ');']);
    eval([currcounter ' = ' currcounter ' + 1;']);
    clear d e;
end

% now figure out num of rep for each trial
unique_words = unique(theOrder.study.wordID);
unique_words_count = zeros(1,length(unique_words));

for i =1:length(theOrder.study.wordID)
    
    word_ind = find(strcmp(unique_words, theOrder.study.wordID{i}));
    unique_words_count(word_ind) = unique_words_count(word_ind) + 1;
    theOrder.study.repCount(i) = unique_words_count(word_ind);
end


%% now make mat and text files with the full list
cd(subDir);

clear a* S* c* p* q* r* Too* Trial*
% clear bl* F*

cmd = ['save ' subID '_studyList'];
eval(cmd);

txtName = [subID '_studyList.txt'];
fid = fopen(txtName, 'wt');
fprintf(fid, 'index\tblock\tcond\tterm\tForS\tcondID\twordID\twordName\timgID\timgName\timgFile\timgType\tsubType\trepType\trepCount\n'); %subsubType\n');
for e = 1:TotalTrialsStudy*2
    fprintf(fid, '%d\t%d\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%d\t%d\n',...
        theOrder.study.index(e), theOrder.study.block(e), theOrder.study.cond{e}, theOrder.study.term{e},...
        theOrder.study.ForS{e}, theOrder.study.condID{e}, theOrder.study.wordID{e}, theOrder.study.wordName{e}, ...
        theOrder.study.imgID{e}, theOrder.study.imgName{e}, theOrder.study.imgFile{e}, ...
        theOrder.study.imgType{e}, theOrder.study.subType{e}, theOrder.study.repType(e), theOrder.study.repCount(e));%, theOrder.study.subsubType{e});
end

%% Create test lists for each block

% Test block stimuli will depend on stimuli presented during preceding 
% study block 

% The below makes a list of the condition ID numbers for each condition
% that is shuffled within block (like for study)
allcons = {'TI_2' 'TO_2' 'TI_4' 'TO_4' 'F'};
nTrialsBlock_bycon = {blockinfo.test.indoorcue/2, blockinfo.test.outdoorcue/2, ...
    blockinfo.test.indoorcue/2, blockinfo.test.outdoorcue/2,blockinfo.test.foil};
nBlocks = blockinfo.test.num;
for p = 1:length(allcons)
    currcon = allcons{p};
    nTrialsBlock = nTrialsBlock_bycon{p}; 
    eval([currcon '_test_IDs = [];']);
    
    for q = 1:nBlocks
        eval([currcon '_test_IDs = [' currcon '_test_IDs paraShuffle( ((q-1)*' num2str(nTrialsBlock) ' +1) : q* ' num2str(nTrialsBlock) ')];']);
    end
    clear currcon;
end


% set counters
TI_2_counter = 1;
TO_2_counter = 1;
TI_4_counter = 1;
TO_4_counter = 1;
F_counter = 1;
studied_testcons = {'TI_2' 'TO_2' 'TI_4' 'TO_4'};
studied_studycons = {'WI_2' 'WO_2' 'WI_4' 'WO_4'};
foil_con = {'FOIL'};

WI_2 = subsetStruc(WI, 'WI_2', 'combType');
WI_4 = subsetStruc(WI, 'WI_4', 'combType');
WO_2 = subsetStruc(WO, 'WO_2', 'combType');
WO_4 = subsetStruc(WO, 'WO_4', 'combType');

% now assign the items
TotalTrialsTest = sum(blockinfo.test.size);
for c = 1:TotalTrialsTest

    currcon = theOrder.test.cond{c};
    currcounter = [currcon '_counter'];
    e = eval([currcounter]); % where we are in the counter
    d = eval([currcon '_test_IDs(e);']);

    % Foil
    if strcmp(currcon, 'F')
        theOrder.test.condID(c) = eval([currcon '.condID(' num2str(d) ');']);
        theOrder.test.wordID(c) = eval([currcon '.wordID(' num2str(d) ');']);
        theOrder.test.wordName(c) = eval([currcon '.wordName(' num2str(d) ');']);
        theOrder.test.ForS(c) = foil_con;
        theOrder.test.imgID(c) = foil_con;
        theOrder.test.imgName(c) = foil_con;
        theOrder.test.imgFile(c) = foil_con;
        theOrder.test.imgType(c) = foil_con;
        theOrder.test.subType(c) = foil_con;
        theOrder.test.repType(c) = 0;
        eval([currcounter ' = ' currcounter ' + 1;']);
        clear d e;

    % Studied
    else
        % Find corresponding study condition
        test_ind = strcmp(currcon, studied_testcons);
        study_con = studied_studycons{test_ind};

        % fill in info based on new shuffled IDs
        theOrder.test.condID(c) = eval([study_con '.condID(' num2str(d) ');']);
        theOrder.test.wordID(c) = eval([study_con '.wordID(' num2str(d) ');']);
        theOrder.test.wordName(c) = eval([study_con '.wordName(' num2str(d) ');']);
        theOrder.test.imgID(c) = eval([study_con '.imgID(' num2str(d) ');']);
        theOrder.test.imgName(c) = eval([study_con '.imgName(' num2str(d) ');']);
        theOrder.test.imgFile(c) = eval([study_con '.imgFile(' num2str(d) ');']);
        theOrder.test.imgType(c) = eval([study_con '.imgType(' num2str(d) ');']);
        theOrder.test.subType(c) = eval([study_con '.subType(' num2str(d) ');']);
        theOrder.test.repType(c) = eval([study_con '.numReps(' num2str(d) ');']);
        eval([currcounter ' = ' currcounter ' + 1;']);
        clear d e;
    end      
end

%% Set up shock
%shock on odd blocks = 0
%shock on even blocks = 1

for c = 1:TotalTrialsTest
    if mod(theOrder.test.block(c),2) == 0 %even
        if mod(str2double(snum(3:end)),2) == 0
            theOrder.test.shockCond{c} = 'safe';
        else
            theOrder.test.shockCond{c} = 'threat';
        end
    else
        if mod(str2double(snum(3:end)),2) == 0
            theOrder.test.shockCond{c} = 'threat';
        else
            theOrder.test.shockCond{c} = 'safe';
        end
    end
end

%num shocks
for i =1:blockinfo.test.num/2
    if randn(1) > 0
        num_shocks(i) = 2;
    else
        num_shocks(i) = 1;
    end
end

trials_perblock = TotalTrialsTest/blockinfo.test.num;
safeblock = repmat(0, trials_perblock, 1);
threat1 = [repmat(0, trials_perblock-num_shocks(1), 1); repmat(1, num_shocks(1), 1)]; threat1=paraShuffle(threat1);
threat2 = [repmat(0, trials_perblock-num_shocks(2), 1); repmat(1, num_shocks(2), 1)]; threat2=paraShuffle(threat2);
threat3 = [repmat(0, trials_perblock-num_shocks(3), 1); repmat(1, num_shocks(3), 1)]; threat3=paraShuffle(threat3);


if mod(str2double(snum(3:end)),2) == 0 % shock on odd blocks
    theOrder.test.shockTrial = [threat1;safeblock;threat2;safeblock;threat3;safeblock];
else% shock on even blocks
    theOrder.test.shockTrial = [safeblock;threat1;safeblock;threat2;safeblock;threat3];
end


%% now make mat and text files with the full list
cd(subDir);

clear a* F* S* bl* c* p* q* r* Too* Trial*
cmd = ['save ' subID '_testList'];
eval(cmd);

txtName = [subID '_testList.txt'];
fid = fopen(txtName, 'wt');
fprintf(fid, 'index\tblock\tcond\tshockCond\tshockTrial\tterm\tForS\tcondID\twordID\twordName\timgID\timgName\timgFile\timgType\tsubType\trepType\n');
for e = 1:TotalTrialsTest
    fprintf(fid, '%d\t%d\t%s\t%s\t%d\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%d\n',...
        theOrder.test.index(e), theOrder.test.block(e), theOrder.test.cond{e}, theOrder.test.shockCond{e},....
        theOrder.test.shockTrial(e), theOrder.test.term{e},...
        theOrder.test.ForS{e}, theOrder.test.condID{e}, theOrder.test.wordID{e}, theOrder.test.wordName{e}, ...
        theOrder.test.imgID{e}, theOrder.test.imgName{e}, theOrder.test.imgFile{e}, ...
        theOrder.test.imgType{e}, theOrder.test.subType{e}, theOrder.test.repType(e));
end

