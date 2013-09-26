//
//  HUDView.m
//  AC234
//
//  Created by Stéphane Rossé on 10.10.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ACHUDView.h"


@implementation ACHUDView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
	if (self) {
		// Initialization code
	}
	return self;
}

#pragma mark -
#pragma mark Drawing
- (void)fillRect:(CGRect)rect inContext:(CGContextRef)context {
	CGContextBeginPath(context);
	CGContextSetRGBFillColor(context, 0.99f, 0.99f, 0.99f, 0.75f);
	CGContextFillRect(context, rect);
	
    
    // Drawing lines with light stroke color
	CGContextSetRGBStrokeColor(context, 0.35f, 0.35f, 0.35f, 0.75f);
	CGContextSetLineWidth(context, 0.5f);
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect) - 0.25f);
	CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect) - 0.25f);
	CGContextStrokePath(context);

    
    // Drawing lines with stronger stroke color
	/*CGContextSetRGBStrokeColor(context, 0.05f, 0.05f, 0.05f, 0.75f);
	CGContextSetLineWidth(context, 0.5f);
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect) - 0.5f);
	CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect) - 0.5f);
	CGContextStrokePath(context);*/
}

- (void)fillRoundedRect:(CGRect)rect inContext:(CGContextRef)context {
	float radius = 8.0f;
	CGContextBeginPath(context);
	CGContextSetRGBFillColor(context, 0.1f, 0.1f, 0.1f, 0.75f);
	CGContextMoveToPoint(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect));
	CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMinY(rect) + radius, radius, 3 * M_PI / 2, 0, 0);
	CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMaxY(rect) - radius, radius, 0, M_PI / 2, 0);
	CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMaxY(rect) - radius, radius, M_PI / 2, M_PI, 0);
	CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect) + radius, radius, M_PI, 3 * M_PI / 2, 0);
	
	CGContextClosePath(context);
	CGContextFillPath(context);
}

- (void)drawRect:(CGRect)rect {
	// draw a box with rounded corners to fill the view -
	CGRect boxRect = self.bounds;
	CGContextRef ctxt = UIGraphicsGetCurrentContext();	
	boxRect = CGRectInset(boxRect, 0.0f, 0.0f);
	[self fillRect:boxRect inContext:ctxt];
}

@end
