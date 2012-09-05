//
//  ACToolbar.m
//  AC234
//
//  Created by Stéphane Rossé on 06.04.11.
//  Copyright 2011 Cyberiacafe. All rights reserved.
//

#import "ACToolbar.h"


@implementation ACToolbar

// Override init.
- (id) init {
	self = [super init];
	[self applyTranslucentBackground];
	return self;
}

// Override initWithFrame.
- (id) initWithFrame:(CGRect) frame {
	self = [super initWithFrame:frame];
	[self applyTranslucentBackground];
	return self;
}

// Override draw rect to avoid
// background coloring
- (void)drawRect:(CGRect)rect {
    // do nothing in here
}

// Set properties to make background
// translucent.
- (void) applyTranslucentBackground {
	self.backgroundColor = [UIColor clearColor];
	self.opaque = NO;
	self.translucent = YES;
}

@end
