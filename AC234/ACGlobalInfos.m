//
//  AC234GlobalInfos.m
//  AC234
//
//  Created by Stéphane Rossé on 16.10.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//
#import "ACGlobalInfos.h"

static ACGlobalInfos *sharedInstance = nil;

@implementation ACGlobalInfos

@synthesize scale, keychainPasswordWrapper, keychainActivationWrapper;

+(ACGlobalInfos*)sharedInstance {
	@synchronized(self) {
		if(sharedInstance == nil) {
			sharedInstance = [[ACGlobalInfos alloc] init];
			
			KeychainItemWrapper *wrapperActive
                = [[KeychainItemWrapper alloc] initWithIdentifier:@"activepassword" accessGroup:@"J6YUBY85D6.com.frentix.player.AC234"];
			sharedInstance.keychainActivationWrapper = wrapperActive;

			
			KeychainItemWrapper *wrapperSecure
                = [[KeychainItemWrapper alloc] initWithIdentifier:@"securepassword" accessGroup:@"J6YUBY85D6.com.frentix.player.AC234"];
			sharedInstance.keychainPasswordWrapper = wrapperSecure;
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
	NSString *activated = [keychainActivationWrapper objectForKey:(__bridge_transfer id)kSecValueData];
	return activated != nil && [@"YES" isEqualToString:activated];
}

-(BOOL)checkPassword:(NSString *)password {
	NSString *secpassword = [keychainPasswordWrapper objectForKey:(__bridge_transfer id)kSecValueData];
	if(secpassword == nil) {
		return YES;//something gone very BAD
	}
	BOOL ok = secpassword != nil && [secpassword isEqualToString:password];
	return ok;
}

@end
