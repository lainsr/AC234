//
//  AC234GlobalInfos.h
//  AC234
//
//  Created by Stéphane Rossé on 16.10.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeychainItemWrapper.h"

enum {
	kPasswordActivateSection,
	kSecurePasswordSection
};


@interface ACGlobalInfos : NSObject {
	CGFloat scale;
	KeychainItemWrapper *keychainPasswordWrapper;
	KeychainItemWrapper *keychainActivationWrapper;
}

@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, retain) KeychainItemWrapper *keychainPasswordWrapper;
@property (nonatomic, retain) KeychainItemWrapper *keychainActivationWrapper;

+(ACGlobalInfos*)sharedInstance;

-(CGFloat)scale;

-(BOOL)isPasswordActivated;
-(BOOL)checkPassword:(NSString *)password;



@end
