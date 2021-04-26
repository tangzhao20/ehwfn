#Compile dependencies:
ebg.real.x: ebg.o readin.o nrtype.o typedefs.o
ebg.cplx.x: ebg.o readin.o nrtype.o typedefs.o
jdos.real.x: jdos.o readin.o nrtype.o typedefs.o
jdos.cplx.x: jdos.o readin.o nrtype.o typedefs.o
ebg.o: readin.o nrtype.o typedefs.o
jdos.o: readin.o nrtype.o typedefs.o
typedefs.o: nrtype.o
readin.o: nrtype.o typedefs.o

