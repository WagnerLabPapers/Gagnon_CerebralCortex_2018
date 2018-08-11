#! /usr/bin/env python

import glob
import os.path as op
import os as os
import nibabel as nib
import pandas as pd
import numpy as np

from nilearn.masking import compute_epi_mask

import matplotlib.pyplot as plt
import matplotlib as mpl

# Nilearn for neuro-imaging-specific machine learning
from nilearn.input_data import NiftiMasker
from nilearn import image
from nilearn.plotting import plot_stat_map, plot_img
from nilearn import decoding
import nilearn.masking

# Nibabel for general neuro-imaging tools
import nibabel

# Scikit-learn for machine learning
from sklearn.svm import SVC
from sklearn.linear_model import LogisticRegression
from sklearn.dummy import DummyClassifier
from sklearn.feature_selection import SelectKBest, f_classif
from sklearn.pipeline import Pipeline
from sklearn.cross_validation import LeaveOneLabelOut, LeavePLabelOut, cross_val_score
from sklearn import preprocessing

# Plotting
import matplotlib.pyplot as plt
from nilearn import plotting
import seaborn as sns
sns.set(context="poster", style="ticks", font="Arial")


from ap_classify import *

###############################################
# Setup info
###############################################

# timeseries info:
smoothing = 'unsmoothed'
regspace = 'epi'
smoothing_fwhm = 0
standardize = True
tr = float(2) # in seconds
ts_type = 'raw' # raw or residual

# Localizer info:
tr_shift = 4.5 # seconds to shift forward by
run_list = [7, 8]
design = 'localizer_cond_mvpa.csv' # onset file in lyman-style

# directory info:
basedir = '/share/awagner/sgagnon/AP'
analydir = op.join(basedir, 'analysis/mvpa_raw')
subjfile = op.join(analydir, 'notebooks/subj_info.csv')
subj_info = pd.read_csv(subjfile)

# Filepath templates
if ts_type == 'raw':
    tsfilename = 'timeseries_xfm.nii.gz'
elif ts_type == 'residual':
    tsfilename = 'res4d_xfm.nii.gz'
tsfile = op.join(analydir, "{subid}", 'reg', regspace, 
                 smoothing, "run_{run_id}", tsfilename)
func_maskfile = op.join(analydir, "{subid}", 'reg', regspace, 
                        smoothing, "run_{run_id}", 'functional_mask_xfm.nii.gz')
maskfile = op.join(basedir, 'data', "{subid}", 'masks', 
                   "{mask_name}.nii.gz")
meanfile = op.join(analydir, "{subid}", 'preproc',
                   "run_{run_id}", 'mean_func.nii.gz')
onsetfile = op.join(basedir, 'data', "{subid}", 'design', design)

# Output templates
outnifti = op.join(analydir, "{subid}", 'importance_maps')

artifacts = op.join(analydir, '{subid}', 'preproc', 'run_{run}', 'artifacts.csv')

# Combine paths into dictionary (facilitate passing i/o of funcs)
paths = dict(tsfile=tsfile, func_maskfile=func_maskfile, 
             maskfile=maskfile, meanfile=meanfile, 
             onsetfile=onsetfile, outnifti=outnifti, 
             analydir=analydir, artifacts=artifacts)
onsetfile = paths['onsetfile']

mask_type = 'func' # functional mask, or anatomical mask defined w/mask_name
mask_name = None
cond_list = ['face', 'object', 'place']


###############################################
# Localizer classification
###############################################

# for subid in subj_info.subid:
#     print subid

#     X, run_labels, ev_labels, ev_trs, ev_onsets, func_masker = get_subj_data(subid, onsetfile, cond_list, paths, mask_type, mask_name,
#                                                                             smoothing_fwhm, standardize, tr, tr_shift, run_list, 
#                                                                             shift_rest=True, filter_artifacts=True)

#     ts_path = paths['tsfile'].format(subid=subid, run_id=1)
#     mask_img = paths['func_maskfile'].format(subid=subid, run_id=1)
#     cv = LeaveOneLabelOut(run_labels)
#     classifier = decoding.SearchLight(mask_img,
#                                       radius=5.6, estimator=LogisticRegression(penalty='l2', C=1.),
#                                       cv=cv, verbose=0, n_jobs=25)

#     X_unmask = nilearn.masking.unmask(X, mask_img)
#     print X_unmask.shape
#     y = ev_labels
#     print y.shape

#     classifier.fit(X_unmask, y)

#     # Save out scores in subj native space
#     mean_fmri = image.mean_img(ts_path)
#     searchlight_scores = image.new_img_like(mean_fmri, classifier.scores_)
#     searchlight_scores.to_filename('/share/awagner/sgagnon/AP/analysis/mvpa_raw/searchlight/localizer_acc_{subid}.nii.gz'.format(subid=subid))


###############################################
# Reinstatement accuracy
###############################################

# Localizer and retrieval info
loc_run_list = [7,8]
loc_design = 'localizer_cond_mvpa.csv'
loc_onsetfile = op.join(basedir, 'data', "{subid}", 'design', loc_design)
loc_cond_list = ['face', 'object', 'place']
tr_shift = 4.5 #4.5 seconds post-stim onset

