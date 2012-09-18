//
//  ACUpdateInfos.m
//  AC234
//
//  Created by Stéphane Rossé on 06.11.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//

#import "ACUpdateInfos.h"


@implementation ACUpdateInfos

@synthesize progress, path, currentPosition, numberOfThumbnails;

- (id)initWithProgress:(float)_progress {
    self = [super init];
	if (self) {
		self.progress = _progress;
	}
	return self;
}


@end
