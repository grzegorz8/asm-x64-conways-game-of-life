WIDTH=50
HEIGHT=60

RIGHT_EXT=$$(($(WIDTH)%4))
H_EXT=4
IT_WIDTH=$(WIDTH)+4+$(RIGHT_EXT)
EXT_WIDTH=$(WIDTH)+4+$(RIGHT_EXT)+4
EXT_HEIGHT=$(HEIGHT)+2

all: conway



conway: conway.c functions.o check_sse.o
	gcc -D WIDTH=$(WIDTH) -D HEIGHT=$(HEIGHT) -D EXT_WIDTH=$(EXT_WIDTH) -D EXT_HEIGHT=$(EXT_HEIGHT) -D RIGHT_EXT=$(RIGHT_EXT) -D H_EXT=$(H_EXT) -std=c99 -o conway conway.c functions.o check_sse.o
	
functions.o: functions.asm
	nasm -D WIDTH=$(WIDTH) -D HEIGHT=$(HEIGHT) -D EXT_WIDTH=$(EXT_WIDTH) -D EXT_HEIGHT=$(EXT_HEIGHT) -D RIGHT_EXT=$(RIGHT_EXT) -D H_EXT=$(H_EXT) -D IT_WIDTH=$(IT_WIDTH) -f elf64 functions.asm
	
check_sse.o: check_sse.asm
	nasm -f elf64 check_sse.asm
clean:
	rm -f *~ *.o conway tests/*~ tests/*/*~ *.swp
