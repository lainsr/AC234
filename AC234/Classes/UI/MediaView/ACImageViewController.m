/*
File: ACImageViewController.m
Abstract: A controller for a single image. 
Version: 1.0
*/

#import "ACImageViewController.h"
#import "ACAppDelegate.h"
#import "ACScaler.h"

@interface ACImageAndPath : NSObject {
	NSString *path;
	UIImage *image;
}

@property(copy) NSString *path;
@property(nonatomic, retain) UIImage *image;

@end

@implementation ACImageAndPath

@synthesize path, image;

-(id)initWithImage:(UIImage*)image_ at:(NSString*)path_{
    self = [super init];
	if(self != nil) {
		self.image = image_;
		self.path = path_;
		return self;
	}
	return nil;
}

@end

@interface ACImageViewController (PrivateMethods)

- (void)performAsyncLoad:(NSString *)path;

- (void)loadDidFinishWithData:(ACImageAndPath*)imageAndPath;

@end

@implementation ACImageViewController

@synthesize imagePath, loadedImagePath, imageView, activityView;

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.view addSubview:activityView];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	[self.imageView setImage:NULL];
}

#pragma mark -
#pragma mark ACController
- (BOOL)empty {
    return [self.imageView image] == NULL;
}

- (void)clearView {
	[self setImagePath:NULL];
	[self.imageView setImage:NULL];
}

- (void)didLoad:(NSString *)path at:(int)index {
	@synchronized(self) {
		if([imagePath isEqualToString:path]) return;
		[self setImagePath:path];
	}

	[self.activityView startAnimating];
	if (self.imageView.image != NULL) {
		[self.imageView setImage:NULL];
	}
	[self performAsyncLoad:path];
}

- (void)willLoad:(NSString *)path at:(int)index {
	@synchronized(self) {
		if([imagePath isEqualToString:path]) return;
		[self setImagePath:path];
	}

	[self.activityView startAnimating];
	if (self.imageView.image != NULL) {
		[self.imageView setImage:NULL];
	}
	//Use NSOperation
	[self performAsyncLoad:path];
}

- (void)willUnload:(NSString *)path at:(int)index {
    //nothing to do
}

- (void)didUnload:(NSString *)path at:(int)index {
    //nothing to do
}

#pragma mark -
#pragma mark Load datas
- (NSString *)healPath:(NSString*)dirtyPath {
	//wrong path??? try to heal it
	if(dirtyPath != nil) {
		NSString *documentPath = [(ACAppDelegate *)[[UIApplication sharedApplication] delegate] applicationDocumentsDirectory];
		NSRange range = [dirtyPath rangeOfString:documentPath];
		NSUInteger location = range.location;
		if(location != 0) {
			NSRange replacementRange = NSMakeRange(0, [documentPath length]);
			NSString *healedPath = [dirtyPath stringByReplacingCharactersInRange:replacementRange withString:documentPath];
			self.imagePath = healedPath;
			return healedPath;
		}
	}
	return dirtyPath;
}

- (void)performAsyncLoad:(NSString *)path {
	NSString *securedPath = [self healPath:path];
    
    ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[appDelegate thumbnailQueue] addOperationWithBlock:^{
        
        ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
        ACCoreDataStore *thumbnailStore = [appDelegate thumbnailStore];
        NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [localContext setPersistentStoreCoordinator: [thumbnailStore persistentStoreCoordinator]];
        [localContext setUndoManager:NULL];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:thumbnailStore selector:@selector(mergeChanges:)
                   name:NSManagedObjectContextDidSaveNotification object:localContext];
        
        UIImage *image = [ACScaler loadDbImage:path withContext:localContext];
        
        NSString *copyPath = [securedPath copyWithZone:nil];
        ACImageAndPath *imageAndPath = [[ACImageAndPath alloc] initWithImage:image at:copyPath];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self loadDidFinishWithData:imageAndPath];
        }];
    }];
}

- (void)loadDidFinishWithData:(ACImageAndPath*)imageAndPath {
	@synchronized(self) {
		if(![[self imagePath] isEqualToString:[imageAndPath path]]) {
            return;
        }
		self.imageView.image = [imageAndPath image];
	}

	[self.activityView stopAnimating];
}

- (void)updateViewAfterOrientationChange {
    if([self imagePath] == nil) {
        return;
    }
    rotating = YES;
    [self performAsyncLoad:imagePath];
}

@end
