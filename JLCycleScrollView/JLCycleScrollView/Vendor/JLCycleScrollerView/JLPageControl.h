//
//  JLPageControl.h
//  JLCycleScrollView
//
//  Created by yangjianliang on 2017/9/24.
//  Copyright © 2017年 yangjianliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JLPageControl : UIPageControl

@property(nonatomic ,assign) BOOL allowChangeFrame; // default is NO,推荐将以下需要修改属性设置后再设置YES

@property(nonatomic, readonly) CGSize jl_MinimumSize; // returns minimum size required to display dots for given page count. can be used to size control if page count could change

@property(nonatomic) CGSize jl_norDotSize; // default is CGSizeMake(7, 7);
@property(nonatomic) CGSize jl_selDotSize; // default is CGSizeMake(7, 7);

@property(nonatomic, assign) CGFloat jl_norDotCornerRadius; // default is 3.5f;
@property(nonatomic, assign) CGFloat jl_selDotCornerRadius; // default is 3.5f;

@property(nonatomic, assign) CGFloat jl_norMagrin; // default is 4.f;
@property(nonatomic, assign) CGFloat jl_selMagrin; // default is 4.f;|o-O-o--o|

@property (nullable, nonatomic, strong) UIImage *jl_norImage; // default is nil
@property (nullable, nonatomic, strong) UIImage *jl_selImage; // default is nil

-(void)layoutSubPages;
@end

@interface UIView (JLFrame)
/**新增x，y，w，h,cX,cY属性,可快速set／get的Frame属性值*/
@property (nonatomic, assign) CGFloat jl_height;
@property (nonatomic, assign) CGFloat jl_width;
@property (nonatomic, assign) CGFloat jl_y;
@property (nonatomic, assign) CGFloat jl_x;

@property (nonatomic, assign) CGFloat jl_centerX;
@property (nonatomic, assign) CGFloat jl_centerY;
@end
