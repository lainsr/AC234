//
//  AKServiceManager.m
//  AirplayKit
//
//  Created by Andy Roth on 1/18/11.
//  Copyright 2011 Roozy. All rights reserved.
//

#import "AKAirplayManager.h"


@implementation AKAirplayManager

@synthesize delegate, autoConnect, connectedDevice;

#pragma mark -
#pragma mark Initialization

- (id) init {
	if((self = [super init])) {
		self.autoConnect = YES;
		foundServices = [[NSMutableArray alloc] init];
	}
	return self;
}

#pragma mark -
#pragma mark Public Methods

- (void) findDevices {
	NSLog(@"Finding Airport devices.");
	serviceBrowser = [[NSNetServiceBrowser alloc] init];
	[serviceBrowser setDelegate:self];
	[serviceBrowser searchForServicesOfType:@"_airplay._tcp" inDomain:@""];
}

- (void) connectToDevice:(AKDevice *)device {
	NSLog(@"Connecting to device : %@:%d", device.hostname, device.port);
	if(!tempDevice) {
		tempDevice = device;
		GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        NSError *error;
		[socket connectToHost:device.hostname onPort:device.port error:&error];
        NSLog(@"Error: %@", error);
	}
}

#pragma mark -
#pragma mark Net Service Browser Delegate
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
	NSLog(@"Found service");
	[aNetService setDelegate:self];
	[aNetService resolveWithTimeout:20.0];
	[foundServices addObject:aNetService];
	
	if(!moreComing)
	{
		[serviceBrowser stop];
		serviceBrowser = nil;
	}
}

#pragma mark -
#pragma mark Net Service Delegate

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
	NSLog(@"Resolved service: %@:%d", sender.hostName, sender.port);
	AKDevice *device = [[AKDevice alloc] init];
	device.hostname = sender.hostName;
	device.port = sender.port;
	
	if(delegate && [delegate respondsToSelector:@selector(manager:didFindDevice:)]) {
		[delegate manager:self didFindDevice:device];
	}
	
	if(autoConnect && !connectedDevice) {
		[self connectToDevice:device];
	}
}

#pragma mark -
#pragma mark AsyncSocket Delegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
	NSLog(@"Connected to device.");
	
	AKDevice *device = tempDevice;
	device.socket = sock;
	device.connected = YES;
	
	self.connectedDevice = device;
	tempDevice = nil;
	
	if(delegate && [delegate respondsToSelector:@selector(manager:didConnectToDevice:)]) {
		[self.connectedDevice sendReverse];
		[delegate manager:self didConnectToDevice:self.connectedDevice];
	}
}

@end
