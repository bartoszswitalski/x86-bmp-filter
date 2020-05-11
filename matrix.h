#pragma once

#include <stdio.h>
#include <stdlib.h>

#define FACTORS_NUMBER 9

int* getMatrix( char* fileName ){

    FILE* file = fopen( fileName, "r" );
    
    int* matrix = malloc( sizeof( int ) * FACTORS_NUMBER );
    
    for( int i = 0; i < FACTORS_NUMBER ; ++i ){

	fscanf( file, "%d", matrix );
	++matrix;

    }

    fclose( file );

    return matrix-FACTORS_NUMBER;

}
