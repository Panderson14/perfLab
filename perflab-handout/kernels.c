/********************************************************
 * Kernels to be optimized for the CS:APP Performance Lab
 ********************************************************/

#include <stdio.h>
#include <stdlib.h>
#include "defs.h"

/* 
 * Please fill in the following team struct 
 */
team_t team = {
    "Gratrick Oxerson",              /* Team name */

    "Patrick Anderson",     /* First member full name */
    "psa5dg@virginia.edu",  /* First member email address */

    "Grant Oxer",                   /* Second member full name (leave blank if none) */
    "gwo8gy@virginia.edu"                    /* Second member email addr (leave blank if none) */
};

/***************
 * ROTATE KERNEL
 ***************/

/******************************************************
 * Your different versions of the rotate kernel go here
 ******************************************************/

/* 
 * naive_rotate - The naive baseline version of rotate 
 */
char naive_rotate_descr[] = "naive_rotate: Naive baseline implementation";
void naive_rotate(int dim, pixel *src, pixel *dst) 
{
    int i, j;

    for (i = 0; i < dim; i++)
	for (j = 0; j < dim; j++)
	    dst[RIDX(dim-1-j, i, dim)] = src[RIDX(i, j, dim)];
}

/* 
 * rotate - Another version of rotate
 */
char rotate_descr[] = "rotate: Current working version";
void rotate(int dim, pixel *src, pixel *dst) 
{
    naive_rotate(dim, src, dst);
}

/*
 * rotate_quad_loop - Rotate with four loops instead of two
 * includes code motion for inner for-loops
 */
char rotate_quad_loop_descr[] = "Rotate with four loops instead of two";
void rotate_quad_loop(int dim, pixel *src, pixel *dst) {
    int BLOCK_SIZE = 8;
    int bi, bj, i, j;

    for (bi = 0; bi < dim; bi+=BLOCK_SIZE)
        for (bj = 0; bj < dim; bj+=BLOCK_SIZE)
            //x = bi + BLOCK_SIZE;
            for (i = bi; i < bi+BLOCK_SIZE; i++)
                //y = bj + BLOCK_SIZE;
                for (j = bj; j < bj+BLOCK_SIZE; j++)
                    dst[RIDX(dim-1-j, i, dim)] = src[RIDX(i, j, dim)];
}


/*
 * rotate_loop_unrolling - Rotate with four loops instead of two
 * includes code motion for inner for-loops
 */
char rotate_loop_unrolling_descr[] = "Loop Unrolling";
void rotate_loop_unrolling(int dim, pixel *src, pixel *dst) {
    int BLOCK_SIZE = 16;
    int bi, bj, i, j;

    for (bi = 0; bi < dim; bi+=BLOCK_SIZE)
        for (bj = 0; bj < dim; bj+=BLOCK_SIZE)
            //x = bi + BLOCK_SIZE;
            for (i = bi; i < bi+BLOCK_SIZE; i+=2)
                //y = bj + BLOCK_SIZE;
                for (j = bj; j < bj+BLOCK_SIZE; j+=2) {
                    dst[RIDX(dim-1-j, i, dim)] = src[RIDX(i, j, dim)];
                    dst[RIDX(dim-1-j, i+1, dim)] = src[RIDX(i+1, j, dim)];
                    dst[RIDX(dim-2-j, i, dim)] = src[RIDX(i, j+1, dim)];
                    dst[RIDX(dim-2-j, i+1, dim)] = src[RIDX(i+1, j+1, dim)];
                }
}


/*
 * rotate_loop_unrolling_more - Rotate with four loops instead of two
 * includes code motion for inner for-loops
 */
