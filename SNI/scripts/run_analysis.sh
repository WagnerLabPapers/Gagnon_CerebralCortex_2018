#!/bin/bash

# subj dir setup
experiment=AP
# init_path=/share
init_path=/Volumes/group
SUBJECTS_DIR=$init_path/awagner/sgagnon/$experiment/data
export SUBJECTS_DIR

# Lyman Setup
LYMAN_DIR=$init_path/awagner/sgagnon/$experiment/scripts
export LYMAN_DIR


##############################################
# Visualize reconstruction
##############################################

# export SUBJ=ap165
# freeview -v $SUBJECTS_DIR/$SUBJ/mri/orig.mgz -v $SUBJECTS_DIR/$SUBJ/mri/brainmask.mgz:colormap=jet:colorscale=0,1:opacity=0.3 -f $SUBJECTS_DIR/$SUBJ/surf/lh.pial:edgecolor='255,0,0' -f $SUBJECTS_DIR/$SUBJ/surf/rh.pial:edgecolor='255,0,0' &

##############################################
# Estimate volume-based reg to MNI template (for ffx in mni, or mfx)
##############################################
# Run this on desktop with ANTS installed

# sub_list=subjects_new.txt
# sub_list=ap174
# run_warp.py -s $sub_list -plugin linear
# anatomy_snapshots.py -subjects $sub_list


##############################################
# Register timeseries for MVPA analyses
##############################################
# 
# sub_list=subjects_new.txt
# sub_list=ap166
# exp=mvpa
# 
# run_fmri.py -s $sub_list -e $exp -w preproc reg -timeseries -regspace epi -unsmoothed -n 20


# sub_list=subjects_new.txt
# sub_list=subjects_rerun.txt
# exp=mvpa_raw
# run_fmri.py -s $sub_list -e $exp -w preproc reg -timeseries -regspace epi -unsmoothed -n 20

# sub_list=ap173
# exp=mvpa_raw
# run_fmri.py -s $sub_list -e $exp -w preproc reg -timeseries -regspace epi -unsmoothed -n 20



##############################################
# Transform mask to anatomical space to see how well it converts
##############################################
# 
# subid=ap100
# rigid=$init_path/awagner/sgagnon/$experiment/analysis/mvpa_raw/$subid/preproc/run_1/func2anat_flirt.mat
# ref=$SUBJECTS_DIR/$subid/mri/T1.mgz
# ref2=$SUBJECTS_DIR/$subid/mri/T1.nii
# input=$SUBJECTS_DIR/$subid/masks/bilat-hippocampus_eroded.nii.gz
# output=$SUBJECTS_DIR/$subid/masks/bilat-hippocampus_eroded_ANAT.nii.gz
# mri_convert --in_type mgz --out_type nii $ref $ref2
# applywarp --ref=$ref2 --in=$input --out=$output --premat=$rigid

# input=$init_path/awagner/sgagnon/AP/analysis/mvpa_raw/$subid/importance_maps/bilat-hippocampus_coef_place.nii.gz
# output=$init_path/awagner/sgagnon/AP/analysis/mvpa_raw/$subid/importance_maps/bilat-hippocampus_coef_place_ANAT.nii.gz
# applywarp --ref=$ref2 --in=$input --out=$output --premat=$rigid

# input=$SUBJECTS_DIR/$subid/masks/bilat-parahipp_fusi_inftemp.nii.gz
# output=$SUBJECTS_DIR/$subid/masks/bilat-parahipp_fusi_inftemp_ANAT.nii.gz
# applywarp --ref=$ref2 --in=$input --out=$output --premat=$rigid



##############################################
# Main analyses (on raw BOLD timeseries)
##############################################
# 
# sub_list=subjects_rerun.txt
# exp_names=ap_memory_raw
# 
# for exp in $exp_names; do
# 	echo $exp
# 	#Run this first

# 	run_fmri.py -s $sub_list -e $exp -w preproc -n 20
# 	run_fmri.py -s $sub_list -e $exp -w model -unsmoothed -n 20
# 	run_fmri.py -s $sub_list -e $exp -w model -n 20

	# Then run script to replace null condition contrasts will null copes/varcopes
	# in ~/Experiments/AssocPlace/analysis/Generate onsets for fMRI.ipynb
		
	# Then, run the following
