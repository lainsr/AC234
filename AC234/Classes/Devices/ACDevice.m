//
//  ACDevice.m
//  AC234
//
//  Created by Stéphane Rossé on 18.04.12.
//  Copyright (c) 2012 Cyberiacafe. All rights reserved.
//

#import "ACDevice.h"

@implementation ACDevice

@synthesize airplayDevice;

- (id)init {
	if((self = [super init])) {
        //
	}
	return self;
}

- (id)initWithAirplayDevice:(AKDevice *)device {
	if((self = [super init])) {
        self.airplayDevice = device;
	}
	return self;
}

- (NSString *) displayName {
    if(self.airplayDevice) {
        return [self.airplayDevice displayName];
    }
	return @"NULL";
}


-(void)sendImage:(UIImage *)image {
    if(self.airplayDevice) {
        return [self.airplayDevice sendImage:image];
    }
    
}

@end
