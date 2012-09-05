//
//  File.m
//  AC234
//
//  Created by Stéphane Rossé on 13.01.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//

#import "File.h"
#import "ImageToDataTransformer.h"

@implementation File

@dynamic path, name, fullPath, indexText, type, rating, creationDate, thumbnailImage, thumbnailLargeImage;

+ (void)initialize {
	if ( self == [File class] ) {
		ImageToDataTransformer *transformer = [[ImageToDataTransformer alloc] init];
		[NSValueTransformer setValueTransformer:transformer forName:@"ImageToDataTransformer"];
	}
}

@end
