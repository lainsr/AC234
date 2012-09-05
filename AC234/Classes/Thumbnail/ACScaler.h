//
//  Scaler.h
//  AC234
//
//  Created by Stéphane Rossé on 20.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "File.h"

@interface ACScaler : NSObject {

}

+ (void)extractThumbnailFrom:(NSString*)imagePath toFile:(File*)savedFile;
+ (void)extractMovieThumbnailAt:(NSString*)imagePath toFile:(File*)savedFile;
+ (void)extractPictureThumbnailAt:(NSString*)imagePath toFile:(File*)savedFile;

+ (void)createThumbnail:(NSString *)imagePath withContext:(NSManagedObjectContext *)localContext;
+ (void)scaleThumbnails:(UIImage *)image toFile:(File *)imageFile;

+ (UIImage *)loadDbImage:(NSString *)imagePath withContext:(NSManagedObjectContext *)localContext;
+ (void)saveDbImage:(UIImage *)image atPath:(NSString *)imagePath withContext:(NSManagedObjectContext *)localContext;

+ (UIImage *)scaleImage:(UIImage *) image transformed:(NSNumber **)transformed;
+ (UIImage *)scaleImage:(UIImage *) image toSize:(CGSize)newSize transformed:(NSNumber **)transformed oriented:(UIDeviceOrientation)deviceOrientation preflipped:(BOOL)flip;

+ (CGAffineTransform)transformForOrientation:(CGSize)newSize of:(UIImage *)image flip:(BOOL)flip;

@end