char rotate_8_descr[] = "Loop Unrolling More";
void rotate_8(int dim, pixel *src, pixel *dst) {
    int BLOCK_SIZE = 8;
    int bi, bj, i, j, x, y;

    for (bi = 0; bi < dim; bi+=BLOCK_SIZE) {
        for (bj = 0; bj < dim; bj+=BLOCK_SIZE) {
            x = bi + BLOCK_SIZE;
            for (i = bi; i < x; i+=4) {
                y = bj + BLOCK_SIZE;
                for (j = bj; j < y; j+=4) {
                    dst[RIDX(dim-1-j, i, dim)] = src[RIDX(i, j, dim)];
                    dst[RIDX(dim-1-j, i+1, dim)] = src[RIDX(i+1, j, dim)];
                    dst[RIDX(dim-1-j, i+2, dim)] = src[RIDX(i+2, j, dim)];  
                    dst[RIDX(dim-1-j, i+3, dim)] = src[RIDX(i+3, j, dim)];
                    dst[RIDX(dim-2-j, i, dim)] = src[RIDX(i, j+1, dim)];
                    dst[RIDX(dim-2-j, i+1, dim)] = src[RIDX(i+1, j+1, dim)];
                    dst[RIDX(dim-2-j, i+2, dim)] = src[RIDX(i+2, j+1, dim)];  
                    dst[RIDX(dim-2-j, i+3, dim)] = src[RIDX(i+3, j+1, dim)]; 
                    dst[RIDX(dim-3-j, i, dim)] = src[RIDX(i, j+2, dim)];
                    dst[RIDX(dim-3-j, i+1, dim)] = src[RIDX(i+1, j+2, dim)];
                    dst[RIDX(dim-3-j, i+2, dim)] = src[RIDX(i+2, j+2, dim)];  
                    dst[RIDX(dim-3-j, i+3, dim)] = src[RIDX(i+3, j+2, dim)]; 
                    dst[RIDX(dim-4-j, i, dim)] = src[RIDX(i, j+3, dim)];
                    dst[RIDX(dim-4-j, i+1, dim)] = src[RIDX(i+1, j+3, dim)];
                    dst[RIDX(dim-4-j, i+2, dim)] = src[RIDX(i+2, j+3, dim)];  
                    dst[RIDX(dim-4-j, i+3, dim)] = src[RIDX(i+3, j+3, dim)]; 
                }
            }
        }
    }
}


/*
 * rotate_loop_unrolling_more - Rotate with four loops instead of two
 * includes code motion for inner for-loops
 */
char rotate_16_descr[] = "Loop Unrolling More";
void rotate_16(int dim, pixel *src, pixel *dst) {
    int BLOCK_SIZE = 16;
    int bi, bj, i, j, x, y;

    for (bi = 0; bi < dim; bi+=BLOCK_SIZE) {
        for (bj = 0; bj < dim; bj+=BLOCK_SIZE) {
            x = bi + BLOCK_SIZE;
            for (i = bi; i < x; i+=4) {
                y = bj + BLOCK_SIZE;
                for (j = bj; j < y; j+=4) {
                    dst[RIDX(dim-1-j, i, dim)] = src[RIDX(i, j, dim)];
                    dst[RIDX(dim-1-j, i+1, dim)] = src[RIDX(i+1, j, dim)];
                    dst[RIDX(dim-1-j, i+2, dim)] = src[RIDX(i+2, j, dim)];  
                    dst[RIDX(dim-1-j, i+3, dim)] = src[RIDX(i+3, j, dim)];
                    dst[RIDX(dim-2-j, i, dim)] = src[RIDX(i, j+1, dim)];
                    dst[RIDX(dim-2-j, i+1, dim)] = src[RIDX(i+1, j+1, dim)];
                    dst[RIDX(dim-2-j, i+2, dim)] = src[RIDX(i+2, j+1, dim)];  
                    dst[RIDX(dim-2-j, i+3, dim)] = src[RIDX(i+3, j+1, dim)]; 
                    dst[RIDX(dim-3-j, i, dim)] = src[RIDX(i, j+2, dim)];
                    dst[RIDX(dim-3-j, i+1, dim)] = src[RIDX(i+1, j+2, dim)];
                    dst[RIDX(dim-3-j, i+2, dim)] = src[RIDX(i+2, j+2, dim)];  
                    dst[RIDX(dim-3-j, i+3, dim)] = src[RIDX(i+3, j+2, dim)]; 
                    dst[RIDX(dim-4-j, i, dim)] = src[RIDX(i, j+3, dim)];
                    dst[RIDX(dim-4-j, i+1, dim)] = src[RIDX(i+1, j+3, dim)];
                    dst[RIDX(dim-4-j, i+2, dim)] = src[RIDX(i+2, j+3, dim)];  
                    dst[RIDX(dim-4-j, i+3, dim)] = src[RIDX(i+3, j+3, dim)]; 
                }
            }
        }
    }
}


