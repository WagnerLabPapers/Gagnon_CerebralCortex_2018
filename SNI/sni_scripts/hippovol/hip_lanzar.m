function [] = hip_lanzar(subid)

% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2016
% Contact: garikoitz@gmail.com
% hippovol v0.1

% addpath(genpath('/Applications/freesurfer/matlab'));
addpath(genpath('/share/software/MATLAB-2014a/bin/matlab')); % if on the vm
% clear all; close all; clc;

subid

%% EDIT THIS
sub = dir(['/share/awagner/sgagnon/SST/data/', subid, '*']); % Wildcard to select all the subjects you are interested. 
% sub = dir(['/share/awagner/sgagnon/AP/data/', subid, '*']); % Wildcard to select all the subjects you are interested. 
% sub = dir(['/Volumes/group/awagner/sgagnon/ObjFam/data/', subid, '*']); % Wildcard to select all the subjects you are interested. 
% sub = dir(['/share/awagner/sgagnon/PARC/data/', subid, '*']); % Wildcard to select all the subjects you are interested. 
Head_Perc_List = 417; % Percentage of length to segment head. We can talk about it, but you can start using this value. 
WRITE_MGZ = 1;  % 1: to write the mgz-s to file, set it to zero in tessting maybe. 
% It will prepend this to the stat files and to the mgz files.
structName = 'HIPPO';
% If we make minor changes we can save them all with different revisions
sufixName = 'v01'; % To identify different versions of output files. 
% END EDIT THIS




%% YOU HAVE MORE OPTIONS HERE BUT DON'T CHANGE THEM FOR NOW
basedir = pwd;
cluster = 0;  % Do not use cluster for now. 
optim = 1; % 1: use matlab's internal fmninunc, 0: use lbfsg in cluster 

% loop over those methods
% lta_list = {'Acqu','A', 'B', 'A1','B1','A2', 'B2','PCA'};
lta_list = {'Acqu'};
MNI_lta_list = {'MNI'}; % Use it for the MNI case
% landmark_lta_list = {'AAcqu', 'BAcqu', 'AT1','BT1','AT2', 'BT2', ...
%                                        'APCA1','BPCA1', 'APCA2','BPCA2'};
landmark_lta_list = {'APCA1','BPCA1', 'APCA2','BPCA2'};
% orientations = {'Acqu', 'Bezier', 'PCA'};
orientations = {'PCA'};
% methods = {'PERC', 'Landmark', 'MNI'};
methods = {'PERC'};
% ComoPost = {'Insausti', 'Tail'}
ComoPost = {'Insausti'};
Rater = {'A', 'B'};

% Head_Perc_List = 201:1:800;
% Head_Perc_List = 393;
% Head_Perc_List = [401 451];

% call hippovol function with these variables
DEBUG=0;    % 1 for showing the plots of the images
orden = 2; % order for Bezier function
mydecimate = 5; % decimation in Bezier function

% it can be 'aseg', 'koen', 'eug1', sabe filenames according to convention 
% so it can be read automatically by hippovol
orig_datos   = 'aseg';
SUBJECTS_DIR = basedir;

% It will save the stats in this folder
glm_datos_dir = [SUBJECTS_DIR filesep 'hippovol' filesep 'data_01']; 
mat_dirs = [glm_datos_dir filesep 'mats'];
mkdirquiet(glm_datos_dir);
mkdirquiet(mat_dirs);


for jj=1:length(methods)
    method = methods{jj};
    if strcmp(method, 'Landmark') % steph edited from strcomp
            lta_list = landmark_lta_list;
    elseif strcmp(method, 'MNI')
            lta_list = MNI_lta_list;
    end
    for kk=1:length(orientations)
        orientation = orientations{kk};
        for ii=1:length(lta_list)
            lta = lta_list{ii};
            for perci=1:length(Head_Perc_List)  
                perc = Head_Perc_List(perci);
                save([mat_dirs filesep methods{jj} '_' orientations{kk} '_' ...
                      lta_list{ii} '_' num2str(Head_Perc_List(perci))]);
                fcmd = ['hippovol(''' mat_dirs '/' methods{jj} '_' ...
                        orientations{kk} '_' lta_list{ii} ...
                        '_' num2str(Head_Perc_List(perci)) ''')' ];
                if cluster
                    % -nojvm removed so that matlabpool is working
                    cmd = ['matlab -nosplash -nodesktop -nodisplay  -r ""' ...
                           fcmd ';exit""'];
                    spcmd = ['qsub -q all.q $mySH/RunMatlab.sh "' cmd '"']
                    [status,result] = system(spcmd);
                else
                    eval(fcmd);
                end
                cd(basedir);
            end
        end
    end
end

% example:
% hippovol('/bcbl/home/public/Gari/PCA/glm/datos_05/mats/PERC_Bezier_Acqu_422')
