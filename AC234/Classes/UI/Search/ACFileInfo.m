//
//  FileInfo.m
//  AC234
//
//  Created by Stéphane Rossé on 11.10.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//

#import "ACFileInfo.h"


@implementation ACFileInfo

@synthesize filename, fullPath;

- (id)initWithFilename:(NSString *)_filename atFullPath:(NSString *)_fullPath {
    self = [super init];
	if (self) {
		self.filename = _filename;
		self.fullPath = _fullPath;
	}
	return self;
}

@end
