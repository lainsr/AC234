//
//  SFHFKeychainUtils.h
//  AC234
//
//  Created by Stéphane Rossé on 24.09.12.
//
//

#import <Foundation/Foundation.h>

@interface SFHFKeychainUtils : NSObject {


}

+ (NSString *) getPasswordForUsername: (NSString *) username andServiceName: (NSString *) serviceName error: (NSError **) error;
+ (BOOL) storeUsername: (NSString *) username andPassword: (NSString *) password forServiceName: (NSString *) serviceName updateExisting: (BOOL) updateExisting error: (NSError **) error;
+ (BOOL) deleteItemForUsername: (NSString *) username andServiceName: (NSString *) serviceName error: (NSError **) error;

@end
