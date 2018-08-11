# fmri_classification

These steps assume your data has been processed using Freesurfer and [lyman](http://stanford.edu/~mwaskom/software/lyman/).

## File information and directory structure

The main functions are in the script `ap_classify.py`. These functions can be imported into a jupyter notebook
for analysis. The two main notebooks are `Localizer_Classification.ipynb`, which runs cross-validated classification,
and `AssocPlace_Classification.ipynb`, which runs classification by training on a subset of the runs
(i.e., from a localizer scan) and testing on another set of runs. Jupyter notebooks can be opened by navigating to the
directory in the terminal, and then typing in `jupyter notebook`. Results from the notebooks are output into the directory
`output_ap`, and into other specified directories on the SNI server (not tracked in this repo).

## Preprocess data

Using [lyman](http://stanford.edu/~mwaskom/software/lyman/), preprocess and register timeseries. Timeseries data can
either be "raw" (just undergoing basic preprocessing steps), a residual timeseries (on modeled data), or a beta timeseries.

**Raw timeseries registration:**
`run_fmri.py -s subjects.txt -e experiment-name -w preproc reg -t -regspace epi -unsmoothed`

**Residual timeseries registration:**
`run_fmri.py  -s subjects.txt -e experiment-name -w preproc model reg -residual -regspace epi -unsmoothed`

## Generate masks

Classification can either be done using a whole brain functional mask, or an anatomical mask, defined for each subject.
To generate anatomical masks, you can do something like this:

```
sub_list=$LYMAN_DIR/subjects.txt
IFS=,
while read subjid; do
    mri_annotation2label --subject $subjid --hemi rh --outdir $SUBJECTS_DIR/$subjid/label
	mri_annotation2label --subject $subjid --hemi lh --outdir $SUBJECTS_DIR/$subjid/label
done < $sub_list


sub_list=subjects.txt
for mask in fusiform inferiortemporal parahippocampal; do
    make_masks.py -s $sub_list -roi bilat-$mask -exp mvpa \
        -label $mask -native -sample graymid -unsmoothed
done

sub_list=$LYMAN_DIR/subjects.txt
IFS=,
while read subid; do
    echo $subid

    mask_path=$SUBJECTS_DIR/$subid/masks

    fslmaths $mask_path/bilat-parahippocampal.nii.gz \
    -add $mask_path/bilat-fusiform.nii.gz \
    -add $mask_path/bilat-inferiortemporal.nii.gz \
    -bin $mask_path/bilat-parahipp_fusi_inftemp.nii.gz

done < $sub_list
```

## Parameters

For the jupyter notebook analyses, you will need to specify a few parameters:

- `smoothing` (str; 'unsmoothed', 'smoothed'): use smoothed or unsmoothed files
- `regspace` (str; 'epi', 'mni')
- `design` (str): the onset file, stored in lyman subject directory
- `standardize` (bool)
- `tr` (float)
- `tr_shift` (int): amount to shift forward in time from onset; in seconds
- `ts_type` (str; 'raw', 'residual'): use raw preprocessed timeseries, or residual
- `run_list` (list): list of integers specifying run numbers
- `mask_type` (str; 'func', 'mask'): use whole brain functional mask or other mask defined in space of first run
- `mask_name` (str): if mask_type == 'anat', use this to determine mask files
- `cond_list` (list): list of strings specifying condition names; these should be in the onset file
- ...

## Classification functions

### Get data from subject

`get_subj_data()`

### Perform cross validated classification

Outputs accuracy (for each condition; "true positive rate") and probability.

`calc_acc_proba()`

### Create coef maps

Train on all the data, and output coefficient maps

To visualize on surface (requires `PySurfer`):
```
%gui qt
from surfer import Brain, io
import surfer as sf
import os.path as op


subid = "ap116"
hemi = "split"
surf = "inflated"
brain = Brain(subid, hemi, surf, views=['lat', 'med', 'ven'])
roi = 'wholebrain'

# coefs

mask_file=op.join('/Volumes/group/awagner/sgagnon/AP/analysis/mvpa_raw/{subid}/importance_maps',
                  '{roi}_coef_{category}.nii.gz')

categories=['place', 'object', 'face']
colors=['Greens', 'Blues', 'Reds']
thresh=0.0001

for cat, color in zip(categories, colors):
    for hemi in ['lh', 'rh']:
        overlay=sf.project_volume_data(mask_file.format(roi=roi,
                                                        category=cat,
                                                        subid=subid),
                                       hemi=hemi, subject_id=subid,
                                       smooth_fwhm=0, projsum="max")

        brain.add_data(overlay, thresh=thresh, hemi=hemi,
                       colormap=color, alpha=.8, colorbar=False)
```

### Train on training set, test on separate set of data

Use this for memory paradigms, where training on all the data from a localizer or
study session, and testing on memory retrieval session.

`calc_acc_train_loc()`
