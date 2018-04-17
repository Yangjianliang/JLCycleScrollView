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
#pragma mark 返回一个数组，数组中存放着可视范围item的布局
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSLog(@"调用了====");
    // 实现父类的一些布局
    NSArray *superArray = [super layoutAttributesForElementsInRect:rect];
    
    //    return superArray;
    // 获取当前中心点的位置
    CGFloat centerX = self.collectionView.frame.size.width / 2 + self.collectionView.contentOffset.x;
    
    // 获取可视范围内item的属性
    for (UICollectionViewLayoutAttributes *attributes in superArray) {
        
        // 获取中心点和item中心点的绝对距离
//        // ABS 求绝对值
//        CGFloat dstL = ABS(attributes.center.x - centerX);
//        CGFloat scale = 1 - dstL / self.collectionView.frame.size.width;
//        
//        CGFloat dstLL = ABS(attributes.center.x - centerX)-100;
//        CGFloat scaleH = 1 - dstLL / self.collectionView.frame.size.width;
//        attributes.transform = CGAffineTransformMakeScale(scale, scaleH);
        
    }
    return superArray;
}
#pragma mark 可视范围发生改变的时候，用来刷新UI的
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}
@end
