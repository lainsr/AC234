//
//  LoadThumbnailsOperation.h
//  AC234
//
//  Created by Stéphane Rossé on 08.05.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ACLoadThumbnailsOperationDelegate;

@interface ACLoadThumbnailsOperation : NSOperation {
	NSString *dirTildePath;
	NSArray *imageNames;
	NSArray *fullPaths;
	BOOL large;
    id<ACLoadThumbnailsOperationDelegate> delegate;
}

@property(nonatomic,strong,readonly) NSString *dirTildePath;
@property(nonatomic,strong,readonly) NSArray *imageNames;
@property(nonatomic,strong,readonly) NSArray *fullPaths;
@property(nonatomic,readonly) BOOL large;
@property(nonatomic,strong) id<ACLoadThumbnailsOperationDelegate> delegate;

-(id)initWithPaths:(NSArray *)paths size:(BOOL)large;
-(id)initWithPath:(NSString *)tildePath subSet:(NSArray *)filenames size:(BOOL)large;

@end

@protocol ACLoadThumbnailsOperationDelegate<NSObject>
-(void) thumbnailFinished:(UIImage*)image forFile:(NSString*)filename;
-(void) thumbnailsFinished;
@end