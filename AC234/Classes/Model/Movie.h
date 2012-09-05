//
//  Movie.h
//  AC234
//
//  Created by Stéphane Rossé on 22.01.12.
//  Copyright (c) 2012 Cyberiacafe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Movie : NSManagedObject

@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSNumber *playbackTime;

@end
