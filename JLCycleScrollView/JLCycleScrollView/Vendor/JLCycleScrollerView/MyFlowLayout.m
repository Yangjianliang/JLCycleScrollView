//
//  MyFlowLayout.m
//  自定义布局
//
//  Created by MCJ on 16/6/3.
//  Copyright © 2016年 MCJ. All rights reserved.
//

#import "MyFlowLayout.h"

@implementation MyFlowLayout

#pragma mark 布局初始化的时候会调用这个方法
- (void)prepareLayout{
   // 1. 调用父类的方法初始化父类
    [super prepareLayout];
   // 2. 初始化自己的
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    CGFloat leftInset = (self.collectionView.frame.size.width) / 2;
    self.sectionInset = UIEdgeInsetsMake(0, leftInset, 0, leftInset);
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
        // ABS 求绝对值
        CGFloat dstL = ABS(attributes.center.x - centerX);
        CGFloat scale = 1 - dstL / self.collectionView.frame.size.width;
        attributes.transform = CGAffineTransformMakeScale(scale, scale);
        
    }
    return superArray;
}

#pragma mark proposedContentOffset 系统希望滑动的位置  velocity 加速度
//- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
//{
//    // 1. 计算最终显示的范围
//    CGRect rect = CGRectMake(proposedContentOffset.x, 0, self.collectionView.frame.size.width, self.collectionView.frame.size.height);
//    
//    // 2. 获取父类计算好的布局
//    NSArray *superArray = [super layoutAttributesForElementsInRect:rect];
//    
//    // 3. 获取中心点的位置
//    CGFloat centerX = self.collectionView.frame.size.width / 2 + proposedContentOffset.x;
//    
//    // 4. 通过和中心得位置对比，确定item要滑动的位置
//    CGFloat minLength = MAXFLOAT;
//    for (UICollectionViewLayoutAttributes *attributes in superArray) {
//        
//        CGFloat minA = ABS(minLength);
//        CGFloat minB = ABS(attributes.center.x - centerX);
//        if (minA > minB) {
//            minLength = attributes.center.x - centerX;
//        }
//        
//    }
//    
//    // 5. 修改item偏移的位置
//    proposedContentOffset.x += minLength;
//    return proposedContentOffset;
//    
//}




#pragma mark 可视范围发生改变的时候，用来刷新UI的
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

@end







