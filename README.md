## [ebg](ebg.f90)

Find the non-interacting transition energy $E_\mathrm{g}^S$:

$$
E_\mathrm{g}^S=\sum_{vck}((A_{vck}^S)^2(E_{ck}-E_{v(k+q)})).
$$

Calculate the IPR of the e-h amplitude:

$$
\mathrm{IPR}^S=(\sum_{vck}(A_{vck}^S)^2)^2/\sum_{vck}(A_{vck}^S)^4.
$$

---

## [pdeh](pdeh.f90)

Calculate the e-h pair participation ratio of exciton states:

$$
D_\mathrm{eh}^S(\omega)=\sum_{vck}(A_{vck}^S)^2\delta(E_{ck}-E_{vk}-\omega).
$$

---

## [ewfn](ewfn.f90)

Calculate the k-dependent pair amplitude of exciton states:

$$
|A_k^S|^2=\sum_{vc}|A_{vck}^S|^2.
$$

---

## [ebands](ebands.f90)

Calculate the electron/hole amplitude of exciton states and
prepare for generating weighted band structure plots:

$$
\begin{split}
|A_{vk}^S|^2&=\sum_c|A_{vck}^S|^2,\\
|A_{ck}^S|^2&=\sum_v|A_{vck}^S|^2,
\end{split}
$$

where k is on the band structure path.

---

## Input files
[input](input)  
eigenvectors or eigenvectors.h5 (from bse absorption)
eqp.dat (and eqp\_q.dat if a shifted grid is used)  
OUT (for the b vectors only)  
labelinfo.dat gw.dat eqp.dat kmap.dat/kgrid.log (ebands.x)  

## Output files
out.dat  
energy.dat  
ewfn_\*.dat  
ehdos_\*.dat  
ebands_\*.dat  
pdeh_\*.dat  

---

## Install

Copy mkf.mk from the [config](config) directory. Modify as needed. Then 
```
make
```

---

## Reference
Please find <https://doi.org/10.1103/PhysRevApplied.17.034068>

---

ZT
