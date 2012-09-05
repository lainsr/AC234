//
//  ACPasswordController.h
//  AC234
//
//  Created by Stéphane Rossé on 19.10.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACPasswordDelegate.h"


@interface ACPasswordController : UIViewController <UITextFieldDelegate> {

	IBOutlet UITextField *passwordField;
	
	IBOutlet UIImageView *passwordFieldView1;
	IBOutlet UIImageView *passwordFieldView2;
	IBOutlet UIImageView *passwordFieldView3;
	IBOutlet UIImageView *passwordFieldView4;
	
	IBOutlet UITextField *confirmationField1;
	
	IBOutlet UIImageView *confirmationFieldView1;
	IBOutlet UIImageView *confirmationFieldView2;
	IBOutlet UIImageView *confirmationFieldView3;
	IBOutlet UIImageView *confirmationFieldView4;
	
	IBOutlet UILabel *message;
	IBOutlet UIView *passwordFieldsView;
	IBOutlet UIView *confirmationFieldsView;
	
	BOOL confirmation;
	NSObject<ACPasswordDelegate> *passwordDelegate;
	
}

@property (nonatomic, retain) IBOutlet UITextField *passwordField;

@property (nonatomic, retain) IBOutlet UIImageView *passwordFieldView1;
@property (nonatomic, retain) IBOutlet UIImageView *passwordFieldView2;
@property (nonatomic, retain) IBOutlet UIImageView *passwordFieldView3;
@property (nonatomic, retain) IBOutlet UIImageView *passwordFieldView4;

@property (nonatomic, retain) IBOutlet UITextField *confirmationField;

@property (nonatomic, retain) IBOutlet UIImageView *confirmationFieldView1;
@property (nonatomic, retain) IBOutlet UIImageView *confirmationFieldView2;
@property (nonatomic, retain) IBOutlet UIImageView *confirmationFieldView3;
@property (nonatomic, retain) IBOutlet UIImageView *confirmationFieldView4;

@property (nonatomic, retain) IBOutlet UILabel *message;
@property (nonatomic, retain) IBOutlet UIView *passwordFieldsView;
@property (nonatomic, retain) IBOutlet UIView *confirmationFieldsView;

@property (nonatomic) BOOL confirmation;
@property (nonatomic, retain) NSObject<ACPasswordDelegate> *passwordDelegate;


- (void)resetFields;
- (BOOL)sendPassword:(UITextField *)lastTextField password:(NSString *)password;
- (IBAction)pressDoneKey;
- (IBAction)textFieldDidChange:(id)textField;

@end
