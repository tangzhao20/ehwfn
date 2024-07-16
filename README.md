# Tool for analyzing exciton properties from BSE calculations

## [ebg](ebg.f90)

First, find the non-interacting transition energy:

$$
E_\mathrm{g}^S=\sum_{vck}((A_{vck}^S)^2(E_{ck}-E_{v(k+q)})).
$$

Then, determine the exciton binding energy:

$$
E_\mathrm{b}^S=E_\mathrm{g}^S-{\Omega}^S.
$$

Calculate the inverse participation ratio (IPR) in the *k* space of the electron-hole amplitude:

$$
\mathrm{IPR}^S=(\sum_{vck}(A_{vck}^S)^2)^2/\sum_{vck}(A_{vck}^S)^4.
$$

The results can be plotted using [plot/ebg.py](plot/ebg.py).

## [ewfn](ewfn.f90)

Calculate the *k*-dependent pair amplitude of exciton states:

$$
|A_k^S|^2=\sum_{vc}|A_{vck}^S|^2.
$$

The results can be plotted using [plot/ewfn.py](plot/ewfn.py). Additionally, [plot/ewfnsum.py](plot/ewfnsum.py) can be used to create plots with summed states. For instance, degenerate states can be summed to generate a plot with full symmetry. 

## [ebands](ebands.f90)

Calculate the electron/hole amplitude of exciton states and prepare for generating weighted band structure plots:

$$
\begin{split}
|A_{vk}^S|^2&=\sum_c|A_{vck}^S|^2,\\
|A_{ck}^S|^2&=\sum_v|A_{vck}^S|^2,
\end{split}
$$

where *k* is on the band structure path.  

The results can be plotted using [plot/ebands.py](plot/ebands.py).

## [pdeh](pdeh.f90)

Calculate the electron-hole pair participation ratio of exciton states:

$$
D_\mathrm{eh}^S(\omega)=\sum_{vck}(A_{vck}^S)^2\delta(E_{ck}-E_{vk}-\omega).
$$

## Input files
An input file for this code:  
* [input](input)  

The files from DFT, GW, and BSE calculations:  
* eigenvectors or eigenvectors.h5  
* eqp.dat (and eqp\_q.dat if a shifted grid is used)  
* OUT (the code only reads the reciprocal vectors from this file)  
* labelinfo.dat gw.dat eqp.dat kmap.dat/kgrid.log (for ebands.x)  

## Output files
* out.dat  
* energy.dat  
* ewfn_\*.dat  
* ehdos_\*.dat  
* ebands_\*.dat  
* pdeh_\*.dat  

## Installation

Copy `mkf.mk` from the [config](config) directory, modify it as needed, and then run: 
```bash
make
```

## Reference and works

This tool was initially developed for the following paper, where the method is thoroughly discussed:  

1.  Zhao Tang, Greis J. Cruz, Yabei Wu, Weiyi Xia, Fanhao Jia, Wenqing Zhang, and Peihong Zhang, *Giant narrow-band optical absorption and distinctive excitonic structures of monolayer C<sub>3</sub>N and C<sub>3</sub>B*, [Physical Review Applied **17**, 034068](https://doi.org/10.1103/PhysRevApplied.17.034068) (2022).  

The following papers have also used this tool:  

2.  Yabei Wu, Zhao Tang, Weiyi Xia, Weiwei Gao, Fanhao Jia, Yubo Zhang, Wenguang Zhu, Wenqing Zhang, and Peihong Zhang, *Prediction of protected band edge states and dielectric tunable quasiparticle and excitonic properties of monolayer MoSi<sub>2</sub>N<sub>4</sub>*, [npj Computational Materials **8**, 129](https://doi.org/10.1038/s41524-022-00815-6) (2022). 
3.  Zhao Tang, Greis J. Cruz, Fanhao Jia, Yabei Wu, Weiyi Xia, and Peihong Zhang, *Stacking up electron-rich and electron-deficient monolayers to achieve extraordinary mid- to far-infrared excitonic absorption: interlayer excitons in the C<sub>3</sub>B/C<sub>3</sub>N bilayer*, [Physical Review Applied **19**, 044085](https://doi.org/10.1103/PhysRevApplied.19.044085) (2023).  
4.  Fanhao Jia, Zhao Tang, Greis J. Cruz, Weiwei Gao, Shaowen Xu, Wei Ren, and Peihong Zhang, *Quasiparticle and excitonic structures of few-layer and bulk GaSe: interlayer coupling, self-energy, and electron-hole interaction*, [Physical Review Applied **21**, 054019](https://doi.org/10.1103/PhysRevApplied.21.054019) (2024). 