# 	run_fmri.py -s $sub_list -e $exp -w reg ffx -regspace epi -unsmoothed -n 20
#  	run_fmri.py -s $sub_list -e $exp -w reg ffx -regspace mni -n 20
# 	surface_snapshots.py -subjects $sub_list -experiment $exp -level subject -regspace mni
# 
# 	run_group.py -s subjects_control.txt -exp $exp -output group_control -n 20
# 	surface_snapshots.py -subjects subjects_control.txt -experiment $exp -level group -output group_control -geometry semi7
# 	run_group.py -s subjects_shock.txt -exp $exp -output group_stress -n 20 
# 	surface_snapshots.py -subjects subjects_shock.txt -experiment $exp -level group -output group_stress -geometry semi7

# done


## Analyze by shockCondition
##############################
# sub_list=subjects_byshockCondSH.txt # eg exclude 121 and 173 with less than 2 runs of SH or CR
# exp_names=ap_memory_raw
# alt=byshockCond

# for exp in $exp_names; do
# 	echo $exp

# 	run_fmri.py -s $sub_list -e $exp -alt $alt -w model -unsmoothed -n 20
# 	run_fmri.py -s $sub_list -e $exp -alt $alt -w model -n 20

	# Then run script to replace null condition contrasts will null copes/varcopes
	# in ~/Experiments/AssocPlace/analysis/Generate onsets for fMRI.ipynb
		
	# Then, run the following
# 	run_fmri.py -s $sub_list -e $exp -alt $alt -w reg ffx -regspace epi -unsmoothed -n 20
#  	run_fmri.py -s $sub_list -e $exp -alt $alt -w reg ffx -regspace mni -n 20
# 	surface_snapshots.py -subjects $sub_list -experiment $exp-$alt_model -level subject -regspace mni
# 

	## RUN THESE w/stephs version of lyman -- output dof merged file for stress safe> threat comparison
# 	run_group.py -s subjects_control_byshockCondSH.txt -exp $exp -alt $alt -output group_control -n 8
# 	surface_snapshots.py -subjects subjects_control_byshockCondSH.txt -experiment $exp -alt $alt -level group -output group_control -geometry semi7
# 	run_group.py -s subjects_shock_byshockCondSH.txt -exp $exp -alt $alt -output group_stress -n 8
# 	surface_snapshots.py -subjects subjects_shock_byshockCondSH.txt -experiment $exp -alt $alt -level group -output group_stress -geometry semi7
# 
# done


##############################################
# Create masks
##############################################

# sub_list=subjects_rerun.txt
# sub_list=subjects.txt
# 
# IFS=, 
# while read subjid; do
#     mri_annotation2label --subject $subjid --hemi rh --outdir $SUBJECTS_DIR/$subjid/label
# 	mri_annotation2label --subject $subjid --hemi lh --outdir $SUBJECTS_DIR/$subjid/label
# done < $sub_list

# subjid=ap154
# mri_annotation2label --subject $subjid --hemi rh --outdir $SUBJECTS_DIR/$subjid/label
# mri_annotation2label --subject $subjid --hemi lh --outdir $SUBJECTS_DIR/$subjid/label


# VTC for multivariate reinstatement
##############################################

# sub_list=subjects.txt
# sub_list=ap154
# for mask in fusiform inferiortemporal parahippocampal lateraloccipital; do
#     make_masks.py -s $sub_list -roi bilat-$mask -exp mvpa_raw \
#         -label $mask -native -sample graymid -unsmoothed
# done

## Also try out inferior parietal / angular-ish region
# sub_list=subjects.txt
# for mask in inferiorparietal; do
#     make_masks.py -s $sub_list -roi lh-$mask -exp mvpa_raw \
#         -label $mask -native -sample graymid -unsmoothed -hemi lh
# done

# sub_list=$LYMAN_DIR/subjects.txt
# # sub_list=$LYMAN_DIR/subjects_rerun.txt
# fs_dir=$SUBJECTS_DIR
# IFS=, 
# while read subid; do
#     echo $subid
#     
#     mask_path=$fs_dir/$subid/masks
    
#     fslmaths $mask_path/bilat-parahippocampal.nii.gz \
#     -add $mask_path/bilat-fusiform.nii.gz \
#     -add $mask_path/bilat-inferiortemporal.nii.gz \
#     -bin $mask_path/bilat-parahipp_fusi_inftemp.nii.gz

