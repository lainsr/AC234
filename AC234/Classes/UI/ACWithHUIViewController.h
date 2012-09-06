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
    
    NSTimer *myTimer;
    int imageIndex;
	int numberOfPages;
	NSString *imagePath;
    
    
    IBOutlet UILabel *informations;
	IBOutlet ACHUDView *informationsHud;
}

@property (copy) NSString *imagePath;
@property (nonatomic) int imageIndex;
@property (nonatomic) int numberOfPages;

@property (nonatomic, strong) IBOutlet UILabel *informations;
@property (nonatomic, strong) IBOutlet ACHUDView *informationsHud;

- (void)hideHUDView;
- (void)clipHUDView;
- (void)toggleInformations;

@end
