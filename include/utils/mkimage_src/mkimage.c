#include <stdio.h>
#include <stdlib.h>
    
main(int argn,char **argv) {
  	FILE *image;
   	image=fopen(argv[1],"wb");
    char *gb_temp = argv[2];
    int gb = atoi(gb_temp);
    while(gb>0){
        fseek(image, (1024*1024*1024), SEEK_CUR);
        gb--;
    }
    fseek(image, -1L, SEEK_CUR);
    fputc('\0', image);
  	fclose(image);
}