#  ## for supplemental analysis (does parahipp drive the preceding effect?)
#     fslmaths $mask_path/bilat-fusiform.nii.gz \
#     -add $mask_path/bilat-inferiortemporal.nii.gz \
#     -bin $mask_path/bilat-fusi_inftemp.nii.gz
# done < $sub_list

# run this on desktop
# subid=ap154
# fs_dir=$SUBJECTS_DIR
# mask_path=$fs_dir/$subid/masks
# fslmaths $mask_path/bilat-parahippocampal.nii.gz \
# -add $mask_path/bilat-fusiform.nii.gz \
# -add $mask_path/bilat-inferiortemporal.nii.gz \
# -bin $mask_path/bilat-parahipp_fusi_inftemp.nii.gz


# HIPP Freesurfer ROI
##############################################
# 
# sub_list=$LYMAN_DIR/subjects.txt
# exp=mvpa_raw

# make_masks.py -s $sub_list -roi bilat-hippocampus -exp $exp -native \
#         -aseg -id 17 53 -debug -unsmoothed
# make_masks.py -s $sub_list -roi lh-hippocampus -exp $exp -native \
#         -aseg -id 17 -debug -unsmoothed
# make_masks.py -s $sub_list -roi rh-hippocampus -exp $exp -native \
#         -aseg -id 53 -debug -unsmoothed


# Make sure VTC and hipp masks aren't overlapping
##############################################

# sub_list=$LYMAN_DIR/subjects.txt
# IFS=, 
# while read subid ; do
# 	echo "$subid"

# 	input=$SUBJECTS_DIR/$subid/masks/bilat-parahipp_fusi_inftemp.nii.gz
# 	remove=$SUBJECTS_DIR/$subid/masks/bilat-hippocampus.nii.gz
# 	output=$SUBJECTS_DIR/$subid/masks/bilat-parahipp_fusi_inftemp_nohipp.nii.gz
# 	fslmaths $input -sub $remove -bin $output

# 	input=$SUBJECTS_DIR/$subid/masks/bilat-fusi_inftemp.nii.gz
# 	remove=$SUBJECTS_DIR/$subid/masks/bilat-hippocampus.nii.gz
# 	output=$SUBJECTS_DIR/$subid/masks/bilat-fusi_inftemp_nohipp.nii.gz
# 	fslmaths $input -sub $remove -bin $output
# 
# done < $sub_list



# Hipp long-axis segmentation using Gari's method:
##############################################

# Create volume-based aseg:
# cd $SUBJECTS_DIR
# subids="$(< /Volumes/group/awagner/sgagnon/AP/scripts/subjects_new.txt)" #names from names.txt file
# for subid in $subids; do
# 	mri_extract_label $subid/mri/aseg.mgz 17 $subid/mri/lh.asegHippo.mgz
# 	mri_extract_label $subid/mri/aseg.mgz 53 $subid/mri/rh.asegHippo.mgz
# done

# Open up matlab, add hippovol to path (and geom3d), update subjects in hip_lanzar()
# cd $SUBJECTS_DIR
# run hip_lanzar via run_subids.m
# 
# cd $SUBJECTS_DIR # need this for path in make_masks.py to be correct!
# subid=subjects
# # subid=ap158
# exp=mvpa_raw
# 
# make_masks.py -s $subid -roi lh-hippocampus-tail -exp $exp -orig "%(subj)s/mri/PCAPERCInsausti.aseg.lh.417.tail.hippovol.mgz" -id 1 -debug -unsmoothed
# make_masks.py -s $subid -roi rh-hippocampus-tail -exp $exp -orig "%(subj)s/mri/PCAPERCInsausti.aseg.rh.417.tail.hippovol.mgz" -id 1 -debug -unsmoothed
# 
# make_masks.py -s $subid -roi lh-hippocampus-head -exp $exp -orig "%(subj)s/mri/PCAPERCInsausti.aseg.lh.417.head.hippovol.mgz" -id 1 -debug -unsmoothed
# make_masks.py -s $subid -roi rh-hippocampus-head -exp $exp -orig "%(subj)s/mri/PCAPERCInsausti.aseg.rh.417.head.hippovol.mgz" -id 1 -debug -unsmoothed
# 
# make_masks.py -s $subid -roi lh-hippocampus-body -exp $exp -orig "%(subj)s/mri/PCAPERCInsausti.aseg.lh.417.body.hippovol.mgz" -id 1 -debug -unsmoothed
# make_masks.py -s $subid -roi rh-hippocampus-body -exp $exp -orig "%(subj)s/mri/PCAPERCInsausti.aseg.rh.417.body.hippovol.mgz" -id 1 -debug -unsmoothed


