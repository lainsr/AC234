//
//  ACPasswordSettingsViewController.h
//  AC234
//
//  Created by Stéphane Rossé on 14.09.12.
//
//

#import <UIKit/UIKit.h>
#import "ACPasswordDelegate.h"

@interface ACPasswordSettingsViewController : UITableViewController <ACPasswordDelegate> {

    BOOL activate;
}

@property (atomic) BOOL activate;

@end
