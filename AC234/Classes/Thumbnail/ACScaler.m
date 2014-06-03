//
//  Scaler.m
//  AC234
//
//  Created by Stéphane Rossé on 20.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "File.h"
#import "Image.h"
#import "ACScaler.h"
#import "ACGlobalInfos.h"
#import "ACAppDelegate.h"
#import "ACStaticIcons.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>


@implementation ACScaler

static const size_t kImageMaxSPP = 4;		// Image maximum samples-per-pixel
static const size_t kImageMaxBPC = 8;		// Image maximum bits-per-component

//static int IMAGE = 0;
//static int FOLDER = 1;
//static int MOVIE = 2;
//static int UNKOWN = 3;

#define IMAGE 0
#define FOLDER 1
#define MOVIE 2
#define UNKOWN 3

+ (UIImage *)scale:(NSManagedObjectContext *) localContext atFolderPath:(NSString*)dirTildePath image:(NSString *)name size:(BOOL)large {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"File" inManagedObjectContext:localContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];

    [request setEntity:entity];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
        
    NSString *loadByAttr = @"name" ;
    if(large) {
        [request setPropertiesToFetch:[NSArray arrayWithObjects:loadByAttr, @"type", @"thumbnailLargeImage", nil]];
    } else {
        [request setPropertiesToFetch:[NSArray arrayWithObjects:loadByAttr, @"type", @"thumbnailImage", nil]];
    }
    [request setFetchBatchSize:10];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(name ==[c] %@) AND (path == %@)", name, dirTildePath]];
   
    NSError *error = NULL;
    NSArray *results = [localContext executeFetchRequest:request error:&error];
    
    UIImage *thumbnail;
    if([results count] > 0) {
        NSDictionary *resultDict =[results objectAtIndex:0];
        NSNumber *type = [resultDict objectForKey:@"type"];
        switch ([type intValue]) {
            case FOLDER: {
                if(large) {
                    thumbnail = [ACStaticIcons folderLargeIcon];
                } else {
                    thumbnail = [ACStaticIcons folderIcon];
                }
                break;
            }
            case UNKOWN: {
                thumbnail = [ACStaticIcons unkownIcon];
                break;
            } default: {
                if(large) {
                    thumbnail = [resultDict objectForKey:@"thumbnailLargeImage"];
                } else {
                    thumbnail = [resultDict objectForKey:@"thumbnailImage"];
                }
            }
        }
    } else {
        File *savedFile = [NSEntityDescription insertNewObjectForEntityForName:@"File" inManagedObjectContext:localContext];
        NSString *expandedPath = [dirTildePath stringByExpandingTildeInPath];
        savedFile.path = dirTildePath;
        savedFile.name = name;
        savedFile.fullPath = [expandedPath stringByAppendingPathComponent:name];
                    
        BOOL isDir;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:[savedFile fullPath] isDirectory:&isDir] && !isDir) {
            [ACScaler extractThumbnailFrom:[savedFile fullPath] toFile:savedFile];
            if(large) {
                thumbnail = [savedFile thumbnailLargeImage];
            } else {
                thumbnail = [savedFile thumbnailImage];
            }
                        
        } else if (isDir) {
            savedFile.type = [NSNumber numberWithInt:FOLDER];
            if(large) {
                thumbnail = [ACStaticIcons folderLargeIcon];
            } else {
                thumbnail = [ACStaticIcons folderIcon];
            }
        } else {
            thumbnail = [ACStaticIcons unkownIcon];
        }
                    
        if(![[savedFile managedObjectContext] save:&error]) {
            NSLog(@"Cannot save thumbnail %@, %@", error, [error userInfo]);
        }
    }
    return thumbnail;
}

