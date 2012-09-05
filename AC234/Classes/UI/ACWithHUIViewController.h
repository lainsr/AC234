//
//  ACWithHUIViewController.h
//  AC234
//
//  Created by Stéphane Rossé on 19.05.11.
//  Copyright 2011 Cyberiacafe. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ACHUDView.h"

@interface ACWithHUIViewController : UIViewController {
    BOOL rotating;
    UILabel *informations;
	ACHUDView *informationsHud;
    
    NSTimer *myTimer;
    int imageIndex;
	int numberOfPages;
	NSString *imagePath;
}

@property (nonatomic, retain) IBOutlet UILabel *informations;
@property (nonatomic, retain) IBOutlet ACHUDView *informationsHud;

@property (copy) NSString *imagePath;
@property (nonatomic) int imageIndex;
@property (nonatomic) int numberOfPages;

- (void)hideHUDView;
- (void)clipHUDView;
- (void)toggleInformations;

@end
