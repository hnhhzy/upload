#include <stdio.h>
#include <stdlib.h>

#include "bitmap.h"

int raw2bmp(FILE *rawfile, FILE *bmpfile, LONG biWidth, LONG biHeight, WORD biBitCount)
{
	BITMAPFILEHEADER bmpFileHeader;
    BITMAPINFOHEADER bmpInfoHeader;
	WORD biDepth = biBitCount / 8;
	BYTE *linebuf;
	DWORD linesize = biWidth * biDepth;
	LONG i, j;
	BYTE temp;
	
	bmpFileHeader.bfType = 0x4D42;
	bmpFileHeader.bfSize = sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER) + biWidth * biHeight * biDepth;
	bmpFileHeader.bfReserved1 = 0x00;
	bmpFileHeader.bfReserved2 = 0x00;
	bmpFileHeader.bfOffBits = sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER);
	
	bmpInfoHeader.biSize = sizeof(BITMAPINFOHEADER);
    bmpInfoHeader.biWidth = biWidth;
    bmpInfoHeader.biHeight = biHeight;
    bmpInfoHeader.biPlanes = 1;
    bmpInfoHeader.biBitCount = biBitCount;
    bmpInfoHeader.biCompression = 0;
    bmpInfoHeader.biSizeImage= biWidth * biHeight * biDepth;
    bmpInfoHeader.biXPelsPerMeter = bmpInfoHeader.biYPelsPerMeter = 0;
    bmpInfoHeader.biClrUsed = bmpInfoHeader.biClrImportant = 0;
	
	fwrite(&bmpFileHeader, 1, sizeof(BITMAPFILEHEADER), bmpfile);
    fwrite(&bmpInfoHeader, 1, sizeof(BITMAPINFOHEADER), bmpfile);

	linebuf = (BYTE *) malloc(linesize);
	for (j = biHeight; j > 0; --j) {
		fseek(rawfile, (j - 1) * linesize, SEEK_SET);
		fread(linebuf, 1, linesize, rawfile);
		for (i = 0; i < linesize; i += biDepth) {
			temp = linebuf[i + 2];
			linebuf[i + 2] = linebuf[i];
			linebuf[i] = temp;
		}
		fwrite(linebuf, 1, linesize, bmpfile);
	}
	free(linebuf);
	
	return 0;
}
