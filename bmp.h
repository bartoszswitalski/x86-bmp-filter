#pragma once

#include <stdio.h>
#include <stdlib.h>

#define CHAR_SIZE 1
#define SIZE_OFFSET 2
char* getBitmap( char* fileName ){

    FILE *file = fopen( fileName, "rb" );

    /* Get size of the file */
    fseek( file, 0, SEEK_END);
    unsigned int fileSize = ftell( file );
    rewind( file );

    char* bitmap = malloc( fileSize );
    fread( bitmap, CHAR_SIZE, fileSize, file );

    rewind( file );
    fclose( file );

    return bitmap;

}

void saveBitmap( char* bitmap, char* fileName ){

    FILE* file = fopen( fileName, "wb" );

    unsigned int fileSize = *(int*)&bitmap[SIZE_OFFSET];
    fwrite( bitmap, CHAR_SIZE, fileSize, file );

    free( bitmap );
    fclose( file );

}
