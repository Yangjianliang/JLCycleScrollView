//
//  JLPageControl.m
//  JLCycleScrollView
//
//  Created by yangjianliang on 2017/9/24.
//  Copyright © 2017年 yangjianliang. All rights reserved.
//

#import "JLPageControl.h"
#import "UIView+JLExtension.h"
@implementation JLPageControl

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initDefaultData];
    }
    return self;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initDefaultData];
    }
    return self;
}

-(void)initDefaultData
{
    _minimumSize = CGSizeZero;
    _pageIndicatorSize = CGSizeMake(7, 7);
    _currentPageIndicatorSize = CGSizeMake(7, 7);
    _pageIndicatorSpacing = 9.f;
    _currentPageIndicatorSpacing = 9.f;
    _pageIndicatorRadius = 3.5f;
    _currentPageIndicatorRadius = 3.5f;
    _pageIndicatorImage = nil;
    _currentPageIndicatorImage= nil;
    _pageIndicatorAnimated = NO;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.allowUpdatePageIndicator) {
        [self layoutSubPages];
    }
}
-(void)setCurrentPage:(NSInteger)currentPage
{
    [super setCurrentPage:currentPage];
    if (self.allowUpdatePageIndicator) {
        [self layoutSubPages];
    }
}
-(void)setAllowUpdatePageIndicator:(BOOL)allowUpdatePageIndicator
{
    _allowUpdatePageIndicator = allowUpdatePageIndicator;
    if (!_allowUpdatePageIndicator) {
        [self initDefaultData];
    }
    [self layoutSubPages];
}
#pragma mark 利用遍历子控件修改每一个Page的size及Page之间间隙
-(void)layoutSubPages
{
    CGFloat X = 0.f;
    CGFloat H = _currentPageIndicatorSize.height>_pageIndicatorSize.height?_currentPageIndicatorSize.height:_pageIndicatorSize.height;
    CGFloat min_Y = ABS(_currentPageIndicatorSize.height-_pageIndicatorSize.height)/2.f;
    if (self.numberOfPages != [self.subviews count]) {
        self.allowUpdatePageIndicator = NO;
        return;
    }
    for (int i=0; i<[self.subviews count]; i++) {
        UIView* dot = [self.subviews objectAtIndex:i];
        dot.layer.masksToBounds = YES;
        if (i == self.currentPage-1) {
            CGFloat Y = _currentPageIndicatorSize.height>_pageIndicatorSize.height?min_Y:0;
            [dot setFrame:CGRectMake(X , Y, _pageIndicatorSize.width, _pageIndicatorSize.height)];
            X+=_pageIndicatorSize.width+_currentPageIndicatorSpacing;
            if (self.pageIndicatorImage) {
                dot.layer.contents = (id)self.pageIndicatorImage.CGImage;
                dot.backgroundColor = [UIColor clearColor];
            }else{
                dot.layer.contents = nil;
                dot.backgroundColor = self.pageIndicatorTintColor;
            }
            dot.layer.cornerRadius = self.pageIndicatorRadius;
        }else if (i == self.currentPage) {
            CGFloat Y = _currentPageIndicatorSize.height>_pageIndicatorSize.height?0:min_Y;
            [dot setFrame:CGRectMake(X , Y, _currentPageIndicatorSize.width,_currentPageIndicatorSize.height)];
            if (i==[self.subviews count]-1) {
                X+=_currentPageIndicatorSize.width;
            }else{
                X+=_currentPageIndicatorSize.width+_currentPageIndicatorSpacing;
            }
            if (self.currentPageIndicatorImage) {
                dot.layer.contents = (id)self.currentPageIndicatorImage.CGImage;
                dot.backgroundColor = [UIColor clearColor];
            }else{
                dot.layer.contents = nil;
                dot.backgroundColor = self.currentPageIndicatorTintColor;
            }
            dot.layer.cornerRadius = self.currentPageIndicatorRadius;
        }else {
            CGFloat Y = _currentPageIndicatorSize.height>_pageIndicatorSize.height?min_Y:0;
            [dot setFrame:CGRectMake(X , Y, _pageIndicatorSize.width, _pageIndicatorSize.height)];
            if (i==[self.subviews count]-1) {
                X+=_pageIndicatorSize.width;
            }else{
                X+=_pageIndicatorSize.width+_pageIndicatorSpacing;
            }
            if (self.pageIndicatorImage) {
                dot.layer.contents = (id)self.pageIndicatorImage.CGImage;
                dot.backgroundColor = [UIColor clearColor];
            }else{
                dot.layer.contents = nil;
                dot.backgroundColor = self.pageIndicatorTintColor;
            }
            dot.layer.cornerRadius = self.pageIndicatorRadius;
        }
    }
    self.frame = CGRectMake(self.jl_x, self.jl_y, X, H);
    _minimumSize = CGSizeMake(X, H);
}
-(void)animatedWithDot:(UIView *)dot
{
    
}
-(CGSize)sizeForNumberOfPages:(NSInteger)pageCount
{
    if (self.allowUpdatePageIndicator) {
        return _minimumSize;
    }
    return [super sizeForNumberOfPages:pageCount];
}

@end

