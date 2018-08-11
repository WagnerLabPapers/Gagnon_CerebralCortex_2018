#! /usr/bin/env python

import glob
import os.path as op
import os as os
import nibabel as nib
import pandas as pd
import numpy as np
import scipy as sp
import itertools

from nilearn.masking import compute_epi_mask

import matplotlib.pyplot as plt
import matplotlib as mpl

# Nilearn for neuro-imaging-specific machine learning
from nilearn.input_data import NiftiMasker
from nilearn import image

# Nibabel for general neuro-imaging tools
import nibabel

# Scikit-learn for machine learning
from sklearn.svm import SVC
from sklearn.linear_model import LogisticRegression, ElasticNet, LogisticRegressionCV
from sklearn.ensemble import BaggingClassifier, AdaBoostClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.neural_network import MLPClassifier
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.dummy import DummyClassifier
from sklearn.feature_selection import SelectKBest, f_classif
from sklearn.decomposition import PCA
from sklearn.pipeline import Pipeline
from sklearn.cross_validation import LeaveOneLabelOut, LeavePLabelOut, cross_val_score
from sklearn.metrics import confusion_matrix, classification_report, roc_auc_score
from sklearn.model_selection import permutation_test_score
from sklearn import preprocessing
from imblearn.over_sampling import SMOTE
from imblearn.under_sampling import RandomUnderSampler
from sklearn.model_selection import validation_curve

# Plotting
import matplotlib.pyplot as plt
from nilearn import plotting
import seaborn as sns
sns.set(context="poster", style="ticks", font="Arial")

print 'v6'



##########################################
# Get data
# Load in timeseries, mask, select relevant timepoints, scale
##########################################


