#!/usr/bin/env python3

# Plot the band structure weighted by the electron/hole amplitude

# input: iwstates
# read from files: band.dat, labelinfo.dat, ebands_istate.dat
# write to files: ebands_istate.png

# Add -w flag to write c_*.dat, v_*.dat, eigenval.dat, and label.dat files

import matplotlib as mpl
import matplotlib.pyplot as plt
import sys

lwrite=False
if "-w" in sys.argv  :
    lwrite=True

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

# TODO: split x into paths
f0=open("band.dat","r")
line=f0.readlines()
f0.close()
x=[]
energy=[]
lfirst=1
for l in range(len(line)) :
    word=line[l].split()
    if lfirst==1 :
        x0=[]
        energy0=[]
        lfirst=0
    elif len(word)==0 or l==len(line)-1 :
        x.append(x0)
        energy.append(energy0)
        lfirst=1
        continue
    x0.append(float(word[0]))
    energy0.append(float(word[1]))

ef=max(energy[nbsv-1])
for i in range(len(energy)):
    for j in range(len(energy[i])) :
        energy[i][j]=energy[i][j]-ef

f0=open("labelinfo.dat","r")
line=f0.readlines()
f0.close()
xticks=[]
xlabels=[]
xindex=[]
for l in range(len(line)) :
    word=line[l].split()
    x1t=float(word[2])
    x1l=word[0]
    x1i=int(word[1])-1
    if word[0]=="G" or word[0]=="Gamma" :
        x1l="Γ"
    if len(xlabels)==0 or abs(x1t-xticks[-1][-1])<=1.e-6 :
        xlabels.append([x1l])
        xticks.append([x1t])
        xindex.append([x1i])
    else :
        xlabels[-1].append(x1l)
        xticks[-1].append(x1t)
        xindex[-1].append(x1i)
np=len(xlabels)
width=[]
for ip in range(np) :
    width.append(xticks[ip][-1]-xticks[ip][0])
for ip in range(np-1) :
    xlabels[ip][-1]=xlabels[ip][-1]+"|"+xlabels[ip+1][0]
    xlabels[ip+1][0]=""

if lwrite :
    f3=open("eigenval.dat","w")
    f3.write("# x, energy(eV)\n")
    for ib in range(len(energy)) :
        for ik in range(len(energy[ib])) :
            f3.write(f"{x[ib][ik]:18.12f}{energy[ib][ik]:18.12f}\n")
        f3.write("\n")
    f3.close()
    f4=open("label.dat","w")
    f4.write("# x, label\n")
    for ip in range(np):
        for ik in range(len(xticks[ip])):
            f4.write(str(xticks[ip][ik])+" "+xlabels[ip][ik]+"\n")
        f4.write("\n")
    f4.close()

colpal=["#2959aa","#f7768e","#9ece6a","#c6c6c9","#ffffff","#1a1b26"] # blue, red, green, grey, white, black
mpl.rcParams["font.sans-serif"].insert(0,"Noto Sans")
mpl.rcParams.update({'font.size': 14})

for ie in range(len(iwstates)) :
    istate=iwstates[ie]

    f0=open("ebands_"+str(istate)+".dat")
    line=f0.readlines()
    f0.close()
    
    xdot=[]
    energydot=[]
    sizedot=[]
    colordot=[]
    for ip in range(np) :
        xdot.append([])
        energydot.append([])
        sizedot.append([])
        colordot.append([])

    if lwrite:
        f1=open("v_"+str(istate)+".dat","w")
        f2=open("c_"+str(istate)+".dat","w")
        f1.write("# x, energy(eV), size\n")
        f2.write("# x, energy(eV), size\n")

    for l in range(len(line)) :
        word=line[l].split()
        if len(word)==0 or word[0][0]=="#" or word[0][0]=="!" :
            continue
        xdot0=float(word[0])
        energydot0=float(word[1])
        sizedot0=float(word[2])**0.5*600
#        sizedot0=float(word[2])*6000
        if abs(xdot0)<1e-6 :
            ip=0
        else :
            for ip1 in range(np-1) :
                if xdot[ip][-1]<=xticks[ip1][-1]+1.e-6 and xdot0>=xticks[ip1][-1]-1.e-6 :
                    ip=ip+1

        xdot[ip].append(xdot0)
        energydot[ip].append(energydot0)
        sizedot[ip].append(sizedot0)
        # here we assume the band gap is larger than 0.005
        if float(energydot0) < 1e-6+0.005 :
            colordot[ip].append(colpal[1])
            if lwrite:
                f1.write(f"{xdot0:18.12f}{energydot0:18.12f}{sizedot0:18.12f}\n")
        else :
            colordot[ip].append(colpal[2])
            if lwrite:
                f2.write(f"{xdot0:18.12f}{energydot0:18.12f}{sizedot0:18.12f}\n")
    
    if lwrite:
        f1.close()
        f2.close()

    fig = plt.figure(figsize=(5,3.75))
    gs0=fig.add_gridspec(1,len(xlabels),wspace=0.0,hspace=0.00,left=0.18,right=0.98,top=0.97,bottom=0.07,width_ratios=width)
    ax=[]

    for ip in range(np):
        ax.append(fig.add_subplot(gs0[ip]))
        ax[-1].axhline(linewidth=1,color=colpal[3],zorder=1)
        ax[-1].grid(axis="x",linewidth=1, color=colpal[3],zorder=1)
        
        for b in range(len(energy)) :
            ax[-1].plot(x[b],energy[b],linewidth=1, color=colpal[0],zorder=2)
        ax[-1].scatter(xdot[ip],energydot[ip],s=sizedot[ip],c=colordot[ip],zorder=3)
        
        ax[-1].set_ylim(-7.5,10)
        ax[-1].set_xlim(xticks[ip][0],xticks[ip][-1])
        
        ax[-1].set_xticks(xticks[ip],xlabels[ip],color=colpal[-1])
        ax[-1].tick_params(axis="x", direction="in", length=0)
        ax[-1].tick_params(axis="y", left=False, right=False, direction="in", color=colpal[3], labelcolor=colpal[-1], width=1, zorder=0)
        if ip!=0 :
            ax[-1].yaxis.set_ticklabels([])
        for edge in ["bottom", "top", "left", "right"] :
            ax[-1].spines[edge].set_color(colpal[-1])
            ax[-1].spines[edge].set_linewidth(1)
            ax[-1].spines[edge].set_zorder(4)
    ax[0].set_ylabel("Energy (eV)",color=colpal[-1])
    ax[0].tick_params(axis="y", left=True)
    ax[-1].tick_params(axis="y", right=True)
    plt.savefig("ebands_"+str(istate)+".png",dpi=1200)
    plt.close()
