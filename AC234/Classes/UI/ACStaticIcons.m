//
//  ACStaticIcons.m
//  AC234
//
//  Created by Stéphane Rossé on 27.01.12.
//  Copyright (c) 2012 Cyberiacafe. All rights reserved.
//

#import "ACStaticIcons.h"




@implementation ACStaticIcons

static UIImage* unkonwIcon;
static UIImage* folderIcon;
static UIImage* folderLargeIcon;
static UIImage* cellPattern;

static UIColor* darkBackground;
static UIColor* lightBackground;
static UIColor* sepBackground;
static UIColor* lightFontColor;
static UIColor* f1LineColor;
static UIColor* f2LineColor;

+ (void) initialize {
    unkonwIcon = [UIImage imageNamed:@"Unkown.png"];
    folderIcon = [UIImage imageNamed:@"Folder.png"];
    folderLargeIcon = [UIImage imageNamed:@"FolderLarge.png"];
    cellPattern = [UIImage imageNamed:@"Green-noise.png"];

    //list view
    darkBackground = [UIColor colorWithRed:10.0/255.0 green:12.0/255.0 blue:15.0/255.0 alpha:1.0];
    lightBackground = [UIColor colorWithRed:22.0/255.0 green:23.0/255.0 blue:25.0/255.0 alpha:1.0];
    sepBackground = [UIColor colorWithRed:45.0/255.0 green:47.0/255.0 blue:49.0/255.0 alpha:1.0];
    lightFontColor = [UIColor colorWithRed:180.0/255.0 green:183.0/255.0 blue:185.0/255.0 alpha:1.0];
    f1LineColor = [UIColor colorWithRed:180.0/255.0 green:3.0/255.0 blue:5.0/255.0 alpha:1.0];
    f2LineColor = [UIColor colorWithRed:8.0/255.0 green:183.0/255.0 blue:5.0/255.0 alpha:1.0];
}

+ (UIImage*)unkownIcon {
    return unkonwIcon;
}

+ (UIImage*)folderIcon {
    return folderIcon;
}

+ (UIImage*)folderLargeIcon {
    return folderLargeIcon;
}

+ (UIImage*)cellPattern {
    return cellPattern;
}

+ (UIColor*) darkBackground {
    return darkBackground;
}

+ (UIColor*) lightBackground {
    return lightBackground;
}

+ (UIColor*) lightFontColor {
    return lightFontColor;
}

+ (UIColor*) f1LineColor {
    return f1LineColor;
}

+ (UIColor*) f2LineColor {
    return f2LineColor;
}

+ (UIColor*) sepBackground {
    return sepBackground;
}

@end