def get_subj_data(subid, onsetfile, cond_list, paths, mask_type, mask_name,
                  smoothing_fwhm, standardize, tr, tr_shift, run_list,
                  output=True, shift_rest=False, filter_artifacts=False,
                  equalize_trialcounts=False, standardize_patterns=True, 
                  random_state=None):

    # Get relevant onset info
    onsets = pd.read_csv(onsetfile.format(subid=subid)) # load in onset/event data
    onsets = onsets[onsets.condition.isin(cond_list)].reset_index() # subset for conditions

    # User func mask
    if mask_type == 'func':
        # Specify path for func mask (run 1 if registered)
        mask_path = paths['func_maskfile'].format(subid=subid, run_id=1)
    elif mask_type == 'mask':
        mask_path = paths['maskfile'].format(subid=subid, mask_name=mask_name)

    # Define mask for timeseries data (to convert 4D to 2D)
    # apply smoothing and standardization of features here if necessary
    func_masker = NiftiMasker(mask_img=mask_path,
                              smoothing_fwhm=smoothing_fwhm,
                              standardize=standardize)

    num_voxels = np.sum(nib.load(mask_path).get_data(), axis=None).astype(int)

    if output:
        print 'Number of voxels: ' + str(num_voxels)

    # Iterate through runs, get functional data, run labels, and y labels
    X = np.array([]).reshape(0, num_voxels) #initialize storage tr x voxel
    run_labels = np.array([])
    ev_labels = np.array([])
    ev_trs = np.array([])
    ev_onsets = np.array([])
    for run in run_list:
    	print 'Loading data from run ' + str(run) + ' ...'

        # Convert 4D timeseries to 2D (tr x voxel) w/mask
        ts_path = paths['tsfile'].format(subid=subid, run_id=run)
        func_masked = func_masker.fit_transform(ts_path)

        # Get y TRs and labels
        run_events = onsets[onsets.run == run]

        # Optionally balance number of trials/condition
        if equalize_trialcounts:
            print 'balancing trial counts'

            # Figure out counts/run
            condition_df = pd.DataFrame(cond_list, columns=['index']) # full dataframe of conditions requested
            value_counts = run_events.condition.value_counts() # what we have in this run
            cond_counts = pd.merge(condition_df, 
                                   pd.DataFrame(value_counts).reset_index(), how='left') # figure out if missing some
            missing_cond = np.any(cond_counts.condition.isnull()) # any missing conditions?

            # If have trials in this run, sub-sample run events to balance out
            if not missing_cond:
                min_count = cond_counts.condition.min()

                # construct new run_events, equalizing trial counts/condition
                # if min count for a condition is 0 (i.e., a missing condition), then have null df
                sub_sample_events = pd.DataFrame()

                for cond in cond_list:
                    sub_sampled = run_events.loc[run_events.condition == cond].sample(n=min_count,
                                                                                      random_state=random_state)
                    sub_sample_events = sub_sample_events.append(sub_sampled, ignore_index=True)

                run_events = sub_sample_events

            else:
                min_count = 0
        else: min_count = 1 # set to > 0 to run through subseqent analyses

        # if there are events for this run, go through and extract them
        if min_count > 0:
            if shift_rest: # if using fixation between mini-blocks as condition (prob should't)
                run_events.loc[run_events.condition == 'rest',
                            'onset'] = run_events.loc[run_events.condition == 'rest',
                                                        'onset'] + 5

            # Figure out the corresponding TRs
            ev_trs_run = np.ceil((run_events.onset + tr_shift)/tr).astype(int)
            ev_trs_run = ev_trs_run.replace(to_replace=0, value=1) # replace onsets of zero with 1 for indexing later on

            # Remove duplicate TRs (when 2 events are within same TR, e.g., fast localizer)
            unique_rows = ~ev_trs_run.duplicated()
            run_events = run_events[unique_rows]
            ev_trs_run = ev_trs_run[unique_rows]

            # If flagged, remove TRs with artifacts (determined from preprocessing)
            if filter_artifacts:
                run_arts = pd.read_csv(paths['artifacts'].format(subid=subid, run=str(int(run))))
                run_arts['tr'] = np.arange(1,len(run_arts)+1).astype(int)
                bad_trs = list(run_arts.loc[(run_arts.intensity > 0) | (run_arts.motion > 0), 'tr'])

                if bad_trs:
                    good_trs = ~ev_trs_run.isin(bad_trs)
                    print 'Removing ' + str(sum(ev_trs_run.isin(bad_trs))) +' TRs with artifacts...'
                    run_events = run_events[good_trs]
                    ev_trs_run = ev_trs_run[good_trs]

            # Get relevant labels, add to stack
            ev_labels = np.hstack((ev_labels, run_events.condition))
            run_labels = np.hstack((run_labels, run_events.run))
            ev_trs = np.hstack((ev_trs, ev_trs_run))
            ev_onsets = np.hstack((ev_onsets, run_events.onset))

            # Select relevant TRs from 2D data (back 1 for 0 indexing), scale
            if standardize_patterns:
                print 'scaling the data...'
                X_run = preprocessing.scale(func_masked[ev_trs_run-1,:])
            else:
                X_run = func_masked[ev_trs_run-1,:]

            # Append to X
            X = np.vstack((X, X_run))

            if output:
                print '# Events: ' + str(ev_labels.shape)
                print 'Orig TRs: ' + str(func_masked.shape[0])
                print 'X shape: ' + str(X.shape)
        else:
            print 'No events for this run...'

    return X, run_labels, ev_labels, ev_trs, ev_onsets, func_masker


##########################################
# Calculate multivariate variability
# Using formula suggested here:
# http://stats.stackexchange.com/questions/13272/2d-analog-of-standard-deviation
##########################################

def calc_2d_stdev(X):
    centroid = np.mean(X, axis=0)

    dist_from_centroid = []
    for row in X:
        dist = sp.spatial.distance.euclidean(row, centroid)
        dist_from_centroid.append(dist)

    return np.mean(dist_from_centroid)



##########################################
# Logistic Regression Classification
# L2 regularized LR, with leave one run out CV. Separately classify each category (1-vs-other).
##########################################

