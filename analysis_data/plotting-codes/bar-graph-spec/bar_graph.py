#%matplotlib inline
import matplotlib.pyplot as plt
#matplotlib.use('gtk')
import numpy as np
import os
ev_list = [10,20,30,50,70]
comput_names = ['CYCL','YL' ,'CL' , 'LL', 'DB' , u'H\u2082' ,'C-Gas','CS']



group1 = [.0094,.047,.0701,.098,.14]
group2 = [.01,.18,.385,.34,.34]
group3 = [0,.01,.243,.96,1.63]
group4 = [0.019,.34,.57,.725,1] 
group5 = [0,.011,.2,.255,.26]
group6 = [0,.11,.058,.11,.12]
group7 = [.02,.62,.97,1.7,2.64]
chain_scision = [4/100.,30/100,155/200.,247./200,340/200.]

error1 = [.0021,.0022,0,.0031,0,0,.002,.001]
error2 = [.01,.017,.0041,.024,.014,.013,.011,.013]
error3 = [.011,.022,.02,.033,.016,.012,.016,.022]
error4 = [.014,.023,.034,.031,.022,.014,.018,.024]
error5 = [.015,.023,.041,.046,.021,.014,.023,.022]


group1tmp = [group1[0],group2[0],group6[0],group5[0],group7[0],group3[0],group4[0],chain_scision[0]]
group2tmp = [group1[1],group2[1],group6[1],group5[1],group7[1],group3[1],group4[1],chain_scision[1]]
group3tmp = [group1[2],group2[2],group6[2],group5[2],group7[2],group3[2],group4[2],chain_scision[2]]
group4tmp = [group1[3],group2[3],group6[3],group5[3],group7[3],group3[3],group4[3],chain_scision[3]]
group5tmp = [group1[4],group2[4],group6[4],group5[4],group7[4],group3[4],group4[4],chain_scision[4]]

group1 = group1tmp
group2 = group2tmp
group3 = group3tmp
group4 = group4tmp
group5 = group5tmp


fig , ax = plt.subplots()

X_axis = np.arange(len(comput_names))
#plt.rcParams["figure.figsize"] = (14,10)

ax.bar(X_axis - .30,group1, 0.15, label = "10 eV", yerr=error1)
ax.bar(X_axis -.15, group2, 0.15, label = "20 eV", yerr=error2)
ax.bar(X_axis , group3, 0.15, label = "30 eV", yerr=error3)
ax.bar(X_axis +.15, group4, .15, label = "50 eV", yerr=error4)
ax.bar(X_axis +  .30, group5, .15, label = "70 eV", yerr=error5)
plt.xticks(X_axis,comput_names)
#plt.xticks(rotation = (18))
plt.xticks(fontsize=30)
plt.yticks(fontsize=24)
plt.ylim([0,2.7])
plt.ylabel("Average # Per Simulation" , fontsize=32)
plt.legend(fontsize=26,loc="upper left")
fig.set_size_inches(14,10)
fig.tight_layout()
plt.savefig("final_bar_graph_test.png")
plt.show()



