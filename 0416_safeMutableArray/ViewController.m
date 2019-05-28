//
//  ViewController.m
//  0416_safeMutableArray
//
//  Created by cs on 2018/4/16.
//  Copyright © 2018年 cs. All rights reserved.
//

#import "ViewController.h"
#import "SyncMutableArray.h"
#import "BGSafeMutableArray.h"
//#import "NSMutableArray+SafeAccess.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [self bgSafeMutableArray];
//    [self syncMutableArray];
    [self syncMutableArrayAdd];
}

- (void)bgSafeMutableArray {
    NSDate *startDate = [[NSDate alloc] init];
    BGSafeMutableArray *safeArr = [[BGSafeMutableArray alloc] init];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for ( int i = 0; i < 1000; i ++) {
        dispatch_async(queue, ^{
            NSLog(@"添加第%d个",i);
            [safeArr addObject:[NSString stringWithFormat:@"%d",i]];
        });
        
        dispatch_async(queue, ^{
            NSLog(@"删除第%d个",i);
            [safeArr removeObjectAtIndex:i];
        });
        
        dispatch_async(queue, ^{
            NSLog(@"读取第%d个数据:%@",i,[safeArr objectAtIndex:i]);
        });
    }
    
    NSDate *endDate = [[NSDate alloc] init];
    double time = [endDate timeIntervalSince1970] - [startDate timeIntervalSince1970];
    NSLog(@"执行时间:%f",time);
}

- (void)syncMutableArray {
    NSDate *startDate = [[NSDate alloc] init];
    SyncMutableArray *safeArr = [[SyncMutableArray alloc] init];
    for ( int i = 0; i < 1000; i ++) {
        NSLog(@"添加第%d个",i);
        [safeArr addObject:[NSString stringWithFormat:@"%d",i]];
        
        NSLog(@"删除第%d个",i);
        [safeArr removeObjectAtIndex:i];
    }
    
    NSDate *endDate = [[NSDate alloc] init];
    double time = [endDate timeIntervalSince1970] - [startDate timeIntervalSince1970];
    NSLog(@"执行时间:%f",time);
}

- (void)syncMutableArrayAdd {
    NSMutableArray *safeArr = [[NSMutableArray alloc] init];
    NSString *str = @"123";
    [safeArr addObject:str];//只做一个简单的插入nil测试，发现safeAddObject 方法调用了900多次
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
