//
//  JLCycScrollFlowLayout.m
//  JLCycleScrollView
//
//  Created by 杨建亮 on 2018/4/6.
//  Copyright © 2018年 yangjianliang. All rights reserved.
//

#import "JLCycScrollFlowLayout.h"

NSNotificationName const JLCycScrollFlowLayoutPrepareLayout = @"JLCycScrollFlowLayoutPrepareLayout";
@implementation JLCycScrollFlowLayout
- (void)prepareLayout{

    [super prepareLayout];
    NSLog(@"初始化好了prepareLayout");
    [[NSNotificationCenter defaultCenter] postNotificationName:JLCycScrollFlowLayoutPrepareLayout object:self];

}
@end