def calc_scores(df, subid, mask_name, X, ev_labels, run_labels, n_permutations=0, d_permute=None, plot_permutation=False, multi_class = 'ovr'):
    """Classify 2D data (f1 scoring, to take into account precision & recall)
    ----------
    df : pandas dataframe
        Must have columns=['subid', 'mask_name', 'category', 'type', 'mean', 'sd'])
    subid : str
        Subject ID (e.g., 'ap01')
    mask_name: str
    	Name of mask used when calling get_subj_data
    X : 2D numpy array
        Selected BOLD data (sample x voxel) for classification
    ev_labels : list/array of strings
        condition labels (length = # of samples)
    run_labels : list/array of ints
        run label by which to perform cross-validation (length = # of samples)
    n_permutations: ints
        number of permutations (0=don't run)
    d_permute: pandas dataframe
        Should be initialized like this:
        iter_list = list(np.arange(1, n_permutations + 1))
        iter_list.insert(0, 'subid')
        d_permute = pd.DataFrame(columns=iter_list)
    plot_permutation: bool
        Plot a histogram for each subject?

    Returns
    -------
    df : pandas dataframe
        Must have columns=['subid', 'mask_name', 'category', 'type', 'mean', 'sd'])
    """


    if multi_class == 'ovr':
        classifier = LogisticRegression(penalty='l2', C=1.)
    elif multi_class == 'multinomial':
        classifier = LogisticRegression(penalty='l2', C=1.,
                                           multi_class='multinomial', solver='newton-cg')

    dummy_classifier = DummyClassifier()
    cv = LeaveOneLabelOut(run_labels)

    # Run a permutation test, constraining permutations within runs (labels are permuted among samples in same run)
    # Using within-subject permutation approach: http://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=7270849
    # Different relabeling for each subject, and samples may potentially be too nearby in time
    if n_permutations > 0:
        score, permutation_scores, pvalue = permutation_test_score(classifier, X, ev_labels, groups=run_labels,
                                                                   scoring="accuracy", cv=cv,
                                                                   n_permutations=n_permutations, n_jobs=1)
        # actual accuracy
        row = {'subid': subid,
               'mask_name': mask_name,
               'category': 'all',
               'type': 'accuracy',
               'mean': score,
               'sd': np.nan}
        df = df.append(pd.DataFrame.from_dict({0: row}, orient='index'))

        # permutation accuracy
        permute_list = list(permutation_scores)
        permute_list.insert(0, subid)

        iter_list = list(np.arange(1, n_permutations + 1))
        iter_list.insert(0, 'subid')
        d_permute = d_permute.append(pd.Series(permute_list, index=iter_list), ignore_index=True)

        if plot_permutation:
            plt.hist(permutation_scores, 20, label='Permutation scores')
            ylim = plt.ylim()
            plt.plot(2 * [score], ylim, '--g', linewidth=3,
                     label='Classification Score'
                     ' (pvalue %s)' % pvalue)
            plt.plot(2 * [1. / len(set(ev_labels))], ylim, '--k', linewidth=3, label='Luck')
            plt.plot(2 * [permutation_scores.mean()], ylim, '--r', linewidth=3, label='Mean permutation score')

            plt.ylim(ylim)
            plt.xlim((0,1))
            plt.legend()
            plt.xlabel('Score')
            plt.show()

    for category in np.unique(ev_labels):
        classification_target = ev_labels == category # category=True, other=False
        print category

        for acc_type, classify in zip(['f1 score', 'chance'], [classifier, dummy_classifier]):

            scores = cross_val_score(classify, X,
                                     classification_target,
                                     cv=cv, scoring="f1") # other types of scoring include acc, weighted f1, etc

            row = {'subid': subid,
                   'mask_name': mask_name,
                   'category': category,
                   'type': acc_type,
                   'mean': scores.mean(),
                   'sd': scores.std()}

            df = df.append(pd.DataFrame.from_dict({0: row}, orient='index'))

    if n_permutations:
        return df, d_permute
    else:
        return df


##########################################
# Logistic Regression, calculate accuracy & probabilities
# For multi-class classification, supports one-vs-all or multinomial
##########################################

