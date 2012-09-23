//
//  ACSettingsViewController.h
//  AC234
//
//  Created by Stéphane Rossé on 05.09.12.
//
//
#import "ACAppDelegate.h"
#import "ACToggleSwitchCell.h"

@implementation ACToggleSwitchCell

@synthesize valueView, delegate;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
		UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
		[switchview addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
		[self.contentView addSubview:switchview];
		self.valueView = switchview;
	}
	return self;
}

- (void) setValue:(NSNumber*) newvalue {
    self.valueView.on = [newvalue boolValue];
}

- (void) valueChanged {
    BOOL val = [self.valueView isOn];
    [[NSUserDefaults standardUserDefaults] setBool:val forKey:@"isWebDAVServer"];
    
    ACAppDelegate *appDelegate = (ACAppDelegate*)[[UIApplication sharedApplication] delegate];
    if(val) {
        [appDelegate startWebDAVServer];
    } else {
        [appDelegate stopWebDAVServer];
    }
    
    if ([self delegate] != NULL) {
        [self.delegate valueChanged];
    }
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
