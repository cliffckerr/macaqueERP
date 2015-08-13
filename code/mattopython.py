# -*- coding: utf-8 -*-
"""
MATTOPYTHON

Convert data from Matlab to Python.

Data are saved in the following format:
data      = 2x2 dict array (1st dimension: attend vs. non-attend; 2nd dimension: IT vs. V4)
data[i,j] = dictionary with the following keys:
    filename = full name of original file
    epoch    = peristimulus window in s
    channels = chant nels from the original file
    Hz       = sampling rate in Hz
    attend   = whether or not the visual stimuli were being attended to
    xaxis    = simply epoch*Hz; the time points corresponding to the data
    std     = visual standard epoched data, dimensions are channel | trial | time] -- optional
    odd      = visual oddball epoched data, dimensions are channel | trial | time

@author: cliffk
"""

from matplotlib.pylab import empty
from scipy.io import loadmat

#import os.path
#
#def getmatdata():
#
#    #filename = "C:\\Users\\Felicity\\macaqueERP\\data\\"
#    filename = os.path.normcase("C:/Users/Felicity/macaqueERP/data/epocheddata.mat")
#    print('Loading data...')
#    orig = loadmat(filename)
#    data = orig['data']
#    print('Done.')
#    return data


import utils as u
from numpy import save
import os.path


filedir = os.path.dirname(os.path.dirname(__file__))+"\\data\\"

outputfile = 'epocheddata'

print('Loading data...')

datakeys = ['filename', 'epoch', 'channels', 'Hz', 'attend', 'xaxis', 'std', 'odd']
data = empty((2,2), dtype=object) # Array of dictionaries
for i in range(2): # Loop over attend vs. non-attend
    for j in range(2): # Loop over IT vs. V4
        data[i,j] = {} # Initialize dictionary
        for key in datakeys:
            filename = '%i_%i_%s.mat' % (i+1, j+1, key)
            fullpath = filedir+filename
            print('  Loading '+filename)
            orig = loadmat(fullpath) # Original data
            if key in ['filename', 'epoch', 'channels', 'xaxis', 'std']:
                data[i,j][key] = orig['tmp'][0]
            if key in ['Hz', 'attend']:
                data[i,j][key] = orig['tmp'][0][0]
            if key in ['std', 'odd']:
                data[i,j][key] = orig['tmp']
            
            u.printdata(data[i,j][key])


print('Saving data...')
save(filedir+outputfile, data)


print('Done.')
