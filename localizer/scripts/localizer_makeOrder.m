function localizer_makeOrder(subID,thePath,inputlist,savePath,blockinfo)
% %% Some info about block & trial counts (for sub/subsubtype distribution)
% blockinfo.run_num = 2; % how many blocks (scanner runs) are there
% blockinfo.miniblock_num = 4; % how many miniblocks per category per block
% blockinfo.stim_per_miniblock = 10; % how many stim per block? (must be divisible by subcat_num)
% blockinfo.task = 1; % 1=category judgment, 2=1back, 3=2back, 4=oddball
% blockinfo.max_cat_seqreps = 2; % max # of miniblocks of one category in a row
% blockinfo.rest = 1; % include rest period after each miniblock?

%% Makes the stim list for each subject
% Adapted from Anthony Stigliani's makeorder_fLoc.m

%% initialize randomness  
rand('twister',sum(100*clock));


%% Read in stim info & calculate other info
[~,TXT,~] = xlsread(inputlist);
cat_col = 1;
subcat_col = 2;
imgPath_col = 3;
imgNum_col = 4;

blockinfo.cat_list = unique(TXT(2:end,cat_col), 'stable');
blockinfo.subcat_list = unique(TXT(2:end,subcat_col), 'stable');

ncats = numel(blockinfo.cat_list);
nsubcats = numel(unique(TXT(2:end, ...
    subcat_col)))/ncats; % how many subcategories per category
nconds = ncats; % number of conditions
nstim = blockinfo.run_num * blockinfo.miniblock_num * ...
    blockinfo.stim_per_miniblock / nsubcats; % total nstim per subcategory

%% GENERATE STIMULUS SEQUENCES

% randomize order of stimulus numbers for each subcategory
for iSubcat = 1:ncats*nsubcats
    for iRun = 1:ceil(blockinfo.run_num/3)
        stimnums(nstim*(iRun-1)+1:nstim*(iRun-1)+nstim,iSubcat) = Shuffle(1:nstim);
    end
end

% convert stim subcat numbers to indices into TXT
col_increment = 0:ncats*nsubcats-1; % label 0-(n-1)
col_increment = col_increment .* nstim;
col_increment = col_increment + 1; % adjust for header row

stim_ind = bsxfun(@plus,stimnums,col_increment);

% create miniblock sequence data structure, with max # seqreps per cat
for iRun = 1:blockinfo.run_num
    
    TooManyRepeats = .5;
    while TooManyRepeats > 0;
        % create random order of blocks
        miniblockorder = Shuffle(repmat(1:nconds,1,blockinfo.miniblock_num));

        % determine repetitions of category in a row
        repcount = 0;
        repcount_list = [];
        for iTrial=2:length(miniblockorder)
            if miniblockorder(iTrial) == miniblockorder(iTrial-1)
                repcount = repcount + 1;
                repcount_list(iTrial) = repcount;
            else
                repcount = 0;
                repcount_list(iTrial) = repcount;
            end    
        end

        % find max reps in a row, and make sure its not more than specified!
        m = max(repcount_list);
        if m > blockinfo.max_cat_seqreps-1
            TooManyRepeats = 1;
        else
            TooManyRepeats = 0;
        end
    end 
    
    % save to stimseq
    stimseq(iRun).miniblock_cat = repmat(miniblockorder,[blockinfo.stim_per_miniblock 1]);
    stimseq(iRun).miniblock_cat = stimseq(iRun).miniblock_cat(:)';
    
    stimseq(iRun).miniblock = repmat(1:blockinfo.miniblock_num*nconds, [blockinfo.stim_per_miniblock 1]);
    stimseq(iRun).miniblock = stimseq(iRun).miniblock(:)';
    
end


% Assign subcategory & stimulus to each trial
subcat_list = repmat(1:nsubcats, 1, blockinfo.stim_per_miniblock/2); % subcats within miniblock

subcat_ind = repmat(1, 1, nsubcats*ncats); % current row #s in stim_ind 
for iRun = 1:blockinfo.run_num
    
    % assign subcategory to each trial within each miniblock
    subcat_miniblock = [];
    for iMiniBlock = 1:blockinfo.miniblock_num*nconds
        % Shuffle subcategory for each miniblock
        subcat_miniblock = [subcat_miniblock Shuffle(subcat_list)];
    end
    
    stimseq(iRun).subcat_num = subcat_miniblock;
    
    for iTrial = 1:length(stimseq(iRun).miniblock)
        
        cat_num = stimseq(iRun).miniblock_cat(iTrial);
        stimseq(iRun).cat_name(iTrial) = blockinfo.cat_list(cat_num);
        
        subcat_num = stimseq(iRun).subcat_num(iTrial);
        
        ind2stim_ind = (cat_num * nsubcats-(nsubcats-1)) + subcat_num-1; % subcat specific ind
        stimseq(iRun).subcat_name(iTrial) = blockinfo.subcat_list(ind2stim_ind);

        ind2TXT = stim_ind(subcat_ind(ind2stim_ind), ind2stim_ind);
        
        stimseq(iRun).imgFile(iTrial) = TXT(ind2TXT, imgPath_col);
        stimseq(iRun).imgNum(iTrial) = TXT(ind2TXT, imgNum_col);
        stimseq(iRun).subcat(iTrial) = TXT(ind2TXT, subcat_col);
       
        % increment subcat specific ind
        subcat_ind(ind2stim_ind) = subcat_ind(ind2stim_ind) + 1;
    end
end

% Add in rest trial if requested
if blockinfo.rest
    stimseq_fields = fields(stimseq);
%     stimseq_rest = [];
    
    for iRun = 1:blockinfo.run_num
        for iField = 1:length(stimseq_fields)
            field_name = stimseq_fields{iField};
            tmpField = eval(['stimseq(iRun).' field_name]);
            
            if iscell(tmpField)
                eval(['stimseq(iRun).' field_name '= insertn(tmpField, {''rest''}, blockinfo.stim_per_miniblock)'';'])
            else
                eval(['stimseq(iRun).' field_name '= insertn(tmpField, 0, blockinfo.stim_per_miniblock)'';'])
            end
        end
    end
end


%% Save to file

%% now make mat and text files with the full list
subDir = fullfile(thePath.orderfiles, [subID]);
if ~exist(subDir)
   mkdir(subDir);
end
cd(subDir);

cmd = ['save ' subID savePath];
eval(cmd);

txtName = [subID savePath '.txt'];
fid = fopen(txtName, 'wt');
fprintf(fid, 'index\tblock\tminiblock\tcategory\tsubcategory\timgID\timgFile\n');
for iRun = 1:blockinfo.run_num
    for iTrial = 1:length(stimseq(1).miniblock)
        fprintf(fid, '%d\t%d\t%d\t%s\t%s\t%s\t%s\n',...
            iTrial, iRun, stimseq(iRun).miniblock(iTrial), ...
            stimseq(iRun).cat_name{iTrial}, ...
            stimseq(iRun).subcat_name{iTrial}, ...
            stimseq(iRun).imgNum{iTrial}, ...
            stimseq(iRun).imgFile{iTrial});
    end
end