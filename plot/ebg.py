#!/usr/bin/env python3
#
# This script generates a plot of Eb vs. Eg using the ebg.x output energy.dat.
# To execute the code:
# python ebg.py (dipole) (light) (E1) (E2)
#
# Use the dipole option to display the colors for the dipole term.
# Choose the light option to apply the light color scheme.
# Utilize E1 and E2 to define the energy range:
# if neither is provided, the range defaults to [min(eg)-1, min(eg)+5] in eV;
# if only E1 is given, the range becomes [min(eg)-E1/6, min(eg)+E1*5/6] in eV;
# if both E1 and E2 are available, the range is [E1, E2] in eV.
# No additional arguments are permitted.
#
# Input: energy.dat
# Output: ebg.png

import sys
import os
import math
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

# read files:
f0=open("energy.dat","r")
line=f0.readlines()
f0.close()
eb=[]
ee=[]
eg=[]
dip=[]
lfirst=False
ldipole=False
if "dipole" in sys.argv :
    lfirst=True
    sys.argv.remove("dipole")
for l in line :
    word=l.split()
    if len(word)==0 or word[0][0]=="!" or word [0][0]=="#" :
        continue
    if lfirst :
        if len(word)==6 :
            ldipole=True
        elif len(word)==5 :
            ldipole=False
        else :
            print("Error: number of columns of energy.dat should be 6 or 5 (w. or w/o dipole).")
            sys.exit()
    ee.append(float(word[1]))
    eg.append(float(word[2]))
    eb.append(float(word[3]))
    if ldipole :
        dip.append(np.log10(float(word[5])+1e-15))

if ldipole :
    dip_max=max(max(dip),-1)
    dip_min=max(dip_max-5,-5)
    combined=zip(dip,ee,eg,eb)
    sorted_combined=sorted(combined)
    dip,ee,eg,eb=zip(*sorted_combined)

# set figure styles
colpal=["#34548a","#7aa2f7","#cfc9c2","#ffffff","#1a1b26"] # [blue, light blue, gray, white, black]
mpl.rcParams["font.sans-serif"].insert(0,"Noto Sans")
mpl.rcParams['mathtext.fontset'] = 'custom'
mpl.rcParams['mathtext.rm'] = 'Noto Sans'
mpl.rcParams['mathtext.it'] = 'Noto Sans:italic'
mpl.rcParams.update({'font.size': 14})

if ldipole :
    if "light_rygb_lch" in sys.argv :
        colorfile="light_rygb_lch.dat"
        sys.argv.remove("light_rygb_lch")
    elif "light" in sys.argv :
        colorfile="light_rygb_lch.dat"
        sys.argv.remove("light")
    else :
        colorfile="dark_rygb_lch.dat"
    # rgb in hex, from red to blue.
    f1=open(os.path.dirname(sys.argv[0])+"/"+colorfile,"r")
    line=f1.readlines()
    f1.close()
    colors=[]
    for l in line :
        word=l.split()
        if len(word)==0 or word[0][0]=="#" or word[0][0]=="!" :
            continue
        colors0=[]
        for i in range(3) :
            colors0.append(int(word[i],16)/255)
        colors.append(colors0)
    x=[]
    for ix in range(len(colors)) :
        x.append(ix/(len(colors)-1))
    
    cdict={}
    cdict['red']=[]
    cdict['green']=[]
    cdict['blue']=[]
    for ix in range(len(x)) :
        cdict['red'].append([x[ix],colors[len(x)-ix-1][0],colors[len(x)-ix-1][0]])
        cdict['green'].append([x[ix],colors[len(x)-ix-1][1],colors[len(x)-ix-1][1]])
        cdict['blue'].append([x[ix],colors[len(x)-ix-1][2],colors[len(x)-ix-1][2]])

    newcmp = mcolors.LinearSegmentedColormap('newcmp', segmentdata=cdict, N=1000)
    plt.register_cmap(cmap=newcmp)
    cmap0='newcmp'
    normalize = plt.Normalize(dip_min, dip_max)

else :
    if "light_rygb_lch" in sys.argv :
        cblue=colpal[1]
        sys.argv.remove("light_rygb_lch")
    elif "light" in sys.argv :
        cblue=colpal[1]
        sys.argv.remove("light")
    else :
        cblue=colpal[0]

# ploting data
fig=plt.figure(figsize=(5,3.75))
if ldipole :
    img = plt.imshow(np.array([[dip_min,dip_max]]), cmap=cmap0)
    plt.gca().set_visible(False)

if ldipole :
    gs0=fig.add_gridspec(1,1,wspace=0.0,hspace=0.00,left=0.16,right=0.96,top=0.9, bottom=0.6 )
    ax0=gs0.subplots()
    labels=[]
    ticks=[]
    for power in range(int(math.ceil(dip_min)),int(math.floor(dip_max))+1) :
        labels.append(f"$10^{{{power}}}$")
        ticks.append(power)
    cb=fig.colorbar(img,ax=ax0,format="%.1f",location="top",shrink=1,extend='both')
    cb.set_ticks(ticks)
    cb.set_ticklabels(labels)
    ax0.set_axis_off()

    gs1=fig.add_gridspec(1,1,wspace=0.0,hspace=0.00,left=0.16,right=0.96,top=0.80, bottom=0.17)
else :
    gs1=fig.add_gridspec(1,1,wspace=0.0,hspace=0.00,left=0.16,right=0.96,top=0.90, bottom=0.17)

ax1=gs1.subplots()
for edge in ["bottom","top","left","right"] :
    ax1.spines[edge].set_color(colpal[-1])
    ax1.spines[edge].set_linewidth(1)
    ax1.spines[edge].set_zorder(4)

ax1.tick_params(axis="x", bottom=True, top=False, direction="in", color=colpal[-3],labelcolor=colpal[-1], width=1, zorder=0, pad=4)
ax1.tick_params(axis="y", left=True, right=False, direction="in", color=colpal[-3], labelcolor=colpal[-1], width=1, zorder=0, pad=4)
if ldipole :
    ax1.scatter(eg,eb,c=dip,s=1,cmap=cmap0,norm=normalize)
else :
    ax1.scatter(eg,eb,c=cblue,s=1)

if len(sys.argv)==1 :
    xlim_min=min(eg)-1
    xlim_max=min(eg)+5
elif len(sys.argv)==2 :
    xlim_min=min(eg)-float(sys.argv[1])/6
    xlim_max=min(eg)+float(sys.argv[1])*5/6
else :
    xlim_min=float(sys.argv[1])
    xlim_max=float(sys.argv[2])
ax1.set_xlim([xlim_min,xlim_max])
ax1.set_ylim([0,max(eb)*1.1])

if ldipole :
    fig.text(0.01, 0.9, r"$|\mathrm{dipole}|^2$"+"\n(a.u.)",horizontalalignment='left',verticalalignment="center")
ax1.set_ylabel(r"$E_\mathrm{b}^S$ (eV)",color=colpal[-1])
ax1.set_xlabel(r"$E_\mathrm{g}^S$ (eV)",color=colpal[-1])
fig.savefig("ebg.png",dpi=1200)
