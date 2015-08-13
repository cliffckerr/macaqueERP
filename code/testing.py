# -*- coding: utf-8 -*-
import mattopython as m2p
import matplotlib.pyplot as plt
import numpy as np

electrode = 1
trial = 4

#convert the mat data into python variables
data = m2p.getmatdata()

#take the [1,1] element of data? -> gives me a [1,1] matrix 
exampledata = data[0][0]

#look into one
example = exampledata[0][0]

#trying implementing the x/y-axis stuff
xaxis = np.matrix.transpose(example['xaxis'])
yaxis = np.squeeze(example['odd'][electrode][trial])
meanyaxis = np.squeeze(np.mean(example['odd'][electrode],0))

plt.plot(xaxis, yaxis, color = 'b', label="Data for trial {}".format(trial))
plt.plot(xaxis, meanyaxis, color='g', label = "Average over all trials")
plt.xlabel(r'Time $\mu$(s)')
plt.ylabel("Potential (mV)")
plt.legend(loc=4, fontsize = 'small')

plt.show()

