//
//  ACSettingsViewController.h
//  AC234
//
//  Created by Stéphane Rossé on 05.09.12.
//
//
#import <Foundation/Foundation.h>
#import "ACSettingsCellDelegate.h"

@interface ACToggleSwitchCell : UITableViewCell {
    
    UISwitch *valueView;
    NSObject<ACSettingsCellDelegate> *delegate;

}

@property (nonatomic, strong) UISwitch *valueView;
@property (nonatomic, strong) NSObject<ACSettingsCellDelegate> *delegate;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)setValue:(NSNumber*) newvalue;

@end
