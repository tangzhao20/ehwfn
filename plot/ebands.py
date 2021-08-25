#!/usr/bin/env python3

# input: iwstates
# read from files: gw.dat, label.dat, ebands_istate.dat
# write to files: ebands_istate.png

import matplotlib.pyplot as plt
import sys

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

f0=open('gw.dat')
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

f0=open('label.dat')
line=f0.readlines()
f0.close()
x1ticks=[]
x1label=[]
for l in range(len(line)) :
    word=line[l].split()
    x1ticks.append(float(word[0]))
    x1label.append(word[1])

for ie in range(len(iwstates)) :
    istate=iwstates[ie]

    f0=open("ebands_"+str(istate)+".dat")
    line=f0.readlines()
    f0.close()
    
    xdot=[]
    eigdot=[]
    sizedot=[]
    
    for l in range(len(line)) :
        word=line[l].split()
        if len(word)==0 or word[0][0]=="#" or word[0][0]=="!" :
            continue
        xdot.append(float(word[0]))
        eigdot.append(float(word[1]))
        sizedot.append(float(word[2]))
    
    sumsize=sum(sizedot)
    for i in range(len(sizedot)) :
        sizedot[i]=sizedot[i]*5000

    fig = plt.figure()
    ax = fig.add_subplot(111)
    
    plt.gca().grid(axis="x",linewidth=0.75, color="silver")
    plt.axhline(linewidth=0.75,color="silver")
    
    for b in range(len(eig)) :
        plt.plot(x[b],eig[b],color="C0",zorder=1)
    plt.scatter(xdot,eigdot,s=sizedot,c="C1",zorder=2)
    
    
    plt.ylim(-6,8)
    plt.xlim(x[0][0],x[0][len(x[0])-1])
    
    plt.xticks(x1ticks,x1label)
    plt.ylabel("Energy (eV)")
    plt.savefig("ebands_"+str(istate)+".png",dpi=300,bbox_inches='tight')
    #plt.show()