# Frontoparietal CCN/DAN networks
##############################################

### Merge lat frontoparietal ROIs
# for hemi in lh rh; do 
# 	basedir=$SUBJECTS_DIR/fsaverage/label
# 	mri_mergelabels -i $basedir/$hemi.superiorparietal.label \
# 	-i $basedir/$hemi.inferiorparietal.label \
# 	-i $basedir/$hemi.supramarginal.label \
# 	-i $basedir/$hemi.precentral.label \
# 	-i $basedir/$hemi.postcentral.label \
# 	-i $basedir/$hemi.caudalmiddlefrontal.label \
# 	-i $basedir/$hemi.rostralmiddlefrontal.label \
# 	-i $basedir/$hemi.superiorfrontal.label \
# 	-i $basedir/$hemi.parsopercularis.label \
# 	-i $basedir/$hemi.insula.label \
# 	-i $basedir/$hemi.parstriangularis.label \
# 	-i $basedir/$hemi.parsorbitalis.label \
# 	-i $basedir/$hemi.lateralorbitofrontal.label \
# 	-o $basedir/$hemi.frontoparietal_combined.label
# done
# 

### Merge lat frontoparietal ROIs --> just include SPL for parietal component of DAN
# for hemi in lh rh; do 
# 	basedir=$SUBJECTS_DIR/fsaverage/label
# 	mri_mergelabels -i $basedir/$hemi.superiorparietal.label \
# 	-i $basedir/$hemi.precentral.label \
# 	-i $basedir/$hemi.caudalmiddlefrontal.label \
# 	-i $basedir/$hemi.rostralmiddlefrontal.label \
# 	-i $basedir/$hemi.superiorfrontal.label \
# 	-i $basedir/$hemi.parsopercularis.label \
# 	-i $basedir/$hemi.insula.label \
# 	-i $basedir/$hemi.parstriangularis.label \
# 	-i $basedir/$hemi.parsorbitalis.label \
# 	-i $basedir/$hemi.lateralorbitofrontal.label \
# 	-o $basedir/$hemi.frontoparietal_combined_SPL.label
# done
# 
#
# Now intersect these with parietal regions
# #Create combined labels for yeo networks
# for hemi in lh rh; do 
# 	basedir=$SUBJECTS_DIR/fsaverage/label
# 	mri_mergelabels -i $basedir/$hemi.17Networks_5.label \
#     -i $basedir/$hemi.17Networks_6.label \
# 	-o $basedir/$hemi.dorsalattn.label
# 	
# 	mri_mergelabels -i $basedir/$hemi.17Networks_13.label \
#     -i $basedir/$hemi.17Networks_12.label \
# 	-o $basedir/$hemi.frontoparietal.label
# done

# find intersection with lateral fronto/parietal regions defined anatomically
# basedir=/share/awagner/sgagnon/AP/data/fsaverage/label/
# for hemi in rh lh; do
# 	file1=$basedir/$hemi.frontoparietal_combined_SPL.label
# 	file2=$basedir/$hemi.dorsalattn.label
# 	./labels_intersect_jim.sh $file1 $file2 $basedir/$hemi.dorsalattn.label
# 
# 	file1=$basedir/$hemi.frontoparietal_combined.label
# 	file2=$basedir/$hemi.frontoparietal.label
# 	./labels_intersect_jim.sh $file1 $file2 $basedir/$hemi.frontoparietal.label
# done

#Create sub-specific masks
# sub_list=$LYMAN_DIR/subjects.txt
# experiment=mvpa_raw
# 
# # for label in dorsalattn frontoparietal; do
# for label in dorsalattn; do
#     for hemi in lh rh; do
#         echo $hemi
#         make_masks.py -s $sub_list -hemi $hemi -roi $hemi-$label -exp $experiment -label $label -sample graymid -unsmoothed -save_native
#     done
# done

### Other memory ROIs (angular, rsp)
####################################

# sub_list=subjects.txt
# exp=mvpa_raw
# for hemi in lh; do
# 	for mask in DefaultA_IPL; do
# 		make_masks.py -s $sub_list -hemi $hemi -roi $hemi-$mask -exp $exp -label 17Networks_$mask -sample graymid -save_native
# 	done
# done

