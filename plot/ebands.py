#!/usr/bin/env python3

# Plot the band structure weighted by the electron/hole amplitude

# input: iwstates
# read from files: band.dat, labelinfo.dat, ebands_istate.dat
# write to files: ebands_istate.png

# Add -cv or -vc flag to write c_*.dat and v_*.dat files

import matplotlib.pyplot as plt
import sys

fsplit=False
if "-cv" in sys.argv or "-vc" in sys.argv :
    fsplit=True

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
    if word[0]=="nbsv" :
        nbsv=int(word[1])
if iwstates==[] :
    for l in range(len(line)) :
        word=line[l].split()
        if len(word)==0 or word[0][0] == "#" or word[0][0] == "!" :
            continue
        if word[0]=="nwstates" :
            nwstates=int(word[1])
            for i in range(nwstates) :
                iwstates.append(i+1)
            break

f0=open('band.dat')
line=f0.readlines()
f0.close()
x=[]
eig=[]
lfirst=1
for l in range(len(line)) :
    word=line[l].split()
    if lfirst==1 :
        x0=[]
        eig0=[]
        lfirst=0
    elif len(word)==0 or l==len(line)-1 :
        x.append(x0)
        eig.append(eig0)
        lfirst=1
        continue
    x0.append(float(word[0]))
    eig0.append(float(word[1]))

ef=max(eig[nbsv-1])
for i in range(len(eig)):
    for j in range(len(eig[i])) :
        eig[i][j]=eig[i][j]-ef

f0=open('labelinfo.dat')
line=f0.readlines()
f0.close()
x1ticks=[]
x1label=[]
for l in range(len(line)) :
    word=line[l].split()
    x1ticks.append(float(word[2]))
    if word[0]=="G" or word[0]=="Gamma" :
        x1label.append("Γ")
    else :
        x1label.append(word[0])


for ie in range(len(iwstates)) :
    istate=iwstates[ie]

    f0=open("ebands_"+str(istate)+".dat")
    line=f0.readlines()
    f0.close()
    
    xdot=[]
    eigdot=[]
    sizedot=[]
    colordot=[]
    
    if fsplit==True:
        f1=open("v_"+str(istate)+".dat","w")
        f2=open("c_"+str(istate)+".dat","w")

    for l in range(len(line)) :
        word=line[l].split()
        if len(word)==0 or word[0][0]=="#" or word[0][0]=="!" :
            continue
        xdot0=float(word[0])
        eigdot0=float(word[1])
        sizedot0=float(word[2])**0.5*1000
#        sizedot0=float(word[2])*6000
        xdot.append(xdot0)
        eigdot.append(eigdot0)
        sizedot.append(sizedot0)
        # TODO: fix color at VBM
        # here we assume the band gap is larger than 0.005
        if float(eigdot0) < 1e-6+0.005 :
            colordot.append("C0")
            if fsplit:
                f1.write(str(xdot0)+" "+str(eigdot0)+" "+str(sizedot0)+"\n")
        else :
            colordot.append("C1")
            if fsplit:
                f2.write(str(xdot0)+" "+str(eigdot0)+" "+str(sizedot0)+"\n")
    
    if fsplit:
        f1.close()
        f2.close()
    fig = plt.figure()
    ax = fig.add_subplot(111)
    
    plt.gca().grid(axis="x",linewidth=0.75, color="silver",zorder=1)
    plt.axhline(linewidth=0.75,color="silver",zorder=1)
    
    for b in range(len(eig)) :
        plt.plot(x[b],eig[b],linewidth=1, color="black",zorder=2)
    plt.scatter(xdot,eigdot,s=sizedot,c=colordot,zorder=3)
    
    
    plt.ylim(-6,8)
    plt.xlim(x[0][0],x[0][len(x[0])-1])
    
    plt.xticks(x1ticks,x1label)
    plt.ylabel("Energy (eV)")
    plt.savefig("ebands_"+str(istate)+".png",dpi=300,bbox_inches='tight')
    #plt.show()
    plt.close()
