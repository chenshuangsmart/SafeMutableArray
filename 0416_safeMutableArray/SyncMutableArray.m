//
//  SyncMutableArray.m
//  banggood
//
//  Created by cs on 2016/10/16.
//

#import "SyncMutableArray.h"
#import "NSArray+SafeAccess.h"

@interface SyncMutableArray ()
@property(nonatomic, strong) NSMutableArray *array;
@property(nonatomic, strong) dispatch_queue_t dispatchQueue;
@end

@implementation SyncMutableArray
- (instancetype)init {
    if (self = [super init]) {
        _array = [NSMutableArray new];
        _dispatchQueue = dispatch_queue_create("com.wenwenSycmutableArray", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)addObject:(id)anObject {
    dispatch_sync(_dispatchQueue, ^{
        if (!anObject) return;
        [_array addObject:anObject];
    });
}

- (void)addObjectsFromArray:(id)anArray {
    dispatch_sync(_dispatchQueue, ^{
        if (!anArray) return;
        [_array addObjectsFromArray:anArray];
    });
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    dispatch_sync(_dispatchQueue, ^{
        if (!anObject) return;
        [_array insertObject:anObject atIndex:index];
    });
}

- (id)popLastObject {
    __block id object;
    dispatch_sync(_dispatchQueue, ^{
        object = [_array lastObject];
        [_array removeLastObject];
    });
    return object;
}

- (void)removeLastObject {
    dispatch_sync(_dispatchQueue, ^{
        [_array removeLastObject];
    });
}

- (id)popFirstObject {
    __block id object;
    dispatch_sync(_dispatchQueue, ^{
        object = [_array firstObject];
        [_array removeLastObject];
    });
    return object;
}

- (id)firstObject {
    __block id object;
    dispatch_sync(_dispatchQueue, ^{
        object = [_array firstObject];
    });
    return object;
}

- (id)lastObject {
    __block id object;
    dispatch_sync(_dispatchQueue, ^{
        object = [_array lastObject];
    });
    return object;
}

- (void)removeAllObjects {
    dispatch_sync(_dispatchQueue, ^{
        [_array removeAllObjects];
    });
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    dispatch_sync(_dispatchQueue, ^{
        [_array removeObjectAtIndex:index];
    });
}

- (void)removeObject:(id)anObject {
    dispatch_sync(_dispatchQueue, ^{
        if (!anObject) return;
        [_array removeObject:anObject];
    });
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    dispatch_sync(_dispatchQueue, ^{
        if (!anObject) return;
        _array[index] = anObject;
    });
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
    dispatch_sync(_dispatchQueue, ^{
        [_array removeObjectsAtIndexes:indexes];
    });
}

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    dispatch_sync(_dispatchQueue, ^{
        [_array enumerateObjectsUsingBlock:block];
    });
}


- (NSMutableArray *)getArray {
    __block NSMutableArray *temp;
    dispatch_sync(_dispatchQueue, ^{
        temp = _array;
    });
    return temp;
}


- (NSInteger)count {
    __block NSInteger returnObject = 0;
    dispatch_sync(_dispatchQueue, ^{
        returnObject = _array.count;
    });
    return returnObject;
}

- (BOOL)containsObject:(id)anObject {
    __block BOOL returnObject = NO;
    dispatch_sync(_dispatchQueue, ^{
        if (!anObject || ![_array isKindOfClass:[NSMutableArray class]]) return;
        returnObject = [_array containsObject:anObject];
    });
    return returnObject;
}

- (id)objectAtIndex:(NSUInteger)index {
    __block id returnObject = nil;
    dispatch_sync(_dispatchQueue, ^{
        if (_array.count > 0) {
            returnObject = [_array objectWithIndex:index];
        } else {
            returnObject = nil;
        }
    });
    return returnObject;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@", _array];
}

@end
