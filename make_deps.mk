#Compile dependencies:
ebg.real.x: ebg.o readin.o readeqp.o common.o nrtype.o typedefs.o math.o
ebg.cplx.x: ebg.o readin.o readeqp.o common.o nrtype.o typedefs.o math.o

jdos.real.x: jdos.o readin.o readeqp.o common.o nrtype.o typedefs.o math.o
jdos.cplx.x: jdos.o readin.o readeqp.o common.o nrtype.o typedefs.o math.o

ewfn.real.x: ewfn.o readin.o readeqp.o common.o nrtype.o typedefs.o math.o
ewfn.cplx.x: ewfn.o readin.o readeqp.o common.o nrtype.o typedefs.o math.o

ebands.real.x: ebands.o math.o readin.o common.o nrtype.o typedefs.o
ebands.cplx.x: ebands.o math.o readin.o common.o nrtype.o typedefs.o

ipr.real.x: ipr.o math.o readin.o common.o nrtype.o typedefs.o
ipr.cplx.x: ipr.o math.o readin.o common.o nrtype.o typedefs.o

kdx.real.x: kdx.o readin.o common.o nrtype.o typedefs.o
kdx.cplx.x: kdx.o readin.o common.o nrtype.o typedefs.o

ebg.o: readin.o readeqp.o common.o nrtype.o typedefs.o
jdos.o: readin.o readeqp.o common.o nrtype.o typedefs.o
ewfn.o: readin.o readeqp.o common.o nrtype.o typedefs.o
ebands.o: math.o readin.o common.o nrtype.o typedefs.o
ipr.o: math.o readin.o common.o nrtype.o typedefs.o
kdx.o: readin.o common.o nrtype.o typedefs.o

readeqp.o: nrtype.o typedefs.o math.o
readin.o: nrtype.o typedefs.o
math.o: nrtype.o typedefs.o
#common.o: nrtype.o typedefs.o 

#typedefs.o: nrtype.o
