//
//  BGSafeMutableArray.m
//  0416_safeMutableArray
//
//  Created by cs on 2018/4/16.
//  Copyright © 2018年 cs. All rights reserved.
//

#import "BGSafeMutableArray.h"

@interface BGSafeMutableArray() {
    CFMutableArrayRef _array;
}

@end

@implementation BGSafeMutableArray

- (id)init {
    self = [super init];
    if (self) {
        _array = CFArrayCreateMutable(kCFAllocatorDefault, 10,  &kCFTypeArrayCallBacks);
    }
    return self;
}

// 获取可变数组数量
- (NSUInteger)count {
    __block NSUInteger result;
    dispatch_sync(self.syncQueue, ^{
        result = CFArrayGetCount(_array);
    });
    return result;
}

// 获取第N个位置的对象
- (id)objectAtIndex:(NSUInteger)index {
    __block id result;
    dispatch_sync(self.syncQueue, ^{
        NSUInteger count = CFArrayGetCount(_array);
        result = index < count ? CFArrayGetValueAtIndex(_array, index) : nil;
    });
    return result;
}

// 插入对象至指定位置
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    __block NSUInteger blockIndex = index;
    dispatch_barrier_async(self.syncQueue, ^{
        if (!anObject) {
            return;
        }
        
        NSUInteger count = CFArrayGetCount(_array);
        blockIndex = blockIndex > count ? count : blockIndex;
        
        CFArrayInsertValueAtIndex(_array, index, (__bridge const void *)anObject);
    });
}

// 删除指定位置上的对象
- (void)removeObjectAtIndex:(NSUInteger)index {
    dispatch_barrier_async(self.syncQueue, ^{
        NSUInteger count = CFArrayGetCount(_array);
        if (index < count) {
            CFArrayRemoveValueAtIndex(_array, index);
        }
    });
}

// 添加对象
- (void)addObject:(id)anObject {
    dispatch_barrier_async(self.syncQueue, ^{
        if (!anObject) {
            return;
        }
        CFArrayAppendValue(_array, (__bridge const void *)anObject);
    });
}

// 删除最后一个对象
- (void)removeLastObject {
    dispatch_barrier_async(self.syncQueue, ^{
        NSUInteger count = CFArrayGetCount(_array);
        if (count > 0) {
            CFArrayRemoveValueAtIndex(_array, count-1);
        }
    });
}

// 替换指定位置的对象
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    dispatch_barrier_async(self.syncQueue, ^{
        if (!anObject) {
            return;
        }
        
        NSUInteger count = CFArrayGetCount(_array);
        if (index >= count) {
            return;
        }
        
        CFArraySetValueAtIndex(_array, index, (__bridge const void*)anObject);
    });
}

#pragma mark - options
// 移除所有对象
- (void)removeAllObjects {
    dispatch_barrier_async(self.syncQueue, ^{
        CFArrayRemoveAllValues(_array);
    });
}

// 获取某一个对象的索引位置
- (NSUInteger)indexOfObject:(id)anObject {
    if (!anObject) {
        return NSNotFound;
    }
    
    __block NSUInteger result;
    dispatch_sync(self.syncQueue, ^{
        NSUInteger count = CFArrayGetCount(_array);
        result = CFArrayGetFirstIndexOfValue(_array, CFRangeMake(0, count), (__bridge const void *)(anObject));
    });
    return result;
}

- (dispatch_queue_t)syncQueue {
    static dispatch_queue_t queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.kong.NSKSafeMutableArray", DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}

@end