+ (NSArray *)scale:(NSManagedObjectContext *) localContext atFolderPath:(NSString*)dirTildePath subSet:(NSArray *)imageNames size:(BOOL)large {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"File" inManagedObjectContext:localContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entity];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    
    NSString *loadByAttr = @"name" ;
    if(large) {
        [request setPropertiesToFetch:[NSArray arrayWithObjects:loadByAttr, @"type", @"thumbnailLargeImage", nil]];
    } else {
        [request setPropertiesToFetch:[NSArray arrayWithObjects:loadByAttr, @"type", @"thumbnailImage", nil]];
    }
    [request setFetchBatchSize:10];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(name IN %@) AND (path == %@)", imageNames, dirTildePath]];
    
    NSError *error = NULL;
    NSArray *results = [localContext executeFetchRequest:request error:&error];
    
    int numOfFiles = [imageNames count];
    NSMutableDictionary *thumbnailDict = [NSMutableDictionary dictionaryWithCapacity:numOfFiles];
    for(int i=[results count]; i-->0; ) {
        NSDictionary *resultDict =[results objectAtIndex:i];
        NSNumber *type = [resultDict objectForKey:@"type"];
        NSString *name = [resultDict objectForKey:@"name"];
       
        UIImage *thumbnail;
        switch ([type intValue]) {
            case FOLDER: {
                if(large) {
                    thumbnail = [ACStaticIcons folderLargeIcon];
                } else {
                    thumbnail = [ACStaticIcons folderIcon];
                }
                break;
            }
            case UNKOWN: {
                thumbnail = [ACStaticIcons unkownIcon];
                break;
            } default: {
                if(large) {
                    thumbnail = [resultDict objectForKey:@"thumbnailLargeImage"];
                } else {
                    thumbnail = [resultDict objectForKey:@"thumbnailImage"];
                }
            }
        }
        if(thumbnail != nil) {
            [thumbnailDict setObject:thumbnail forKey:name];
        }
    }
    
    NSString *expandedPath = NULL;
    NSMutableArray *thumbnails = [NSMutableArray arrayWithCapacity:numOfFiles];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for(int i=0; i<numOfFiles; i++) {
        UIImage *thumbnail;
        NSString *file = [imageNames objectAtIndex:i];
        if([thumbnailDict valueForKey:file] == nil) {
            File *savedFile = [NSEntityDescription insertNewObjectForEntityForName:@"File" inManagedObjectContext:localContext];
            if(expandedPath == NULL) {
                    expandedPath = [dirTildePath stringByExpandingTildeInPath];
            }
            savedFile.path = dirTildePath;
            savedFile.name = file;
            savedFile.fullPath = [expandedPath stringByAppendingPathComponent:file];
                
            BOOL isDir;
            if ([fileManager fileExistsAtPath:[savedFile fullPath] isDirectory:&isDir] && !isDir) {
                [ACScaler extractThumbnailFrom:[savedFile fullPath] toFile:savedFile];
                if(large) {
                    thumbnail = [savedFile thumbnailLargeImage];
                } else {
                    thumbnail = [savedFile thumbnailImage];
                }
            } else if (isDir) {
                savedFile.type = [NSNumber numberWithInt:FOLDER];
                if(large) {
                    thumbnail = [ACStaticIcons folderLargeIcon];
                } else {
                    thumbnail = [ACStaticIcons folderIcon];
                }
            } else {
                thumbnail = [ACStaticIcons unkownIcon];
            }
                
            if(![[savedFile managedObjectContext] save:&error]) {
                NSLog(@"Cannot save thumbnail %@, %@", error, [error userInfo]);
            }
        } else {
            thumbnail = [thumbnailDict valueForKey:file];
        }
        
        if(thumbnail != nil) {
            [thumbnails addObject:thumbnail];
        }
    }
  
    return thumbnails;
}

+ (void)createThumbnail:(NSString *)imagePath withContext:(NSManagedObjectContext *)localContext {
	NSString *expandedPath = [imagePath stringByDeletingLastPathComponent];
	NSString *tildePath = [expandedPath stringByAbbreviatingWithTildeInPath];
	NSString *filename = [imagePath lastPathComponent];

	NSEntityDescription *entity = [NSEntityDescription entityForName:@"File" inManagedObjectContext:localContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	[request setPredicate:[NSPredicate predicateWithFormat:@"(path == %@) AND (name == %@)", tildePath, filename]];
	
	NSError *error;
	NSArray *result = [localContext executeFetchRequest:request error:&error];

	File *savedFile;
	if([result count] == 0) {
		savedFile = [NSEntityDescription insertNewObjectForEntityForName:@"File" inManagedObjectContext:localContext];
		savedFile.name = filename;
		savedFile.path = tildePath;
		savedFile.fullPath = imagePath;
	} else {
        return;
	}
    
	BOOL isDir;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:imagePath isDirectory:&isDir] && !isDir) {
        [ACScaler extractThumbnailFrom:imagePath toFile:savedFile];
	} else if (isDir) {
		savedFile.type = [NSNumber numberWithInt:FOLDER];
	} else {
		savedFile.type = [NSNumber numberWithInt:UNKOWN]; 
    }
	
	if(![localContext save:&error]) {
		NSLog(@"Cannot save thumbnail %@, %@", error, [error userInfo]);
	}
}

