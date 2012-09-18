//
//  ProgressBar.h
//  AC234
//
//  Created by Stéphane Rossé on 04.03.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ACProgressBarController : UIViewController {

	IBOutlet UILabel *filenameLabel;
	IBOutlet UIProgressView *progressView;
	
}

@property (nonatomic, strong) IBOutlet UILabel *filenameLabel;
@property (nonatomic, strong) IBOutlet UIProgressView *progressView;



@end
