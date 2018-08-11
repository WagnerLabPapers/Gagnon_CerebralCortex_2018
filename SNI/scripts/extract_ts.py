import os
import numpy as np
import glob
from os.path import abspath
import csv
import os.path as op

import matplotlib
import matplotlib.pyplot as plt
import pandas as pd
from scipy import stats, optimize
from pandas import DataFrame, Series
from moss import glm
import seaborn as sns
import random as rd
from statsmodels.formula.api import ols
from statsmodels.stats.anova import anova_lm
import scipy.stats

from IPython.parallel import Client
from IPython.display import Image
import multiprocessing

import nibabel as nib
from nipype.pipeline.engine import Node, MapNode, Workflow
from nipype.interfaces.io import DataGrabber, DataFinder, DataSink
from nipype.interfaces import fsl
from nipype.interfaces.fsl import ImageMeants
from nipype.interfaces.fsl import ImageStats

# Define some stuff
home_dir = '/share/awagner/sgagnon/AP'
exps = ['mvpa']
design_file = 'AP_sourcehits-vs-CR.csv'
contrast= 'sourcehit-vs-CR'
data_dir = op.join(home_dir, 'data') 
analy_dir = op.join(home_dir, 'analysis', '{exp}')
num_runs = 6
masks = ['lh-hippocampus-tail', 'rh-hippocampus-tail']
subj_file = op.join(home_dir, 'scripts', 'subjects.txt')

sub_list = list(np.loadtxt(subj_file,'string'))
os.chdir(home_dir)
runs = map(str,range(1,num_runs+1))

global paths
paths = dict(home_dir=home_dir, 
             data_dir=data_dir,
             analy_dir=analy_dir)


def vector_rejection(a,b):
    return a - (np.dot(a,b)/np.dot(b,b) * b)

def extract_roi(in_tuple):
    sub,exp,run,mask = in_tuple
    
    sub_path = op.join(paths['analy_dir'].format(exp=exp), sub, 'preproc', 'run_'+run)
    ts_path = op.join(paths['analy_dir'].format(exp=exp), sub, 'reg/epi/unsmoothed', 'run_'+run)

    #make sure to get coregistered preproc data
    preproc_data = op.join(ts_path, 'timeseries_xfm.nii.gz')

    mask_dir = op.join(paths['data_dir'], sub, 'masks')
    out_dir = mask_dir + '/extractions/'
    
    if not os.path.exists(out_dir):
        os.mkdir(out_dir)

    mask_file = op.join(mask_dir, mask + '.nii.gz')
    out_f = out_dir + ('').join(map(str,in_tuple))+ '.txt'

    if os.path.exists(sub_path):# and not os.path.exists(out_f):
        meants = ImageMeants(in_file = preproc_data, eig = True, order = 1, 
                             mask = mask_file, out_file = out_f)
        meants.run()
        
def extract_roi_prob(in_tuple):
    sub,exp,run,mask = in_tuple
    
    sub_path = op.join(paths['analy_dir'].format(exp=exp), sub, 'preproc', 'run_'+run)
    ts_path = op.join(paths['analy_dir'].format(exp=exp), sub, 'reg/epi/unsmoothed', 'run_'+run)

    #make sure to get coregistered preproc data
    preproc_data = op.join(ts_path, 'timeseries_xfm.nii.gz')

    mask_dir = op.join(paths['data_dir'], sub, 'masks')
    out_dir = mask_dir + '/extractions/'

    prob_file = mask_dir + exp + '_' + mask + '_func_space.nii.gz'
    mask_file = op.join(mask_dir, mask + '.nii.gz')
    out_f = out_dir + ('').join(map(str,in_tuple))+ '.txt'
    tmp_out = mask_dir + sub + exp + run + '.nii.gz'

    if os.path.exists(sub_path):# and not os.path.exists(out_f):
        cmd = ['fslmaths',preproc_data,'-mul',prob_file,tmp_out]
        cmd = ' '.join(cmd)
        os.system(cmd)
        
        meants = ImageMeants(in_file = tmp_out, eig = True, order = 1, 
                             mask = mask_file, out_file = out_f)
        meants.run()
        os.remove(tmp_out)
 
in_tuples = []
for sub in sub_list:
    for exp in exps:
        for run in runs:
            if (sub == 'ap155') & (int(run) > 5):
                print 'Skipping run 6 for ap165!'
            else:
                for mask in masks:
                    in_tuples.append((sub,exp,run,mask))

pool = multiprocessing.Pool(processes = 16)
pool.map(extract_roi,in_tuples)
pool.terminate()
pool.join()