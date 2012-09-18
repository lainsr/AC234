//
//  ACUpdateInfos.h
//  AC234
//
//  Created by Stéphane Rossé on 06.11.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ACUpdateInfos : NSObject {
	int currentPosition;
	int numberOfThumbnails;
	float progress;
	NSString *path;
}

@property(nonatomic) int currentPosition;
@property(nonatomic) int numberOfThumbnails;
@property(nonatomic) float progress;
@property(nonatomic,copy) NSString *path;

- (id)initWithProgress:(float)_progress;

@end
