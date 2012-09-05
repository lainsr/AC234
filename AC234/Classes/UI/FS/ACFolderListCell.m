//
//  FolderListCell.m
//  AC234
//
//  Created by Stéphane Rossé on 14.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ACGlobalInfos.h"
#import "ACStaticIcons.h"
#import "ACFolderListCell.h"

#define ACCESSORY_RECT CGRectMake(0.0f, 0.0f, 40.0f, 36.0f)

@interface FolderListCellContentView : UIView {
    ACFolderListCell *_cell;
    BOOL _highlighted;
}

@end

@implementation FolderListCellContentView

- (id)initWithFrame:(CGRect)frame cell:(ACFolderListCell *)cell {
    self = [super initWithFrame:frame];
	if (self) {
		_cell = cell;
		self.opaque = YES;
		self.backgroundColor = _cell.backgroundColor;
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	[_cell.fontColor set];
	[_cell.filename drawAtPoint:CGPointMake(45.0f, 5.0f) withFont:[UIFont systemFontOfSize:12.0]];

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(context, 1.0f);
	
	CGColorRef sepColor = [_cell.separatorColor CGColor];
	int numComponents = CGColorGetNumberOfComponents(sepColor);
	if (numComponents == 4) {
		const CGFloat *components = CGColorGetComponents(sepColor);
		CGFloat red = components[0];
		CGFloat green = components[1];
		CGFloat blue = components[2];
		CGFloat aleph = components[3];
		CGContextSetRGBStrokeColor(context, red, green, blue, aleph);
	} else {
        CGFloat red = 45.0/255.0;
        CGFloat green = 47.0/255.0;
        CGFloat blue = 49.0/255.0 ;
        CGFloat aleph = 1.0;
        CGContextSetRGBStrokeColor(context, red, green, blue, aleph);
    }

	CGContextMoveToPoint(context, 36.5f, 0.0f);
	CGContextAddLineToPoint(context, 36.5f, rect.size.height);
	CGContextStrokePath(context);

	CGFloat scale = [[ACGlobalInfos sharedInstance] scale];
	
	CGImageRef image = CGImageRetain([[_cell thumbnail] CGImage]);
	size_t width = CGImageGetWidth(image) / scale;
	CGFloat wOffset = (32.0f - width) / 2.0f;
	size_t height = CGImageGetHeight(image) / scale;
	CGFloat hOffset = (32.0f - height) / 2.0f;
	
	CGRect imageRect = CGRectMake(0.0f, 0.0f, width, height);
	CGContextClipToRect(context, CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height));      
	CGContextTranslateCTM(context, 2.0f + wOffset, 2.0f + hOffset);
	CGContextDrawImage(context, imageRect, image);
	CGImageRelease(image);
}

- (void)setHighlighted:(BOOL)highlighted {
	_highlighted = highlighted;
	[self setNeedsDisplay];
}

- (BOOL)isHighlighted {
	return _highlighted;
}

@end


@implementation ACFolderListCell

@synthesize fontColor,lightBackground, darkBackground, separatorColor;
@synthesize filename, thumbnail;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	if (self) {
		cellContentView = [[FolderListCellContentView alloc] initWithFrame:CGRectZero cell:self];
		cellContentView.opaque = YES;
		[self setLightBackground:[ACStaticIcons lightBackground]];
		[self setDarkBackground:[ACStaticIcons darkBackground]];
		[self setFontColor:[ACStaticIcons lightFontColor]];
		[self setSeparatorColor:[ACStaticIcons sepBackground]];
		[self addSubview:cellContentView];
		[self setContentMode:UIViewContentModeLeft];
        [self setAutoresizesSubviews:YES];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	}
	return self;
}

- (void)setRow:(int)row {
	if((row  % 2) == 0) {
		cellContentView.backgroundColor = lightBackground;
		self.backgroundColor = lightBackground;
	} else {
		cellContentView.backgroundColor = darkBackground;
		self.backgroundColor = lightBackground;
	}
}

- (void)addThumbnail:(UIImage *)image {
    [self setThumbnail:NULL];
    [self setThumbnail:image];
}

- (void) setNeedsLayout {
    [super setNeedsLayout];
    [cellContentView setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	CGRect b = [self bounds];
	b.size.height -= 1; // leave room for the seperator line
	if([self isEditing]) {
		b.size.width -= 40;
		b.origin.x = 40;
	}
	[cellContentView setFrame:b];
}

- (void)drawRect:(CGRect)rect {
	if([self isEditing]) {
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSetFillColorWithColor(context, [cellContentView.backgroundColor CGColor]);
		CGContextAddRect(context, ACCESSORY_RECT);
		CGContextFillRect(context, ACCESSORY_RECT);

		//force update of the contentView bounds
		CGRect b = [self bounds];
		CGRect c = [cellContentView bounds];
		if(c.origin.x != 40) {
			b.size.height -= 1; // leave room for the seperator line
			b.size.width -= 40;
			b.origin.x = 40;
			[cellContentView setFrame:b];
		}
	}
	
	[super drawRect:rect];
}

@end
