#include "bmp.h"
#include "matrix.h"
#include "filterBitmap.h"

#define NUMBER_OF_ARGS	    3
#define ARGV_MATRIX	    1
#define ARGV_BITMAP	    2
#define POSITION_OFFSET	    10
#define WIDTH_OFFSET	    18
#define HEIGHT_OFFSET	    22
#define OUTPUT_NAME	    "out.bmp"

int main( int argc, char* argv[] ){

    if( argc != NUMBER_OF_ARGS ){

	printf( "Wrong arguments\n" );
	return 1;

    }
   
    /* Args for filterBitmap.s */

    char* bitmap    = getBitmap( argv[ARGV_BITMAP] );
    int* matrix	    = getMatrix( argv[ARGV_MATRIX] ); 

    int* dataOffset = (int*)&bitmap[POSITION_OFFSET];
    int* width      = (int*)&bitmap[WIDTH_OFFSET];
    int* height     = (int*)&bitmap[HEIGHT_OFFSET];

    filterBitmap( bitmap, matrix, width, height, dataOffset ); 

    saveBitmap( bitmap, "out.bmp" );

    system( "eog out.bmp & eog in.bmp &" );

    return 0;

}
