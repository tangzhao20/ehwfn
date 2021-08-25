#Compile dependencies:
ebg.real.x: ebg.o readin.o readeqp.o common.o nrtype.o typedefs.o
ebg.cplx.x: ebg.o readin.o readeqp.o common.o nrtype.o typedefs.o

jdos.real.x: jdos.o readin.o readeqp.o common.o nrtype.o typedefs.o
jdos.cplx.x: jdos.o readin.o readeqp.o common.o nrtype.o typedefs.o

ewfn.real.x: ewfn.o readin.o readeqp.o common.o nrtype.o typedefs.o
ewfn.cplx.x: ewfn.o readin.o readeqp.o common.o nrtype.o typedefs.o

ebands.real.x: ebands.o math.o readin.o common.o nrtype.o typedefs.o
ebands.cplx.x: ebands.o math.o readin.o common.o nrtype.o typedefs.o

ebg.o: readin.o readeqp.o common.o nrtype.o typedefs.o
jdos.o: readin.o readeqp.o common.o nrtype.o typedefs.o
ewfn.o: readin.o readeqp.o common.o nrtype.o typedefs.o
ebands.o: math.o readin.o common.o nrtype.o typedefs.o

readeqp.o: nrtype.o typedefs.o
readin.o: nrtype.o typedefs.o
math.o: nrtype.o typedefs.o
#common.o: nrtype.o typedefs.o 

#typedefs.o: nrtype.o
