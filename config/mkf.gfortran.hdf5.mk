#F77     = gfortran -std=legacy
F90     = gfortran -ffree-form -ffree-line-length-0

FPP     = cpp
#FPP     = gfortran -cpp

DEFS  = -DHDF5 

#LINK    = gfortran

#FOPTS    = -O3 -no-prec-div -check bounds
FOPTS    = -O3 #-std=f2003

LIBS    = 

#HDF5_LDIR = $(HDF5_DIR)/lib
#HDF5LIB = $(HDF5_LDIR)/libhdf5hl_fortran.a \
#$(HDF5_LDIR)/libhdf5_hl.a \
#$(HDF5_LDIR)/libhdf5_fortran.a \
#$(HDF5_LDIR)/libhdf5.a -lz -ldl
#HDF5INCLUDE = -I$(HDF5_DIR)/include

HDF5_LDIR = -L$(HDF5_DIR)/lib
HDF5LIB = -lhdf5hl_fortran -lhdf5_hl -lhdf5_fortran -lhdf5 -lz -ldl 
HDF5INCLUDE = -I$(HDF5_DIR)/include

LIBS += $(HDF5_LDIR) $(HDF5LIB)
F90 += $(HDF5INCLUDE)

LINK = $(F90)
