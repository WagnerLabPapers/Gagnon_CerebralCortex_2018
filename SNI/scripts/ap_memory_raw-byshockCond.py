source_template = "{subject_id}/bold/raw/scan*.nii.gz"

n_runs = 6

frames_to_toss = 6 # 0 if using distortion corr, where drops first 6 TRs

temporal_interp = True
interleaved = True
slice_order = 'up'

intensity_threshold = 5
motion_threshold = 1

wm_components = 6
smooth_fwhm = 6

hpf_cutoff = 128
TR = 2.

# Model Params
design_name = 'AP_memory_byshockCond'
hrf_model = "GammaDifferenceHRF"
temporal_deriv = False
confound_sources = ['motion']
confound_pca = False
remove_artifacts = True

condition_names = ['CR_safe', 'FA_safe', 'sourcehit_safe', 'itemhit_lo_safe', 'sourcemiss_hi_safe', 'M_safe', 
				   'CR_threat', 'FA_threat', 'sourcehit_threat', 'itemhit_lo_threat', 'sourcemiss_hi_threat', 'M_threat', 
				   'nuisance']

contrasts = [('safe_sourcehit-cr', ['sourcehit_safe', 'CR_safe'], [1, -1]),
			 ('safe_cr-sourcehit', ['sourcehit_safe', 'CR_safe'], [-1, 1]),
			 ('safe_sourcehit-item', ['sourcehit_safe', 'itemhit_lo_safe'], [1, -1]),
			 ('safe_itemhit-sourcehit', ['sourcehit_safe', 'itemhit_lo_safe'], [-1, 1]),
			 ('safe_itemhit-cr', ['itemhit_lo_safe', 'CR_safe'], [1, -1]),
			 ('safe_cr-itemhit', ['itemhit_lo_safe', 'CR_safe'], [-1, 1]),
			 ('threat_sourcehit-cr', ['sourcehit_threat', 'CR_threat'], [1, -1]),
			 ('threat_cr-sourcehit', ['sourcehit_threat', 'CR_threat'], [-1, 1]),
			 ('threat_sourcehit-item', ['sourcehit_threat', 'itemhit_lo_threat'], [1, -1]),
			 ('threat_itemhit-sourcehit', ['sourcehit_threat', 'itemhit_lo_threat'], [-1, 1]),
			 ('threat_itemhit-cr', ['itemhit_lo_threat', 'CR_threat'], [1, -1]),
			 ('threat_cr-itemhit', ['itemhit_lo_threat', 'CR_threat'], [-1, 1]),
			 ]


# Group Params
flame_mode = 'flame1'
cluster_zthresh = 2.3
grf_pthresh = 0.05
peak_distance = 30

sampling_method = 'average'
sampling_range = (0, 1, 0.1)
sampling_units = 'frac'
surf_corr_sign = 'pos'
surf_name = 'inflated'
surf_smooth = 5 #0
