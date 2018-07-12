% Wrapper script for Localizer task
% This script loads the paths for the experiment, creates a stimulus order
% file for a given subject, and runs the task
%
% written by SG in March, 2015
%

% define and load paths
[S,thePath] = setupScript('localizer');

% define subject-specific info
subID = input('What is the subject ID? ','s');

% determine whether stims need to be assigned and order lists created
cd(thePath.orderfiles);
useStims = 0;
if exist(fullfile(thePath.orderfiles,subID,sprintf('%s_locList.mat',subID)),'file') > 0
    useStims = input('Use existing stim file? (1=yes,0=no) ');
end

%% Some info about block & trial counts (for sub/subsubtype distribution)
blockinfo.run_num = 2; % how many blocks (scanner runs) are there
blockinfo.miniblock_num = 4; % how many miniblocks per category per block
blockinfo.stim_per_miniblock = 10; % how many stim per block? (must be divisible by subcat_num)
blockinfo.task = 1; % 1=category judgment, 2=1back, 3=2back, 4=oddball
blockinfo.max_cat_seqreps = 2; % max # of miniblocks of one category in a row
blockinfo.rest = 1; % include rest period after each miniblock?

prac_blockinfo.run_num = 1; % how many blocks (scanner runs) are there
prac_blockinfo.miniblock_num = 1; % how many miniblocks per category per block
prac_blockinfo.stim_per_miniblock = 10; % how many stim per block? (must be divisible by subcat_num)
prac_blockinfo.task = 1; % 1=category judgment, 2=1back, 3=2back, 4=oddball
prac_blockinfo.max_cat_seqreps = 2; % max # of miniblocks of one category in a row
prac_blockinfo.rest = 1; % include rest period after each miniblock?

%% Make order files (if necessary), and run task
cd(thePath.scripts);
if useStims == 0 % create order lists, then run task
    localizer_makeOrder(subID,thePath,'inputlist.xls','_locList',blockinfo);
    localizer_makeOrder(subID,thePath,'prac_inputlist.xls','_locList_prac',prac_blockinfo);
    
    localizer_run(subID,thePath);
    
elseif useStims == 1 % run task
    localizer_run(subID,thePath);
end

clear all;