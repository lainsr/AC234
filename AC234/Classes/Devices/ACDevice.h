//
//  ACDevice.h
//  AC234
//
//  Created by Stéphane Rossé on 18.04.12.
//  Copyright (c) 2012 Cyberiacafe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKDevice.h"

/**
 * Facade to control devices like AppleTV...
**/
@interface ACDevice : NSObject {
    AKDevice *airplayDevice;
    
}

@property (nonatomic, readonly) NSString *displayName;
@property (nonatomic, strong) AKDevice *airplayDevice;

-(id)initWithAirplayDevice:(AKDevice *)device;

-(void)sendImage:(UIImage *)image;

@end
