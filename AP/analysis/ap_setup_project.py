#! /usr/bin/env python

import os
import re
import sys
import imp
import os.path as op
import numpy as np

# for dprime
from scipy.stats import norm
from math import exp,sqrt
Z = norm.ppf

def gather_experiment_info(exp_name=None, dirs=None, altmodel=None):
    """Import an experiment module and add some formatted information."""

    # Import the base experiment
    exp_file = op.join(dirs["analydir"], exp_name + ".py")
    exp = imp.load_source(exp_name, exp_file)
    exp_dict = dict() # could load in default here, and just replace a few things

    def keep(k):
        return not re.match("__.*__", k)

    exp_dict.update({k: v for k, v in exp.__dict__.items() if keep(k)})

    # Possibly import the alternate model details
    if altmodel is not None:

    	alt_file = op.join(dirs["analydir"], "%s-%s.py" % (exp_name, altmodel))
    	alt = imp.load_source(altmodel, alt_file)
    	alt_dict = {k: v for k, v in alt.__dict__.items() if keep(k)}
        # Update the base information with the altmodel info
        exp_dict.update(alt_dict)

    # Save the __doc__ attribute to the dict
    exp_dict["comments"] = "" if exp.__doc__ is None else exp.__doc__
    if altmodel is not None:
        exp_dict["comments"] += "" if alt.__doc__ is None else alt.__doc__


    return exp_dict


def dPrime_list(hits, fas, olds, news):
    # Floors an ceilings are replaced by half hits and half FA's
    halfHit = 0.5/olds
    halfFa = 0.5/news

    # Calculate hitrate and avoid d' infinity
    hitRate = hits/olds
    hitRate[hitRate == 1] = 1-halfHit[hitRate == 1]
    hitRate[hitRate == 0] = halfHit[hitRate == 0]

    # Calculate false alarm rate and avoid d' infinity
    faRate = fas/news
    faRate[faRate == 1] = 1-halfFa[faRate == 1]
    faRate[faRate == 0] = halfFa[faRate == 0]

    # Return d', beta, c and Ad'
    out = {}
    out['d'] = Z(hitRate) - Z(faRate)
    out['beta'] = [exp(x)/2 for x in Z(faRate)**2 - Z(hitRate)**2]
    out['c'] = -(Z(hitRate) + Z(faRate))/2
    out['Ad'] = norm.cdf(out['d']/sqrt(2))
    return out


def dPrime(hits, fas, olds, news):
    # Floors an ceilings are replaced by half hits and half FA's
    halfHit = 0.5/olds
    halfFa = 0.5/news

    # Calculate hitrate and avoid d' infinity
    hitRate = hits/olds
    if hitRate == 1: hitRate = 1-halfHit
    if hitRate == 0: hitRate = halfHit

    # Calculate false alarm rate and avoid d' infinity
    faRate = fas/news
    if faRate == 1: faRate = 1-halfFa
    if faRate == 0: faRate = halfFa

    # Return d', beta, c and Ad'
    out = {}
    out['d'] = Z(hitRate) - Z(faRate)
    out['beta'] = exp(Z(faRate)**2 - Z(hitRate)**2)/2
    out['c'] = -(Z(hitRate) + Z(faRate))/2
    out['Ad'] = norm.cdf(out['d']/sqrt(2))
    return out

def add_subinfo(data, info_dict, col_name):
# Example: add_subinfo(dt, genders, 'gender')

    for info in info_dict.keys():
            data.loc[data.subid.isin(info_dict[info]), col_name] = info

    return data
