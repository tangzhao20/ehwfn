#/usr/bin/env python3

# Plot the band structure weighted by the electron/hole amplitude

# input: iwstates
# read from files: band.dat, labelinfo.dat, ebands_istate.dat
# write to files: ebands_istate.png

# Add -cv or -vc flag to write c_*.dat and v_*.dat files

import matplotlib as mpl
import matplotlib.pyplot as plt
import sys

fsplit=False
if "-cv" in sys.argv or "-vc" in sys.argv :
    fsplit=True

f0=open('input','r')
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
x1index=[]
for l in range(len(line)) :
    word=line[l].split()
    x1t=float(word[2])
    x1l=word[0]
    x1i=int(word[1])-1
    if word[0]=="G" or word[0]=="Gamma" :
        x1l="Γ"
    if len(x1label)==0 or abs(x1t-x1ticks[-1][-1])<=1.e-6 :
        x1label.append([x1l])
        x1ticks.append([x1t])
        x1index.append([x1i])
    else :
        x1label[-1].append(x1l)
        x1ticks[-1].append(x1t)
        x1index[-1].append(x1i)
np=len(x1label)
width=[]
for ip in range(np) :
    width.append(x1ticks[ip][-1]-x1ticks[ip][0])
for ip in range(np-1) :
    x1label[ip][-1]=x1label[ip][-1]+"|"+x1label[ip+1][0]
    x1label[ip+1][0]=""

colpal=["#34548a","#f7768e","#73daca","#cfc9c2","#ffffff","#1a1b26"] # blue , red, green, grey, white, black
mpl.rcParams["font.sans-serif"].insert(0,"Noto Sans")
mpl.rcParams.update({'font.size': 14})

for ie in range(len(iwstates)) :
    istate=iwstates[ie]

    f0=open("ebands_"+str(istate)+".dat")
    line=f0.readlines()
    f0.close()
    
    xdot=[]
    eigdot=[]
    sizedot=[]
    colordot=[]
    for ip in range(np) :
        xdot.append([])
        eigdot.append([])
        sizedot.append([])
        colordot.append([])

    if fsplit==True:
        f1=open("v_"+str(istate)+".dat","w")
        f2=open("c_"+str(istate)+".dat","w")

    for l in range(len(line)) :
        word=line[l].split()
        if len(word)==0 or word[0][0]=="#" or word[0][0]=="!" :
            continue
        xdot0=float(word[0])
        eigdot0=float(word[1])
        sizedot0=float(word[2])**0.5*600
#        sizedot0=float(word[2])*6000
        if abs(xdot0)<1e-6 :
            ip=0
        else :
            for ip1 in range(np-1) :
                if xdot[ip][-1]<=x1ticks[ip1][-1]+1.e-6 and xdot0>=x1ticks[ip1][-1]-1.e-6 :
                    ip=ip+1

        xdot[ip].append(xdot0)
        eigdot[ip].append(eigdot0)
        sizedot[ip].append(sizedot0)
        # here we assume the band gap is larger than 0.005
        if float(eigdot0) < 1e-6+0.005 :
            colordot[ip].append(colpal[1])
            if fsplit:
                f1.write(str(xdot0)+" "+str(eigdot0)+" "+str(sizedot0)+"\n")
        else :
            colordot[ip].append(colpal[2])
            if fsplit:
                f2.write(str(xdot0)+" "+str(eigdot0)+" "+str(sizedot0)+"\n")
    
    if fsplit:
        f1.close()
        f2.close()
    fig = plt.figure(figsize=(5,3.75))
    
    gs0=fig.add_gridspec(1,len(x1label),wspace=0.0,hspace=0.00,left=0.14,right=0.98,top=0.97, bottom=0.07,width_ratios=width)
    ax=[]
    
    for ip in range(np):
        ax.append(fig.add_subplot(gs0[ip]))
        ax[-1].axhline(linewidth=1,color=colpal[3],zorder=1)
        ax[-1].grid(axis="x",linewidth=1, color=colpal[3],zorder=1)
        
        for b in range(len(eig)) :
            ax[-1].plot(x[b],eig[b],linewidth=1, color=colpal[0],zorder=2)
        ax[-1].scatter(xdot[ip],eigdot[ip],s=sizedot[ip],c=colordot[ip],zorder=3)
        
        ax[-1].set_ylim(-7.5,10)
        ax[-1].set_xlim(x1ticks[ip][0],x1ticks[ip][-1])
        
        ax[-1].set_xticks(x1ticks[ip],x1label[ip],color=colpal[-1])
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
        #plt.show()
    plt.close()
