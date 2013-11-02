WIDTH=50
HEIGHT=60

all: conway

conway: conway.c functions.o
	gcc -D WIDTH=$(WIDTH) -D HEIGHT=$(HEIGHT) -std=c99 -o conway conway.c functions.o
	
functions.o: functions.asm
	nasm -D WIDTH=$(WIDTH) -D HEIGHT=$(HEIGHT) -f elf64 functions.asm
	
clean:
	rm -f *~ *.o conway tests/*~ tests/*/*~ *.swp
