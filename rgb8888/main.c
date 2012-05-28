#include <stdio.h>
#include <stdlib.h>

#include "bitmap.h"

#define BIWIDTH 480
#define BIHEIGHT 800
#define BIBITCOUNT 32

int main(int argc, char *argv[])
{
	FILE *rawfile, *bmpfile;

	if (argc < 2) {
		fprintf(stderr, "%s rawfile bmpfile\n", argv[0]);
		return 1;
	}

	if (!(rawfile = fopen(argv[1], "rb"))) {
		fprintf(stderr, "can not open raw file %s\n", argv[1]);
		return 2;
	}

	if (!(bmpfile = fopen(argv[2], "wb"))) {
		fprintf(stderr, "can not create bmp file %s\n", argv[2]);
		return 2;
	}

	raw2bmp(rawfile, bmpfile, BIWIDTH, BIHEIGHT, BIBITCOUNT);
	
    fclose(bmpfile);
    fclose(rawfile);

    printf("bmp generated\n");

    return 0;
}

