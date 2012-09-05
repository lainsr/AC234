/*
File: ACImageViewController.h
Version: 1.0
*/

#import <UIKit/UIKit.h>
#import "ACController.h"
#import "ACWithHUIViewController.h"

@interface ACImageViewController : ACWithHUIViewController <ACController> {
	UIImageView *imageView;
	UIActivityIndicatorView *activityView;
	UINavigationController *navigationController;
	

	NSString *loadedImagePath;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (copy) NSString *loadedImagePath;

- (NSString *)healPath:(NSString*)dirtyPath;

@end