/*
 * rotate_loop_unrolling_more - Rotate with four loops instead of two
 * includes code motion for inner for-loops
 */
char rotate_32_descr[] = "Loop Unrolling More";
void rotate_32(int dim, pixel *src, pixel *dst) {
    int BLOCK_SIZE = 32;
    int bi, bj, i, j, x, y;

    for (bi = 0; bi < dim; bi+=BLOCK_SIZE) {
        for (bj = 0; bj < dim; bj+=BLOCK_SIZE) {
            x = bi + BLOCK_SIZE;
            for (i = bi; i < x; i+=4) {
                y = bj + BLOCK_SIZE;
                for (j = bj; j < y; j+=4) {
                    dst[RIDX(dim-1-j, i, dim)] = src[RIDX(i, j, dim)];
                    dst[RIDX(dim-1-j, i+1, dim)] = src[RIDX(i+1, j, dim)];
                    dst[RIDX(dim-1-j, i+2, dim)] = src[RIDX(i+2, j, dim)];  
                    dst[RIDX(dim-1-j, i+3, dim)] = src[RIDX(i+3, j, dim)];
                    dst[RIDX(dim-2-j, i, dim)] = src[RIDX(i, j+1, dim)];
                    dst[RIDX(dim-2-j, i+1, dim)] = src[RIDX(i+1, j+1, dim)];
                    dst[RIDX(dim-2-j, i+2, dim)] = src[RIDX(i+2, j+1, dim)];  
                    dst[RIDX(dim-2-j, i+3, dim)] = src[RIDX(i+3, j+1, dim)]; 
                    dst[RIDX(dim-3-j, i, dim)] = src[RIDX(i, j+2, dim)];
                    dst[RIDX(dim-3-j, i+1, dim)] = src[RIDX(i+1, j+2, dim)];
                    dst[RIDX(dim-3-j, i+2, dim)] = src[RIDX(i+2, j+2, dim)];  
                    dst[RIDX(dim-3-j, i+3, dim)] = src[RIDX(i+3, j+2, dim)]; 
                    dst[RIDX(dim-4-j, i, dim)] = src[RIDX(i, j+3, dim)];
                    dst[RIDX(dim-4-j, i+1, dim)] = src[RIDX(i+1, j+3, dim)];
                    dst[RIDX(dim-4-j, i+2, dim)] = src[RIDX(i+2, j+3, dim)];  
                    dst[RIDX(dim-4-j, i+3, dim)] = src[RIDX(i+3, j+3, dim)]; 
                }
            }
        }
    }
}

/*********************************************************************
 * register_rotate_functions - Register all of your different versions
 *     of the rotate kernel with the driver by calling the
 *     add_rotate_function() for each test function. When you run the
 *     driver program, it will test and report the performance of each
 *     registered test function.  
 *********************************************************************/

void register_rotate_functions() 
{
    /*add_rotate_function(&naive_rotate, naive_rotate_descr);   
    add_rotate_function(&rotate, rotate_descr);
    add_rotate_function(&rotate_quad_loop, rotate_quad_loop_descr);
    add_rotate_function(&rotate_loop_unrolling, rotate_loop_unrolling_descr);
    add_rotate_function(&rotate_8, rotate_8_descr);
    add_rotate_function(&rotate_16, rotate_16_descr);
    add_rotate_function(&rotate_32, rotate_32_descr); */
    /* ... Register additional test functions here */
}


/***************
 * SMOOTH KERNEL
 **************/

/***************************************************************
 * Various typedefs and helper functions for the smooth function
 * You may modify these any way you like.
 **************************************************************/

/* A struct used to compute averaged pixel value */
typedef struct {
    int red;
    int green;
    int blue;
    int num;
} pixel_sum;

