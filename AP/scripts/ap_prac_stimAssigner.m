function ap_prac_stimAssigner(subID,thePath)
% borrowed from regular stim assigner

%% initialize randomness  
rand('twister',sum(100*clock));

% Setup num blocks + type counts
blockinfo.study.num = 1; %block nums
blockinfo.study.indoorpair = 5;
blockinfo.study.outdoorpair = 5;

total_words = 13;
total_indoor = 5;
total_outdoor = 5;

% how to counterbalance within conditions
indoor_by_subtype = 0;
outdoor_by_subtype = 0;

% stimlist
[NUMERIC,TXT,RAW] = xlsread('prac_inputlist.xls');


% Below things are grouped according to what should be paraShuffled together

% words (rows 2-#)
wordID = TXT(2:(total_words+1),1);
wordName = TXT(2:(total_words+1),2);

% Faces (rows 2-#)
indoorID = TXT(2:(total_indoor+1),3);
indoorName = TXT(2:(total_indoor+1),4);
indoorFile = TXT(2:(total_indoor+1),5);

% Scenes (rows 2-#)
outdoorID = TXT(2:(total_outdoor+1),6);
outdoorName = TXT(2:(total_outdoor+1),7);
outdoorFile = TXT(2:(total_outdoor+1),8);
creator = TXT(2:(total_outdoor+1),9);

%% paraShuffle each of the sets
% the words
[wordID, wordName] = paraShuffle(wordID, wordName);

% the Faces
[indoorID, indoorName, indoorFile] = paraShuffle(indoorID, indoorName, indoorFile);

% the Scenes
[outdoorID, outdoorName, outdoorFile, creator] = paraShuffle(outdoorID, outdoorName, outdoorFile, creator);


%% Assign specific stims to conditions and create pairs
if indoor_by_subtype == 1
    for a = 1:length(indoorID)
        WI.condID{a} = ['WO' num2str(a)];
        WI.wordID(a) = wordID(a);
        WI.wordName(a) = wordName(a);
        WI.imgID(a) = faceID_by_subtype(a);
        WI.imgName(a) = faceName_by_subtype(a);
        WI.imgFile(a) = faceFile_by_subtype(a);
        WI.imgType{a} = ['indoor'];
        WI.subType(a) = actOrSing_by_subtype(a);
        clear a;
    end
else
    for a = 1:length(indoorID)
        WI.condID{a} = ['WI' num2str(a)];
        WI.wordID(a) = wordID(a);
        WI.wordName(a) = wordName(a);
        WI.imgID(a) = indoorID(a);
        WI.imgName(a) = indoorName(a);
        WI.imgFile(a) = indoorFile(a);
        WI.imgType{a} = ['indoor'];
        WI.subType{a} = 'none';
        clear a;
    end
end

for a = 1:length(outdoorID)
    WO.condID{a} = ['WO_' num2str(a)];
    WO.wordID(a) = wordID(a+length(indoorID));
    WO.wordName(a) = wordName(a+length(indoorID));
    WO.imgID(a) = outdoorID(a);
    WO.imgName(a) = outdoorName(a);
    WO.imgFile(a) = outdoorFile(a);
    WO.imgType{a} = ['outdoor'];
    WO.subType{a} = 'none';
    clear a;
end
    
for a = 1:(length(wordID)-(length(indoorID)+length(outdoorID)))
    F.condID{a} = ['F' num2str(a)];
    F.wordID(a) = wordID(a+length(indoorID)+length(outdoorID));
    F.wordName(a) = wordName(a+length(indoorID)+length(outdoorID));
    clear a;
end

cd(thePath.orderfiles);
subDir = fullfile(thePath.orderfiles, [subID]);
if ~exist(subDir)
   mkdir(subDir);
end
cd(subDir);
eval(['save ' subID '_prac_stims WI WO F']);
cd(thePath.scripts);

