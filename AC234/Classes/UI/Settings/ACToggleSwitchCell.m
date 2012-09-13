//
//  ACSettingsViewController.h
//  AC234
//
//  Created by Stéphane Rossé on 05.09.12.
//
//

#import "ACToggleSwitchCell.h"

@implementation ACToggleSwitchCell

@synthesize valueView;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
		UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
		[switchview addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
		[self.contentView addSubview:switchview];
		self.valueView = switchview;
	}
	return self;
}

- (void) setValue:(NSObject *)newvalue {
	super.value = newvalue;
    self.valueView.on = [(NSNumber *)newvalue boolValue];	
}

- (void) valueChanged {
    NSLog(@"Value change");
	//super.value = [NSNumber numberWithBool:[self.valueView on]];
}

- (void)layoutSubviews {
	[super layoutSubviews];

	// set up the value view, if it exists.
	if (self.valueView) {
        CGRect textFrame = self.textLabel.frame;
        self.textLabel.frame = CGRectMake(textFrame.origin.x, textFrame.origin.y, 200.0f, textFrame.size.height);
		self.valueView.frame = CGRectMake(210.0f, 9.0f, 80.0f, 27.0f);
	}
}

@end
