//
//  JLCycScrollFlowLayout.m
//  JLCycleScrollView
//
//  Created by 杨建亮 on 2018/4/6.
//  Copyright © 2018年 yangjianliang. All rights reserved.
//

#import "JLCycScrollFlowLayout.h"

@interface JLCycScrollFlowLayout ()

@end

@implementation JLCycScrollFlowLayout
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
    self.minimumInteritemSpacing = 0.f;
    self.sectionInset = UIEdgeInsetsZero;
    _allAttributesInRect = [NSMutableDictionary dictionary];
}

-(void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing
{
    [super setMinimumLineSpacing:0.0];
}
-(void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing
{
    [super setMinimumInteritemSpacing:0.0];
}
-(void)setItemSize:(CGSize)itemSize
{
    [super setItemSize:CGSizeZero];
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
    NSLog(@"RR_prepareLayout");
   
//    CGFloat leftInset = (self.collectionView.frame.size.width - self.itemSize.width) / 2;
//    self.sectionInset = UIEdgeInsetsMake(0, leftInset, 0, leftInset);
    
    [_allAttributesInRect removeAllObjects];
}
#pragma mark 返回一个数组，数组中存放着可视范围item的布局
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *superArray = [super layoutAttributesForElementsInRect:rect];
    NSLog(@"WW======%s==%ld",__FUNCTION__,superArray.count);
    for (int i=0; i<superArray.count; ++i) {
        UICollectionViewLayoutAttributes *att = superArray[i];
        UICollectionViewLayoutAttributes *attDict = [_allAttributesInRect objectForKey:@(att.indexPath.row)];
        if (!attDict || ![att isEqual:attDict])
        {
            [_allAttributesInRect setObject:att forKey:@(att.indexPath.row)];
        }
//        if (attDict || ![att isEqual:attDict])
//        {
//            NSLog(@"被更新了");
//            
//        }
    }
    

        // 获取当前中心点的位置
    CGFloat centerX = self.collectionView.frame.size.width / 2 + self.collectionView.contentOffset.x;
//    NSArray* attributesToReturn = [[NSArray alloc] initWithArray:superArray copyItems:YES];

    // 获取可视范围内item的属性
    for (UICollectionViewLayoutAttributes *attributes in superArray) {
        // 获取中心点和item中心点的绝对距离
        // ABS 求绝对值
        CGFloat dstL = ABS(attributes.center.x - centerX);
//        NSLog(@"%f",dstL);
        CGFloat scale = 1 - dstL / self.collectionView.frame.size.width/4;
        attributes.transform = CGAffineTransformMakeScale(scale, scale); //collectionViewContentSize是不受影响的
    }
//    NSLog(@"WW======\n%@",self.allAttributesInRect);

    
//    rect.size.width = rect.size.width + KScreenWidth;
//    rect.origin.x = rect.origin.x - KScreenWidth/2;
    
    // 让父类布局好样式
//    NSArray *arr = [[NSArray alloc] initWithArray:[super layoutAttributesForElementsInRect:rect] copyItems:YES];
//
//
//    for (UICollectionViewLayoutAttributes *attributes in arr) {
//        CGFloat scale;
//        //        scale = 1.0;
//
//        // collectionView 的 centerX
//        CGFloat centerX = self.collectionView.center.x;
//        CGFloat step = ABS(centerX - (attributes.center.x - self.collectionView.contentOffset.x));
//        NSLog(@"step %@ : attX %@ - offset %@", @(step), @(attributes.center.x), @(self.collectionView.contentOffset.x));
//        scale = fabsf(cosf(step/centerX * M_PI/5));
//
//        attributes.transform = CGAffineTransformMakeScale(scale, scale);
//    }

    
    
    return superArray;

}
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"RR_%s",__FUNCTION__);
    return [super layoutAttributesForItemAtIndexPath:indexPath];
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
//    return  [super shouldInvalidateLayoutForBoundsChange:newBounds];
    return YES;
}
- (CGSize)collectionViewContentSize
{
    CGSize size =  [super collectionViewContentSize];
//    NSLog(@"collectionViewContentSize%@",NSStringFromCGSize(size));
    return size;
}
@end
