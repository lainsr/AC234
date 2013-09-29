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
#define SEP_LINE_RGB_R 0.7843f
#define SEP_LINE_RGB_G 0.7922f
#define SEP_LINE_RGB_B 0.8f

@interface FolderListCellContentView : UIView {
    ACFolderListCell *_cell;
    BOOL _firstRow;
}

- (void)setFirstRow:(BOOL)firstRow;

@end

@implementation FolderListCellContentView

- (id)initWithFrame:(CGRect)frame cell:(ACFolderListCell *)cell {
    self = [super initWithFrame:frame];
	if (self) {
		_cell = cell;
		self.opaque = YES;
        [self setBackgroundColor:[UIColor whiteColor]];
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	[_cell.fontColor set];
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           [UIFont fontWithName:@"HelveticaNeue" size:11], NSFontAttributeName,
                           nil];
	[_cell.filename drawAtPoint:CGPointMake(45.0f, 5.0f) withAttributes:attrs];

	CGContextRef context = UIGraphicsGetCurrentContext();
	//draw the separator line
    CGContextSetLineWidth(context, 0.5f);
    CGContextSetRGBStrokeColor(context, SEP_LINE_RGB_R, SEP_LINE_RGB_G, SEP_LINE_RGB_B, 1.0f);
    //x,y
	CGContextMoveToPoint(context, 41.0f, 0.25f);
    // -> x,y
	if (![self isFirstRow]) {
        CGContextAddLineToPoint(context, rect.size.width - 33.0f, 0.25);
    }
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

- (void)setFirstRow:(BOOL)firstRow {
	_firstRow  = firstRow;
}

- (BOOL)isFirstRow {
	return _firstRow;
}

@end


@implementation ACFolderListCell

@synthesize fontColor, cellContentView;
@synthesize filename, thumbnail;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	if (self) {
		self.cellContentView = [[FolderListCellContentView alloc] initWithFrame:CGRectZero cell:self];
		self.cellContentView.opaque = YES;
		[self addSubview:cellContentView];
		[self setContentMode:UIViewContentModeLeft];
        [self setAutoresizesSubviews:YES];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	}
	return self;
}

- (void)setRow:(int)row {
	if(row == 0) {
        //self.cellContentView;
    }
}

- (void)addThumbnail:(UIImage *)image {
    [self setThumbnail:NULL];
    [self setThumbnail:image];
}

- (void) setNeedsLayout {
    [super setNeedsLayout];
    [self.cellContentView setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	CGRect b = [self bounds];
	b.size.height -= 1; // leave room for the seperator line
	if([self isEditing]) {
		b.size.width -= 40;
		b.origin.x = 40;
	}
	[self.cellContentView setFrame:b];
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
			[self.cellContentView setFrame:b];
		}
	}
	
	[super drawRect:rect];
}

@end
