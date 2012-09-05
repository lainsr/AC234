//
//  Image.m
//  AC234
//
//  Created by Stéphane Rossé on 04.02.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//

#import "Image.h"
#import "ImageToDataTransformer.h"

@implementation Image

@dynamic image, type, path, transformed;

+ (void)initialize {
	if ( self == [File class] ) {
		ImageToDataTransformer *transformer = [[ImageToDataTransformer alloc] init];
		[NSValueTransformer setValueTransformer:transformer forName:@"ImageToDataTransformer"];
	}
}

@end
