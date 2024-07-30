import numpy as np
import matplotlib.pyplot as plt


groups_labels = ['Y-point', 'carbon-gas', 'hydrogen_gas', 'cyclization', 'chain-lengthened', 'cross-linking', 'chain-scission', 'CG12','double-bonds'];

#double-bonds,hydrogen-gas,chain-scission,carbon-gas
#chain-scission,hydrogen-gas,
#hydrogen-gas,carbon-gas

non_norm_cond = np.load('30eVall-raw-data.txt.npy')


norm_cond = np.zeros((len(non_norm_cond),len(non_norm_cond)))

for i in range(len(norm_cond)):
    for j in range(len(norm_cond)):
        norm_cond[i,j] = non_norm_cond[i,j]/non_norm_cond[i,i]*100

for i in range(len(norm_cond)):
    print(groups_labels[i])
    print(norm_cond[i])
final_bar1 = []
final_bar2 = []
final_name = []

double_HG = norm_cond[8,2]
HG_double = norm_cond[2,8]
final_bar1.append(double_HG)
final_bar2.append(HG_double)
final_name.append("A=DB \nB=H\u2082")

double_CS = norm_cond[8,6]
CS_double = norm_cond[6,8]
final_bar1.append(double_CS)
final_bar2.append(CS_double)
final_name.append("A=DB \nB=CS")


double_CG = norm_cond[8,1]
CG_double = norm_cond[1,8]
final_bar1.append(double_CG)
final_bar2.append(CG_double)
final_name.append("A=DB\nB=C-Gas")

CS_HG     = norm_cond[6,2]
HG_CS     = norm_cond[2,6]
final_bar1.append(CS_HG)
final_bar2.append(HG_CS)
final_name.append('A=CS\nB=H\u2082')

CG_CS    = norm_cond[1,6]
CS_CG    = norm_cond[6,1]
final_bar1.append(CG_CS)
final_bar2.append(CS_CG)
final_name.append('A=CS \nB=C-Gas')

x_len = np.arange(len(final_name))

fig,ax = plt.subplots()




print('A=',final_bar1)
print('B=',final_bar2)
ax.bar(x_len -.1,final_bar1,width=.2,label="P(A|B)")
ax.bar(x_len+.1,final_bar2,width=.2,label="P(B|A)")
ax.set_xticks(x_len,final_name,size=52)
#ax.set_xlabel("chemical groups")
plt.yticks(size=44)
ax.set_ylabel("Conditional Probability (%)",size=52)
#ax.set_title("conditional probablity of only highest groups",fontsize=40)
fig.set_figwidth(26)
fig.set_figheight(21)
ax.legend(fontsize=40)
#plt.show()
fig.savefig("bar-graph-of-30-eV-cond-selected_test.png")
#for i in range(len(coef_data_30)):
#    fig, ax = plt.subplots()
#    ax.bar(groups_labels,coef_data_30[i])
#    ax.set_ylabel("coefficent value",size=16)
#    ax.set_xlabel("chemical group",size=16)
#    ax.set_title(f"control group is {groups_labels[i]}")
#    ax.tick_params(axis='x',rotation=340 ,labelsize=16)
#    ax.tick_params(axis='y' ,labelsize=16)
#    fig.set_figwidth(15)
#    fig.set_figheight(15)
#    plt.savefig(f"coef_plot_{groups_labels[i]}")
