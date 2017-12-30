//
//  UIView+FrameSet.h
//  JLCycleScrollView
//
//  Created by yangjianliang on 2017/9/24.
//  Copyright © 2017年 yangjianliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (JLFrame)
/**新增x，y，w，h,cX,cY属性,可快速set／get的Frame属性值*/
@property (nonatomic, assign) CGFloat jl_height;
@property (nonatomic, assign) CGFloat jl_width;
@property (nonatomic, assign) CGFloat jl_y;
@property (nonatomic, assign) CGFloat jl_x;

@property (nonatomic, assign) CGFloat jl_centerX;
@property (nonatomic, assign) CGFloat jl_centerY;
@end

