function [S,thePath] = setupScript()
% setupScript
% This script loads the paths for the experiment, and creates
% the variable thePath in the workspace.

%% system specific info
[d hostname]=system('hostname'); 
switch strcat(hostname)
    case 'sgagnon-laptop.local' % Steph's macbook pro in lab
        thePath.main = ['/Users/stephaniegagnon/Experiments/AssocPlace/'];
    case 'sgagnon-desktop.stanford.edu'
        thePath.main = ['/Users/steph-backup/Experiments/AssocPlace'];
        thePath.felix = ['/Users/steph-backup/Code/felix/scripts'];
    case 'dn0a22125c.sunet'
        thePath.main = ['/Users/steph-backup/Experiments/AssocPlace'];
    case 'sgagnon-laptop.att.net'
        thePath.main = ['/Users/stephaniegagnon/Experiments/AssocPlace/'];
    case 'nico'
        thePath.main = ['C:\Users\waglab\Desktop\Steph\Experiments\'];
    case 'Curtis'
        thePath.main = ['/Users/waglab/Experiments/steph/AssocPlace/'];
        thePath.felix = ['/Users/waglab/Code/felix/scripts'];
    case 'Ari'
        thePath.main = ['/Users/waglab/Experiments/steph/AssocPlace/'];    
        thePath.felix = ['/Users/waglab/Code/felix/scripts'];
    case 'valerie-desktop.stanford.edu' % valerie's desktop
        thePath.main = ['/Users/vacarr/Desktop/Experiments/'];
    case 'wagner-labs-macbook-pro.local' % wendyo offline
        thePath.main = ['/Users/waglab/Experiments/valerie/Experiments/'];
    otherwise % stph
        thePath.main = ['/Users/sgagnon/Experiments/AssocPlace/'];
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
