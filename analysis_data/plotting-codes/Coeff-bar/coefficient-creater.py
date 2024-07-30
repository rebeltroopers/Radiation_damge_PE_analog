
import numpy as np
import matplotlib.pyplot as plt


def Matts_equation(num_sims,A,B,A_B):
    top = A_B - A*B
    bot = np.sqrt(A*(1-A)*B*(1-B))
    return top/bot


groups_labels = ['Y-point', 'carbon-gas', 'hydrogen_gas', 'cyclization', 'chain-lengthened', 'cross-linking', 'chain-scission', 'CG12','double-bonds']

num_sims = 200
raw_data_70 = np.load("70eVall-raw-data.txt.npy")
raw_data_50 = np.load("50eVall-raw-data.txt.npy")
raw_data_30 = np.load("30eVall-raw-data.txt.npy")
coef_data_70 = np.zeros([len(raw_data_70),len(raw_data_70)])
coef_data_50 = np.zeros([len(raw_data_70),len(raw_data_70)])
coef_data_30 = np.zeros([len(raw_data_70),len(raw_data_70)])
coef_data_all = np.zeros([len(raw_data_70),len(raw_data_70)])



for i in range(len(raw_data_70)):
    A = raw_data_70[i,i] / num_sims

    for j in range(len(raw_data_70)):
        B = raw_data_70[j,j] / num_sims
        coef_data_70[i,j] = Matts_equation(num_sims,A,B,raw_data_70[i,j]/num_sims)

for i in range(len(raw_data_70)):
    A = raw_data_50[i,i] / num_sims

    for j in range(len(raw_data_70)):
        B = raw_data_50[j,j] / num_sims
        coef_data_50[i,j] = Matts_equation(num_sims,A,B,raw_data_50[i,j]/num_sims)

for i in range(len(raw_data_70)):
    A = raw_data_30[i,i] / num_sims

    for j in range(len(raw_data_70)):
        B = raw_data_30[j,j] / num_sims
        coef_data_30[i,j] = Matts_equation(num_sims,A,B,raw_data_30[i,j]/num_sims)

raw_data_all = raw_data_70 + raw_data_50 + raw_data_30
np.save("30_ev_coef-data",coef_data_30)

for i in range(len(raw_data_70)):
    A = raw_data_all[i,i] / 600

    for j in range(len(raw_data_70)):
        B = raw_data_all[j,j] / 600
        coef_data_all[i,j] = Matts_equation(num_sims,A,B,raw_data_all[i,j]/600)

np.set_printoptions(precision=3)
print(groups_labels)
print("70 eV")
print(coef_data_70)
print("50 eV")

print(coef_data_50)
print("30 eV")
print(coef_data_30)
print("all combined")
print(coef_data_all)

print(groups_labels)
coef_double_scission_70 = coef_data_70[-1,-3]
coef_double_scission_50 = coef_data_50[-1,-3]
coef_double_scission_30 = coef_data_30[-1,-3]
coef_double_scission_all = [coef_double_scission_30,coef_double_scission_50,coef_double_scission_70]
eV = ['30','50','70']
coef_double_carbongas_70 = coef_data_70[-1,1]
coef_double_carbongas_50 = coef_data_50[-1,1]
coef_double_carbongas_30 = coef_data_30[-1,1]
coef_double_carbongas_all = [coef_double_carbongas_30,coef_double_carbongas_50,coef_double_carbongas_70]

coef_scission_carbongas_70 = coef_data_70[1,-3]
coef_scission_carbongas_50 = coef_data_50[1,-3]
coef_scission_carbongas_30 = coef_data_30[1,-3]
coef_scission_carbongas_all = [coef_scission_carbongas_30,coef_scission_carbongas_50,coef_scission_carbongas_70]

print("coef values")
print(coef_scission_carbongas_all,coef_double_carbongas_all,coef_double_scission_all)
error_CG_CS = [0.0393 , .0234 , .0303]
error_CS_double = [.02187 , .03224 , 0.142]
error_CG_double = [0.0216, .0296 , 0.1386]
#X_axis = np.arange(len(eV))
X_axis = np.array([0,.7,1.4])
print(coef_double_scission_all)
fig = plt.figure(figsize = (18,16))
plt.bar(X_axis - .2,coef_double_scission_all, .18 ,label="DB and CS" ,yerr=error_CS_double,capsize=3)
plt.bar(X_axis + 0 ,coef_double_carbongas_all, .18 , label="C-Gas and DB",yerr=error_CS_double,capsize=3)
plt.bar(X_axis  +  .2 , coef_scission_carbongas_all, .18 ,label="C-Gas and CS",yerr=error_CG_CS,capsize=3)
plt.legend(fontsize=34)
plt.xticks(X_axis,eV,fontsize=38)
plt.yticks(np.arange(-.05,max(coef_double_carbongas_all)+.05,.1),fontsize=34)
plt.xlabel("Excitation (eV)",fontsize=40)
plt.ylabel("Correlation Coefficient Values",fontsize=38)
#plt.title("coefficient value for several similiar probabilities",fontsize=28)
plt.savefig("bar-graph-coefficient-data-test.png")
plt.show()