/* Compute min and max of two integers, respectively */
static int min(int a, int b) { return (a < b ? a : b); }
static int max(int a, int b) { return (a > b ? a : b); }

/* 
 * initialize_pixel_sum - Initializes all fields of sum to 0 
 */
static void initialize_pixel_sum(pixel_sum *sum) 
{
    sum->red = sum->green = sum->blue = 0;
    sum->num = 0;
    return;
}

/* 
 * accumulate_sum - Accumulates field values of p in corresponding 
 * fields of sum 
 */
static void accumulate_sum(pixel_sum *sum, pixel p) 
{
    sum->red += (int) p.red;
    sum->green += (int) p.green;
    sum->blue += (int) p.blue;
    sum->num++;
    return;
}

/* 
 * assign_sum_to_pixel - Computes averaged pixel value in current_pixel 
 */
static void assign_sum_to_pixel(pixel *current_pixel, pixel_sum sum) 
{
    current_pixel->red = (unsigned short) (sum.red/sum.num);
    current_pixel->green = (unsigned short) (sum.green/sum.num);
    current_pixel->blue = (unsigned short) (sum.blue/sum.num);
    return;
}

/* 
 * avg - Returns averaged pixel value at (i,j) 
 */
static pixel avg(int dim, int i, int j, pixel *src) 
{
    int ii, jj;
    pixel_sum sum;
    pixel current_pixel;

    initialize_pixel_sum(&sum);
    for(ii = max(i-1, 0); ii <= min(i+1, dim-1); ii++) 
	for(jj = max(j-1, 0); jj <= min(j+1, dim-1); jj++) 
	    accumulate_sum(&sum, src[RIDX(ii, jj, dim)]);

    assign_sum_to_pixel(&current_pixel, sum);
    return current_pixel;
}

/******************************************************
 * Your different versions of the smooth kernel go here
 ******************************************************/

/*
 * naive_smooth - The naive baseline version of smooth 
 */
char naive_smooth_descr[] = "naive_smooth: Naive baseline implementation";
void naive_smooth(int dim, pixel *src, pixel *dst) 
{
    int i, j;

    for (i = 0; i < dim; i++)
	for (j = 0; j < dim; j++)
	    dst[RIDX(i, j, dim)] = avg(dim, i, j, src);
}

/*
 * smooth - Another version of smooth. 
 */
char smooth_descr[] = "smooth: Current working version";
void smooth(int dim, pixel *src, pixel *dst) 
{
    naive_smooth(dim, src, dst);
}


/*
 * smooth - Another version of smooth. 
 */
char smooth_trial_descr[] = "first attempt";
void smooth_trial(int dim, pixel *src, pixel *dst) 
{
    int i, j;
    int tl, tc, tr, ml, mc, mr, bl, bc, br;
    int iimin, jjmin;

    for (i = 0; i < dim; i++) {
        tl = tc = tr = ml = mc = mr = bl = bc = br = 0;
        
        for (j = 0; j < dim; j++) {
            tl = tc;
            tc = tr;
            ml = mc;
            mc = mr;
            bl = bc;
            bc = br;

            int ii, jj;
            pixel_sum sum;
            pixel current_pixel;

            sum.red = sum.green = sum.blue = 0;
            sum.num = 0;

            iimin = min(i+1, dim-1);
            jjmin = min(j+1, dim-1);
            for(ii = max(i-1, 0); ii <= iimin; ii++) 
            for(jj = max(j-1, 0); jj <= jjmin; jj++) {

                accumulate_sum(&sum, src[RIDX(ii, jj, dim)]);
            }

            current_pixel.red = (unsigned short) (sum.red/sum.num);
            current_pixel.green = (unsigned short) (sum.green/sum.num);
            current_pixel.blue = (unsigned short) (sum.blue/sum.num);

            dst[RIDX(i, j, dim)] = current_pixel;
        }
    }
}


/*
 * naive_smooth - The naive baseline version of smooth 
 */
