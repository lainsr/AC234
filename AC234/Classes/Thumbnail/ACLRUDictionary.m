//
//  ACLRUDictionary.m
//  AC234
//
//  Created by Stéphane Rossé on 14.01.11.
//  Copyright 2011 Cyberiacafe. All rights reserved.
//

#import "ACLRUDictionary.h"


@interface ACLRUDictionary (Private)
 
-(void)relax;
-(void)addLruCache:(id)aKey;
 
@end

@implementation ACLRUDictionary

- (id)initWithCapacity:(NSUInteger)numItems {
	self = [super init];
    if(self) {
		maxEntries = 100;
		lruArray = [[NSMutableArray alloc] initWithCapacity:maxEntries];
		classicArray = [[NSMutableArray alloc] initWithCapacity:maxEntries];
		reservationArray = [[NSMutableDictionary alloc] initWithCapacity:maxEntries];
		mainDictionary = [[NSMutableDictionary alloc] initWithCapacity:maxEntries];
		return self;
	}
	return nil;
}

- (NSUInteger)count {
	return [classicArray count];
}

-(NSUInteger)indexOfObject:(id)aKey {
	@synchronized(self) {
		return [lruArray indexOfObject:aKey];
	}
}

-(void)reservationForKey:(id)aKey {
	@synchronized(self) {
		[reservationArray setObject:aKey forKey:aKey];
	}
}

-(BOOL)reserved:(id)aKey {
	@synchronized(self) {
		return [reservationArray objectForKey:aKey] != nil;
	}
}

-(void)cancelReservationForKey:(id)aKey {
	@synchronized(self) {
		[reservationArray removeObjectForKey:aKey];
	}
}

- (id)objectForKey:(id)aKey {
	@synchronized(self) {
		[self addLruCache:aKey];
		return [mainDictionary objectForKey:aKey];
	}
}

- (id)containsObjectForKey:(id)aKey {
	@synchronized(self) {
		[self addLruCache:aKey];
		return [mainDictionary objectForKey:aKey];
	}
}

- (void)setObject:(id)anObject forKey:(id)aKey {
	@synchronized(self) {
		[self addLruCache:aKey];
		[mainDictionary setObject:anObject forKey:aKey];
	}
}

- (id)lastObject {
    if([lruArray count] > 0) {
        return [lruArray objectAtIndex:[lruArray count] - 1];
    }
    return nil;
}

- (void)addLruCache:(id)aKey {
	@synchronized(self) {
		[lruArray removeObject:aKey];
		[lruArray insertObject:aKey atIndex:0];
		[classicArray removeObject:aKey];
		[classicArray addObject:aKey];
	
		while ([lruArray count] > maxEntries) {
			[lruArray removeLastObject];
		}
	}
}

- (void)removeObjectForKey:(id)aKey {
	@synchronized(self) {
		[classicArray removeObject:aKey];
	}
}

- (void)removeAllObjects {
	@synchronized(self) {
		[lruArray removeAllObjects];
		[classicArray removeAllObjects];
		[mainDictionary removeAllObjects];
	}
}

-(void)relax {
	NSMutableArray *keyToRemove = [NSMutableArray arrayWithCapacity:20];
	@synchronized(self) {
		NSArray *keys = [mainDictionary allKeys]; 
		for(id aKey in keys){
			if(![lruArray containsObject:aKey] && [reservationArray objectForKey:aKey] == nil) {
				[keyToRemove addObject:aKey];
			}
		}
	
		for(id aKey in keyToRemove){
			[classicArray removeObject:aKey];
			[mainDictionary removeObjectForKey:aKey];
		}
	}
}

@end
