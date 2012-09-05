//
//  Image.h
//  AC234
//
//  Created by Stéphane Rossé on 04.02.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//

#import "File.h"
#import <Foundation/Foundation.h>


@interface Image : NSManagedObject {

}

@property (nonatomic, retain) NSNumber *transformed;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) UIImage *image;

@end
