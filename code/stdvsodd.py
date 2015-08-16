# -*- coding: utf-8 -*-

import matplotlib.pyplot as plt
import numpy as np

data = np.load("data/epocheddata.npy")

attendtext = raw_input("Attended or unattended?\n")
regiontext = raw_input("IT or V4?\n")
electrodestext = raw_input("Which electrodes?\n")

attend = 0 if attendtext.strip() == "a" or attendtext.strip() == "attend" else 1
region = 0 if attendtext.strip() == "IT" else 1

if electrodestext == "all":
    electrodes = range(1,15)
else:
    electrodes = [int(x) for x in electrodestext.strip().split(" ")]
    
datadict = data[attend][region]
xaxis = datadict['xaxis']
        
for k in electrodes:
    odd = np.mean(datadict['odd'][k-1],0)
    std = np.mean(datadict['std'][k-1],0)
    plt.plot(xaxis, odd,label="Odd electode {}".format(str(k+1)))
    plt.plot(xaxis, std,label="Standard electode {}".format(str(k+1)))
    
plt.title("Odd vs Std {} response for {} region".format(attendtext,regiontext))
plt.xlabel(r"Time $\mu$(s)")
plt.ylabel("Potential (mV)")
plt.legend(loc=4, fontsize = 'small')
plt.show()