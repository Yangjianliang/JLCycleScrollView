//
//  NSObject+JLExtension.m
//  JLCycleScrollView
//
//  Created by 杨建亮 on 2018/4/6.
//  Copyright © 2018年 yangjianliang. All rights reserved.
//

#import "NSObject+JLExtension.h"

NSNotificationName const JLCycScrollFlowLayoutPrepareLayout = @"JLCycScrollFlowLayoutPrepareLayout";
@implementation NSObject (JLExtension)

@end


@implementation UIView (JLFrame)
-(CGFloat)jl_centerY
{
    return self.center.y;
}
-(void)setJl_centerY:(CGFloat)jl_centerY
{
    CGPoint center = self.center;
    center.y = jl_centerY;
    self.center = center;
}
-(CGFloat)jl_centerX
{
    return self.center.x;
}
-(void)setJl_centerX:(CGFloat)jl_centerX
{
    CGPoint center = self.center;
    center.x = jl_centerX;
    self.center = center;
}
- (CGFloat)jl_height
{
    return self.frame.size.height;
}
- (void)setJl_height:(CGFloat)jl_height
{
    CGRect temp = self.frame;
    temp.size.height = jl_height;
    self.frame = temp;
}
- (CGFloat)jl_width
{
    return self.frame.size.width;
}
- (void)setJl_width:(CGFloat)jl_width
{
    CGRect temp = self.frame;
    temp.size.width = jl_width;
    self.frame = temp;
}
- (CGFloat)jl_y
{
    return self.frame.origin.y;
}

- (void)setJl_y:(CGFloat)jl_y
{
    CGRect temp = self.frame;
    temp.origin.y = jl_y;
    self.frame = temp;
}
- (CGFloat)jl_x
{
    return self.frame.origin.x;
}

- (void)setJl_x:(CGFloat)jl_x
{
    CGRect temp = self.frame;
    temp.origin.x = jl_x;
    self.frame = temp;
}
@end

