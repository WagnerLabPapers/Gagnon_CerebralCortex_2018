subject_path = '/share/awagner/sgagnon/SST/scripts/subjects.txt';
% subject_path = '/Volumes/group/awagner/sgagnon/ObjFam/data/subids_subset_rmbad.txt';
% subject_path = '/share/awagner/sgagnon/PARC/scripts/subjects_subset.txt';
% subject_path = '/share/awagner/sgagnon/AP/scripts/subjects_new.txt';
% subject_path = '/Volumes/group/awagner/sgagnon/AP/scripts/subjects_new.txt';
subids = textread(subject_path, '%s');

%par
for iSub = 1:length(subids)
    iSub
    hip_lanzar(subids{iSub});
    %hip_lanzar('ap164');
end