def calc_acc_proba(df_acc, df_proba, subid, mask_name, X, ev_labels, run_labels, cv,
                   multi_class='ovr', univariate_fsel_k=None, pca_n=None, upsampling=False, undersampling=False,
                   conf_mat=False, cm_group=None, print_report=False, compute_AUC=False, df_auc=None,
                   cv_C=False, repeated_ttest_fsel=None):
    """Classify 2D data & return accuracy + probabilities for each class
    ----------
    df_acc : pandas dataframe
        Must have columns=['subid', 'mask_name', 'category', 'classifier', 'accuracy'])
    df_proba : pandas dataframe
        Must have columns=['subid', 'mask_name', 'true_category', 'guess_category', 'classifier', 'probability'])
    subid : str
        Subject ID (e.g., 'ap01')
    mask_name: str
    	Name of mask used when calling get_subj_data
    X : 2D numpy array
        Selected BOLD data (sample x voxel) for classification
    ev_labels : list/array of strings
        condition labels (length = # of samples)
    run_labels : list/array of ints
        run label by which to perform cross-validation (length = # of samples)
    cv : cross-validation generator (e.g., LeaveOneLabelOut(run_labels))
    multi_class : str
        In multiclass case, training uses one-vs-rest ('ovr') or multinomial ('multinomial')
    univariate_fsel_k : int
        Option to perform univariate (ANOVA) feature selection based on the training data; 
        take the k best features
    pca_n : int
        Option to perform PCA on the training set to reduce the number of features
    upsampling : bool
        Option to over-sample using SMOTE to deal with class imbalance
    undersampling : bool
        Option to under-sample using random under-sampling (randomly pick samples without 
        replacement) to deal with class imbalance
    cv_C : bool
        Option to select C via CV; only works for multinomial LR (multi_class = 'multinomial')
    repeated_ttest_fsel : int
        Option to select k features for each combination of t-tests (None otherwise)

    Returns
    -------
    df_acc : pandas dataframe
        Must have columns=['subid', 'mask_name', 'category', 'classifier', 'accuracy', 'count'])
    df_proba : pandas dataframe
        Must have columns=['subid', 'mask_name', 'true_category', 'guess_category', 'classifier', 'probability'])
    df_auc : pandas dataframe
        Must have columns=['subid', 'mask_name', 'category', 'classifier', 'auc'])
    """

    # quick double check
    if repeated_ttest_fsel and univariate_fsel_k:
        print 'Cannot have both repeated_ttest_fsel and univariate_fsel_k; one needs to be set to None'
        return

    # Determine classifier
    if multi_class == 'ovr':
        lr_classifier = LogisticRegression(penalty='l2', C=1.)
    elif multi_class == 'multinomial':
        lr_classifier = LogisticRegression(penalty='l2', C=1.,
                                           multi_class='multinomial', solver='newton-cg')
    elif multi_class == 'balanced': #useful if classes are unbalanced
        lr_classifier = LogisticRegression(penalty='l2', C=1., class_weight='balanced')
    elif multi_class == 'KNeighbors':
        lr_classifier = KNeighborsClassifier(weights='distance')
    elif multi_class == 'BaggingClassifier':
        lr_classifier = BaggingClassifier(LogisticRegression(penalty='l2', C=1.),
                                          max_samples=0.5, max_features=0.5)
    elif multi_class == 'GradientBoosting':
        lr_classifier = GradientBoostingClassifier(n_estimators=100)
    elif multi_class == 'GradientBoosted_LR':
        print 'Add in the code for this classifier!'
        # http://scikit-learn.org/stable/auto_examples/ensemble/plot_feature_transformation.html
    elif multi_class == 'AdaBoost':
        lr_classifier = AdaBoostClassifier(n_estimators=100)
    elif multi_class == 'MLP': #multilayer perceptron
        lr_classifier = MLPClassifier(solver='lbfgs', random_state=1,
                                      hidden_layer_sizes=(100, 100, 50))
    else: print 'Need a classifier!'; return

    dummy_classifier = DummyClassifier()

    # initialize confusion matrix
    if conf_mat:
        num_cond = len(np.unique(ev_labels))
        cm_sub = np.zeros([num_cond, num_cond], dtype=int)

    for class_type, classifier in zip(['logreg', 'chance'], [lr_classifier, dummy_classifier]):

        # Calculate C in a CV manner, if requested
        if cv_C and multi_class == 'multinomial':
            calc_c = LogisticRegressionCV(penalty='l2', cv=cv,
                                          multi_class='multinomial',
                                          solver='newton-cg')
            calc_c.fit(X, ev_labels)
            print 'Setting C to: ' + str(calc_c.C_)
            lr_classifier = LogisticRegression(penalty='l2', C=calc_c.C_,
                                               multi_class='multinomial', solver='newton-cg')

        # Go through cross-validation loops
        for train, test in cv:

            # univariate feature selection? t-test version comes later...
            if univariate_fsel_k:
                fsel = SelectKBest(f_classif, k=univariate_fsel_k).fit(X[train], ev_labels[train])
                X_train = fsel.transform(X[train])
            else:
                X_train = X[train]

            # Feature decomposition?
            if pca_n:
                pca = PCA(n_components=pca_n).fit(X_train)
                X_train = pca.transform(X_train)

            # over/under sampling to balance classes during training?
            if upsampling:
                sm = SMOTE(random_state=42) # Synthetic Minority Over-sampling Technique
                X_train, ev_labels_train = sm.fit_sample(X_train, ev_labels[train])
                # print X_train.shape
                # print ev_labels_train
            elif undersampling:
                rus = RandomUnderSampler(random_state=42, replacement=False)
                X_train, ev_labels_train = rus.fit_sample(X_train, ev_labels[train])
            else:
                ev_labels_train = ev_labels[train]

            # If running feature selection using lowest pvals from combinations of classes
            if repeated_ttest_fsel:
                pvals = [] # initalize list for pvals across all combos

                for i, combo in enumerate(itertools.combinations(list(set(ev_labels_train)), 2)):
                    print i, combo

                    # figure out which samples are of interest
                    mask = np.in1d(ev_labels_train, combo)

                    # get pvals, add on to pvals list
                    fval, pval = f_classif(X_train[mask], ev_labels_train[mask])
                    pvals.extend(list(pval.argsort()[:repeated_ttest_fsel]))

                # Now just grab relevant features from training data
                selected_voxels = list(set(pvals))
                print 'Total of ' + str(len(selected_voxels)) + ' voxels.'
                X_train = X_train[:, selected_voxels]
                print X_train.shape


            # Fit classifier w/training data & labels
            classifier.fit(X_train, ev_labels_train)

            # Now prepare for testing!
            if univariate_fsel_k:
                X_test = fsel.transform(X[test])
            else:
                X_test = X[test]

            if repeated_ttest_fsel:
                X_test = X_test[:, selected_voxels]
                print X_test.shape

            if pca_n:
                X_test = pca.transform(X_test)

            # update confusion matrix if necessary
            if conf_mat and class_type != 'chance':
                y_pred = classifier.predict(X_test)
                cm_fold = confusion_matrix(ev_labels[test], y_pred)
                cm_sub = np.sum([cm_sub, cm_fold], axis=0)

            if print_report:
                y_pred = classifier.predict(X_test)
                print(classification_report(ev_labels[test], y_pred,
                                            target_names=classifier.classes_))

            # get logits for all trials
            if compute_AUC and class_type != 'chance':
                y_score = classifier.decision_function(X_test)

            # Iterate through each class to get acc, proba, etc.
            for i, category in enumerate(classifier.classes_):

                # Get indices for the true category
                cat_ind = ev_labels[test] == category

                # if this trial exists
                if sum(cat_ind) > 0:
                    # Determine accuracy (TPR)
                    acc = classifier.score(X_test[cat_ind],
                                           ev_labels[test][cat_ind])

                    if compute_AUC and class_type != 'chance':
                        if len(classifier.classes_) > 2:
                            auc = roc_auc_score(cat_ind, y_score[:, i])
                        else: auc = roc_auc_score(cat_ind, y_score)
                        row = {'subid': subid,
                               'mask_name': mask_name,
                               'category': category,
                               'classifier': class_type,
                               'auc': auc}
                        df_auc = df_auc.append(pd.DataFrame.from_dict({0: row}, orient='index'))

                    # Determine probabilities & save out probabilities for each category guessed
                    probabilities = classifier.predict_proba(X_test[cat_ind]).T #class x sample
                    prob_byclass = np.mean(probabilities, axis=1) # mean probability for each class for these samples

                    for guess_cat in classifier.classes_:
                        proba = prob_byclass[classifier.classes_ == guess_cat][0] # select the relevant column

                        row = {'subid': subid,
                               'mask_name': mask_name,
                               'true_category': category,
                               'guess_category': guess_cat,
                               'classifier': class_type,
                               'probability': proba}

                        df_proba = df_proba.append(pd.DataFrame.from_dict({0: row}, orient='index'))
                else:
                    print 'Nothing to score!'
                    acc = np.nan

                row = {'subid': subid,
                       'mask_name': mask_name,
                       'category': category,
                       'classifier': class_type,
                       'accuracy': acc,
                       'count': sum(cat_ind)}

                df_acc = df_acc.append(pd.DataFrame.from_dict({0: row}, orient='index'))

        # save confusion matrix, once iterated through CV folds
        if conf_mat and class_type != 'chance':
            print classifier.classes_

            print 'Confusion matrix (raw counts):'
            print cm_sub

            # normalize, and add to group matrix
            cm_sub = cm_sub.astype('float') / cm_sub.sum(axis=1)[:, np.newaxis]
            print 'Confusion matrix (normalized):'
            print cm_sub

            cm_group = np.append(cm_group, [cm_sub], axis=0)

    # Return calculations
    if compute_AUC:
        if conf_mat:
            return df_acc, df_proba, df_auc, cm_group
        else:
            return df_acc, df_proba, df_auc
    else:
        if conf_mat:
            return df_acc, df_proba, cm_group
        else:
            return df_acc, df_proba


