//
//  JLPageControl.m
//  JLCycleScrollView
//
//  Created by yangjianliang on 2017/9/24.
//  Copyright © 2017年 yangjianliang. All rights reserved.
//

#import "JLPageControl.h"

@implementation JLPageControl

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initData];
    }
    return self;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initData];
    }
    return self;
}
-(void)initData
{
    _jl_MinimumSize = CGSizeZero;
    _jl_norDotSize = CGSizeMake(7, 7);
    _jl_selDotSize = CGSizeMake(7, 7);
    _jl_norMagrin = 9.f;
    _jl_selMagrin = 9.f;
    _jl_norDotCornerRadius = 3.5;
    _jl_selDotCornerRadius = 3.5;
    _jl_norImage = nil;
    _jl_selImage= nil;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.allowChangeFrame) {
        [self layoutSubPages];
    }
}
-(void)setCurrentPage:(NSInteger)currentPage
{
    [super setCurrentPage:currentPage];
    if (self.allowChangeFrame) {
        [self layoutSubPages];
    }
}
-(void)setAllowChangeFrame:(BOOL)allowChangeFrame
{
    _allowChangeFrame = allowChangeFrame;
    if (!_allowChangeFrame) {
        [self initData];
    }
    [self layoutSubPages];
}
#pragma mark 利用遍历子控件修改每一个Page的size及Page之间间隙
-(void)layoutSubPages
{
    CGFloat X = 0.f;
    CGFloat H = _jl_selDotSize.height>_jl_norDotSize.height?_jl_selDotSize.height:_jl_norDotSize.height;
    CGFloat min_Y = ABS(_jl_selDotSize.height-_jl_norDotSize.height)/2.f;
    if (self.numberOfPages != [self.subviews count]) {
        self.allowChangeFrame = NO;
        return;
    }
    for (int i=0; i<[self.subviews count]; i++) {
        UIView* dot = [self.subviews objectAtIndex:i];
        dot.layer.masksToBounds = YES;
        if (i == self.currentPage-1) {
            CGFloat Y = _jl_selDotSize.height>_jl_norDotSize.height?min_Y:0;
            [dot setFrame:CGRectMake(X , Y, _jl_norDotSize.width, _jl_norDotSize.height)];
            X+=_jl_norDotSize.width+_jl_selMagrin;
            if (self.jl_norImage) {
                dot.layer.contents = (id)self.jl_norImage.CGImage;
                dot.backgroundColor = [UIColor clearColor];
            }else{
                dot.layer.contents = nil;
                dot.backgroundColor = self.pageIndicatorTintColor;
            }
            dot.layer.cornerRadius = self.jl_norDotCornerRadius;
        }else if (i == self.currentPage) {
            CGFloat Y = _jl_selDotSize.height>_jl_norDotSize.height?0:min_Y;
            [dot setFrame:CGRectMake(X , Y, _jl_selDotSize.width,_jl_selDotSize.height)];
            if (i==[self.subviews count]-1) {
                X+=_jl_selDotSize.width;
            }else{
                X+=_jl_selDotSize.width+_jl_selMagrin;
            }
            if (self.jl_selImage) {
                dot.layer.contents = (id)self.jl_selImage.CGImage;
                dot.backgroundColor = [UIColor clearColor];
            }else{
                dot.layer.contents = nil;
                dot.backgroundColor = self.currentPageIndicatorTintColor;
            }
            dot.layer.cornerRadius = self.jl_selDotCornerRadius;
        }else {
            CGFloat Y = _jl_selDotSize.height>_jl_norDotSize.height?min_Y:0;
            [dot setFrame:CGRectMake(X , Y, _jl_norDotSize.width, _jl_norDotSize.height)];
            if (i==[self.subviews count]-1) {
                X+=_jl_norDotSize.width;
            }else{
                X+=_jl_norDotSize.width+_jl_norMagrin;
            }
            if (self.jl_norImage) {
                dot.layer.contents = (id)self.jl_norImage.CGImage;
                dot.backgroundColor = [UIColor clearColor];
            }else{
                dot.layer.contents = nil;
                dot.backgroundColor = self.pageIndicatorTintColor;
            }
            dot.layer.cornerRadius = self.jl_norDotCornerRadius;
        }
    }
    self.frame = CGRectMake(self.jl_x, self.jl_y, X, H);
    _jl_MinimumSize = CGSizeMake(X, H);
}
-(CGSize)sizeForNumberOfPages:(NSInteger)pageCount
{
    if (self.allowChangeFrame) {
        return _jl_MinimumSize;
    }
    return [super sizeForNumberOfPages:pageCount];
}
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

