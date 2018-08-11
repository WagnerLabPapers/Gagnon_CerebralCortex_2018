# Gagnon_CerebralCortex_2018
Analysis repository for Gagnon et al. (2018) Cerebral Cortex

## Dependencies (incomplete list):

- Python 2.7 (Anaconda 2.3 / 2.4)
- https://github.com/sgagnon/lyman (adapted from https://github.com/mwaskom/lyman)
- https://github.com/sgagnon/lyman-tools
- https://github.com/sgagnon/felix
- https://github.com/sgagnon/fmri_classification
- https://github.com/mwaskom/seaborn
- https://github.com/mwaskom/moss

- FSL
- Freesurfer
- ANTS
- scikit-learn
- nibabel
- nitime
- nipype

- See files in `environment` for other packages

## Directory overview

- Main code to run behavioral task: `AP/ap.m` and assorted files in `scripts`
- Behavioral data: `AP/data`
- Behavioral preprocessing: `AP/analysis`
- Localizer task/data: `localizer`
- MRI data processing: `SNI` (corresponds to `/Volumes/group/awagner/sgagnon/AP`)
- Statistics: `stats` (All statistics: `AP_results.Rmd`)

## MRI data/results

- ROI parameter estimates: `SNI/analysis/ap_memory_raw/group/roi`
	- note: see Archive for trial-wise ROI data

Statistical maps (Neurovault): https://neurovault.org/collections/3173/

[*TBD: ARCHIVE LINK]


## Code references

This repository contains code taken/adapted from the following sources:

#### https://github.com/amgordon/Gordon_CerCor_2014

License:

Copyright (c) 2013 Alan Gordon, J. Benjamin Hutchinson, Jesse Rissman.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

Also, we'd like to thank Alan Gordon for experimentation code snippets.

#### https://github.com/garikoitz/hippovol

The MIT License (MIT)

Copyright (c) 2016 garikoitz. Garikoitz Lerma-Usabiaga (garikoitz@gmail.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

#### https://www.mathworks.com/matlabcentral/fileexchange/24484-geom3d

Copyright (c) 2018, INRA 
All rights reserved.

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are 
met:

* Redistributions of source code must retain the above copyright 
notice, this list of conditions and the following disclaimer. 
* Redistributions in binary form must reproduce the above copyright 
notice, this list of conditions and the following disclaimer in 
the documentation and/or other materials provided with the distribution

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
POSSIBILITY OF SUCH DAMAGE.

#### Error bar code 
http://www.cookbook-r.com/Graphs/Plotting_means_and_error_bars_(ggplot2)/#Helper%20functions

#### Experiment code from Brice Kuhl's RIFS Task / Wagner Lab / AM task (in collaboration with Valerie Carr)

This included lists of words (nouns) used as stimuli

#### Questionnaire code from Amitai Shenhav

#### Trigger code from the CNI and Kelly Hennigan

#### `labels_intersect_jim.sh`
Code from Jim Porter (University of Minnesota) from the Freesurfer message board
https://mail.nmr.mgh.harvard.edu/pipermail//freesurfer/2009-September/011846.html

#### Inspiration from https://github.com/mwaskom/Waskom_CerebCortex_2017