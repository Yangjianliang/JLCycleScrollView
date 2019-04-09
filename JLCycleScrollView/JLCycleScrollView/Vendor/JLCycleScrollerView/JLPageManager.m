//
//  JLPageManager.m
//  JLCycleScrollView
//
//  Created by 杨建亮 on 2018/4/8.
//  Copyright © 2018年 yangjianliang. All rights reserved.
//

#import "JLPageManager.h"
#import "JLCycleScrollerView.h"

@interface JLPageManager ()
@property (nonatomic) NSInteger lastRow;
@property (nonatomic, strong, nullable) NSMutableArray<__kindof UICollectionViewLayoutAttributes *> * arrayPlaceholderAttributes;
@end

@implementation JLPageManager
-(instancetype)initWithCollView:(UICollectionView *)collView layout:(JLCycScrollFlowLayout *)layout cycView:(JLCycleScrollerView *)cycView
{
    if (self = [super init]) {
        _collectionView = collView;
        _layout = layout;
        _cycScrollerView = cycView;
        _outItemSpacing = 0.0;
        _lastRow = 0;
    }
    return self;
}
-(NSInteger)getCurryPageInteger
{
    NSInteger curryPage = roundf([self getCurryPageFloat]);
    _lastRow = curryPage;//scrollViewDidScroll、优化下次查找效率
    return curryPage;
}
-(CGFloat)getCurryPageFloat
{
    if (self.layout.allAttributesInRect.allKeys.count==0)
    {
        if (self.arrayPlaceholderAttributes && self.arrayPlaceholderAttributes.count >0) {
            for (int i = 0; i<self.arrayPlaceholderAttributes.count; ++i) {
                UICollectionViewLayoutAttributes *attr = self.arrayPlaceholderAttributes[i];
                CGFloat curryPage = [self findPageFloat:attr];
                if (curryPage>=0)
                {
                    return curryPage+i;
                }
            }
            NSLog(@"not initialized and not find in arrayPlaceholderAttributes!");
        }
        NSLog(@"not initialized");
        return 0.0;
    }
    NSInteger numItems = [self.cycScrollerView getNumberOfItemsInSection];
    NSInteger idx = numItems-self.lastRow;
    if (idx <=0 || idx >self.lastRow)
    {
        int j = (int)self.lastRow;
        for (int i= (int)self.lastRow;i<numItems; ++i) {
            UICollectionViewLayoutAttributes *attr = [self.layout.allAttributesInRect objectForKey:@(i)];
            CGFloat curryPage = [self findPageFloat:attr];
            if (curryPage>=0)
            {
                curryPage = curryPage+i;
                return curryPage;
            }
            else
            {
                j--;
                if (j>=0)
                {
                    UICollectionViewLayoutAttributes *attr = [self.layout.allAttributesInRect objectForKey:@(j)];
                    CGFloat curryPage = [self findPageFloat:attr];
                    if (curryPage>=0)
                    {
                        curryPage = curryPage+j;
                        return curryPage;
                    }
                }
            }
        }
    }else{
        int j = (int)self.lastRow;
        for (int i= (int)self.lastRow;i>=0; --i) {
            UICollectionViewLayoutAttributes *attr = [self.layout.allAttributesInRect objectForKey:@(i)];
            CGFloat curryPage = [self findPageFloat:attr];
            if (curryPage>=0)
            {
                curryPage = curryPage+i;
                return curryPage;
            }
            else
            {
                j++;
                if (j<numItems)
                {
                    UICollectionViewLayoutAttributes *attr = [self.layout.allAttributesInRect objectForKey:@(j)];
                    CGFloat curryPage = [self findPageFloat:attr];
                    if (curryPage>=0)
                    {
                        curryPage = curryPage+j;
                        return curryPage;
                    }
                }
            }
        }
    }
    NSLog(@"not find but Data");
    return 0.0;
}
//renturn [0.0-1.0) if(1.0) return -1
- (CGFloat)findPageFloat:(UICollectionViewLayoutAttributes *)attributes
{
    if (!attributes) {
        NSLog(@"attributes is nil！！！！");
        return -1.0;
    }
    if (self.layout.scrollDirection == UICollectionViewScrollDirectionVertical ) {
        return [self findDVerticalPageFloat:attributes];
    }else{
        return [self findDHorizontalPageFloat:attributes];
    }
}
- (CGFloat)findDVerticalPageFloat:(UICollectionViewLayoutAttributes *)attributes
{
    _outItemSpacing = 0.0;
    CGFloat offsetY = self.collectionView.contentOffset.y ;
    CGFloat top = self.layout.sectionInset.top;
    
    CGFloat attMinY = CGRectGetMinY(attributes.frame);
    CGFloat attMaxY = CGRectGetMaxY(attributes.frame);
    BOOL isInRange = attMinY-top <= offsetY && offsetY< (attMaxY+self.cycScrollerView.itemSpacing)-top;
    if (isInRange){
        CGFloat sizeH = CGRectGetHeight(attributes.frame);
        CGFloat pageFloat = (offsetY-attMinY+top)/(sizeH);
        BOOL isOutCell = pageFloat>=1.0;
        CGFloat curryPage = isOutCell?0.0:pageFloat;
        if (isOutCell) {
            _outItemSpacing = offsetY-attMaxY+top +sizeH;
//            NSLog(@"_outItemSpacing=%f",_outItemSpacing);
        }
        return curryPage;
    }
    return -1.0;
}
- (CGFloat)findDHorizontalPageFloat:(UICollectionViewLayoutAttributes *)attributes
{
    _outItemSpacing = 0.0;
    CGFloat offsetX = self.collectionView.contentOffset.x ;
    CGFloat left = self.layout.sectionInset.left;
    
    CGFloat attMinX = CGRectGetMinX(attributes.frame);
    CGFloat attMaxX = CGRectGetMaxX(attributes.frame);
    BOOL isInRange = attMinX-left <= offsetX && offsetX< (attMaxX+self.cycScrollerView.itemSpacing)-left;
    if (isInRange) {
        CGFloat sizeW = CGRectGetWidth(attributes.frame);
        CGFloat pageFloat = (offsetX-attMinX+left)/(sizeW);
        BOOL isOutCell = pageFloat>=1.0;
        CGFloat curryPage = isOutCell?0.0:pageFloat;
        if (isOutCell) {
            _outItemSpacing = offsetX-attMaxX+left +sizeW;
//            NSLog(@"_outItemSpacing=%f",_outItemSpacing);
        }
        return curryPage;

    }
    return -1.0;
}

