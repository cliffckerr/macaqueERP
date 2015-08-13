# -*- coding: utf-8 -*-

import matplotlib.pyplot as plt
import numpy as np

electrode = 1
trial = 4

#convert the mat data into python variables
data = np.load("data/epocheddata.npy")

#take the [1,1] element of data? -> will be attended IT
exampledata = data[0][0]

xaxis = exampledata['xaxis']
yaxis = exampledata['odd'][electrode][trial]
meanyaxis = np.mean(exampledata['odd'][electrode],0)
plt.plot(xaxis, yaxis, color = 'b', label="Data for trial {}".format(trial))
plt.plot(xaxis, meanyaxis, color='g', label = "Average over all trials")
plt.xlabel(r'Time $\mu$(s)')
plt.ylabel("Potential (mV)")
plt.legend(loc=4, fontsize = 'small')

plt.show()