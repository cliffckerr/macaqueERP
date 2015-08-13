# -*- coding: utf-8 -*-
"""
MATTOPYTHON

Convert data from Matlab to Python

@author: cliffk
"""

from scipy.io import loadmat
import os.path

def getmatdata():

    #filename = "C:\\Users\\Felicity\\macaqueERP\\data\\"
    filename = os.path.normcase("C:/Users/Felicity/macaqueERP/data/epocheddata.mat")
    print('Loading data...')
    orig = loadmat(filename)
    data = orig['data']
    print('Done.')
    return data