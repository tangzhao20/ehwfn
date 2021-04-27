#Compile dependencies:
ebg.real.x: ebg.o readin.o nrtype.o typedefs.o readeqp.o
ebg.cplx.x: ebg.o readin.o nrtype.o typedefs.o readeqp.o
jdos.real.x: jdos.o readin.o nrtype.o typedefs.o readeqp.o
jdos.cplx.x: jdos.o readin.o nrtype.o typedefs.o readeqp.o
ebg.o: readin.o nrtype.o typedefs.o readeqp.o
jdos.o: readin.o nrtype.o typedefs.o readeqp.o
typedefs.o: nrtype.o
readin.o: nrtype.o typedefs.o
readeqp.o: nrtype.o typedefs.o
