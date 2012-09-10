//
//  FileInfo.h
//  AC234
//
//  Created by Stéphane Rossé on 11.10.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//



@interface ACFileInfo : NSObject {
		NSString *filename;
		NSString *fullPath;
}

@property (nonatomic, copy) NSString *filename;
@property (nonatomic, copy) NSString *fullPath;

- (id)initWithFilename:(NSString *)_filename atFullPath:(NSString *)_fullPath;

@end