##########################################
# Create importance maps
# Fit classifier to the entire dataset, pull out coefficients, and save niftis and pngs if requested
##########################################

def create_coef_maps(subid, X, ev_labels, func_masker, mask_name, paths,
                     save_img=True, show_img=False, calc_A=False, univariate_fsel_k=None):

    """Create coef maps, output niftis and pngs
    ----------
    subid : str
        Subject ID (e.g., 'ap01')
    X : 2D numpy array
        Selected BOLD data (sample x voxel) for classification
    ev_labels : list/array of strings
        condition labels (length = # of samples)
    func_masker : NiftiMasker object
        created from mask image, use to convert 2D back to 3D
    paths : dict
        filepaths to the mean functional (to use as background for png) & output directory
    save_img : bool
        save out niftis and png images?
    show_img : bool
        show images?
    calc_A : bool
        calculate activation patterns? This is just covariance matrix of data multiplied by coefficients. Might crash computer if X is too big?
        http://www.sciencedirect.com/science/article/pii/S1053811913010914
    univariate_fsel_k : int
        include univariate feature selection (using ANOVA) for k best features before training classifier
    """

    # if using feature selection, do it now
    if univariate_fsel_k:
        fsel = SelectKBest(f_classif, k=univariate_fsel_k).fit(X, ev_labels)
        X = fsel.transform(X)

    classifier = LogisticRegression(penalty='l2', C=1.)
    classifier.fit(X, ev_labels)

    print classifier.classes_

    if len(classifier.classes_) > 2:
        cats = classifier.classes_
    else:
        cats = [classifier.classes_[0]]

    d_coef = pd.DataFrame(columns=cats)

    print 'Categories: '
    print cats

    for category in cats:
        print category

        # Get coefficients for the category of interest, save in d_coef df
        if len(classifier.classes_) > 2:
            coef = classifier.coef_[classifier.classes_ == category]
            d_coef[category] = pd.Series(coef.squeeze())
        else:
            coef = classifier.coef_
            d_coef[category] = pd.Series(coef.squeeze())

        # reverse feature selection if necessary
        if univariate_fsel_k:
            coef = fsel.inverse_transform(coef)

        # Transform activation patterns or coefs to native space
        if calc_A: #careful, might crash computer...
            print 'computing cov mat...'
            data_cov = np.cov(X.T)
            print 'multiplying matrices...'
            A_w = np.matmul(data_cov, coef.T)
            print 'transforming to epi space'
            weight_img = func_masker.inverse_transform(A_w.T)
            filename = "{mask_name}_activationpattern_{category}"
        else:
            weight_img = func_masker.inverse_transform(coef)
            filename = "{mask_name}_coef_{category}"

        # Save output
        if save_img:
            filepath = paths['outnifti'].format(subid=subid)

            if not op.exists(filepath):
                os.makedirs(filepath)

            weight_img.to_filename(op.join(filepath, 
                                           filename + '.nii.gz').format(mask_name=mask_name,
                                                                        category=category))
            plotting.plot_stat_map(weight_img,
                                   paths['meanfile'].format(subid=subid, run_id=1),
                                   title=category,
                                   output_file=op.join(filepath, 
                                                       filename + '.png').format(mask_name=mask_name,
                                                                                 category=category))
        elif show_img:
            print 'plot stat map'
            plotting.plot_stat_map(weight_img,
                                   paths['meanfile'].format(subid=subid, run_id=1),
                                   title=category)

    return d_coef



