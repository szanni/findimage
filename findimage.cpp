/*--
 * Copyright (c) 2013, Angelo Haller <angelo@szanni.org>
 * All rights reserved.

 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
#define _XOPEN_SOURCE 700
#include <ftw.h>
#include <stdio.h>
#include <stdlib.h>

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc.hpp>

using namespace cv;

#include "unused.h"

struct findimage_result
{
	double correlation;
	int x;
	int y;
};

Mat object;

int
findimage_match(Mat object, const char *file, struct findimage_result *result)
{
	Mat scene = imread(file, IMREAD_COLOR);
	if (!scene.data)
		return 1;

	// object has to be smaller than scene
	if (scene.cols < object.cols || scene.rows < object.rows)
		return 1;

	int result_cols =  scene.cols - object.cols + 1;
	int result_rows = scene.rows - object.rows + 1;
	Mat results = Mat(result_rows, result_cols, CV_32F);

	matchTemplate(scene, object, results, TM_CCORR_NORMED);

	double minVal, maxVal, matchVal;
	Point minLoc, maxLoc, matchLoc;

	minMaxLoc(results, &minVal, &maxVal, &minLoc, &maxLoc, Mat());

	matchVal = maxVal;
	matchLoc = maxLoc;

	result->correlation = matchVal;
	result->x = matchLoc.x;
	result->y = matchLoc.y;

	return 0;
}

static int
process_file(const char *path, const struct stat * UNUSED(st), int flag, struct FTW * UNUSED(ftw))
{
	if (flag != FTW_F)
		return 0;

	struct findimage_result result;

	if (!findimage_match(object, path, &result))
		printf("%.5f\t%d:%d\t%s\n", result.correlation, result.x, result.y, path);

	return 0;
}

int
main(int argc, char *argv[])
{
	int rv = EXIT_SUCCESS;

	if (argc != 3) {
		printf ("Usage: %s path object\n", argv[0]);
		return EXIT_FAILURE;
	}

	object = imread(argv[2], IMREAD_COLOR);
	if (!object.data)
		return EXIT_FAILURE;

	char *path = realpath(argv[1], NULL);
	if (path == NULL)
		return EXIT_FAILURE;

	nftw(path, process_file, 10, 0);
	free(path);

	return rv;
}

