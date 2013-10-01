//
//  ACHThumbnailViewController.m
//  AC234
//
//  Created by Stéphane Rossé on 10.10.12.
//
//
#import "ACAppDelegate.h"
#import "ACStaticIcons.h"
#import "ACHThumbnailViewController.h"
#import "ACThumbnailCollectionView.h"
#import "ACLoadThumbnailsOperation.h"

#define DEFAULT_CACHE_SIZE 36
#define PANIC_SIZE 35
#define PANIC_OPERATION_QUEUE_SIZE 0
#define NUM_OF_THUMBNAILS 10

@implementation ACHThumbnailViewController

@synthesize thumbnailBuffer, thumbnailCollectionViews, parentController = _parentController;
@synthesize folderList, selectedFile, currentDirPath, folderTildePath;


- (void)viewDidLoad {
    ACLRUDictionary *thumbnails = [[ACLRUDictionary alloc] initWithCapacity:DEFAULT_CACHE_SIZE * 2 + 1];
	self.thumbnailBuffer = thumbnails;
    
    [super viewDidLoad];
    
    //UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:[ACStaticIcons collectionPattern]];
	//[self.thumbnailCollectionViews setBackgroundColor:backgroundColor];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.folderList count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    int rowIndex = [indexPath indexAtPosition:0];
    NSString *filePath = [self.folderList objectAtIndex:rowIndex];
    [_parentController selectFile:filePath];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ACThumbnailCollectionView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];

    int rowIndex = [indexPath indexAtPosition:0];
    NSString *filePath = [self.folderList objectAtIndex:rowIndex];
    NSString *filename = [filePath lastPathComponent];
    
    [self loadThumbnailInCell:cell atRow:rowIndex forImage:filename atSize:YES];
    [cell setNeedsDisplay];

    return cell;
}

- (void)loadThumbnailInCell:(ACThumbnailCollectionView*)cell atRow:(int)row forImage:(NSString *)filename atSize:(BOOL)large {
	ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
	UIImage *thumbnail = [thumbnailBuffer objectForKey:filename];
	if(thumbnail == nil) {
		//check if the next
		if([[[appDelegate thumbnailQueue]operations]count] > PANIC_OPERATION_QUEUE_SIZE) {
			if ([thumbnailBuffer reserved:filename]) {
				int count = 0;
				while (thumbnail == nil) {
					struct timespec ts;
					ts.tv_sec = 0;
					ts.tv_nsec = 10000000;
					nanosleep(&ts, NULL);
					thumbnail = [thumbnailBuffer objectForKey:filename];
					if(count++ > 20) {
						break;
					}
				}
			}
			
			if(thumbnail == nil) {
				[[appDelegate thumbnailQueue] waitUntilAllOperationsAreFinished];
				thumbnail = [thumbnailBuffer objectForKey:filename];
				if(thumbnail == nil) {
					//miss the right thumbnails
					[thumbnailBuffer removeAllObjects];
					[self fillThumbnailsBufferAt:row size:large waitUntilFilled:YES];
				}
			}
		} else {
			[self fillThumbnailsBufferAt:row size:large waitUntilFilled:YES];
		}
		thumbnail = [thumbnailBuffer objectForKey:filename];
	} else if ([thumbnailBuffer count] < PANIC_SIZE && [[[appDelegate thumbnailQueue]operations]count] == 0) {
		[self fillThumbnailsBufferAt:row size:large waitUntilFilled:NO];
	}
    
	if(thumbnail == NULL) {
		NSLog(@"Null thumbnail %@",filename);
	} else {
		[cell setThumbnail:thumbnail];
	}
	
	[thumbnailBuffer removeObjectForKey:filename];
}

- (void)fillThumbnailsBufferAt:(int)row size:(BOOL)large waitUntilFilled:(BOOL)wait {
    
	NSMutableArray *filenames = [NSMutableArray arrayWithCapacity:DEFAULT_CACHE_SIZE];
	@synchronized(thumbnailBuffer) {
		BOOL cancel = NO;
        BOOL backwards = NO;
        if(backwards) {
            int nextStop = row + DEFAULT_CACHE_SIZE;
            for(int i=row; i>=nextStop && i>=0; i--) {
                NSString *path = [self.folderList objectAtIndex:i];
                NSString *filename = [path lastPathComponent];
                if(![thumbnailBuffer reserved:filename] && [thumbnailBuffer objectForKey:filename] == NULL) {
                    [thumbnailBuffer reservationForKey:filename];
                    [filenames addObject:filename];
                    if(!wait && row - i > 20) {
                        cancel = YES;
                        break;
                    }
                }
            }
        } else {
            int nextStop = row + DEFAULT_CACHE_SIZE;
            for(int i=row; i<nextStop && i<[self.folderList count];i++) {
                NSString *path = [self.folderList objectAtIndex:i];
                NSString *filename = [path lastPathComponent];
                if (![thumbnailBuffer reserved:filename] && [thumbnailBuffer objectForKey:filename] == NULL) {
                    [thumbnailBuffer reservationForKey:filename];
                    [filenames addObject:filename];
                    if(!wait && i - row > 20) {
                        cancel = YES;
                        break;
                    }
                }
            }
        }
		
		if(cancel) {
			for(int i=[filenames count]; i-->0; ) {
				[thumbnailBuffer cancelReservationForKey:[filenames objectAtIndex:i]];
			}
			return;
		}
	}
	
	if([filenames count] > 0) {
		ACLoadThumbnailsOperation *loadBatch = [[ACLoadThumbnailsOperation alloc] initWithPath:self.folderTildePath subSet:filenames size:large];
		loadBatch.delegate = self;// set the delegate
		ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
		[[appDelegate thumbnailQueue] addOperation:loadBatch];
		if(wait) {
			[[appDelegate thumbnailQueue] waitUntilAllOperationsAreFinished];
		}
	}
}

#pragma mark - ACLoadThumbnailsOperation
-(void) thumbnailFinished:(UIImage*)image forFile:(NSString*)filename {
	[thumbnailBuffer setObject:image forKey:filename];
	[thumbnailBuffer cancelReservationForKey:filename];
}

-(void) thumbnailsFinished {
    //
}

@end