##########################################
# Logistic Regression Classification
# L2 regularized LR, train on localizer, test on other data
##########################################


def calc_acc_train_loc(d_lr, subid, paths, mask_type, mask_name,
                       smoothing_fwhm, standardize, tr, tr_shift,
                       loc_cond_list, loc_run_list,
                       mem_cond_list, mem_run_list,
                       tr_range=False, multi_class='ovr',
                       output='logit', save_trials=False, timepts_save=None, ev_mapping=None,
                       standardize_test=True, equalize_trialcounts=False):

    #########################################
    # Get localizer training data
    #########################################

    onsetfile = paths['loc_onsetfile']
    cond_list = loc_cond_list
    run_list = loc_run_list

    X, run_labels, ev_labels, ev_trs, ev_onsets, func_masker = get_subj_data(subid, onsetfile, cond_list,
                                                                             paths, mask_type, mask_name,
                                                                             smoothing_fwhm, standardize,
                                                                             tr, tr_shift, run_list,
                                                                             output=False, shift_rest=True,
                                                                             filter_artifacts=True)

    if multi_class == 'ovr':
        lr_classifier = LogisticRegression(penalty='l2', C=1.)
    elif multi_class == 'multinomial':
        lr_classifier = LogisticRegression(penalty='l2', C=1.,
                                           multi_class='multinomial', solver='newton-cg')

    classifier = lr_classifier

    # Fit classifier to localizer
    classifier.fit(X, ev_labels)
    print 'Fit localizer data...'

    #########################################
    # Get memory test data for testing
    #########################################

    onsetfile = paths['mem_onsetfile']
    cond_list = mem_cond_list
    run_list = mem_run_list

    print 'Run list:'
    print run_list

    # Determine the number of timepoints to test
    if tr_range:
        time_list = timepts_save
    else:
        time_list = tr_shift

    # hacky for now, but get a random state for sampling within get_subj_data across time shifts
    if equalize_trialcounts:
        random_state = np.random.randint(1, 100000)
    else:
        random_state = None


    for time in time_list:
        print 'Time sample: ' + str(time)
        Y, run_labels, ev_labels, ev_trs, ev_onsets, func_masker = get_subj_data(subid, onsetfile, cond_list, paths, mask_type, mask_name,
                                                                                 smoothing_fwhm, standardize_test, tr, time, run_list, output=False,
                                                                                 equalize_trialcounts=equalize_trialcounts,
                                                                                 random_state=random_state)

        print 'Loaded in testing data...'

        # deal with 2 vs. > 2 classes
        if len(classifier.classes_) < 3:
            col_names = [classifier.classes_[0]]
        else:
            col_names = classifier.classes_

        # Calculate probabilities with memory data (event x class matrix)
        if output == 'proba':
            dprob = pd.DataFrame(classifier.predict_proba(Y),
                                 columns=col_names, index=ev_labels)
        # Calculate logits with memory data (event x class matrix)
        elif output == 'logit':
            dprob = pd.DataFrame(classifier.decision_function(Y),
                                 columns=col_names, index=ev_labels)
        # Calculate classification accuracy
        elif output == 'acc':
            cond_subset = ev_mapping.keys()
            dprob = pd.DataFrame(columns=['value', 'mem_cond'], index=cond_subset)

            # determine what the labels should be for each sample (based on ev_labels label for each trial)
            correct_labels = [ev_mapping[trial_type] for trial_type in ev_labels]

            # iterate through the relevant trial types and calculate accuracy for each
            for trial_type in cond_subset:
                trial_ind = ev_labels == trial_type

                # if there are any trials w/this trial type, calculate accuracy
                if any(trial_ind):
					dprob.ix[trial_type, 'value'] = classifier.score(Y[trial_ind], np.array(correct_labels)[trial_ind])
					dprob.ix[trial_type, 'mem_cond'] = trial_type

        # If saving out all trials for this subject:
        if save_trials and (time in timepts_save) and (output != 'acc'):

            # create trial_estimates directory if necessary
            trial_output = paths['outtrials'].format(subid=subid, output=output, time=str(time), mask=mask_name, multi_class_alg=multi_class)
            try:
                os.makedirs(op.split(trial_output)[0])
            except OSError:
                pass

            df_out = dprob
            df_out['tr'] = ev_trs
            df_out['onset'] = ev_onsets
            df_out['run'] = run_labels
            df_out.to_csv(trial_output)

        if output == 'acc':
            means = dprob
            means.rename(columns={'value': output}, inplace=True)

        else:
            # Collapse across memory trials
            means = dprob.groupby(dprob.index).mean()
            # Create a longform matrix of probabilities/logits (mem_cond and class)
            means = pd.melt(means.reset_index(), id_vars=['index'], value_vars=loc_cond_list)
            means.rename(columns={'index': 'mem_cond', 'variable': 'class', 'value': output}, inplace=True)

        # Add the probability df to group
        means['subid'] = subid
        means['mask'] = mask_name
        means['time'] = time
        d_lr = d_lr.append(means, ignore_index=True)

    return d_lr