# sub_list=subjects.txt
# exp=mvpa_raw
# for hemi in rh lh; do
# 	for mask in DefaultC_Rsp; do
# 		make_masks.py -s $sub_list -hemi $hemi -roi $hemi-$mask -exp $exp -label 17Networks_$mask -sample graymid -save_native
# 	done
# done


##############################################
# Run between groups analysis
##############################################
# cd $LYMAN_DIR

# python run_between_group.py -e ap_memory_raw -output group_control-stress
# surface_snapshots.py -experiment ap_memory_raw -level group -output group_control-stress -geometry semi7

# python run_between_group.py -e ap_memory_raw -output group_stress-control #make sure change line in run_between_groups.py
# surface_snapshots.py -experiment ap_memory_raw -level group -output group_stress-control -geometry semi7

# python run_between_group.py -e ap_memory_raw-rt -output group_control-stress
# surface_snapshots.py -experiment ap_memory_raw -alt rt -level group -output group_control-stress -geometry semi7

## Group comparison by shockcond
# cd $LYMAN_DIR
# python run_between_group.py -e ap_memory_raw-byshockCond -output group_control-stress
# surface_snapshots.py -experiment ap_memory_raw -alt byshockCond -level group -output group_control-stress -geometry semi7


# ##############################################
# Extract raw activity (after preprocessed timeseries)
# Then run /notebooks/AP_extract_rawactivity.ipynb
##############################################

## Focus on Hipp, CCN/DAN, but also pull out regions along long-axis and ang/rsp
# extract_info=AP_mvpa_raw
# masklist=( "lh-hippocampus" "rh-hippocampus" "rh-hippocampus-tail" "lh-hippocampus-tail" "rh-hippocampus-head" \
# 		   "lh-hippocampus-head" "lh-hippocampus-body" "rh-hippocampus-body" "rh-DefaultC_Rsp" "lh-DefaultC_Rsp" \
# 		   "lh-DefaultA_IPL" "lh-frontoparietal" "lh-dorsalattn" "rh-frontoparietal" "rh-dorsalattn" )
# 
# cd /share/awagner/sgagnon/scripts/lyman-tools/timeseries/
# for mask_name in "${masklist[@]}"; do
#     echo $mask_name
#     python run_extractraw.py -extract_info $extract_info -mask_type mask -mask_name $mask_name
# done

##############################################
# Pull coefs out of sphere centered on peak voxel from main analysis
##############################################

## group: memory 
# cd $init_path/awagner/sgagnon/scripts/lyman-tools/roi
# python create_sphere_frompeak.py -exp ap_memory_raw -contrast sourcehit-CR -group group_control-stress -peak_num 1

## Optionally group: localizer bilateral PPA/OPA -- use group-based approach? Probably more exact to do for each participant... (see below)
# cd $init_path/awagner/sgagnon/scripts/lyman-tools/roi
# for peak_num in 0 1 2 3; do
# 	echo $peak_num
# 	python create_sphere_frompeak.py -exp localizer -contrast place-other_img -group group -peak_num $peak_num
# done

##############################################
# Extract mean copes
# Then run notebooks/extract_rois.ipynb to get plots for each
##############################################
# cd $init_path/awagner/sgagnon/scripts/lyman-tools/roi
# python extract_copes.py -exp ap_memory_raw -masks anat_masks.csv -group_info subjects_groups.csv
# python extract_copes.py -exp ap_memory_raw -masks anat_masks_rerun.csv -group_info subjects_groups.csv

# cd $init_path/awagner/sgagnon/scripts/lyman-tools/roi
# python extract_copes.py -subjects $LYMAN_DIR/subjects_byshockCondSH.txt -exp ap_memory_raw -alt byshockCond -masks anat_masks.csv -group_info subjects_groups.csv
# python extract_copes.py -subjects $LYMAN_DIR/subjects_byshockCondSH.txt -exp ap_memory_raw -alt byshockCond -masks anat_masks_rerun.csv -group_info subjects_groups.csv

# cd $init_path/awagner/sgagnon/scripts/lyman-tools/roi
# python extract_copes.py -exp ap_memory_raw -masks sphere_masks.csv -mni_space -contrast_exp ap_memory_raw \
# -threshold zstat1_peak1_5mm_sphere_masked.nii.gz -group group_control-stress -group_info subjects_groups.csv

