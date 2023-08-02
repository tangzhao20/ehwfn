F90     = ifort

FPP     = ifort -EP

DEFS  = -DHDF5 

FOPTS    = -O3

LIBS    = 

HDF5_LDIR = -L$(HDF5_DIR)/lib
HDF5LIB = -lhdf5hl_fortran -lhdf5_hl -lhdf5_fortran -lhdf5 -lz -ldl 
HDF5INCLUDE = -I$(HDF5_DIR)/include

LIBS += $(HDF5_LDIR) $(HDF5LIB)
F90 += $(HDF5INCLUDE)

LINK = $(F90)
