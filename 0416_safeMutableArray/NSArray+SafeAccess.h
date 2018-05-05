//
//  NSArray+SafeAccess.h
//  Pods
//
//  Created by cs on 2016/8/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSArray (SafeAccess)
-(id)objectWithIndex:(NSUInteger)index;

- (NSString*)stringWithIndex:(NSUInteger)index;

- (NSNumber*)numberWithIndex:(NSUInteger)index;

- (NSDecimalNumber *)decimalNumberWithIndex:(NSUInteger)index;

- (NSArray*)arrayWithIndex:(NSUInteger)index;

- (NSDictionary*)dictionaryWithIndex:(NSUInteger)index;

- (NSInteger)integerWithIndex:(NSUInteger)index;

- (float)floatWithIndex:(NSUInteger)index;

- (NSDate *)dateWithIndex:(NSUInteger)index dateFormat:(NSString *)dateFormat;
//CG
- (CGFloat)CGFloatWithIndex:(NSUInteger)index;
/**
 Returns a reversed Array
 */
- (NSArray *)Reverse;

/**
 Applies the callback to the elements of the given arrays.
 
 @return an new array containing all the elements of receiver after applying the callback function to each one.
 */
- (NSArray *)map:(id (^)(id obj))block;
/**
 Converts receiver to json string. return nil if an error occurs.
 */
- (NSString *)jsonString;
@end


#pragma --mark NSMutableArray setter

@interface NSMutableArray(SafeAccess)

-(void)addObj:(id)i;

-(void)addString:(NSString*)i;

-(void)addBool:(BOOL)i;

-(void)addInt:(int)i;

-(void)addInteger:(NSInteger)i;

-(void)addCGFloat:(CGFloat)f;

@end
