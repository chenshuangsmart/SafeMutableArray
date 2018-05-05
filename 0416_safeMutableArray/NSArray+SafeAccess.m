//
//  NSArray+SafeAccess.m
//  Pods
//
//  Created by cs on 2016/8/14.
//
//

#import "NSArray+SafeAccess.h"
#import <objc/runtime.h>

@implementation NSArray (SafeAccess)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 1 添加空对象
        SEL safeAdd = @selector(GFS_safeAddObject:);
        SEL unsafeAdd = @selector(addObject:);
        
        Method originalSEL = class_getInstanceMethod(objc_getClass("__NSArrayM"), unsafeAdd);
        Method swizzleSEL = class_getInstanceMethod(objc_getClass("__NSArrayM"), safeAdd);
        
        BOOL didAddMethod = class_addMethod(self, unsafeAdd, method_getImplementation(swizzleSEL), method_getTypeEncoding(swizzleSEL));
        
        if (didAddMethod) {
            class_replaceMethod(self, safeAdd, method_getImplementation(originalSEL), method_getTypeEncoding(originalSEL));
        }else{
            method_exchangeImplementations(originalSEL, swizzleSEL);
        }
        
        // 2 数组越界
        SEL safeObjcAtIndex = @selector(cs_safeObjcAtIndex:);
        SEL unsafeObjcAtIndex = @selector(objectAtIndex:);
        
        Class arryClass = NSClassFromString(@"__NSArrayI");
        Method originalObjcAtIndex = class_getInstanceMethod(arryClass, unsafeObjcAtIndex);
        Method swizzleObjcAtIndex = class_getInstanceMethod(arryClass, safeObjcAtIndex);
        method_exchangeImplementations(originalObjcAtIndex, swizzleObjcAtIndex);
    });
}

- (id)cs_safeObjcAtIndex:(NSUInteger)index{
    if (self.count - 1 < index) {
        NSAssert(NO, @"beyond the boundary");
        return nil;
    }else{
        return [self cs_safeObjcAtIndex:index];
    }
}

- (void)GFS_safeAddObject:(id)object{
    if (!object) {// objectt == nil
        NSAssert(NO, @"added a nil object");
    }else{
        [self GFS_safeAddObject:object];
    }
}

-(id)objectWithIndex:(NSUInteger)index{
    if (index >= [self count]) {
        return nil;
    }
    id value = self[(NSUInteger) index];
    if (value == [NSNull null]) {
        return nil;
    }
    return value;
}

- (NSString*)stringWithIndex:(NSUInteger)index{
    id value = [self objectWithIndex:index];
    if (value == nil || value == [NSNull null]){
        return @"";
    }
    if ([value isKindOfClass:[NSString class]]) {
        return (NSString*)value;
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value stringValue];
    }
    return nil;
}


- (NSNumber*)numberWithIndex:(NSUInteger)index{
    id value = [self objectWithIndex:index];
    if ([value isKindOfClass:[NSNumber class]]) {
        return (NSNumber*)value;
    }
    if ([value isKindOfClass:[NSString class]]) {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        return [f numberFromString:(NSString*)value];
    }
    return nil;
}

- (NSDecimalNumber *)decimalNumberWithIndex:(NSUInteger)index{
    id value = [self objectWithIndex:index];
    
    if ([value isKindOfClass:[NSDecimalNumber class]]) {
        return value;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber * number = (NSNumber*)value;
        return [NSDecimalNumber decimalNumberWithDecimal:[number decimalValue]];
    } else if ([value isKindOfClass:[NSString class]]) {
        NSString * str = (NSString*)value;
        return [str isEqualToString:@""] ? nil : [NSDecimalNumber decimalNumberWithString:str];
    }
    return nil;
}

- (NSArray*)arrayWithIndex:(NSUInteger)index{
    id value = [self objectWithIndex:index];
    if (value == nil || value == [NSNull null]){
        return nil;
    }
    if ([value isKindOfClass:[NSArray class]]){
        return value;
    }
    return nil;
}

- (NSDictionary*)dictionaryWithIndex:(NSUInteger)index{
    id value = [self objectWithIndex:index];
    if (value == nil || value == [NSNull null]){
        return nil;
    }
    if ([value isKindOfClass:[NSDictionary class]]){
        return value;
    }
    return nil;
}

- (NSInteger)integerWithIndex:(NSUInteger)index{
    id value = [self objectWithIndex:index];
    if (value == nil || value == [NSNull null]){
        return 0;
    }
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]){
        return [value integerValue];
    }
    return 0;
}