char smooth_debug_descr[] = "We will debug our code";
void smooth_debug(int dim, pixel *src, pixel *dst) 
{
    int i, j;
    int iimin, jjmin;

    for (i = 0; i < dim; i++) {
        for (j = 0; j < dim; j++) {
            int ii, jj;
            pixel_sum sum;
            pixel current_pixel;

            sum.red = sum.green = sum.blue = 0;
            sum.num = 0;

            iimin = min(i+1, dim-1);
            jjmin = min(j+1, dim-1);

            for(ii = max(i-1, 0); ii <= iimin; ii++) 
            for(jj = max(j-1, 0); jj <= jjmin; jj++) {
                sum.red += (int) src[RIDX(ii, jj, dim)].red;
                sum.green += (int) src[RIDX(ii, jj, dim)].green;
                sum.blue += (int) src[RIDX(ii, jj, dim)].blue;
                sum.num++;
            }

            current_pixel.red = (unsigned short) (sum.red/sum.num);
            current_pixel.green = (unsigned short) (sum.green/sum.num);
            current_pixel.blue = (unsigned short) (sum.blue/sum.num);

            dst[RIDX(i, j, dim)] = current_pixel;
        } 
    }
}


/*
 * 1. Write out each corner (no loops)
 * 2. Write out each edge (one loop for each if unrolled)
 * 3. Do the center (two loops, unrolled)
 */