mem_run_list = range(1,6+1)
mem_design = 'AP_memory_itemhits_byrep.csv' # stored in $SUBJECTS_DIR/subid/design/
mem_onsetfile = op.join(basedir, 'data', "{subid}", 'design', mem_design)
mem_cond_list = ['sourcemiss_hi-4', 'CR-0', 
                 'sourcehit-2', 'sourcehit-4', 'M-4',
                 'M-2', 'FA-0', 'itemhit_lo-2', 
                 'sourcemiss_hi-2', 'itemhit_lo-4'] # nb, pull all categories for scaling,
target_cond_list = ['sourcehit-2', 'sourcehit-4']   # remove unnecessary ones later,
                                                    # with target_cond_list

tr_shift_test_list = [0, 2, 4, 6, 8, 10, 12] # seconds to shift onset forward by

# How test conditions (keys) map to localizer conditions (values)
ev_mapping = {'sourcehit-4': 'place',
              'sourcehit-2': 'place'}

for subid in subj_info.subid:
    print subid

# subid = 'ap100'
    if subid == 'ap155':
        mem_run_list = range(1, 6)
    else:
        mem_run_list = range(1, 7)
        
        
# # append test to training data; y = vector of "place" length of samples
# # average samples over time window? or generate 4D timeseries of brains.


    # Subject specific info
    ts_path = paths['tsfile'].format(subid=subid, run_id=1)
    mask_img = paths['func_maskfile'].format(subid=subid, run_id=1)

    # Get localizer training data
    #########################################

    X, run_labels, ev_labels, \
    ev_trs, ev_onsets, func_masker = get_subj_data(subid, loc_onsetfile, loc_cond_list,
                                                   paths, mask_type, mask_name,
                                                   smoothing_fwhm, standardize,
                                                   tr, tr_shift, loc_run_list,
                                                   output=False, shift_rest=True,
                                                   filter_artifacts=True)

    # Get memory test data for testing
    #########################################

    # for time in tr_shift_test_list:
    for time in tr_shift_test_list:
        print 'Time sample: ' + str(time)
        Y, run_labels_test, ev_labels_test, \
        ev_trs_test, ev_onsets_test, func_masker = get_subj_data(subid, mem_onsetfile, mem_cond_list,
                                                                 paths, mask_type, mask_name,
                                                                 smoothing_fwhm, standardize, tr, time,
                                                                 mem_run_list, output=False)
        print 'Loaded in testing data...'

        # Subset to just target sourcehits
        sh_bool = np.in1d(ev_labels_test, target_cond_list)
        Y = Y[sh_bool]
        run_labels_test = run_labels_test[sh_bool]
        ev_labels_test = ev_labels_test[sh_bool]

        # Convert test ev labels to match localizer
        mapped_labels = [ev_mapping[trial_type] for trial_type in ev_labels_test]

        # Combine with localizer data
        X_full = np.vstack((X, Y))
        run_labels_full = np.hstack((run_labels, run_labels_test))
        ev_labels_full = np.hstack((ev_labels, mapped_labels))

        # Create CV generator (1-fold, train on localizer, test on retrieval)
        cv = []
        trainIndices = np.where(np.in1d(run_labels_full, loc_run_list))
        testIndices = np.where(np.in1d(run_labels_full, mem_run_list))
        cv.append((trainIndices, testIndices))

        classifier = decoding.SearchLight(mask_img,
                                          radius=5.6, estimator=LogisticRegression(penalty='l2', C=1.),
                                          cv=cv, verbose=0, n_jobs=25)

        X_unmask = nilearn.masking.unmask(X_full, mask_img)
        print X_unmask.shape
        y = ev_labels_full
        print y.shape

        classifier.fit(X_unmask, y)

        # Save out scores in subj native space
        mean_fmri = image.mean_img(ts_path)
        searchlight_scores = image.new_img_like(mean_fmri, classifier.scores_)
        searchlight_scores.to_filename('/share/awagner/sgagnon/AP/analysis/mvpa_raw/' +
                                       'searchlight_test/sourcehit_time{time}_acc_{subid}.nii.gz'.format(time=str(time), subid=subid))

############################################
# Visualize accuracy (for given subject)
############################################

from surfer import Brain, project_volume_data
tr_shift_test_list = [0, 2, 4, 6, 8, 10, 12] # seconds to shift onset forward by

# for subid in subj_info.subid:
subid = 'ap101'
for time in tr_shift_test_list:
    brain = Brain(subid, "split", "inflated",  views=['lat', 'med', 'ven'], background="white")
    volume_file = '/Volumes/group/awagner/sgagnon/AP/analysis/mvpa_raw/searchlight_test/sourcehit_time{time}_acc_{subid}.nii.gz'.format(time=str(time), subid=subid)

    for hemi in ['lh', 'rh']:
        zstat = project_volume_data(volume_file, hemi, subject_id=subid, smooth_fwhm=0.5)
        brain.add_overlay(zstat, hemi=hemi, min=.333)
    brain.save_image('/Volumes/group/awagner/sgagnon/AP/analysis/mvpa_raw/searchlight_test/sourcehit_time{time}_acc_{subid}.png'.format(time=str(time), subid=subid))
