% Wrapper script for Associative Place (ap) task w/stress manipulation
% This script loads the paths for the experiment, creates a stimulus order
% file for a given subject, and runs the task
%
% written by SG 05/07/14, adapted from BK's RIFS task and VC and SGs
% AM Task

% Screen('Preference', 'SkipSyncTests', 1)

% define and load paths
[S,thePath] = setupScript();

% define subject-specific info
subID = input('What is the subject ID? ','s');

% determine whether stims need to be assigned and order lists created
cd(thePath.orderfiles);
useStims = 0;
if exist(fullfile(thePath.orderfiles,subID,sprintf('%s_stims.mat',subID)),'file')
    useStims = input('Use existing stim file? (1=yes,0=no) ');
end

cd(thePath.scripts);
if useStims == 0 % create order lists, then run task
    ap_stimAssigner(subID,thePath);
    ap_makeOrder(subID,thePath);
    ap_prac_stimAssigner(subID,thePath);
    ap_prac_makeOrder(subID,thePath);
    
    ap_run(subID,thePath);
    
elseif useStims == 1 % run task
    ap_run(subID,thePath);
end

clear all;