# pull out copes from MNI-defined localizer peaks
# for peak_num in '0' '1' '2' '3'; do
# 	echo $peak_num
# 
# 	python extract_copes.py -exp ap_memory_raw -masks sphere_masks_localizer.csv -mni_space -contrast_exp localizer \
# 	-threshold zstat1_peak${peak_num}_5mm_sphere_masked.nii.gz -group group -group_info subjects_groups.csv
# done



# Localizer analysis
##############################################
# sub_list=subjects.txt
# exp=localizer

# run_fmri.py -s $sub_list -e $exp -w preproc model reg ffx -regspace mni -n 15
# run_group.py -s $sub_list -exp $exp -regspace mni -n 15
# surface_snapshots.py -subjects $sub_list -experiment $exp -level group -regspace mni

## Now run in native space to extract PPA from each subject
# run_fmri.py -s $sub_list -e $exp -regexp mvpa_raw -w model reg ffx -regspace epi -unsmoothed -n 25

## to register into space of *first* run from test session, need to move the ffx from localizer over to mvpa_raw dir
## then, we can make masks just using the mvpa_raw directory, and relevant first run for then extracting betas
# IFS=, 
# while read subjid; do
#     cp -r $init_path/awagner/sgagnon/AP/analysis/localizer/$subjid/ffx $init_path/awagner/sgagnon/AP/analysis/mvpa_raw/$subjid/.
# done < $sub_list


###### ANALYSIS with PPA using -sample white (SHOULD USE GRAYMID -- use below code to be consistent with other analyses)
## mask generated from intersection of parahippocampal label, and scene selective regions from localizer
## native_label, not restricting number of voxels. Stats are uncorrected, and image is unsmoothed
# make_masks.py -s $sub_list -exp mvpa_raw -roi bilat-ppa_scene -label parahippocampal -contrast place-other_img -thresh 2.3 -sample white -native -unsmoothed

## Run /Volumes/group/awagner/sgagnon/AP/scripts/notebooks/extract_rois.ipynb to determine min mask size
## restrict to 33 voxels (minimum, that ap168 has)
# make_masks.py -s $sub_list -exp mvpa_raw -roi bilat-ppa_scene_limitvox -label parahippocampal -contrast place-other_img -thresh 2.3 -sample white -native -unsmoothed -nvoxels 33
# 
# cd $init_path/awagner/sgagnon/scripts/lyman-tools/roi
# python extract_copes.py -exp ap_memory_raw -masks func_masks.csv -group_info subjects_groups.csv

###### ANALYSIS with PPA using -sample graymid (SAME RESULTS AS ABOVE, but this is the preferred way, to be consistent)
# sub_list=subjects.txt
# cd $LYMAN_DIR # run on SNI server
# make_masks.py -s $sub_list -exp mvpa_raw -roi bilat-ppa_scene_graymid -label parahippocampal -contrast place-other_img -thresh 2.3 -sample graymid -native -unsmoothed

## Run /Volumes/group/awagner/sgagnon/AP/scripts/notebooks/extract_rois.ipynb to determine min mask size
## restrict to 39 voxels (minimum, that ap168 has)
# make_masks.py -s $sub_list -exp mvpa_raw -roi bilat-ppa_scene_graymid_limitvox -label parahippocampal -contrast place-other_img -thresh 2.3 -sample graymid -native -unsmoothed -nvoxels 39
# cd $init_path/awagner/sgagnon/scripts/lyman-tools/roi
# python extract_copes.py -exp ap_memory_raw -masks func_masks_graymid.csv -group_info subjects_groups.csv


##############################################
# ADDITIONAL ANALYSES
#############################################

##############################################
# Covariate analysis: how does activity to SH > CRs scale with high confidence source accuracy?
##############################################
# cd $LYMAN_DIR
# python run_groups_covariate.py -e ap_memory_raw -output group_cov_sourceAcc
# surface_snapshots.py -experiment ap_memory_raw -level group -output group_cov_sourceAcc -geometry semi7

##############################################
# Covariate analysis: how does activity to SH > CRs scale cortisol?
##############################################
# cd $LYMAN_DIR
# python run_groups_covariate.py -e ap_memory_raw -output group_cov_cort
# surface_snapshots.py -experiment ap_memory_raw -level group -output group_cov_cort -geometry semi7

