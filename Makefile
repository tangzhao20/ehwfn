include mkf.mk
include flavor.mk

SRC	:= main.f90 readin.f90
MODULE := typedefs.o nrtype.o
OBJ	:= $(SRC:.f90=.o) 


default: all
all: 
	make clean
	make real
	make clean
	make cplx
	make clean
real:
	cp flavor_real.mk flavor.mk
	make module
	make obj
	$(LINK) $(FOPTS) -o ebg.real.x $(OBJ) $(LIBS)
cplx:
	cp flavor_cplx.mk flavor.mk
	make module
	make obj
	$(LINK) $(FOPTS) -o ebg.cplx.x $(OBJ) $(LIBS)

.SUFFIXES: .f90p .f90 $(SUFFIXES)
module:
	make nrtype.o $(MODULE)
obj:
	make $(OBJ)

.f90.o:
	$(F90) -c $(FOPTS) $*.f90 $(LIBS)

.f90p.o:
	$(FPP) $(DEFS) $(TYPEFLAG) $< > $*.p.f90
	$(F90) -c $(FOPTS) $*.p.f90 $(LIBS)
	mv $*.p.o $*.o

clean:
	rm -f *.o *.mod *.p.f90
cleanall:
	rm -f *.o *.mod *.p.f90 *.x
