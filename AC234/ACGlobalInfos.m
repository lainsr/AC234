//
//  AC234GlobalInfos.m
//  AC234
//
//  Created by Stéphane Rossé on 16.10.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//
#import "ACGlobalInfos.h"
#import "SFHFKeychainUtils.h"

static ACGlobalInfos *sharedInstance = nil;

@implementation ACGlobalInfos

@synthesize scale;

+(ACGlobalInfos*)sharedInstance {
	@synchronized(self) {
		if(sharedInstance == nil) {
			sharedInstance = [[ACGlobalInfos alloc] init];
		}
	}
	return sharedInstance;
}

#pragma mark -
#pragma mark Lifecycle

- (CGFloat)scale {
	if (scale > 0.1f) {
		return scale;
	}
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]){
		scale = [[UIScreen mainScreen] scale];
	} else {
		scale = 1.0f;
	}
	return scale;
}

-(BOOL)isPasswordActivated {
    NSString *secpassword = [SFHFKeychainUtils getPasswordForUsername:@"me" andServiceName:@"AC234" error:nil];
    return secpassword != nil;
}

-(BOOL)checkPassword:(NSString *)password {
	NSString *secpassword = [SFHFKeychainUtils getPasswordForUsername:@"me" andServiceName:@"AC234" error:nil];
	if(secpassword == nil) {
		return YES;//something gone very BAD
	}
	BOOL ok = secpassword != nil && [secpassword isEqualToString:password];
	return ok;
}

@end
