#Compile dependencies:
ebg.real.x: ebg.o readin.o readeqp.o common.o nrtype.o typedefs.o
ebg.cplx.x: ebg.o readin.o readeqp.o common.o nrtype.o typedefs.o

jdos.real.x: jdos.o readin.o readeqp.o common.o nrtype.o typedefs.o
jdos.cplx.x: jdos.o readin.o readeqp.o common.o nrtype.o typedefs.o

ewfn.real.x: ewfn.o readin.o readeqp.o common.o nrtype.o typedefs.o
ewfn.cplx.x: ewfn.o readin.o readeqp.o common.o nrtype.o typedefs.o

ebg.o: readin.o readeqp.o common.o nrtype.o typedefs.o
jdos.o: readin.o readeqp.o common.o nrtype.o typedefs.o
ewfn.o: readin.o readeqp.o common.o nrtype.o typedefs.o

readeqp.o: nrtype.o typedefs.o
readin.o: nrtype.o typedefs.o
#common.o: nrtype.o typedefs.o 

#typedefs.o: nrtype.o
