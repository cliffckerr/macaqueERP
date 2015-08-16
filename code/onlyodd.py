# -*- coding: utf-8 -*-

import matplotlib.pyplot as plt
import numpy as np

data = np.load("data/epocheddata.npy")

#[attended][IT vs V4]

#so first of all lets compare the plots for the different electrodes for all 4
#combinations of attend/IT etc for oddplots
electrodestext = raw_input('Which electrodes?')
if electrodestext == "all":
    electrodes = range(1,15)
else:
    electrodes = [int(x) for x in electrodestext.strip().split(" ")]

for i in range(2):
    for j in range(2):
        datadict = data[i][j]
        xaxis = datadict['xaxis']
        
        for k in electrodes:
            yaxis = np.mean(datadict['odd'][k-1],0)
            plt.plot(xaxis, yaxis,label="Electrode {}".format(str(k)))
        attend = "attended" if i == 0 else "unattended"
        region = "IT" if j == 0 else "V4"
        plt.title("Odd {} response for {} region".format(attend,region))
        plt.xlabel(r"Time $\mu$(s)")
        plt.ylabel("Potential (mV)")
        plt.legend(loc=4, fontsize = 'small')
        plt.show()
        

#response to an event happens later in IT it seems. looking at electrode 1
#V4 response occurs at roughly 0.12 and IT at 0.18
        
#looking at the electrodes in groups of 3:
#we see quite similar responses for 1,2,3. Biggest difference between
#the 3  signals is for V4 region at roughly 0.18 
        