//
//  Folder.h
//  AC234
//
//  Created by Stéphane Rossé on 10.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Folder : NSManagedObject {

}

@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSString *lastViewed;

@end
