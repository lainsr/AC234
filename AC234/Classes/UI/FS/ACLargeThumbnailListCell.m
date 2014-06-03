//
//  ACLargeThumbnailListCell.m
//  AC234
//
//  Created by Stéphane Rossé on 06.04.11.
//  Copyright 2011 Cyberiacafe. All rights reserved.
//

#import "ACGlobalInfos.h"
#import "ACLargeThumbnailListCell.h"

@interface LargeThumbnailListCellContentView : UIView {
    ACLargeThumbnailListCell *_cell;
    UIColor *shadowColor;
    UIColor *selectionColor;
    BOOL _highlighted;
    NSUInteger _highlightPosition;
    CGFloat _spareSpace;
    CGFloat _thumbnailSpace;
    CGFloat _margin;
}

-(void)selectAnImage:(NSNumber *)iconIndex;

@end

@implementation LargeThumbnailListCellContentView

- (id)initWithFrame:(CGRect)frame cell:(ACLargeThumbnailListCell *)cell {
    self = [super initWithFrame:frame];
	if (self) {
		_cell = cell;
        _thumbnailSpace = 96.0f;
        shadowColor = [[UIColor alloc] initWithRed:0.141f green:0.141f blue:0.141f alpha:1.0f];
        selectionColor = [[UIColor alloc] initWithRed:3.0/255.0 green:125.0/255.0 blue:241.0/255.0 alpha:1.0f];
		self.opaque = YES;
        UIColor *background = [UIColor whiteColor];// [[UIColor alloc] initWithRed:0.404f green:0.404f blue:0.404f alpha:1.0f];
		self.backgroundColor = background;
        self.userInteractionEnabled = YES;
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat scale = [[ACGlobalInfos sharedInstance] scale];

    int count = 0;
    int numOfThumbnails = [[_cell thumbnails] count];
    CGContextClipToRect(context, CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height));

    CGFloat cellWidth = rect.size.width;
    _spareSpace = cellWidth - ((_thumbnailSpace + 2) * numOfThumbnails) - 14;
    _margin = _spareSpace / (numOfThumbnails - 1);
    
    BOOL selected = [_cell isSelected];
    
    for(UIImage *thumbnail in [_cell thumbnails]) {
        CGImageRef image = CGImageRetain([thumbnail CGImage]);
        size_t width = CGImageGetWidth(image) / scale;
        CGFloat wOffset = (_thumbnailSpace - width) / 2.0f;
        size_t height = CGImageGetHeight(image) / scale;
        CGFloat hOffset = (_thumbnailSpace - height) / 2.0f;
        
        CGRect imageRect = CGRectMake(0.0f, 0.0f, width, height);
        
        CGFloat vOffset = 4.0f + hOffset;
        CGFloat hhOffset = (count == 0 ? 7.0f : 2.0f + _margin) + wOffset;
        if(selected && count == _highlightPosition) {
            CGContextTranslateCTM(context, hhOffset - 2.0f, vOffset - 2.0f);
            CGContextSetRGBFillColor(context, 3.0/255.0, 125.0/255.0, 241.0/255.0, 1.0f);
            CGContextFillRect(context, CGRectMake(0.0f, 0.0f, width + 4.0f, height + 4.0f));
            CGContextTranslateCTM(context, 2.0f, 2.0f);
        } else {
            CGContextTranslateCTM(context, hhOffset, vOffset);
        }
        
        CGContextDrawImage(context, imageRect, image);
        CGImageRelease(image);
        
        if (count < (numOfThumbnails - 1)) {
            CGContextTranslateCTM(context, 96.0f - (wOffset), -vOffset);
        }
        count++;
    }
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    UITouch* touch = touches.anyObject;
    CGPoint location = [touch locationInView:self];
    CGRect testRect = [self frame];
    if (CGRectContainsPoint(testRect, location)) {
        CGFloat x = location.x;
        CGFloat y = location.y;
        CGFloat scale = [[ACGlobalInfos sharedInstance] scale];
        
        int xPos = 0;
        int count = 0;
        for(UIImage *thumbnail in [_cell thumbnails]) {
            CGImageRef image = CGImageRetain([thumbnail CGImage]);
            size_t width = CGImageGetWidth(image) / scale;
            size_t height = CGImageGetHeight(image) / scale;
            CGImageRelease(image);
            
            CGFloat wOffset = (_thumbnailSpace - width) / 2.0f;
            CGFloat hOffset = (_thumbnailSpace - height) / 2.0f;
            
            //horizontal box
            CGFloat leftMargin = (count == 0 ? 7.0f : 2.0f + _margin);
            CGFloat hStart = xPos + leftMargin + wOffset;
            CGFloat hStop = hStart + width;
            //vertical box
            CGFloat vStart = 4.0f + hOffset;
            CGFloat vStop = vStart + height;

            if(x >= hStart && x <= hStop && y >= vStart && y <= vStop) {
                _highlightPosition = count;
                [_cell setSelected:YES animated:NO];
                [_cell setNeedsLayout];
                SEL theSelector = NSSelectorFromString(@"selectAnImage:");
                [self performSelector:theSelector withObject:[NSNumber numberWithInteger:count] afterDelay:0.5];
                return;
            }
            count++;
            xPos += _thumbnailSpace + leftMargin;
        }
    } else {
        [super touchesBegan:touches withEvent:event];
    }
}

-(void)selectAnImage:(NSNumber*)iconIndex {
    id view = [_cell superview];
    while ([view isKindOfClass:[UITableView class]] == NO) {
        view = [view superview];
    }
    UITableView *tableView = (UITableView *)view;
    NSIndexPath *indexPath = [tableView indexPathForCell:_cell];
    NSIndexPath *exactIndexPath = [indexPath indexPathByAddingIndex:[iconIndex intValue]];
    [[tableView delegate] tableView:tableView didSelectRowAtIndexPath:exactIndexPath];
    [_cell setSelected:NO animated:NO];
    [_cell setNeedsLayout];
}

@end


@implementation ACLargeThumbnailListCell

@synthesize thumbnails, row;
@synthesize firstFilename;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        cellContentView = [[LargeThumbnailListCellContentView alloc] initWithFrame:CGRectZero cell:self];
		cellContentView.opaque = YES;
		[self setContentMode:UIViewContentModeLeft];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
		[self.contentView addSubview:cellContentView];
        [self setUserInteractionEnabled:YES];
        NSMutableArray *thumbnailsArray = [[NSMutableArray alloc] initWithCapacity:5];
        [self setThumbnails:thumbnailsArray];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	CGRect b = [self bounds];
	[cellContentView setFrame:b];
}

- (void)setRow:(NSInteger)_row {
    row = _row;
    [self setNeedsLayout];
}

- (void)addThumbnail:(UIImage *)thumbnail {
    [[self thumbnails] addObject:thumbnail];
}

- (void)removeAllThumbnails {
    [[self thumbnails] removeAllObjects];
}

- (void) setNeedsLayout {
    [super setNeedsLayout];
    [cellContentView setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
