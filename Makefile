include mkf.mk
include flavor.mk

default: all

include make_deps.mk

all: 
	make clean
	make real
	make clean
	make cplx
	make clean
real:
	cp flavor_real.mk flavor.mk
	make ebg.real.x
	make pdeh.real.x
	make ewfn.real.x
	make ebands.real.x
cplx:
	cp flavor_cplx.mk flavor.mk
	make ebg.cplx.x
	make pdeh.cplx.x
	make ewfn.cplx.x
	make ebands.cplx.x

.SUFFIXES: .f90p .f90 $(SUFFIXES)


.f90.o:
	$(F90) -c $(FOPTS) $*.f90 $(LIBS)

.f90p.o:
	$(FPP) $(DEFS) $(TYPEFLAG) $< > $*.p.f90
	$(F90) -c $(FOPTS) $*.p.f90 $(LIBS)
	mv $*.p.o $*.o

	
%.x:
	$(LINK) $(FOPTS) -o $@ $^ $(LIBS)

tar:
	tar --exclude="*.tar.gz" --exclude=".git*" --exclude="*.x" --exclude="*.o" --transform=s,^,ehwfn\/,S -cvzf ehwfn.tar.gz *

clean:
	rm -f *.o *.mod *.p.f90
cleanall:
	rm -f *.o *.mod *.p.f90 *.x
