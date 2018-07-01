# Gagnon_CerebralCortex_2018
Analysis repository for Gagnon et al. (2018) Cerebral Cortex

## Dependencies (incomplete list):

- Python 2.7 (Anaconda 2.3 / 2.4)
- https://github.com/sgagnon/lyman (adapted from https://github.com/mwaskom/lyman)
- https://github.com/sgagnon/lyman-tools
- https://github.com/sgagnon/felix
- https://github.com/mwaskom/seaborn
- https://github.com/mwaskom/moss

- FSL
- Freesurfer
- ANTS

## Directory overview

- Main code to run behavioral task: `ap.m` and assorted files in `scripts`
- Picture stimuli for behavioral task: `stimuli`
- Behavioral data: `data`
- MRI data processing: `SNI/scripts`
- Statistics: `stats` (All statistics: `AP_results.Rmd`)

## MRI data/results

- ROI parameter estimates: `SNI/analysis/ap_memory_raw/group/roi`
	- note: see Archive for trial-wise ROI data

[NeuroVault LINKs]

[ARCHIVE LINK]


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

#### Error bar code 
http://www.cookbook-r.com/Graphs/Plotting_means_and_error_bars_(ggplot2)/#Helper%20functions

#### Experiment code from Brice Kuhl's RIFS Task / Wagner Lab / AM task (in collaboration with Valerie Carr)

This included lists of words (nouns) used as stimuli

#### Questionnaire code from Amitai Shenhav

#### Trigger code from the CNI and Kelly Hennigan

#### Inspiration from https://github.com/mwaskom/Waskom_CerebCortex_2017