//
//  File.h
//  AC234
//
//  Created by Stéphane Rossé on 13.01.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface File : NSManagedObject {

}

@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *fullPath;
@property (nonatomic, retain) NSString *indexText;
@property (nonatomic, retain) NSNumber *type;
@property (nonatomic, retain) NSNumber *rating;
@property (nonatomic, retain) NSDate *creationDate;
@property (nonatomic, retain) UIImage *thumbnailImage;
@property (nonatomic, retain) UIImage *thumbnailLargeImage;

@end
