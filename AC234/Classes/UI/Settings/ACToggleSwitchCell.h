//
//  ACSettingsViewController.h
//  AC234
//
//  Created by Stéphane Rossé on 05.09.12.
//
//
#import <Foundation/Foundation.h>

@interface ACToggleSwitchCell : UITableViewCell {
    
    UISwitch *valueView;

}


@property (nonatomic, strong) UISwitch *valueView;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
