# -*- coding: utf-8 -*-
"""
MATTOPYTHON

Convert data from Matlab to Python

@author: cliffk
"""

from scipy.io import loadmat

filename = '/u/cliffk/bill/data/juemo/raw/epocheddata.mat'

print('Loading data...')
orig = loadmat(filename)
data = orig['data']

print('Done.')