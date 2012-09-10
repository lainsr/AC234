//
//  ACController.h
//  AC234
//
//  Created by Stéphane Rossé on 16.10.09.
//  Copyright 2009 Cyberiacafe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ACController

- (void)clearView;

- (void)willLoad:(NSString *)path at:(int)index;

- (void)didLoad:(NSString *)path at:(int)index;

- (void)willUnload:(NSString *)path at:(int)index;

- (void)didUnload:(NSString *)path at:(int)index;

- (void)updateViewAfterOrientationChange:(BOOL)async;

@end

