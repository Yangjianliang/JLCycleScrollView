//
//  JLCycScrollFlowLayout.m
//  JLCycleScrollView
//
//  Created by 杨建亮 on 2018/4/6.
//  Copyright © 2018年 yangjianliang. All rights reserved.
//

#import "JLCycScrollFlowLayout.h"

@interface JLCycScrollFlowLayout ()
@property(nonatomic, strong) NSMutableArray *arrayHistory;
@end

@implementation JLCycScrollFlowLayout
@dynamic minimumLineSpacing;
@dynamic itemSize;
@dynamic scrollDirection;
@dynamic sectionInset;
- (instancetype)init
{
    if (self == [super init]) {
        [self setDefaultData];
    }return self;
}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setDefaultData];
    }return self;
}
-(void)setDefaultData
{
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.minimumLineSpacing = 0.f;
    self.arrayHistory = [NSMutableArray array];
}
-(void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing
{
    BOOL isSame = self.minimumLineSpacing == minimumLineSpacing;
    if (!isSame&&self.willUpdateJLCycScrollFlowLayout) {
        self.willUpdateJLCycScrollFlowLayout(@"minimumLineSpacing");
    }
    [super setMinimumLineSpacing:minimumLineSpacing];
    if (!isSame&&self.didUpdateJLCycScrollFlowLayout) {
        self.didUpdateJLCycScrollFlowLayout(@"minimumLineSpacing");
    }
}
-(void)setItemSize:(CGSize)itemSize
{
    BOOL isSame = CGSizeEqualToSize(self.itemSize, itemSize) ;
    if (!isSame&&self.willUpdateJLCycScrollFlowLayout) {
        self.willUpdateJLCycScrollFlowLayout(@"itemSize");
    }
    [super setItemSize:itemSize];
    
//    [self invalidateLayout];
    if (!isSame&&self.didUpdateJLCycScrollFlowLayout) {
        self.didUpdateJLCycScrollFlowLayout(@"itemSize");
    }
}
-(void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
    BOOL isSame = self.scrollDirection == scrollDirection;
    if (!isSame&&self.willUpdateJLCycScrollFlowLayout) {
        self.willUpdateJLCycScrollFlowLayout(@"scrollDirection");
    }
    [super setScrollDirection:scrollDirection];
    if (!isSame&&self.didUpdateJLCycScrollFlowLayout) {
        self.didUpdateJLCycScrollFlowLayout(@"scrollDirection");
    }
}
-(void)setSectionInset:(UIEdgeInsets)sectionInset
{
    BOOL isSame = UIEdgeInsetsEqualToEdgeInsets(self.sectionInset, sectionInset);
    if (!isSame&&self.willUpdateJLCycScrollFlowLayout) {
        self.willUpdateJLCycScrollFlowLayout(@"sectionInset");
    }
    [super setSectionInset:sectionInset];
    if (!isSame&&self.didUpdateJLCycScrollFlowLayout) {
        self.didUpdateJLCycScrollFlowLayout(@"sectionInset");
    }
}
- (void)prepareLayout
{
    [super prepareLayout];
    NSLog(@"初始化好了prepareLayout");
    if (self.didPrepareLayout) {
        self.didPrepareLayout();
    }
    
}
#pragma mark 返回一个数组，数组中存放着可视范围item的布局
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSLog(@"layoutAttributesForElementsInRect");
    // 实现父类的一些布局
    NSArray *superArray = [super layoutAttributesForElementsInRect:rect];
    
    for (int i=0; i<superArray.count; ++i) {
        UICollectionViewLayoutAttributes *att = superArray[i];
        if (![self.arrayHistory containsObject:att]) {
            [self.arrayHistory addObject:att];
            NSLog(@"jl__没有以添加");
        }
        NSLog(@"jl__%@",self.arrayHistory);

    }
    
    //    return superArray;
    // 获取当前中心点的位置
    CGFloat centerX = self.collectionView.frame.size.width / 2 + self.collectionView.contentOffset.x;
    
    // 获取可视范围内item的属性
    for (UICollectionViewLayoutAttributes *attributes in superArray) {
        
//         获取中心点和item中心点的绝对距离
        // ABS 求绝对值
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
//- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
//{
//    return YES;
//}
@end
