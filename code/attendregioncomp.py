# -*- coding: utf-8 -*-

import matplotlib.pyplot as plt
import numpy as np

data = np.load("data/epocheddata.npy")
k = int(raw_input('Which electrode? '))
regiontext = raw_input("Which region? ")

region = 0 if regiontext.strip() == "IT" else 1

for i in range(2):
        datadict = data[i][region]
        xaxis = datadict['xaxis']

        yaxis = np.mean(datadict['odd'][k-1],0)
        attend = "att" if i == 0 else "unatt"
        plt.plot(xaxis, yaxis,label="{} in {}".format(attend,regiontext))
        
        plt.title("Odd electrode {} response ".format(str(k)))
        plt.xlabel(r"Time $\mu$(s)")
        plt.ylabel("Potential (mV)")
        plt.legend(loc=4, fontsize = 'small')
        
plt.show()