+ (void)extractThumbnailFrom:(NSString*)imagePath toFile:(File*)savedFile {
    NSString *extension = [imagePath pathExtension];
    if([extension isEqualToString:@"mp4"] || [extension isEqualToString:@"m4v"] || [extension isEqualToString:@"mpg"] || [extension isEqualToString:@"mov"])  {
        [ACScaler extractMovieThumbnailAt:imagePath toFile:savedFile];
    } else {
        [ACScaler extractPictureThumbnailAt:imagePath toFile:savedFile];
    }
}

+ (void)extractMovieThumbnailAt:(NSString*)imagePath toFile:(File*)savedFile {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:imagePath] options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];

    CMTime requestedTime = CMTimeMakeWithSeconds(0.0, 600);
    NSError *outError = nil;
    CMTime actualTime;
    
    CGImageRef imageRef = [generator copyCGImageAtTime:requestedTime actualTime:&actualTime error:&outError];
    UIImage *imageToLoad = [[UIImage alloc] initWithCGImage:imageRef];
    if(imageToLoad == NULL ) {
        NSLog(@"Unable to capture a thumbnail %@",outError);
    } else {
        [ACScaler scaleThumbnails:imageToLoad toFile:savedFile];
    }
    
    if ([savedFile thumbnailImage] == nil) {
        NSLog(@"Cannot generate thumbnail from: %@",imagePath);
    } else {
        savedFile.type = [NSNumber numberWithInt:MOVIE];
    }
    CGImageRelease(imageRef);
}

+ (void)extractPictureThumbnailAt:(NSString*)imagePath toFile:(File*)savedFile {
    UIImage *imageToLoad = [UIImage imageWithContentsOfFile:imagePath];
    [ACScaler scaleThumbnails:imageToLoad toFile:savedFile];
    if ([savedFile thumbnailImage] == nil) {
        NSLog(@"Cannot generate thumbnail from: %@",imagePath);
    } else {
        savedFile.type = [NSNumber numberWithInt:IMAGE];
    }
}

+ (void)saveDbImage:(UIImage *)image atPath:(NSString *)imagePath withContext:(NSManagedObjectContext *)localContext {
	NSString *type;
	UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
	if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
		type = @"landscape";
	} else {
		type = @"portrait";
	}
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Image" inManagedObjectContext:localContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	[request setPredicate:[NSPredicate predicateWithFormat:@"path == %@ and type == %@", [imagePath stringByAbbreviatingWithTildeInPath], type]];
	
	NSError *error;
	NSArray *result = [localContext executeFetchRequest:request error:&error];
	
	Image *savedImage;
	if([result count] == 0) {
        savedImage = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:localContext];
        savedImage.path = [imagePath stringByAbbreviatingWithTildeInPath];
        savedImage.type = type;
	} else {
		savedImage = [result lastObject];
	}
    
    NSNumber *transformed = NULL;
    savedImage.image = [ACScaler scaleImage:image transformed:&transformed];
    savedImage.transformed = [NSNumber numberWithBool:YES];

    NSError *errSave;
    if(![[savedImage managedObjectContext] save:&errSave]) {
        NSLog(@"Cannot save image %@, %@", errSave, [errSave userInfo]);
    }
}

+ (UIImage *)loadDbImage:(NSString *)imagePath withContext:(NSManagedObjectContext *)localContext {
	CGFloat scale = [[ACGlobalInfos sharedInstance] scale];
	
	NSString *type;
	UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
	if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
		type = @"landscape";
	} else {
		type = @"portrait";
	}
    
	UIImage *image;
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Image" inManagedObjectContext:localContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	[request setPredicate:[NSPredicate predicateWithFormat:@"path == %@ and type == %@", [imagePath stringByAbbreviatingWithTildeInPath], type]];
	
	NSError *error;
	NSArray *result = [localContext executeFetchRequest:request error:&error];
	
	Image *savedImage;
	if([result count] == 0) {
		NSNumber *transformed = NULL;
		UIImage *imageToLoad = [UIImage imageWithContentsOfFile:imagePath];
		image = [ACScaler scaleImage:imageToLoad transformed:&transformed];
		if (image == nil) {
			NSLog(@"Problem");
		} else {
			savedImage = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:localContext];
			savedImage.path = [imagePath stringByAbbreviatingWithTildeInPath];
			savedImage.type = type;
			savedImage.transformed = transformed;
			if([transformed boolValue]) {
				savedImage.image = image;
			}
			
			NSError *errSave;
			if(![[savedImage managedObjectContext] save:&errSave]) {
				NSLog(@"Cannot save image %@, %@", errSave, [errSave userInfo]);
			}
		}
	} else {
		savedImage = [result lastObject];

		if([savedImage.transformed boolValue]) {
			image = [savedImage image];
		} else {
			image = [UIImage imageWithContentsOfFile:imagePath];
		}
		if (scale > 1.9) {
			CGImageRef tmpCGImage = [image CGImage];

			size_t outputWidth;
			size_t outputHeight;
			if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
				outputWidth = 480;
				outputHeight = 320;
			} else {
				outputWidth = 320;
				outputHeight = 480;
			}
				
			size_t width = CGImageGetWidth(tmpCGImage);
			size_t height = CGImageGetHeight(tmpCGImage);
			if(width <= outputWidth && height <= outputHeight) {
				image = [UIImage imageWithCGImage:tmpCGImage scale:1.0 orientation:UIImageOrientationUp];
			} else {
				image = [UIImage imageWithCGImage:tmpCGImage scale:scale orientation:UIImageOrientationUp];
			}
		}
	}
	
	return image;
}

