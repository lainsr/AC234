//
//  ACDeviceManager.h
//  AC234
//
//  Created by Stéphane Rossé on 18.04.12.
//  Copyright (c) 2012 Cyberiacafe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACDevice.h"
#import "AKAirplayManager.h"

@protocol ACDeviceManagerDelegate<NSObject>
-(void)deviceDetected:(ACDevice *)device;
-(void)deviceConnected;
-(void)deviceDisconnected;
@end

@interface ACDeviceManager : NSObject <AKAirplayManagerDelegate> {
    AKAirplayManager *airplayManager;
    NSObject<ACDeviceManagerDelegate> *delegate;
    
}

@property (nonatomic, readonly) BOOL  deviceAvailable;
@property (nonatomic, strong) ACDevice *connectedDevice;
@property (nonatomic, strong) AKAirplayManager *airplayManager;
@property (nonatomic, strong) NSObject<ACDeviceManagerDelegate> *delegate;

-(void)autoConnect;
-(void)connectToDevice:(ACDevice *)device;
-(void)stop;

-(void)pushFileToDevice:(NSString *)file;
-(void)addDeviceConnectionDelegate:(NSObject<ACDeviceManagerDelegate> *) connectionDelegate;

@end




