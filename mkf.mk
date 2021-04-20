F77     = ifort
F90     = ifort

F90free = ifort -free
FPP     = ifort -EP

DEFS  = -DDEBUG
#DO NOT USE -DCPLX here. Find in flavor.mk

LINK    = ifort

#FOPTS    = -O3 -no-prec-div -check bounds
FOPTS    = -O3

LIBS    = 

