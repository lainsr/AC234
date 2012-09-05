//
//  ImageToDataTransformer.m
//  AC234
//
//  Created by Stéphane Rossé on 04.02.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//

#import "ImageToDataTransformer.h"
#include <CoreGraphics/CGImage.h>


@implementation ImageToDataTransformer

+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSData class];
}

- (id)transformedValue:(id)value {
	NSData *data = UIImageJPEGRepresentation(value,0.9);
	return data;
}

- (id)reverseTransformedValue:(id)value {
	CGDataProviderRef dref = CGDataProviderCreateWithCFData((__bridge CFDataRef)value);
	CGImageRef cgImage = CGImageCreateWithJPEGDataProvider(dref, NULL, false, kCGRenderingIntentDefault);
	CGDataProviderRelease(dref);
	UIImage *uiImage = [UIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
	return uiImage; 
}


@end