#pragma park mark -
-(BOOL)isDVertical
{
    return self.layout.scrollDirection == UICollectionViewScrollDirectionVertical;
}
-(BOOL)isItemSizeCustom
{
    return self.cycScrollerView.delegate&&[self.cycScrollerView.delegate respondsToSelector:@selector(jl_cycleScrollerView:sizeForItemAtIndex:preLayout:)] ;
}
-(CGSize)itemSizeWithIndex:(NSInteger)index
{
    CGSize size = [self.cycScrollerView.delegate jl_cycleScrollerView:self.cycScrollerView  sizeForItemAtIndex:index preLayout:YES];
    return size;
}
-(CGFloat)prepareCalculateCellsOfLine
{
    NSLog(@"prepareCalculateCellsOfLine");
    [self.layout.allAttributesInRect removeAllObjects];
    CGFloat cellsOfLine = self.cycScrollerView.cellsOfLine;
    if ([self isItemSizeCustom])
    {
        if (self.cycScrollerView.infiniteDragging)
        {
            self.arrayPlaceholderAttributes = [NSMutableArray array];
            
            CGFloat item_XY = [self isDVertical]?self.layout.sectionInset.top:self.layout.sectionInset.left;
            CGSize size = [self itemSizeWithIndex: self.cycScrollerView.sourceArray.count-1];
            UICollectionViewLayoutAttributes *att  = [[UICollectionViewLayoutAttributes alloc] init];
            att.frame = CGRectMake(item_XY, item_XY,size.width, size.height);
            [self.arrayPlaceholderAttributes addObject:att];
            
            //计算下一个(实际展示第一个)的origin
            CGFloat LWH = [self isDVertical]?size.height:size.width;
            item_XY = item_XY+ LWH +self.cycScrollerView.itemSpacing;
            
            for (int i=0; i<self.cycScrollerView.sourceArray.count; ++i) {
                CGSize size = [self itemSizeWithIndex:i];
                UICollectionViewLayoutAttributes *att  = [[UICollectionViewLayoutAttributes alloc] init];
                att.frame = CGRectMake(item_XY, item_XY,size.width, size.height);//水平时只用到X、垂直只用到Y
                [self.arrayPlaceholderAttributes addObject:att];
                
                //计算下一个的origin
                CGFloat IWH = [self isDVertical]?size.height:size.width;
                item_XY = item_XY+ IWH +self.cycScrollerView.itemSpacing;
                
                //减去第一个(实际是最后一个)的宽(高)和间距来计算cellsOfLine以判定是否可以无限拖拽
                CGFloat max_XY = [self isDVertical]?CGRectGetMaxY(att.frame):CGRectGetMaxX(att.frame);
                UICollectionViewLayoutAttributes *attrFirst = self.arrayPlaceholderAttributes.firstObject;
                CGFloat FWH = [self isDVertical]?attrFirst.frame.size.height:attrFirst.frame.size.width;
                max_XY = max_XY-FWH-self.cycScrollerView.itemSpacing;
                CGFloat collectWH = [self isDVertical]?self.collectionView.jl_height:self.collectionView.jl_width;
                
                if (max_XY>=collectWH) {
                    cellsOfLine = i+1.0;
                    break;
                }else{
                    if (i==self.cycScrollerView.sourceArray.count-1) {
                        cellsOfLine = self.cycScrollerView.sourceArray.count+1;
                        break;
                    }
                }
            }
        }
    }
    else
    {
        if ([self.cycScrollerView canInfiniteDrag]) {
            self.arrayPlaceholderAttributes = [NSMutableArray array];
            CGFloat item_XY = [self isDVertical]?self.layout.sectionInset.top:self.layout.sectionInset.left;
            for (int i=0; i<2; ++i) {//只需两个
                UICollectionViewLayoutAttributes *att  = [[UICollectionViewLayoutAttributes alloc] init];
                if ([self isDVertical]) {
                    att.frame = CGRectMake(0, item_XY+(self.cycScrollerView.itemSize.height+self.cycScrollerView.itemSpacing)*i, 0, self.cycScrollerView.itemSize.height);
                }else{
                    att.frame = CGRectMake(item_XY+(self.cycScrollerView.itemSize.width+self.cycScrollerView.itemSpacing) *i, 0, self.cycScrollerView.itemSize.width, 0);
                }
                [self.arrayPlaceholderAttributes addObject:att];
            }
        }
    }
    NSLog(@"cellsOfLine=%f",cellsOfLine);
    return cellsOfLine;
}
-(BOOL)jl_setContentOffsetAtIndex:(CGFloat)item animated:(BOOL)animated
{
    NSLog(@"设置偏移:%.2f==%@",item,animated?@"YES":@"NO");
    NSInteger numberOfItems = [self.cycScrollerView getNumberOfItemsInSection];
    if (item >=0.0 && item<numberOfItems ) {
        NSInteger row = floorf(item);//只舍不入
        UICollectionViewLayoutAttributes *att = [self getAttributesWithRow:row];
        if (att) {
            if ([self isDVertical])
            {
                CGFloat offSet = att.frame.origin.y -self.layout.sectionInset.top +(item-row)*(att.frame.size.height);
                if (_outItemSpacing >0.0) {
                    offSet = offSet+ _outItemSpacing;
                }
                [self.collectionView setContentOffset:CGPointMake(0, offSet) animated:animated];
            }
            else
            {
                CGFloat offSet = att.frame.origin.x -self.layout.sectionInset.left +(item-row)*(att.frame.size.width);
                if (_outItemSpacing >0.0) {
                    offSet = offSet+ _outItemSpacing;
                }
                [self.collectionView setContentOffset:CGPointMake(offSet, 0) animated:animated];
            }
            _outItemSpacing = 0.0;//flwLayout、cellOfLine等改变
            return YES;
        }
    }
    _outItemSpacing = 0.0;
    return NO;
}
-(UICollectionViewLayoutAttributes *)getAttributesWithRow:(NSInteger)row
{
    UICollectionViewLayoutAttributes *attributes = [self.layout.allAttributesInRect objectForKey:@(row)];
    if (attributes)
    {
        return attributes;
    }
    else
    {
        if (self.layout.allAttributesInRect.count == 0)
        {//尚未准备好布局
            if (row < self.arrayPlaceholderAttributes.count) {
                UICollectionViewLayoutAttributes *attr  = self.arrayPlaceholderAttributes[row];
                return attr;
            }else{//If necessary
                [self recalculateAllPlaceholderAttributes];
                if (row < self.arrayPlaceholderAttributes.count) {
                    UICollectionViewLayoutAttributes *attr  = self.arrayPlaceholderAttributes[row];
                    return attr;
                }
            }
            return nil;
        }
        else
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            UICollectionViewLayoutAttributes *attr  = [self.layout layoutAttributesForItemAtIndexPath:indexPath];
            return attr;
        }
    }
}
-(void)recalculateAllPlaceholderAttributes
{
    NSLog(@"recalculateAllPlaceholderAttributes");
    self.arrayPlaceholderAttributes = [NSMutableArray array];
    if ([self isItemSizeCustom])
    {
        CGFloat item_XY = [self isDVertical]?self.layout.sectionInset.top:self.layout.sectionInset.left;
        if ([self.cycScrollerView canInfiniteDrag])
        {
            CGSize size = [self itemSizeWithIndex: self.cycScrollerView.sourceArray.count-1];
            UICollectionViewLayoutAttributes *att  = [[UICollectionViewLayoutAttributes alloc] init];
            att.frame = CGRectMake(item_XY, item_XY,size.width, size.height);
            [self.arrayPlaceholderAttributes addObject:att];
            
            //计算下一个(实际展示第一个)的origin
            CGFloat LWH = [self isDVertical]?size.height:size.width;
            item_XY = item_XY+ LWH +self.cycScrollerView.itemSpacing;
            
            for (int i=0; i<self.cycScrollerView.sourceArray.count; ++i) {
                CGSize size = [self itemSizeWithIndex:i];
                UICollectionViewLayoutAttributes *att  = [[UICollectionViewLayoutAttributes alloc] init];
                att.frame = CGRectMake(item_XY, item_XY,size.width, size.height);//水平时只用到X、垂直只用到Y
                [self.arrayPlaceholderAttributes addObject:att];
                
                //计算下一个的origin
                CGFloat IWH = [self isDVertical]?size.height:size.width;
                item_XY = item_XY+ IWH +self.cycScrollerView.itemSpacing;
            }
        }else{
            for (int i=0; i<self.cycScrollerView.sourceArray.count; ++i) {
                CGSize size = [self itemSizeWithIndex:i];
                UICollectionViewLayoutAttributes *att  = [[UICollectionViewLayoutAttributes alloc] init];
                att.frame = CGRectMake(item_XY, item_XY,size.width, size.height);//水平时只用到X、垂直只用到Y
                [self.arrayPlaceholderAttributes addObject:att];
                
                //计算下一个的origin
                CGFloat IWH = [self isDVertical]?size.height:size.width;
                item_XY = item_XY+ IWH +self.cycScrollerView.itemSpacing;
            }
        }
    }
    else
    {
        CGFloat item_XY = [self isDVertical]?self.layout.sectionInset.top:self.layout.sectionInset.left;
        NSInteger nums = [self.cycScrollerView canInfiniteDrag]?self.cycScrollerView.sourceArray.count+1:self.cycScrollerView.sourceArray.count;
        for (int i=0; i<nums; ++i) {
            UICollectionViewLayoutAttributes *att  = [[UICollectionViewLayoutAttributes alloc] init];
            if ([self isDVertical]) {
                att.frame = CGRectMake(0, item_XY+(self.cycScrollerView.itemSize.height+self.cycScrollerView.itemSpacing)*i, 0, self.cycScrollerView.itemSize.height);
            }else{
                att.frame = CGRectMake(item_XY+(self.cycScrollerView.itemSize.width+self.cycScrollerView.itemSpacing) *i, 0, self.cycScrollerView.itemSize.width, 0);
            }
            [self.arrayPlaceholderAttributes addObject:att];
        }
    }
}
@end
