//
//  ACUpdateThumbnailsOperation.h
//  AC234
//
//  Created by Stéphane Rossé on 06.11.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACUpdateInfos.h"

@protocol ACUpdateThumbnailsOperationDelegate;

@interface ACUpdateThumbnailsOperation : NSOperation {
	BOOL reset;
	NSObject<ACUpdateThumbnailsOperationDelegate> *delegate;
}

@property BOOL reset;
@property(nonatomic,strong) NSObject<ACUpdateThumbnailsOperationDelegate> *delegate;

- (void)updateThumbnails:(NSMutableArray *)collector withContext:(NSManagedObjectContext *)localContext;
- (void)collectThumbnailsPathIn:(NSMutableArray *)collector at:(NSString *)dir;
- (void)mergeChanges:(NSNotification *)notification;

@end

@protocol ACUpdateThumbnailsOperationDelegate<NSObject>

-(void)updateThumbnailsProgress:(ACUpdateInfos *)infos;
-(void)operationFinished:(ACUpdateThumbnailsOperation*)op;

@end