+ (void)scaleThumbnails:(UIImage *) image toFile:(File *) imageFile {
	UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
	CGSize newSize = CGSizeMake(96.0, 96.0);
	NSNumber *transformed = NULL;
	UIImage *largeThumbnail = [ACScaler scaleImage:image toSize:newSize transformed:&transformed oriented:deviceOrientation preflipped:YES];
    [imageFile setThumbnailLargeImage:largeThumbnail];
    CGSize smallSize = CGSizeMake(32.0, 32.0);
	UIImage *thumbnail = [ACScaler scaleImage:largeThumbnail toSize:smallSize transformed:&transformed oriented:deviceOrientation preflipped:NO];
    [imageFile setThumbnailImage:thumbnail];
}

+ (UIImage *)scaleImage:(UIImage *) image transformed:(NSNumber **)transformed {
	UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
	CGSize newSize = CGSizeMake(320.0f, 480.0f);
	return [ACScaler scaleImage:image toSize:newSize transformed:transformed oriented:deviceOrientation preflipped:NO];
}
	
+ (UIImage *)scaleImage:(UIImage *) image toSize:(CGSize)newSize transformed:(NSNumber **)transformed 
	oriented:(UIDeviceOrientation)deviceOrientation preflipped:(BOOL)flip {

	CGFloat scale = [[ACGlobalInfos sharedInstance] scale];

	size_t outputWidth;
	size_t outputHeight;
	size_t scaledOutputWidth;
	size_t scaledOutputHeight;
	
	if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
		outputWidth = newSize.height;
		outputHeight = newSize.width;
		scaledOutputWidth = outputWidth * scale;
		scaledOutputHeight = outputHeight * scale;
	} else {
		outputWidth = newSize.width;
		outputHeight = newSize.height;
		scaledOutputWidth = outputWidth * scale;
		scaledOutputHeight = outputHeight * scale;
	}

	CGImageRef imgRef = [image CGImage];
	if (imgRef == nil) {
		return nil;
	}
	size_t width = CGImageGetWidth(imgRef);
	size_t height = CGImageGetHeight(imgRef);
	
	BOOL transposed = NO;
	switch (image.imageOrientation) {
		case UIImageOrientationLeft:
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRight:
		case UIImageOrientationRightMirrored: {
			size_t tzre = width;
			width = height;
			height = tzre;
			transposed = YES;
			break;
		}
		default:
			transposed = NO;
	}
 
	if (width <= scaledOutputWidth && height <= scaledOutputHeight) {
		if(scale < 1.9) {
			*transformed = [NSNumber numberWithBool:NO];
			return image;
		} else if(width <= outputWidth && height <= outputHeight) {
			*transformed = [NSNumber numberWithBool:NO];
			CGImageRef refImage = [image CGImage];
			return [UIImage imageWithCGImage:refImage scale:1.0 orientation:UIImageOrientationUp];
		} else {
			//for image beetwen 480x320 and 960x640 on retina, scale them with a sacle factor 
			//of 1.0 to fill the screen with a lower quality image
			scale = 1.0;
			scaledOutputWidth = outputWidth;
			scaledOutputHeight = outputHeight;
		}
	}
	*transformed = [NSNumber numberWithBool:YES];
	
	CGFloat ratio = (CGFloat)width / (CGFloat)height;
	CGFloat outputRatio = (CGFloat)scaledOutputWidth / (CGFloat)scaledOutputHeight;

	size_t scaledWidth;
	size_t scaledHeight;
	//scale to fit
	if(ratio > outputRatio) {
		scaledWidth = scaledOutputWidth;
		scaledHeight = (height * scaledOutputWidth) / width ;
	} else {
		scaledWidth = (width * scaledOutputHeight) / height;
		scaledHeight = scaledOutputHeight;
	}
		
	if(scaledWidth < 1) {
		scaledWidth = 1;
	}
	if(scaledHeight < 1) {
		scaledHeight = 1;
	}
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	size_t bitsPerComponent    = kImageMaxBPC;
	size_t rowBytes            = kImageMaxSPP * scaledWidth;
	
	CGContextRef context = CGBitmapContextCreate(NULL, scaledWidth, scaledHeight, bitsPerComponent, rowBytes, colorSpace, kCGImageAlphaNoneSkipFirst);

	CGSize scaledSize = CGSizeMake(scaledWidth, scaledHeight);
	CGAffineTransform transform = [ACScaler transformForOrientation:scaledSize of:image flip:flip];
	CGContextConcatCTM(context, transform);
	
	CGRect rect = CGRectIntegral(CGRectMake(0, 0, scaledWidth, scaledHeight));
	if(transposed) {
		rect = CGRectMake(0, 0, scaledHeight, scaledWidth);
	}
	
	CGContextDrawImage(context, rect, [image CGImage]);
	CGImageRef refNewImage = CGBitmapContextCreateImage(context);
	UIImage *newImage;
	if(scale < 1.9) {
	  newImage = [UIImage imageWithCGImage:refNewImage];
	} else {
		newImage = [UIImage imageWithCGImage:refNewImage scale:scale orientation:UIImageOrientationUp];
	}
		
	CGImageRelease(refNewImage);
	CGColorSpaceRelease(colorSpace);
	CGContextRelease(context);

	return newImage;
}

