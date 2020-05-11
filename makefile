CC = gcc
CFLAGS = -Wall -m64 -std=c99 -pedantic

all: clean main.o filterBitmap.o 
	$(CC) $(CFLAGS64) -o prog main.o filterBitmap.o

filterBitmap.o: filterBitmap.s
	nasm -felf64 filterBitmap.s

main.o: main.c
	$(CC) $(CFLAGS64) -fpack-struct=1 -c -o main.o main.c

clean:
	rm -f *.o
