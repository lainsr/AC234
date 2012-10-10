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
static UIImage* collectionPattern;

static UIColor* darkBackground;
static UIColor* lightBackground;
static UIColor* sepBackground;
static UIColor* lightFontColor;

+ (void) initialize {
    unkonwIcon = [UIImage imageNamed:@"Unkown.png"];
    folderIcon = [UIImage imageNamed:@"Folder.png"];
    folderLargeIcon = [UIImage imageNamed:@"FolderLarge.png"];
    cellPattern = [UIImage imageNamed:@"Green-noise.png"];
    collectionPattern = [UIImage imageNamed:@"MiniBackground.png"];

    //list view
    darkBackground = [UIColor colorWithRed:10.0/255.0 green:12.0/255.0 blue:15.0/255.0 alpha:1.0];
    lightBackground = [UIColor colorWithRed:22.0/255.0 green:23.0/255.0 blue:25.0/255.0 alpha:1.0];
    sepBackground = [UIColor colorWithRed:45.0/255.0 green:47.0/255.0 blue:49.0/255.0 alpha:1.0];
    lightFontColor = [UIColor colorWithRed:180.0/255.0 green:183.0/255.0 blue:185.0/255.0 alpha:1.0];
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

+ (UIImage*)collectionPattern {
    return collectionPattern;
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

+ (UIColor*) sepBackground {
    return sepBackground;
}

@end
