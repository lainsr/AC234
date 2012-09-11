//
//  ACDeviceManager.m
//  AC234
//
//  Created by Stéphane Rossé on 18.04.12.
//  Copyright (c) 2012 Cyberiacafe. All rights reserved.
//

#import "ACDeviceManager.h"

@interface ACDeviceManager (PrivateMethods)

-(void)asyncSendToDevice:(NSString *)file;

-(void)sendImageToDevice:(UIImage *)image;
    
@end

@implementation ACDeviceManager

@synthesize delegate, connectedDevice, airplayManager;

- (id)init {
	if((self = [super init])) {
        //
	}
	return self;
}

- (BOOL)deviceAvailable {
	return (self.connectedDevice != NULL);
}


-(void)addDeviceConnectionDelegate:(NSObject<ACDeviceManagerDelegate> *) connectionDelegate {
    [self setDelegate:NULL];
    [self setDelegate:connectionDelegate];
}


-(void)autoConnect {
    if([self airplayManager] == NULL) {
        self.airplayManager = [[AKAirplayManager alloc] init];
        [self.airplayManager setAutoConnect:NO];
        [self.airplayManager setDelegate:self]; 
    }
    [self.airplayManager findDevices];
}


-(void)connectToDevice:(ACDevice *)device {
    [airplayManager connectToDevice:[device airplayDevice]];
}

-(void)stop {
    if(airplayManager &&  airplayManager.connectedDevice) {
        [airplayManager.connectedDevice sendStop];
        [self setConnectedDevice: NULL];
    }
    if([self delegate]) {
        [self.delegate deviceDisconnected];
    }
}

-(void)pushFileToDevice:(NSString *)file {
    //no device to push
    if(![self deviceAvailable]) {
        return;
    }
    
    if([NSThread isMainThread]) {
        [self performSelectorInBackground:@selector(asyncSendToDevice:) withObject:file];
    } else {
        [self asyncSendToDevice:file];
    }
}

#pragma mark -
#pragma mark Private
-(void)asyncSendToDevice:(NSString *)file {
    NSString *fileExtension = [[file pathExtension] lowercaseString];
    if([@"jpg" isEqualToString:fileExtension] || [@"jpeg" isEqualToString:fileExtension]
       || [@"gif" isEqualToString:fileExtension]
       || [@"tiff" isEqualToString:fileExtension]
       || [@"png" isEqualToString:fileExtension]) {
        //send jpg, png, gif and tiff
        UIImage *image = [UIImage imageWithContentsOfFile:file];
        [self performSelectorOnMainThread:@selector(sendImageToDevice:) withObject:image waitUntilDone:NO];
    } else {
        NSLog(@"Unsupported format: %@", fileExtension);
    }
}

-(void)sendImageToDevice:(UIImage *)image {
    ACDevice *targetDevice = [self connectedDevice];
    if(targetDevice) {
        [targetDevice sendImage:image];
    }
}

#pragma mark -
#pragma mark AKAirplayManagerDelegate
- (void) manager:(AKAirplayManager *)manager didFindDevice:(AKDevice *)device {
    // Use - (void) connectToDevice:(AKDevice *)device; to connect to a specific device.
	NSLog(@"Found device...");
    if([self delegate]) {
        ACDevice *myDevice = [[ACDevice alloc] initWithAirplayDevice:device];
        [self.delegate deviceDetected:myDevice];
    }
}

- (void) manager:(AKAirplayManager *)manager didConnectToDevice:(AKDevice *)device{
    // Once connected, use AKDevice 
	NSLog(@"Connected to device : %@", device.hostname);
    ACDevice *myDevice = [[ACDevice alloc] initWithAirplayDevice:device];
    self.connectedDevice = myDevice;
    if([self delegate]) {
        [self.delegate deviceConnected];
    }
} 

@end
