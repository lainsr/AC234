//
//  ACStaticIcons.h
//  AC234
//
//  Created by Stéphane Rossé on 27.01.12.
//  Copyright (c) 2012 Cyberiacafe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACStaticIcons : NSObject

+ (UIImage*)unkownIcon;
+ (UIImage*)folderIcon;
+ (UIImage*)folderLargeIcon;
+ (UIImage*)cellPattern;

#pragma mark -
#pragma mark Dark theme
+ (UIColor*) darkBackground;
+ (UIColor*) lightBackground;
+ (UIColor*) lightFontColor;
+ (UIColor*) f1LineColor;
+ (UIColor*) f2LineColor;
+ (UIColor*) sepBackground;

@end
