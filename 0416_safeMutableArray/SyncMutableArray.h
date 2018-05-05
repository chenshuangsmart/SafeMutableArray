//
//  SyncMutableArray.h
//  banggood
//
//  Created by cs on 2016/10/16.
//

#import <Foundation/Foundation.h>

@interface SyncMutableArray : NSObject

- (void)addObject:(id)anObject;

- (void)addObjectsFromArray:(NSArray *)anArray;

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;

- (id)popFirstObject;

- (id)firstObject;

- (id)lastObject;

- (id)popLastObject;

- (void)removeLastObject;

- (void)removeObjectAtIndex:(NSUInteger)index;

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes;

- (void)removeObject:(id)anObject;

- (void)removeAllObjects;

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

- (NSInteger)count;

- (BOOL)containsObject:(id)anObject;

- (id)objectAtIndex:(NSUInteger)index;

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;

- (NSMutableArray *)getArray;

@end
