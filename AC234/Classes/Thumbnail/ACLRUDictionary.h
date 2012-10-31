//
//  ACLRUDictionary.h
//  AC234
//
//  Created by Stéphane Rossé on 14.01.11.
//  Copyright 2011 Cyberiacafe. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ACLRUDictionary : NSObject {

    NSMutableArray *lruArray;
    NSMutableArray *classicArray;
    NSMutableDictionary *mainDictionary;
    NSMutableDictionary *reservationArray;
    NSUInteger maxEntries;
    
}

-(id)initWithCapacity:(NSUInteger)numItems;

-(NSUInteger)count;

-(NSUInteger)indexOfObject:(id)aKey;

-(BOOL)reserved:(id)aKey;

-(void)reservationForKey:(id)aKey;

-(void)cancelReservationForKey:(id)aKey;

-(id)objectForKey:(id)aKey;

-(id)lastObject;

-(void)setObject:(id)anObject forKey:(id)aKey;

-(void)removeObjectForKey:(id)aKey;

-(void)removeAllObjects;

-(void)relax;

@end
