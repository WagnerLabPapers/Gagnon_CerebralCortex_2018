source_template = "{subject_id}/bold/raw/scan*.nii.gz"

n_runs = 8

frames_to_toss = 6

temporal_interp = True
interleaved = True
slice_order = 'up'

intensity_threshold = 5
motion_threshold = 1

smooth_fwhm = 6

hpf_cutoff = 128
TR = 2.

# Model Params
design_name = 'localizer_cond'
hrf_model = "GammaDifferenceHRF"
temporal_deriv = False
confound_pca = False

condition_names = []

contrasts = []


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
