# -*- coding: utf-8 -*-

#flips at 9 probably for standard just looking at electrodes for IT
#same for V4 

import matplotlib.pyplot as plt
import numpy as np

colormap = plt.cm.rainbow
num_plots = 14
plt.gca().set_color_cycle([colormap(i) for i in np.linspace(0, 0.99, num_plots)])

#
#attendtext = raw_input("Attended or unattended?\n")
#regiontext = raw_input("IT or V4?\n")
#electrodestext = raw_input("Which electrodes?\n")
data = np.load("../data/epocheddata.npy")

attendtext = "unattend"
regiontext = "IT"
electrodestext = "13"

attend = 0 if attendtext.strip() == "a" or attendtext.strip() == "attend" else 1
region = 0 if regiontext.strip() == "IT" else 1

if electrodestext == "all":
    electrodes = range(1,15)
else:
    electrodes = [int(x) for x in electrodestext.strip().split(" ")]
    
colormap = plt.cm.rainbow
num_plots = len(electrodes)*3
plt.gca().set_color_cycle([colormap(i) for i in np.linspace(0, 0.99, num_plots)])
    
datadict = data[attend][region]
xaxis = datadict['xaxis']
        
for k in electrodes:
    odd = np.mean(datadict['odd'][k-1],0)
    std = np.mean(datadict['std'][k-1],0)
    maxval = max(odd)
    diff = [abs(x-y) for x, y in zip(odd,std)]
    normdiff = [abs(x-y)/maxval for x, y in zip(odd,std)]
#
    plt.plot(xaxis, odd,label="Odd electode {}".format(str(k)))
    plt.plot(xaxis, std,label="Standard electode {}".format(str(k)))
    plt.plot(xaxis, diff, label = "diff in electode {}".format(str(k)))
#    plt.plot(xaxis,normdiff, label = "normdiff in electode {}".format(str(k)))
    

plt.title("Odd vs Std {} response for {} region".format(attendtext,regiontext))
plt.xlabel(r"Time $\mu$(s)")
plt.ylabel("Potential (mV)")
plt.legend( fontsize = 'small',bbox_to_anchor=(0., -0.1, 1., -0.1), loc=1 )
plt.show()