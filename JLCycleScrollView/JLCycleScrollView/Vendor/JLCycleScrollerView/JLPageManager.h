//
//  JLPageManager.h
//  JLCycleScrollView
//
//  Created by 杨建亮 on 2018/4/8.
//  Copyright © 2018年 yangjianliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class JLCycleScrollerView;
@class JLCycScrollFlowLayout;

@interface JLPageManager : NSObject
- (instancetype)initWithCollView:(UICollectionView *)collView layout:(JLCycScrollFlowLayout *)layout cycView:(JLCycleScrollerView *)cycView;
@property (nonatomic, weak, readonly) UICollectionView *collectionView;
@property (nonatomic, weak, readonly) JLCycScrollFlowLayout *layout;
@property (nonatomic, weak, readonly) JLCycleScrollerView *cycScrollerView;

@property (nonatomic, readonly) CGFloat outItemSpacing;

- (CGFloat)prepareCalculateCellsOfLine;

- (CGFloat)getCurryPageFloat;
- (NSInteger)getCurryPageInteger;
- (BOOL)jl_setContentOffsetAtIndex:(CGFloat)item animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
