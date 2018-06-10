source_template = "{subject_id}/bold/raw/scan*.nii.gz"

n_runs = 5

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
design_name = 'AP_memory_itemhits'
hrf_model = "GammaDifferenceHRF"
temporal_deriv = False
confound_sources = ['motion']
confound_pca = False
remove_artifacts = True

condition_names = ['CR', 'FA', 'sourcehit', 'itemhit_lo', 'sourcemiss_hi', 'M', 'nuisance']

contrasts = [('hit-miss', ['sourcehit', 'sourcemiss_hi', 'itemhit_lo', 'M'], [.33, .33, .33, -1]),
			 ('miss-hit', ['sourcehit', 'sourcemiss_hi', 'itemhit_lo', 'M'], [-.33, -.33, -.33, 1]),
			 ('itemhit-miss', ['itemhit_lo', 'M'], [1, -1]),
			 ('sourcehit-miss', ['sourcehit', 'M'], [1, -1]),
			 ('hit-cr', ['sourcehit', 'itemhit_lo', 'sourcemiss_hi', 'CR'], [.33, .33, .33, -1]),
			 ('itemhit-cr', ['itemhit_lo', 'CR'], [1, -1]),
			 ('sourcehit-cr', ['sourcehit', 'CR'], [1, -1]),
			 ('cr-hit', ['sourcehit', 'sourcemiss_hi', 'itemhit_lo', 'CR'], [-.33, -.33, -.33, 1]),
			 ('cr-sourcehit', ['sourcehit', 'CR'], [-1, 1]),
			 ('sourcehit-item', ['sourcehit', 'itemhit_lo'], [1, -1]),
			 ('itemhit-source', ['sourcehit', 'itemhit_lo'], [-1, 1]),
			 ('sourcehit-fa', ['sourcehit', 'FA'], [1, -1]),
			 ('sourcehit-sourcemiss', ['sourcehit', 'sourcemiss_lo'], [1, -1]),
			 ('sourcemiss-sourcehit', ['sourcehit', 'sourcemiss_lo'], [-1, 1]),
			 ('itemhit-fa', ['itemhit_lo', 'FA'], [1, -1]),
			 ('hit-fa', ['sourcehit', 'sourcemiss_hi', 'itemhit_lo', 'FA'], [.33, .33, .33, -1]),
			 ('fa-hit', ['sourcehit', 'sourcemiss_hi', 'itemhit_lo', 'FA'], [-.33, -.33, -.33, 1])
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