char smooth_pro_descr[] = "This is the Pro version";
void smooth_pro(int dim, pixel *src, pixel *dst) 
{
    pixel_sum sum;
    pixel current_pixel;

    //Top left corner
    sum.red = sum.green = sum.blue = 0;

    sum.red += (int) src[RIDX(0, 0, dim)].red;
    sum.green += (int) src[RIDX(0, 0, dim)].green;
    sum.blue += (int) src[RIDX(0, 0, dim)].blue;

    sum.red += (int) src[RIDX(1, 0, dim)].red;
    sum.green += (int) src[RIDX(1, 0, dim)].green;
    sum.blue += (int) src[RIDX(1, 0, dim)].blue;

    sum.red += (int) src[RIDX(0, 1, dim)].red;
    sum.green += (int) src[RIDX(0, 1, dim)].green;
    sum.blue += (int) src[RIDX(0, 1, dim)].blue;

    sum.red += (int) src[RIDX(1, 1, dim)].red;
    sum.green += (int) src[RIDX(1, 1, dim)].green;
    sum.blue += (int) src[RIDX(1, 1, dim)].blue;

    current_pixel.red = (unsigned short) (sum.red/4);
    current_pixel.green = (unsigned short) (sum.green/4);
    current_pixel.blue = (unsigned short) (sum.blue/4);

    dst[RIDX(0, 0, dim)] = current_pixel;


    // Top right corner
    // Make those variables
    // Todo
    sum.red = sum.green = sum.blue = 0;

    sum.red += (int) src[RIDX(0, dim-1, dim)].red;
    sum.green += (int) src[RIDX(0, dim-1, dim)].green;
    sum.blue += (int) src[RIDX(0, dim-1, dim)].blue;

    sum.red += (int) src[RIDX(0, dim-2, dim)].red;
    sum.green += (int) src[RIDX(0, dim-2, dim)].green;
    sum.blue += (int) src[RIDX(0, dim-2, dim)].blue;

    sum.red += (int) src[RIDX(1, dim-1, dim)].red;
    sum.green += (int) src[RIDX(1, dim-1, dim)].green;
    sum.blue += (int) src[RIDX(1, dim-1, dim)].blue;

    sum.red += (int) src[RIDX(1, dim-2, dim)].red;
    sum.green += (int) src[RIDX(1, dim-2, dim)].green;
    sum.blue += (int) src[RIDX(1, dim-2, dim)].blue;

    current_pixel.red = (unsigned short) (sum.red/4);
    current_pixel.green = (unsigned short) (sum.green/4);
    current_pixel.blue = (unsigned short) (sum.blue/4);

    dst[RIDX(i, j, dim)] = current_pixel;


    // Bottom left corner
    sum.red = sum.green = sum.blue = 0;

    sum.red += (int) src[RIDX(dim-1, 0, dim)].red;
    sum.green += (int) src[RIDX(dim-1, 0, dim)].green;
    sum.blue += (int) src[RIDX(dim-1, 0, dim)].blue;

    sum.red += (int) src[RIDX(dim-2, 0, dim)].red;
    sum.green += (int) src[RIDX(dim-2, 0, dim)].green;
    sum.blue += (int) src[RIDX(dim-2, 0, dim)].blue;

    sum.red += (int) src[RIDX(dim-1, 1, dim)].red;
    sum.green += (int) src[RIDX(dim-1, 1, dim)].green;
    sum.blue += (int) src[RIDX(dim-1, 1, dim)].blue;

    sum.red += (int) src[RIDX(dim-2, 1, dim)].red;
    sum.green += (int) src[RIDX(dim-2, 1, dim)].green;
    sum.blue += (int) src[RIDX(dim-2, 1, dim)].blue;

    current_pixel.red = (unsigned short) (sum.red/4);
    current_pixel.green = (unsigned short) (sum.green/4);
    current_pixel.blue = (unsigned short) (sum.blue/4);

    dst[RIDX(i, j, dim)] = current_pixel;


    // Bottom right corner
    sum.red = sum.green = sum.blue = 0;

    sum.red += (int) src[RIDX(dim-1, dim-1, dim)].red;
    sum.green += (int) src[RIDX(dim-1, dim-1, dim)].green;
    sum.blue += (int) src[RIDX(dim-1, dim-1, dim)].blue;

    sum.red += (int) src[RIDX(dim-2, dim-1, dim)].red;
    sum.green += (int) src[RIDX(dim-2, dim-1, dim)].green;
    sum.blue += (int) src[RIDX(dim-2, dim-1, dim)].blue;

    sum.red += (int) src[RIDX(dim-1, dim-2, dim)].red;
    sum.green += (int) src[RIDX(dim-1, dim-2, dim)].green;
    sum.blue += (int) src[RIDX(dim-1, dim-2, dim)].blue;

    sum.red += (int) src[RIDX(dim-2, dim-2, dim)].red;
    sum.green += (int) src[RIDX(dim-2, dim-2, dim)].green;
    sum.blue += (int) src[RIDX(dim-2, dim-2, dim)].blue;

    current_pixel.red = (unsigned short) (sum.red/4);
    current_pixel.green = (unsigned short) (sum.green/4);
    current_pixel.blue = (unsigned short) (sum.blue/4);

    dst[RIDX(i, j, dim)] = current_pixel;


    /*
    int i, j;
    int iimin, jjmin;

    for (i = 0; i < dim; i++) {
        for (j = 0; j < dim; j++) {
            int ii, jj;
            pixel_sum sum;
            pixel current_pixel;

            sum.red = sum.green = sum.blue = 0;
            sum.num = 0;

            iimin = min(i+1, dim-1);
            jjmin = min(j+1, dim-1);

            for(ii = max(i-1, 0); ii <= iimin; ii++) 
            for(jj = max(j-1, 0); jj <= jjmin; jj++) {
                sum.red += (int) src[RIDX(ii, jj, dim)].red;
                sum.green += (int) src[RIDX(ii, jj, dim)].green;
                sum.blue += (int) src[RIDX(ii, jj, dim)].blue;
                sum.num++;
            }

            current_pixel.red = (unsigned short) (sum.red/sum.num);
            current_pixel.green = (unsigned short) (sum.green/sum.num);
            current_pixel.blue = (unsigned short) (sum.blue/sum.num);

            dst[RIDX(i, j, dim)] = current_pixel;
        } 
    }
    */
}


/********************************************************************* 
 * register_smooth_functions - Register all of your different versions
 *     of the smooth kernel with the driver by calling the
 *     add_smooth_function() for each test function.  When you run the
 *     driver program, it will test and report the performance of each
 *     registered test function.  
 *********************************************************************/

void register_smooth_functions() {
    //add_smooth_function(&smooth, smooth_descr);
    add_smooth_function(&naive_smooth, naive_smooth_descr);
    //add_smooth_function(&smooth_trial, smooth_trial_descr);
    //add_smooth_function(&smooth_debug, smooth_debug_descr);
    add_smooth_function(&smooth_pro, smooth_pro_descr);
    /* ... Register additional test functions here */
}

