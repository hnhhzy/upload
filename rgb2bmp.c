/*
  All Rights Reserved
  Author:fanping.deng@gmail.com
  Function: convert RGB565 to BMP
  Build by g++
*/

#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>

#include <string.h>

typedef short WORD;
typedef int DWORD;
typedef int LONG;
typedef char BYTE;

//BITMAP  File Header info
typedef struct tagBITMAPFILEHEADER
{
    WORD bfType;
    DWORD bfSize;
    WORD bfReserved1;
    WORD bfReserved2;
    DWORD bfOffBits;
}__attribute__((packed)) BITMAPFILEHEADER;

//Bitmap info header
typedef struct tagBITMAPINFOHEADER{ // bmih
    DWORD biSize;
    LONG biWidth; //以像素为单位的图像宽度
    LONG biHeight;// 以像素为单位的图像长度
    WORD biPlanes;
    WORD biBitCount;// 每个像素的位数
    DWORD biCompression;
    DWORD biSizeImage;
    LONG biXPelsPerMeter;
    LONG biYPelsPerMeter;
    DWORD biClrUsed;
    DWORD biClrImportant;
}__attribute__((packed)) BITMAPINFOHEADER;

static void initBMPHeader(BITMAPFILEHEADER* pBmpFileHeader, LONG xres, LONG yres, WORD size)
{
    pBmpFileHeader->bfType = 0X4D42;  //Magic number
    pBmpFileHeader->bfSize = sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER) + xres * yres * size; //320*480, screen size, hardcoded. You should change it for different size
    pBmpFileHeader->bfReserved1 = 0X00;
    pBmpFileHeader->bfReserved2 = 0X00;
    pBmpFileHeader->bfOffBits = sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER);
}

static void initBMPInfoHeader(BITMAPINFOHEADER* pBmpInfoHeader, LONG xres, LONG yres, WORD bitcount)
{
    pBmpInfoHeader->biSize = sizeof(BITMAPINFOHEADER);
    pBmpInfoHeader->biWidth = xres;//这个地方写死了，因为当时测试手机的屏幕就是这个尺寸的
    pBmpInfoHeader->biHeight = yres;
    pBmpInfoHeader->biPlanes = 1;
    pBmpInfoHeader->biBitCount = bitcount;
    pBmpInfoHeader->biCompression = 0;
    pBmpInfoHeader->biSizeImage= xres * yres * bitcount / 8;
    pBmpInfoHeader->biXPelsPerMeter = pBmpInfoHeader->biYPelsPerMeter = 0;
    pBmpInfoHeader->biClrUsed = pBmpInfoHeader->biClrImportant = 0;
}
#if 0
static void convetBmp(int fs,int fd, short* pSrcShortBuffer,char *pDstIntBUffer)
{
    int height = 480;
    int srcLineLength = sizeof(short)*320;
    int dstLienLength = sizeof(char)*3*320;

    while(height > 0)
    {

        lseek(fs,(height-1)*srcLineLength,SEEK_SET);
        read(fs,(char*)pSrcShortBuffer,srcLineLength);
        for(int x = 0; x < 320; x++)
        {
            short srcPixel = *(pSrcShortBuffer+x); //first change RGB565 to RGB888
            char srcR = (srcPixel&0xF800)>>11;
            char srcG = (srcPixel&0x07E0)>>5;
            char srcB = srcPixel&0x001F;

            pDstIntBUffer[x*3 + 0] = srcB;
            pDstIntBUffer[x*3 + 1] = srcG;
            pDstIntBUffer[x*3 + 2] = srcR;


            pDstIntBUffer[x*3 + 0] <<= 3;
            pDstIntBUffer[x*3 + 1] <<= 2;
            pDstIntBUffer[x*3 + 2] <<= 3;

           // pDstIntBUffer[x*3 + 0] |= (srcB&0X07);
           // pDstIntBUffer[x*3 + 1] |= (srcG&0X03);
          //  pDstIntBUffer[x*3 + 2] |= (srcR&0X07);
        }
        write(fd,(char*)pDstIntBUffer,dstLienLength);
        --height;
    }
}
#endif
int main(int argc, char *argv[])
{
	FILE *rawfile, *bmpfile;
	LONG xres, yres, i, j, buffer_size;
   	WORD bitcount, size;
	char *buffer, temp;

	if (argc < 5) {
		fprintf(stderr, "%s rawfile xres yres bmpfile\n", argv[0]);
		return 1;
	}

	if (!(rawfile = fopen(argv[1], "rb"))) {
		fprintf(stderr, "can not open raw file %s\n", argv[1]);
		return 2;
	}

	xres = atoi(argv[2]);
	yres = atoi(argv[3]);
	bitcount = atoi(argv[4]);
	size = bitcount / 8;
	printf("xres %d, yres %d, bitcount %d\n", xres, yres, bitcount);

	if (!(bmpfile = fopen(argv[5], "wb"))) {
		fprintf(stderr, "can not create bmp file %s\n", argv[5]);
		return 2;
	}

    BITMAPFILEHEADER bmpFileHeader;
    initBMPHeader(&bmpFileHeader, xres, yres, size);

    BITMAPINFOHEADER bmpInfoHeader;
    initBMPInfoHeader(&bmpInfoHeader, xres, yres, bitcount);

    //Write head info to the destination file
    //注意：转换后BMP的数据格式是RGB888，所以不需要palette信息。关于BMP的信息可以搜索一下
    fwrite(&bmpFileHeader, 1, sizeof(BITMAPFILEHEADER), bmpfile);
    fwrite(&bmpInfoHeader, 1, sizeof(BITMAPINFOHEADER), bmpfile);

	buffer_size = xres * size;
	if (!(buffer = (char *)malloc(buffer_size))) {
		fprintf(stderr, "can not alloc buffer size %d\n", buffer_size);
		return 3;
	}

	for (i = 0; i < yres; ++i) {
		fread(buffer, 1, buffer_size, rawfile);
#if 0
		for (j = 0; j < buffer_size; ++j) {
			buffer[j] = ~buffer[j];
		//	temp = buffer[j + 1];
		//	buffer[j + 1] = buffer[j + 2];
		//	buffer[j + 2] = temp;
		}
#endif
		fwrite(buffer, 1, buffer_size, bmpfile);
	}

	free(buffer);

    fclose(bmpfile);
    fclose(rawfile);

    printf("bmp generated\n");

    return 0;
}