# Plot a validation curve (scores for training, testing) to assess overfitting
# http://scikit-learn.org/stable/modules/learning_curve.html
def plot_validation_curve(X, ev_labels, cv, c_list=np.logspace(-3, 2, 6)):

    # specify model
    lr_classifier = LogisticRegression(penalty='l2',
                                       multi_class='multinomial', solver='newton-cg')

    # calculate val curve
    train_scores, valid_scores = validation_curve(lr_classifier, X, ev_labels,
                                                  "C", c_list, cv=cv)

    # combine scores into df
    d = pd.DataFrame(train_scores, columns=cv.unique_labels.astype(int))
    d['score_type'] = 'train'
    d['C'] = c_list

    d2 = pd.DataFrame(valid_scores, columns=cv.unique_labels.astype(int))
    d2['score_type'] = 'valid'
    d2['C'] = c_list

    d = d.append(d2)

    # calc mean across folds
    d['mean_score'] = d[cv.unique_labels.astype(int)].mean(axis=1)

    sns.factorplot(x='C', y='score', hue='score_type', aspect=1.5,
                   data=pd.melt(d,
                                id_vars=['C', 'mean_score', 'score_type'],
                                value_vars=[13, 14], var_name='cv', value_name='score'))




# Plot a validation curve (scores for training, testing) to assess overfitting
# http://scikit-learn.org/stable/modules/learning_curve.html
def plot_validation_curve(X, ev_labels, cv, c_list=np.logspace(-3, 2, 6)):

    # specify model
    lr_classifier = LogisticRegression(penalty='l2',
                                       multi_class='multinomial', solver='newton-cg')

    # calculate val curve
    train_scores, valid_scores = validation_curve(lr_classifier, X, ev_labels,
                                                  "C", c_list, cv=cv)

    # combine scores into df
    d = pd.DataFrame(train_scores, columns=cv.unique_labels.astype(int))
    d['score_type'] = 'train'
    d['C'] = c_list

    d2 = pd.DataFrame(valid_scores, columns=cv.unique_labels.astype(int))
    d2['score_type'] = 'valid'
    d2['C'] = c_list

    d = d.append(d2)

    # calc mean across folds
    d['mean_score'] = d[cv.unique_labels.astype(int)].mean(axis=1)

    sns.factorplot(x='C', y='score', hue='score_type', aspect=1.5,
                   data=pd.melt(d,
                                id_vars=['C', 'mean_score', 'score_type'],
                                value_vars=[13, 14], var_name='cv', value_name='score'))
