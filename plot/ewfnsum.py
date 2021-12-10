#!/usr/bin/env python3

# Used to sum up the k-dependent pair amplitude for a few states.
# The states can be degenerated or not.
# ewfnsum.py istate1 istate2 [istate3 istate4 ...]

# read from files: ewfn_istate_plt.dat
# write to files: ewfn_istate1_istate2...png

import matplotlib.pyplot as plt
import sys

if len(sys.argv) < 3 :
    print("ewfnsum.py istate1 istate2 [istate3 istate4 ...]")
    sys.exit()
iwstates=[]
for i in range(1,len(sys.argv)) :
    iwstates.append(int(sys.argv[i]))


for ie in range(len(iwstates)) :
    f1=open("ewfn_"+str(iwstates[ie])+"_plt.dat","r")
    line=f1.readlines()
    f1.close()
    if ie==0 :
        x=[]
        y=[]
        z=[]
        for l in range(len(line)) :
            word=line[l].split()
            x.append(float(word[0]))
            y.append(float(word[1]))
            z.append(float(word[2]))
    else :
        for l in range(len(line)) :
            word=line[l].split()
            z[l]=z[l]+float(word[2])

filename="ewfn"
for ie in range(len(iwstates)) :
    filename=filename+"_"+str(iwstates[ie])
filename=filename
f3=open(filename+"_plt.dat","w")
for ik in range(len(x)):
    f3.write(str(x[ik])+" "+str(y[ik])+" "+str(z[ik])+"\n")
f3.close()

fig = plt.figure()
ax = fig.add_subplot(111)
plt.tricontourf(x, y, z, 1000, cmap="viridis")
plt.xlim(min(x)*1.1,max(x)*1.1)
plt.ylim(min(y)*1.1,max(y)*1.1)
ax.set_xlabel("kx (1/Å)")
ax.set_ylabel("ky (1/Å)")
plt.colorbar(format="%.1f")
ax.set_aspect('equal')
plt.savefig(filename+".png",dpi=300,bbox_inches='tight')
plt.close()
