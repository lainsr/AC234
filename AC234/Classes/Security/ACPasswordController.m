//
//  ACPasswordController.m
//  AC234
//
//  Created by Stéphane Rossé on 19.10.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//

#import "ACStaticIcons.h"
#import "ACPasswordController.h"

@interface ACPasswordController (PrivateMethods) 

-(void)updatePasswordFieldView:(BOOL)secured1 field2:(BOOL)secured2 field3:(BOOL)secured3 field4:(BOOL)secured4;
-(void)updateConfirmationFieldView:(BOOL)secured1 field2:(BOOL)secured2 field3:(BOOL)secured3 field4:(BOOL)secured4;

@end


@implementation ACPasswordController

@synthesize passwordField, passwordFieldView1, passwordFieldView2, passwordFieldView3, passwordFieldView4, passwordFieldsView;
@synthesize confirmationField, confirmationFieldView1, confirmationFieldView2, confirmationFieldView3, confirmationFieldView4, confirmationFieldsView;
@synthesize passwordDelegate, confirmation, message;


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[passwordField becomeFirstResponder];
}

- (void)viewDidLoad {
	[super viewDidLoad];
    UIColor *greenNoiseColor = [[UIColor alloc] initWithPatternImage:[ACStaticIcons cellPattern]];
	[self.view setBackgroundColor:greenNoiseColor];
	[self.message setText:NSLocalizedString(@"TypePassword",@"")];
	[passwordField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSString *value = [textField text];
	int textLength = [value length] + [string length] - range.length;
	if([passwordField isEqual:textField]) {
		if(textLength == 0) {
			[self updatePasswordFieldView:NO field2:NO field3:NO field4:NO];
		} else if(textLength == 1) {
			[self updatePasswordFieldView:YES field2:NO field3:NO field4:NO];
		} else if(textLength == 2) {
			[self updatePasswordFieldView:YES field2:YES field3:NO field4:NO];
		} else if (textLength == 3) {
			[self updatePasswordFieldView:YES field2:YES field3:YES field4:NO];
		} else if(textLength == 4) {
			[self updatePasswordFieldView:YES field2:YES field3:YES field4:YES];
			if(confirmation) {
				//check password
			} else {
				NSMutableString *password = [NSMutableString stringWithCapacity:4];
				[password appendString:[passwordField text]];
				[password appendString:string];
				return [self sendPassword:passwordField password:password];
			}
		}
	}	else if([confirmationField isEqual:textField]) {
		if(textLength == 0) {
			[self updateConfirmationFieldView:NO field2:NO field3:NO field4:NO];
		}else if (textLength == 1) {
			[self updateConfirmationFieldView:YES field2:NO field3:NO field4:NO];
		} else if(textLength == 2) {
			[self updateConfirmationFieldView:YES field2:YES field3:NO field4:NO];
		} else if(textLength == 3) {
			[self updateConfirmationFieldView:YES field2:YES field3:YES field4:NO];
		} else if(textLength == 4) {
			[self updateConfirmationFieldView:YES field2:YES field3:YES field4:YES];
			NSMutableString *password = [NSMutableString stringWithCapacity:4];
			[password appendString:[confirmationField text]];
			[password appendString:string];
			return [self sendPassword:confirmationField password:password];
		}
	}
	return YES;
}

-(void)updatePasswordFieldView:(BOOL)secured1 field2:(BOOL)secured2 field3:(BOOL)secured3 field4:(BOOL)secured4 {
	[passwordFieldView1 setImage:secured1 ? [UIImage imageNamed:@"PasswordFieldFilled.png"] : [UIImage imageNamed:@"PasswordField.png"]];
	[passwordFieldView2 setImage:secured2 ? [UIImage imageNamed:@"PasswordFieldFilled.png"] : [UIImage imageNamed:@"PasswordField.png"]];
	[passwordFieldView3 setImage:secured3 ? [UIImage imageNamed:@"PasswordFieldFilled.png"] : [UIImage imageNamed:@"PasswordField.png"]];
	[passwordFieldView4 setImage:secured4 ? [UIImage imageNamed:@"PasswordFieldFilled.png"] : [UIImage imageNamed:@"PasswordField.png"]];
}

-(void)updateConfirmationFieldView:(BOOL)secured1 field2:(BOOL)secured2 field3:(BOOL)secured3 field4:(BOOL)secured4 {
	[confirmationFieldView1 setImage:secured1 ? [UIImage imageNamed:@"PasswordFieldFilled.png"] : [UIImage imageNamed:@"PasswordField.png"]];
	[confirmationFieldView2 setImage:secured2 ? [UIImage imageNamed:@"PasswordFieldFilled.png"] : [UIImage imageNamed:@"PasswordField.png"]];
	[confirmationFieldView3 setImage:secured3 ? [UIImage imageNamed:@"PasswordFieldFilled.png"] : [UIImage imageNamed:@"PasswordField.png"]];
	[confirmationFieldView4 setImage:secured4 ? [UIImage imageNamed:@"PasswordFieldFilled.png"] : [UIImage imageNamed:@"PasswordField.png"]];
}

- (IBAction)pressDoneKey {
	[passwordField resignFirstResponder];
}

- (IBAction)textFieldDidChange:(id)textField {
	if(confirmation && [passwordField isEqual:textField] && [passwordField.text length] > 3) {
		[passwordFieldsView setHidden:YES];
		[confirmationFieldsView setHidden:NO];
		[message setText:NSLocalizedString(@"NeedPasswordConfirmation",@"")];
		[passwordField resignFirstResponder];
		[confirmationField becomeFirstResponder];
	}
}

- (BOOL)sendPassword:(UITextField *)lastTextField password:(NSString *)password {
	[lastTextField resignFirstResponder];
	if (confirmation) {
		NSString *confirmedPassword = [passwordField text];
		if([confirmedPassword isEqualToString:password]) {
			if(![self.passwordDelegate passwordSet:password]) {
				[self resetFields];
				return NO;
			}
		} else {
			[self resetFields];
			return NO;
		} 
	} else if(![self.passwordDelegate passwordSet:password]) {
		[self resetFields];
		return NO;
	}
	return YES;
}

- (void)resetFields {
	[passwordField setText:@""];
	[self updatePasswordFieldView:NO field2:NO field3:NO field4:NO];
	[confirmationField setText:@""];
	[self updateConfirmationFieldView:NO field2:NO field3:NO field4:NO];
	if (confirmation) {
		[confirmationFieldsView setHidden:YES];
		[passwordFieldsView setHidden:NO];
		[passwordField becomeFirstResponder];
		[message setText:NSLocalizedString(@"RetypePasswordAndConfirmation",@"")];
	} else {
		[passwordField becomeFirstResponder];
		[message setText:NSLocalizedString(@"RetypePassword",@"")];
	}
}

@end
