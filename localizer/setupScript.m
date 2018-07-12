function [S,thePath] = setupScript(expName)
% setupScript
% This script loads the paths for the experiment (expName = 'localizer'), and creates
% the variable thePath in the workspace.

%% system specific info
[~, hostname]=system('hostname'); 
hostname = hostname(1:end-1); % remove weird extra stuff

[~, user] = system('whoami');
user = user(1:end-1);

switch hostname
    case 'STEPHANIEsMBP2.att.net'
        thePath.main = fullfile(['/Users/', user, '/Experiments/'], expName);
        thePath.felix = ['/Users/', user, '/Code/felix/'];
        
        Screen('Preference', 'SkipSyncTests', 1);
    case 'Curtis'
        thePath.main = fullfile(['/Users/', user, '/Experiments/steph/'], expName);
        thePath.felix = ['/Users/', user, '/Code/felix/'];
    case 'Ari'
        thePath.main = fullfile(['/Users/', user, '/Experiments/steph/'], expName);
        thePath.felix = ['/Users/', user, '/Code/felix/'];
        
    case 'sgagnon-desktop.stanford.edu';
        thePath.main = fullfile(['/Users/', user, '/Experiments/'], expName);
        thePath.felix = ['/Users/', user, '/Code/felix/'];
end

if ismac
    S.separator = '/';
else
    S.separator = '\';
end

thePath.scripts = fullfile(thePath.main, 'scripts');
thePath.stim = fullfile(thePath.main, 'stimuli');
thePath.data = fullfile(thePath.main, 'data');
thePath.orderfiles = fullfile(thePath.main, 'orderfiles');
thePath.analysis = fullfile(thePath.main, 'analysis');


% Add relevant paths for this experiment
names = fieldnames(thePath);
for f = 1:length(names)
    eval(['addpath(genpath(thePath.' names{f} '))']);
    fprintf(['added ' names{f} '\n']);
end

addpath(genpath(thePath.felix));

cd(thePath.main);
