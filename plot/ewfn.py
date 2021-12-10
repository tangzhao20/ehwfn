#!/usr/bin/env python3

# Plot the k-dependent pair amplitude
# The hexagonal structure is supported

# input: iwstates
# read from files: OUT(reciprocal lattice), ewfn_istate.dat
# write to files: ewfn_istate.png

import matplotlib.pyplot as plt
import sys
import math

acc=0.0001

f0=open("input","r")
line=f0.readlines()
f0.close()
iwstates=[]
for l in range(len(line)) :
    word=line[l].split()
    if len(word)==0 or word[0][0] == "#" or word[0][0] == "!" :
        continue
    if word[0]=="iwstates" :
        for i in range(1,len(word)) :
            iwstates.append(int(word[i]))
        break
if iwstates==[] :
    for l in range(len(line)) :
        word=line[l].split()
        if len(word)==0 or word[0][0] == "#" or word[0][0] == "!" :
            continue
        if word[0]=="nwstates" :
            nwstates=int(word[1])
            break
    for i in range(nwstates) :
        iwstates.append(i+1)

f2=open("OUT","r")
line=f2.readlines()
f2.close()
for i in range(len(line)) :
    word0=line[i].split()
    if len(word0)>1 and word0[0]=="reciprocal" :
        kp=[[float(line[i+2].split()[0])/0.529177249,float(line[i+2].split()[1])/0.529177249],[float(line[i+3].split()[0])/0.529177249,float(line[i+3].split()[1])/0.529177249]]
        rot=math.atan(kp[0][1]/kp[0][0])+1.047197551196597746154
        break
#print(kp)
    
k_len=(kp[0][0]**2+kp[0][1]**2)**0.5
Area=2.598076211353315940291*k_len*k_len*0.25
k2=k_len*3**-0.5

for ie in range(len(iwstates)) :
    f1=open("ewfn_"+str(iwstates[ie])+".dat","r")
    lines=f1.readlines()
    f1.close()
    x=[]
    y=[]
    z=[]
    Nk=len(lines)-1
    v=[0.0]*Nk
    for j in range(Nk) :
        word=lines[j+1].split()
        x.append(float(word[0]))
        y.append(float(word[1]))
        z.append(float(word[2]))
        v[j]=v[j]+float(word[3])

    for i in range(len(x)):
        if x[i]<0.0 - acc :
            x[i]=x[i]+1.0
        if y[i]<0.0 - acc :
            y[i]=y[i]+1.0

    xlarge=[]
    ylarge=[]
    zlarge=[]
    for i in range(2) :
        for j in range(2) :
            for k in range(len(x)) :
                xlarge.append(x[k]+float(i)-1.0)
                ylarge.append(y[k]+float(j)-1.0)
                zlarge.append(v[k])

    for i in range(len(xlarge)):
        x_tmp=xlarge[i]*kp[0][0]+ylarge[i]*kp[1][0]
        y_tmp=xlarge[i]*kp[0][1]+ylarge[i]*kp[1][1]
        xlarge[i]=x_tmp
        ylarge[i]=y_tmp

    ### rotate the hexagon by 60 degs, depend on structure
    for i in range(len(xlarge)):
        x_tmp=xlarge[i]
        y_tmp=ylarge[i]
        xlarge[i]=x_tmp*math.cos(rot)-y_tmp*math.sin(rot)
        ylarge[i]=x_tmp*math.sin(rot)+y_tmp*math.cos(rot)

    x_out=[]
    y_out=[]
    z_out=[]
    for i in range(len(zlarge)):
        if xlarge[i]<=k_len/2+acc and xlarge[i]>=-k_len/2-acc and ylarge[i] <= k2-xlarge[i]*3.0**-0.5+acc and ylarge[i] <= k2+xlarge[i]*3.0**-0.5+acc and ylarge[i] >= -k2+xlarge[i]*3.0**-0.5-acc and ylarge[i] >= -k2-xlarge[i]*3.0**-0.5-acc : # shape of BZ
            x_out.append(xlarge[i])
            y_out.append(ylarge[i])
            z_out.append(zlarge[i])

    for i in range(len(z_out)) : # renormalize to area
        z_out[i]=z_out[i]*Nk/Area

    fig = plt.figure()
    ax = fig.add_subplot(111)
    plt.tricontourf(x_out, y_out, z_out,1000,cmap="viridis")
    f3=open("ewfn_"+str(iwstates[ie])+"_plt.dat","w")
    for ik in range(len(x_out)):
        f3.write(str(x_out[ik])+" "+str(y_out[ik])+" "+str(z_out[ik])+"\n")
    f3.close()
    #plt.tricontourf(x_out, y_out, z_out,1000,cmap="nipy_spectral")
    
    plt.xlim(min(x_out)*1.1,max(x_out)*1.1)
    plt.ylim(min(y_out)*1.1,max(y_out)*1.1)
    ax.set_xlabel("kx (1/Å)")
    ax.set_ylabel("ky (1/Å)")
    plt.colorbar(format="%.1f")
    ax.set_aspect('equal')
    plt.savefig("ewfn_"+str(iwstates[ie])+".png",dpi=300,bbox_inches='tight')
    plt.close()