+ (CGAffineTransform)transformForOrientation:(CGSize)newSize of:(UIImage *)image flip:(BOOL)flip {
	CGAffineTransform transform = CGAffineTransformIdentity;
    
	switch (image.imageOrientation) {
		case UIImageOrientationDown:           // EXIF = 3
		case UIImageOrientationDownMirrored:   // EXIF = 4
			transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
            
		case UIImageOrientationLeft:           // EXIF = 6
		case UIImageOrientationLeftMirrored:   // EXIF = 5
			transform = CGAffineTransformTranslate(transform, newSize.width, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI_2);
			break;
            
		case UIImageOrientationRight:          // EXIF = 8
		case UIImageOrientationRightMirrored:  // EXIF = 7
			transform = CGAffineTransformTranslate(transform, 0.0, newSize.height);
			transform = CGAffineTransformRotate(transform, -M_PI_2);
			break;
            
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            //do nothing
            break;
	}
	
	if(flip) {
		switch (image.imageOrientation) {
			case UIImageOrientationUp:            // EXIF = 1
			case UIImageOrientationDown:          // EXIF = 3
				transform = CGAffineTransformTranslate(transform, 0.0, newSize.height);
				transform = CGAffineTransformScale(transform, 1.0, -1.0);
				break;
				
			case UIImageOrientationUpMirrored:    // EXIF = 2
			case UIImageOrientationDownMirrored:  // EXIF = 4
				transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
				transform = CGAffineTransformScale(transform, -1.0, -1.0);
				break;
			
			case UIImageOrientationLeftMirrored:  // EXIF = 5
			case UIImageOrientationRightMirrored: // EXIF = 7
				break;
				
			case UIImageOrientationLeft:          // EXIF = 6
			case UIImageOrientationRight:         // EXIF = 8
				transform = CGAffineTransformTranslate(transform, newSize.height, 0.0);
				transform = CGAffineTransformScale(transform, -1.0, 1.0);
				break;
		}
	} else {
		switch (image.imageOrientation) {
			case UIImageOrientationUpMirrored:     // EXIF = 2
			case UIImageOrientationDownMirrored:   // EXIF = 4
				transform = CGAffineTransformTranslate(transform, newSize.width, 0.0);
				transform = CGAffineTransformScale(transform, -1, 1);
				break;
            
			case UIImageOrientationLeftMirrored:   // EXIF = 5
			case UIImageOrientationRightMirrored:  // EXIF = 7
				transform = CGAffineTransformTranslate(transform, newSize.height, 0.0);
				transform = CGAffineTransformScale(transform, -1.0, 1.0);
				break;

            case UIImageOrientationUp:
            case UIImageOrientationDown:
            case UIImageOrientationLeft:
            case UIImageOrientationRight:
                //do nothing
                break;
		}
	}
	return transform;
}

@end
