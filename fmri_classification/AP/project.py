import os.path as op
import pandas as pd

############################
# Basic parameters
############################

mask_type = 'mask' # functional mask ('func'), or anatomical mask ('mask') defined w/mask_name
if mask_type == 'func':
	mask_name = 'functional mask'
mask_name = 'bilat-parahipp_fusi_inftemp_nohipp'
cond_list = ['face', 'object', 'place']
multi_class = 'ovr'

smoothing = 'unsmoothed'
regspace = 'epi'
design = 'localizer_cond_mvpa.csv' # onset file in lyman-style
smoothing_fwhm = 0
standardize = True
tr = float(2) # in seconds
tr_shift = 4.5 # seconds to shift forward by
ts_type = 'raw' # raw or residual
run_list = [7, 8]

basedir = '/Volumes/group/awagner/sgagnon/AP'
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
             
###########################################
# Additional params, if testing on other dataset
###########################################
loc_design = design
loc_onsetfile = onsetfile

mem_design = 'AP_memory_itemhits.csv' 
mem_onsetfile = op.join(basedir, 'data', "{subid}", 'design', mem_design)
multi_class_alg = multi_class
tr_shift_test_list = [0, 2, 4, 6, 8, 10, 12] # seconds to shift onset forward by
mem_run_list = range(1,7)
mem_cond_list = ['sourcehit', 'CR']

outtrials = op.join(analydir, "{subid}", 'trial_estimates', 
                    '{subid}_{output}_{time}s_trial_{multi_class_alg}_estimates_3class_{mask}_byrep_filtartloc_equalizecounts.csv')

paths = dict(tsfile=tsfile, func_maskfile=func_maskfile,
             maskfile=maskfile, meanfile=meanfile,
             onsetfile=onsetfile,
             loc_onsetfile=loc_onsetfile, mem_onsetfile=mem_onsetfile,
             outnifti=outnifti, outtrials=outtrials, analydir=analydir,
             artifacts=artifacts)