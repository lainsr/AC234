//
//  ACThumbnailSettingsViewController.h
//  AC234
//
//  Created by Stéphane Rossé on 14.09.12.
//
//

#import <UIKit/UIKit.h>
#import "ACUpdateThumbnailsOperation.h"

@interface ACThumbnailSettingsViewController : UITableViewController <ACUpdateThumbnailsOperationDelegate> {
    
    ACProgressBarController *progressBarController;
}

@property (strong) ACProgressBarController *progressBarController;

@end