- (float)floatWithIndex:(NSUInteger)index{
    id value = [self objectWithIndex:index];
    
    if (value == nil || value == [NSNull null]){
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]){
        return [value floatValue];
    }
    return 0;
}

- (NSDate *)dateWithIndex:(NSUInteger)index dateFormat:(NSString *)dateFormat {
    NSDateFormatter *formater = [[NSDateFormatter alloc]init];
    formater.dateFormat = dateFormat;
    id value = [self objectWithIndex:index];
    
    if (value == nil || value == [NSNull null]){
        return nil;
    }
    
    if ([value isKindOfClass:[NSString class]] && ![value isEqualToString:@""] && !dateFormat) {
        return [formater dateFromString:value];
    }
    return nil;
}

- (CGFloat)CGFloatWithIndex:(NSUInteger)index{
    id value = [self objectWithIndex:index];
    
    CGFloat f = [value doubleValue];
    return f;
}

- (NSArray *)Reverse{
    return self.reverseObjectEnumerator.allObjects;
}

- (NSArray *)map:(id  _Nonnull (^)(id _Nonnull))block{
    __block NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [array addObject:block(obj)];
    }];
    return array;
}

- (NSString *)jsonString{
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return json;
    }
    return nil;
}

@end


#pragma --mark NSMutableArray setter
@implementation NSMutableArray (SafeAccess)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        id obj = [[self alloc] init];
        [obj swizzleMethod:@selector(addObject:) withMethod:@selector(safeAddObject:)];
        [obj swizzleMethod:@selector(objectAtIndex:) withMethod:@selector(safeObjectAtIndex:)];
        [obj swizzleMethod:@selector(removeObjectAtIndex:) withMethod:@selector(safeRemoveObjectAtIndex:)];
        [obj swizzleMethod:@selector(replaceObjectAtIndex:withObject:) withMethod:@selector(safeReplaceObjectAtIndex:withObject:)];
        [obj swizzleMethod:@selector(removeObjectsInRange:) withMethod:@selector(safeRemoveObjectsInRange:)];
        [obj swizzleMethod:@selector(insertObject:atIndex:) withMethod:@selector(safeInsertObject:atIndex:)];
    });
}

- (id)safeObjectAtIndex:(NSUInteger)index
{
    if (index >= self.count)
    {
        return nil;
    }
    return [self safeObjectAtIndex:index];
}

- (void)safeAddObject:(id)anObject
{
    if (!anObject)
    {
        return;
    }
    [self safeAddObject:anObject];
}

- (void)safeRemoveObjectAtIndex:(NSUInteger)index
{
    if (index >= [self count]) {
        return;
    }
    
    return [self safeRemoveObjectAtIndex:index];
}

- (void)safeReplaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    if (index >= [self count])
    {
        return;
    }
    
    if (!anObject)
    {
        return;
    }
    
    [self safeReplaceObjectAtIndex:index withObject:anObject];
}

- (void)safeRemoveObjectsInRange:(NSRange)range
{
    if (range.location > self.count)
    {
        return;
    }
    
    if (range.length > self.count)
    {
        return;
    }
    
    if ((range.location + range.length) > self.count)
    {
        return;
    }
    
    return [self safeRemoveObjectsInRange:range];
}

- (void)safeInsertObject:(id)anObject atIndex:(NSUInteger)index
{
    if (index > self.count)
    {
        return;
    }
    
    if (!anObject)
    {
        return;
    }
    
    [self safeInsertObject:anObject atIndex:index];
}

-(void)addObj:(id)i{
    if ( i!= nil) {
        [self addObject:i];
    }
}

-(void)addString:(NSString*)i{
    if (i != nil) {
        [self addObject:i];
    }
}

-(void)addBool:(BOOL)i{
    [self addObject:@(i)];
}

-(void)addInt:(int)i{
    [self addObject:@(i)];
}

-(void)addInteger:(NSInteger)i{
    [self addObject:@(i)];
}

-(void)addCGFloat:(CGFloat)f{
    [self addObject:@(f)];
}

- (void)swizzleMethod:(SEL)origSelector withMethod:(SEL)newSelector
{
    Class cls = [self class];
    
    Method originalMethod = class_getInstanceMethod(cls, origSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, newSelector);
    
    BOOL didAddMethod = class_addMethod(cls,
                                        origSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(cls,
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}


@end
