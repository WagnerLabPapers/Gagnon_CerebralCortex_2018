HIPPOVOL
Hippocampal segmentation along its longitudinal axis

Notes for sgagnon@stanford.edu


First: extract the hippocampal labels from aseg. Assuming that you are always located in the SUBJECTS_DIR of your project, this is what you have to do: 
mri_extract_label  <SUBJECT_NAME>/mri/aseg.mgz 17  <SUBJECT_NAME>/mri/lh.asegHippo.mgz
mri_extract_label  <SUBJECT_NAME>/mri/aseg.mgz 53  <SUBJECT_NAME>/mri/rh.asegHippo.mgz
This will create the lh.asegHippo.mgz and rh.asegHippo.mgz inside the mri folder of each subject in your experiment. 

NOTE1: You will have result based on aseg. I've used other options: for example, adding all the hippo-subfields from version 5.3, and the resulting hippocampus it is a little bit more refined than the original aseg version. I am waiting for FS6.0, then I will use the results of the new hippo-subfields code to create new and more refined whole hippocampi by default. Will let you know. In any case, the results are usually highly correlated so hopefully you will find similar results with your data. 

NOTE2: The resulting labels (HEAD, BODY, TAIL, POSTERIOR) will be stored in the same location: in every subjects mri folder with .mgz extension. 

Next: run the segmentation: 
- Unzip the code and add it to your Matlab path. 
- Open Matlab and go to the SUBJECTS_DIR
- Write in the command line: edit hip_lanzar.m
- Edit at least the wildcard to detect all your subjects. 
- Run hip_lanzar

OUTPUT: the stat file will be a csv file in SUBJECTS_DIR/hippovol/, and as said before, every subject will have its segmented hippocampus under the folder mri 


TODO: 
- add notes on all the options of hip_lanzar
- comment the code, and check there are no comments in Spanish
- change hip_lanzar to hip_run and make it accept the options without the need of editing the file. 
- Explain the options on LBFGS, fminunc and sge cluster (right now it is setup so that it is not using the cluster or the parallel toolbox, but it is using the Optimization Toolbox, because the LBFGS package is OS dependant)
- Extract hipposubfields with FS6 and create whole hippocampus automatically out of it. 
- ...






SUPPLEMENTARY MATERIALS
About the MNI implementation
The Talairach/MNI coordinate-based segmentation entailed an additional step relative to the two previous methods. Since the FS package already provides the transformation matrix of the Talairach space (i.e., talairach.lta), we used it to convert left and right hippocampus. Once in the transformed space, the coordinate to separate anterior from posterior hippocampus is always the same (i.e., Y = -20) in the Talairach space (Poppenk et al., 2013). And, as in the previous methods, the remaining section posterior hippocampal section was divided in half to obtain the body and tail. Nevertheless, it is important to indicate that the Talairach/MNI coordinate-based segmentation has the inherent caveat that the Talairach transform is affine and not lineal. To solve this issue, the head, body and tail volumes obtained with this method were divided by the Jacobian of the transformation matrix to scale them back to the original hippocampal volume values. 




