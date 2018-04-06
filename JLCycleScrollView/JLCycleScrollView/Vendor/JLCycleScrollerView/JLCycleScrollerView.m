//
//  JLCycleScrollerView.m
//  JLCycleScrollView
//
//  Created by yangjianliang on 2017/9/24.
//  Copyright © 2017年 yangjianliang. All rights reserved.
//


#import "JLCycleScrollerView.h"
#import "MyFlowLayout.h"

typedef NS_ENUM(NSInteger, PageControlMode) {
    PageControlModeCenterX = 0,
    PageControlModeLeft    = 1,
    PageControlModeRight   = 2 ,
    
    PageControlModeTop     = 3,
    PageControlModeBottom  = 4,
    PageControlModeCenterY = 5,
};
@interface JLCycleScrollerView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSMutableArray<__kindof UICollectionViewLayoutAttributes *> *arrayAttributes;
@property (nonatomic, strong, nullable) NSMutableArray<__kindof UICollectionViewLayoutAttributes *> * arrayPlaceholderAttributes;
@property (nonatomic, strong) NSArray *arrayData;
@property (nonatomic) NSInteger lastPage;
@property (nonatomic, copy) NSString *reuseIdentifier;
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic) PageControlMode pageControl_X;
@property (nonatomic) PageControlMode pageControl_Y;
@property (nonatomic) BOOL transformSize;

@end
static NSTimeInterval const animatedTime = 0.35;
static NSString * const JLCycScrollDefaultCellResign = @"JLCycScrollDefaultCellResign";
@implementation JLCycleScrollerView
@synthesize pageControl = _pageControl;
#pragma mark - ---InitJLCycleScrollerView
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initDefaultData];
        [self initUI];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initDefaultData];
        [self initUI];
    }
    return self;
}
-(void)initDefaultData
{
    _scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _timeDuration = 3.0;
    _pageControl_botton = 10.f;
    _pageControl_centerX = 0.f;
    _cellsOfLine = 1.2 ;
    _timerNeed = YES;
    _infiniteDragging = YES;
    _infiniteDraggingForSinglePage = NO;
    _scrollEnabled = YES;
    _pageControlNeed = YES;
    _pagingEnabled = YES;
    self.arrayData = [NSArray array];
    self.lastPage = 0;
    self.transformSize = NO;
    self.pageControl_X = PageControlModeCenterX;
    self.pageControl_Y = PageControlModeBottom;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}
-(void)initUI
{
    MyFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
//    flowLayout.sectionInset = UIEdgeInsetsZero;
    flowLayout.scrollDirection = self.scrollDirection;
    _flowLayout = flowLayout;
    
    UICollectionView*collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    collectionView.pagingEnabled = self.pagingEnabled;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.scrollsToTop = NO;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    self.collectionView = collectionView;
    [self.collectionView registerClass:[JLCycScrollDefaultCell class] forCellWithReuseIdentifier:JLCycScrollDefaultCellResign];
    [self addSubview:self.collectionView];
}
#pragma mark  - reloadData
-(void)setSourceArray:(NSArray *)sourceArray
{
    [self deallocTimerIfNeed];
    BOOL sameMemory = [sourceArray isEqualToArray:self.arrayData];
    CGFloat item = self.pagingEnabled?[self getCurryPageInteger]:[self getCurryPageFloat];
    CGFloat scrollAtItem = sameMemory?item:0.0;
    self.arrayData = [NSArray arrayWithArray:sourceArray];
    [self reloadDataAtItem:scrollAtItem];
}
-(NSArray *)sourceArray
{
    return [NSArray arrayWithArray:self.arrayData];
}
-(void)reloadDataAtItem:(CGFloat)item
{
    [self deallocTimerIfNeed];
    [self layoutIfNeeded];
    if (self.pageControlNeed) {
        self.pageControl.numberOfPages = self.arrayData.count;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self prepareCalculateCellsOfLineIfInfiniteDrag];
        if ([self canInfiniteDrag] && [self getCurryPageFloat]<1.0) {
            [self jl_setContentOffsetAtIndex:1.0 animated:NO];
        }else{
            [self jl_setContentOffsetAtIndex:item animated:NO];
        }
        [self.collectionView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initializeArrayAttributes];
            if (self.superview&&self.timerNeed) {
                [self setupTimer];
            }
        });
    });
}
#pragma mark - -----PageControl------
-(void)setPageControl:(JLPageControl *)pageControl
{
    if (!pageControl) {
        self.pageControlNeed = NO;
    }
    if ([pageControl isKindOfClass:[UIPageControl class]]) {
        if (_pageControl) {
            [_pageControl removeFromSuperview];
            _pageControl = nil;
        }
        _pageControl = pageControl;
        if (_pageControl&&!_pageControl.superview) {
            [self addSubview:_pageControl];
        }
    }
}
-(JLPageControl *)pageControl
{
    if (!_pageControl && _pageControlNeed) {
        JLPageControl* pageControl = [[JLPageControl alloc] init];
        pageControl.hidesForSinglePage = YES;
        self.pageControl = pageControl;
    }
    return _pageControl;
}
-(void)updataPageControlFrame
{
    [self.pageControl layoutIfNeeded];
    switch (self.pageControl_X) {
        case 1:
            self.pageControl_left = _pageControl_left;
            break;
        case 2:
            self.pageControl_right = _pageControl_right;
            break;
        default:
            self.pageControl_centerX = _pageControl_centerX;
            break;
    }
    switch (self.pageControl_Y) {
        case 3:
            self.pageControl_top = _pageControl_top;
            break;
        case 5:
            self.pageControl_centerY = _pageControl_centerY;
            break;
        default:
            self.pageControl_botton = _pageControl_botton;
            break;
    }
}
-(void)setPageControlNeed:(BOOL)pageControlNeed
{
    _pageControlNeed = pageControlNeed;
    if (!_pageControlNeed) {
        [_pageControl removeFromSuperview];
        _pageControl = nil;
    }else{
        [self addSubview:self.pageControl];
    }
}
-(void)setPageControl_top:(CGFloat)pageControl_top
{
    _pageControl_top = pageControl_top;
    _pageControl_Y = PageControlModeTop;
    _pageControl.jl_y = _pageControl_top;
}
-(void)setPageControl_botton:(CGFloat)pageControl_botton
{
    _pageControl_botton = pageControl_botton;
    _pageControl_Y = PageControlModeBottom;
    _pageControl.jl_y = self.jl_height-_pageControl.jl_height-_pageControl_botton;
}
-(void)setPageControl_left:(CGFloat)pageControl_left
{
    _pageControl_left = pageControl_left;
    _pageControl_X = PageControlModeLeft;
    _pageControl.jl_width = [_pageControl sizeForNumberOfPages:self.arrayData.count].width;
    _pageControl.jl_x = _pageControl_left;
}
-(void)setPageControl_right:(CGFloat)pageControl_right
{
    _pageControl_right = pageControl_right;
    _pageControl_X = PageControlModeRight;
    _pageControl.jl_width = [_pageControl sizeForNumberOfPages:self.arrayData.count].width;
    _pageControl.jl_x = self.jl_width-_pageControl.jl_width-_pageControl_right;
}
-(void)setPageControl_centerX:(CGFloat)pageControl_centerX
{
    _pageControl_centerX = pageControl_centerX;
    _pageControl_X = PageControlModeCenterX;
    self.pageControl.jl_centerX = self.jl_width/2.f+pageControl_centerX;
}
-(void)setPageControl_centerY:(CGFloat)pageControl_centerY
{
    _pageControl_centerY = pageControl_centerY;
    _pageControl_Y = PageControlModeCenterY;
    self.pageControl.jl_centerY = self.jl_height/2.f+pageControl_centerY;
}
#pragma park mark - ----CollectionView----
-(void)useCustomCell:(UICollectionViewCell<JLCycSrollCellDataProtocol> *)cell isXibBuild:(BOOL)isxib
{
    if (![cell isKindOfClass:[UICollectionViewCell class]]) {
        NSLog(@"\n---------方法:%sCell参数传入错误----------",__FUNCTION__);
        return;
    }
    NSString* ClassCell =  NSStringFromClass([cell class]);
    self.reuseIdentifier = [NSString stringWithFormat:@"%@Resign",ClassCell];
    if (isxib) {
        [self.collectionView registerNib:[UINib nibWithNibName:ClassCell bundle: [NSBundle mainBundle]] forCellWithReuseIdentifier:self.reuseIdentifier];
    }else{
        [self.collectionView registerClass:[NSClassFromString(ClassCell) class] forCellWithReuseIdentifier:self.reuseIdentifier];
    }
    if (self.arrayData.count>0) {
        [self reloadDataAtItem:0];
    }
}
-(void)setPlaceholderImage:(UIImage *)placeholderImage
{
    if (placeholderImage) {
        if (!self.collectionView.backgroundView) {
            UIImageView  *placeholderIMV = [[UIImageView alloc] init];
            self.collectionView.backgroundView = placeholderIMV;
        }
        if ([self.collectionView.backgroundView respondsToSelector:@selector(image)]) {
            [self.collectionView.backgroundView setValue:placeholderImage forKey:@"image"];
        }
    }else{
        self.collectionView.backgroundView = nil;
    }
    _placeholderImage = placeholderImage;
}
-(void)setScrollEnabled:(BOOL)scrollEnabled
{
    _scrollEnabled = scrollEnabled;
    self.collectionView.scrollEnabled = scrollEnabled;
}
-(void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
    _scrollDirection = scrollDirection;
    self.flowLayout.scrollDirection = scrollDirection;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initializeArrayAttributes];
    });
}
-(void)setInfiniteDragging:(BOOL)infiniteDragging
{
    BOOL changed =_infiniteDragging==infiniteDragging?NO:YES;
    NSInteger lastItem = [self getCurryPageInteger];
    BOOL last = [self dataIsUnavailable];
    _infiniteDragging = infiniteDragging;
    BOOL curry = [self dataIsUnavailable];
    if (changed) {
        if (_infiniteDragging) {
            if (!curry) {
                lastItem++;
            }
        }else{
            if (!last) {
                lastItem--;
            }
        }
    }
    [self reloadDataAtItem:lastItem];
}
-(void)setPagingEnabled:(BOOL)pagingEnabled
{
    _pagingEnabled = pagingEnabled;
    [self set_pagingEnabled];
}
-(void)set_pagingEnabled
{
    if (_pagingEnabled && _cellsOfLine > 1.0) {
        self.collectionView.pagingEnabled = NO; //自定分页效果
    }else{
        self.collectionView.pagingEnabled = _pagingEnabled;//系统默认分页效果
    }
}
-(void)setCellsOfLine:(CGFloat)cellsOfLine
{
    if ([self isItemSizeCustom]) {
        return;
    }
    BOOL last = self.infiniteDragging&&![self dataIsUnavailable]?YES:NO;
    NSInteger lastItem = [self getCurryPageInteger];
    _cellsOfLine = cellsOfLine>0.0?cellsOfLine:1.0;
    BOOL curry = self.infiniteDragging&&![self dataIsUnavailable]?YES:NO;
    if (last!=curry) {
        if (last) {
            lastItem++;
        }else{
            lastItem--;
        }
    }
    [self reloadDataAtItem:lastItem];
    [self set_pagingEnabled];
}

//-(void)setCurryIndex:(CGFloat)curryIndex
//{
//    if (self.arrayData.count==0) {
//        _curryIndex = 0.0;
//        return;
//    }else{
//        NSInteger idex = curryIndex>0.0?curryIndex:0.0;
//        _curryIndex = idex>self.arrayData.count-1?self.arrayData.count-1:curryIndex;
//    }
//    self.ignorePage = YES;
//    BOOL realInfiniteDragging = self.infiniteDragging&&![self dataIsUnavailable]?YES:NO;
//    if (realInfiniteDragging) {
////        [self setContentOffsetAtIndex:_curryIndex+1.0];
//    }else{
////        [self setContentOffsetAtIndex:_curryIndex];
//    }
//    self.ignorePage = NO;
//}
#pragma mark - -----UICollectionView Delegate------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self getNumberOfItemsInSection];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.reuseIdentifier) {
        UICollectionViewCell<JLCycSrollCellDataProtocol> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.reuseIdentifier forIndexPath:indexPath];
        if (![cell conformsToProtocol:@protocol(JLCycSrollCellDataProtocol)]) {
            return cell;
        }else{
            if ([self canInfiniteDrag]) {
                if (indexPath.row == 0) {
                    [cell setJLCycSrollCellData:self.arrayData[self.arrayData.count-1]];
                }else{
                    NSInteger item = (indexPath.row-1)%self.arrayData.count;
                    [cell setJLCycSrollCellData:self.arrayData[item]];
                }
            }else{
                [cell setJLCycSrollCellData:self.arrayData[indexPath.row]];
            }
            return cell;
        }
    }else{
        JLCycScrollDefaultCell* defaultCell = [collectionView dequeueReusableCellWithReuseIdentifier:JLCycScrollDefaultCellResign forIndexPath:indexPath];
        if (self.datasource && [self.datasource respondsToSelector:@selector(jl_cycleScrollerView:defaultCell:cellForItemAtIndex:sourceArray:)]) {
            if ([self canInfiniteDrag]) {
                if (indexPath.row == 0) {
                    id data = [self.datasource jl_cycleScrollerView:self defaultCell:defaultCell cellForItemAtIndex:self.arrayData.count-1 sourceArray:self.arrayData];
                    [defaultCell setJLCycSrollCellData:data];
                }else{
                    NSInteger item = (indexPath.row-1)%self.arrayData.count;
                    id data = [self.datasource jl_cycleScrollerView:self defaultCell:defaultCell cellForItemAtIndex:item sourceArray:self.arrayData];
                    [defaultCell setJLCycSrollCellData:data];
                }
            }else{
                id data = [self.datasource jl_cycleScrollerView:self defaultCell:defaultCell cellForItemAtIndex:indexPath.row sourceArray:self.arrayData];
                [defaultCell setJLCycSrollCellData:data];
            }
            
        }else{
            if ([self canInfiniteDrag]) {
                if (indexPath.row == 0) {
                    [defaultCell setJLCycSrollCellData:self.arrayData[self.arrayData.count-1]];
                }else{
                    NSInteger item = (indexPath.row-1)%self.arrayData.count;
                    [defaultCell setJLCycSrollCellData:self.arrayData[item]];
                }
            }else{
                [defaultCell setJLCycSrollCellData:self.arrayData[indexPath.row]];
            }
        }
        return defaultCell;
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isItemSizeCustom]){
        if ([self canInfiniteDrag]) {
            if (indexPath.row == 0) {
                return [self getDelegateCellSize:self.arrayData.count-1];
            }else{
                NSInteger item = (indexPath.row-1)%self.arrayData.count;
                return [self getDelegateCellSize:item];
            }            
        }
        return [self getDelegateCellSize:indexPath.row];
    }
    return CGSizeMake([self getCellWidth], [self getCellHeight]);
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(jl_cycleScrollerView:willDisplayCell:forItemAtIndex:)]) {
        [self.delegate jl_cycleScrollerView:self willDisplayCell:cell forItemAtIndex:indexPath.row];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(jl_cycleScrollerView:didEndDisplayingCell:forItemAtIndex:)]) {
        [self.delegate jl_cycleScrollerView:self didEndDisplayingCell:cell forItemAtIndex:indexPath.row];
    }
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(jl_cycleScrollerView:didSelectItemAtIndex:sourceArray:)]) {
        if ([self canInfiniteDrag]) {
            if (indexPath.row == 0) {
                [self.delegate jl_cycleScrollerView:self didSelectItemAtIndex:self.arrayData.count-1 sourceArray:self.arrayData];
            }else{
                NSInteger item = (indexPath.row-1)%self.arrayData.count;
                [self.delegate jl_cycleScrollerView:self didSelectItemAtIndex:item sourceArray:self.arrayData];
            }
        }else{
            [self.delegate jl_cycleScrollerView:self didSelectItemAtIndex:indexPath.row sourceArray:self.arrayData];
        }
    }
}
-(BOOL)dataIsUnavailable
{
    NSInteger lineCells = ceilf(self.cellsOfLine);
    if (self.arrayData.count<lineCells)
    {
        return YES;
    }
    else if (self.arrayData.count==lineCells)
    {
        return !self.infiniteDraggingForSinglePage;
    }
    return NO;
}

-(BOOL)canInfiniteDrag
{
    return self.infiniteDragging&&![self dataIsUnavailable]?YES:NO;
}
-(NSInteger)getNumberOfItemsInSection
{
    if ([self canInfiniteDrag]) {
        return self.arrayData.count+ceilf(self.cellsOfLine)+1;
    }else{
        return self.arrayData.count;
    }
}
-(BOOL)isDVertical
{
    return self.flowLayout.scrollDirection == UICollectionViewScrollDirectionVertical;
}
-(BOOL)isItemSizeCustom
{
    return self.delegate&&[self.delegate respondsToSelector:@selector(jl_cycleScrollerView:sizeForItemAtIndex:)] ;
}
-(CGFloat)getCellWidth
{
    if ([self isDVertical]) {
        CGFloat sectionInset_left_right = self.flowLayout.sectionInset.left+self.flowLayout.sectionInset.right;
        if (self.transformSize) {
            return self.jl_width-sectionInset_left_right;
        }
        return self.collectionView.jl_width-sectionInset_left_right;
    }else{
        CGFloat sectionInset_left = self.flowLayout.sectionInset.left;
        if (self.transformSize) {
            return ceilf((self.jl_width-sectionInset_left)/self.cellsOfLine);
        }
        return ceilf((self.collectionView.jl_width-sectionInset_left)/self.cellsOfLine);
    }
}
-(CGFloat)getCellHeight
{
    if ([self isDVertical]) {
        CGFloat sectionInset_top = self.flowLayout.sectionInset.top;
        if (self.transformSize) {
            return ceilf((self.jl_height-sectionInset_top)/self.cellsOfLine);
        }
        return ceilf((self.collectionView.jl_height-sectionInset_top)/self.cellsOfLine);
    }else{
        CGFloat sectionInset_top_bottom = self.flowLayout.sectionInset.top+self.flowLayout.sectionInset.bottom;
        if (self.transformSize) {
            return self.jl_height-sectionInset_top_bottom;
        }
        return self.collectionView.jl_height-sectionInset_top_bottom;
    }
}
-(CGSize)getDelegateCellSize:(NSInteger)integer
{
    CGSize size = [self.delegate jl_cycleScrollerView:self sizeForItemAtIndex:integer];
    if ([self isDVertical]) {
        return CGSizeMake([self getCellWidth],size.height);
    }else{
        return CGSizeMake(size.width,[self getCellHeight]);
    }
}

-(void)prepareCalculateCellsOfLineIfInfiniteDrag
{
    if ([self isItemSizeCustom]) {
        if ([self isDVertical]) {
            CGFloat item_Y = self.flowLayout.sectionInset.top;
            self.arrayPlaceholderAttributes = [NSMutableArray array];
            if (self.infiniteDragging) {//此时cellsOfLine尚未计算出来
                CGSize size = [self.delegate jl_cycleScrollerView:self sizeForItemAtIndex:self.arrayData.count-1];
                UICollectionViewLayoutAttributes *att  = [[UICollectionViewLayoutAttributes alloc] init];
                att.frame = CGRectMake(0, item_Y, 0, size.height);
                [self.arrayPlaceholderAttributes addObject:att];
                item_Y+=size.height;
            }
            for (int i=0; i<self.arrayData.count; ++i) {
                CGSize size = [self.delegate jl_cycleScrollerView:self sizeForItemAtIndex:i];
                UICollectionViewLayoutAttributes *att  = [[UICollectionViewLayoutAttributes alloc] init];
                att.frame = CGRectMake(0, item_Y, 0, size.height);
                [self.arrayPlaceholderAttributes addObject:att];
                item_Y+=size.height;
                
                CGFloat max_Y = att.frame.origin.y+att.frame.size.height;
                if (self.infiniteDragging) {
                    UICollectionViewLayoutAttributes *attrFirst = self.arrayPlaceholderAttributes.firstObject;
                    max_Y-=attrFirst.frame.size.height;
                }
                if (max_Y>=self.collectionView.jl_height) {
                    _cellsOfLine = i+1.0;
                    self.collectionView.pagingEnabled = NO;//这种不管是否分页均关系统分页，采用自定义实现分页
                    break;
                }else{
                    if (i==self.arrayData.count-1) {
                        _cellsOfLine = 1.0;
                        self.collectionView.pagingEnabled = NO;
                    }
                }
            }
        }else{
            CGFloat item_X = self.flowLayout.sectionInset.left;
            self.arrayPlaceholderAttributes = [NSMutableArray array];
            if (self.infiniteDragging) {
                CGSize size = [self.delegate jl_cycleScrollerView:self sizeForItemAtIndex:self.arrayData.count-1];
                UICollectionViewLayoutAttributes *att  = [[UICollectionViewLayoutAttributes alloc] init];
                att.frame = CGRectMake(item_X, 0, size.width, 0);
                [self.arrayPlaceholderAttributes addObject:att];
                item_X+=size.width;
            }
            for (int i=0; i<self.arrayData.count; ++i) {
                CGSize size = [self.delegate jl_cycleScrollerView:self sizeForItemAtIndex:i];
                UICollectionViewLayoutAttributes *att  = [[UICollectionViewLayoutAttributes alloc] init];
                att.frame = CGRectMake(item_X, 0, size.width, 0);
                [self.arrayPlaceholderAttributes addObject:att];
                item_X+=size.width;
                
                CGFloat max_X = att.frame.origin.x+att.frame.size.width;
                if (self.infiniteDragging) {
                    UICollectionViewLayoutAttributes *attrFirst = self.arrayPlaceholderAttributes.firstObject;
                    max_X-=attrFirst.frame.size.width;
                }
                if (max_X>=self.collectionView.jl_width) {
                    _cellsOfLine = i+1;
                    self.collectionView.pagingEnabled = NO;
                    break;
                }else{
                    if (i==self.arrayData.count-1) {
                        _cellsOfLine = 1.0;
                        self.collectionView.pagingEnabled = NO;
                    }
                }
            }
        }
    }else{
        if ([self canInfiniteDrag]) {
            self.arrayPlaceholderAttributes = [NSMutableArray array];
            CGFloat item_XY = [self isDVertical]?self.flowLayout.sectionInset.top:self.flowLayout.sectionInset.left;
            for (int i=0; i<2; ++i) {//只需要两个
                UICollectionViewLayoutAttributes *att  = [[UICollectionViewLayoutAttributes alloc] init];
                if ([self isDVertical]) {
                    att.frame = CGRectMake(0, item_XY+[self getCellHeight]*i, 0, [self getCellHeight]);
                }else{
                    att.frame = CGRectMake(item_XY+[self getCellWidth]*i, 0, [self getCellWidth], 0);
                }
                [self.arrayPlaceholderAttributes addObject:att];
            }
        }
    }
}
-(void)initializeArrayAttributes
{
    self.arrayAttributes = [NSMutableArray array];
    for ( int i=0; i<[self getNumberOfItemsInSection]; ++i) {
        UICollectionViewLayoutAttributes *att = [self.flowLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [self.arrayAttributes addObject:att];
    }
    NSLog(@"arrayAttributes:\n%@\narrayPlaceholderAttributes:\n%@",self.arrayAttributes,self.arrayPlaceholderAttributes);
    self.arrayPlaceholderAttributes = nil;
}
#pragma mark - -----UIScrollView Delegate------
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger curryPage = [self getCurryPageInteger];
    if ([self canInfiniteDrag]) {
        if (curryPage == 0) {
            if (self.lastPage!=curryPage) {
                [self curryPageDidChanged:self.arrayData.count-1];
                self.lastPage = curryPage;
            }
        }else{
            NSInteger item = (curryPage-1)%self.arrayData.count;
            if (self.lastPage!=item) {
                [self curryPageDidChanged:item];
                self.lastPage = item;
            }
        }
    }else{
        if (self.lastPage!=curryPage) {
            [self curryPageDidChanged:curryPage];
            self.lastPage = curryPage;
        }
    }
    [self draggingSwitchTheForeAndAft];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self pauseTimer];
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
//    if (self.pagingEnabled && self.cellsOfLine>1.0) { //大小不同带特殊处理
//    if ([self isDVertical]) {
//            CGPoint targetContentOffsetCopy = CGPointMake(targetContentOffset->x, targetContentOffset->y);
//            NSInteger page = roundf(targetContentOffsetCopy.y/self.collectionView.jl_height*self.cellsOfLine);
//            CGFloat Y = [self getCellHeight]*page;
//            *targetContentOffset = CGPointMake(targetContentOffsetCopy.x, Y);
//        }else{
//            CGPoint targetContentOffsetCopy = CGPointMake(targetContentOffset->x, targetContentOffset->y);
//            CGFloat page = roundf(targetContentOffsetCopy.x/self.collectionView.jl_width*(CGFloat)self.cellsOfLine);
//            CGFloat X = [self getCellWidth]*page;
//            *targetContentOffset = CGPointMake(X, targetContentOffsetCopy.y);
//        }
//    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self resumeTimerAfterDuration:_timeDuration];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self resumeTimerAfterDuration:_timeDuration];
    if (self.infiniteDragging) {
        [self switchTheForeAndAft];
    }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (self.infiniteDragging) {
        [self switchTheForeAndAft];
    }
}
-(void)curryPageDidChanged:(NSInteger)curryPage
{
    if (self.pageControlNeed) {
        self.pageControl.currentPage = curryPage;
    }
    UICollectionViewCell * cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:curryPage inSection:0]];
    if (self.delegate && [self.delegate respondsToSelector:@selector(jl_cycleScrollerView:didChangeCurryCell:curryPage:)]){
        [self.delegate jl_cycleScrollerView:self didChangeCurryCell:cell curryPage:curryPage];
    }
    NSLog(@">>>>>%ld",curryPage);
}
- (void)draggingSwitchTheForeAndAft
{
    if (self.collectionView.tracking && [self canInfiniteDrag]) {
        CGFloat pageFloat = [self getCurryPageFloat];
        if (pageFloat > self.arrayData.count+1.0) {
            [self jl_setContentOffsetAtIndex:1 animated:NO];
        }
        if (pageFloat < 0.0 ) {
            [self jl_setContentOffsetAtIndex:self.arrayData.count animated:NO];
        }
    }
}
-(void)switchTheForeAndAft
{
    NSInteger page = [self getCurryPageInteger];
    if (page == self.arrayData.count+1 && ![self dataIsUnavailable]) {
        [self jl_setContentOffsetAtIndex:1 animated:NO];
    }
    if (page == 0 && ![self dataIsUnavailable]) {
        [self jl_setContentOffsetAtIndex:self.arrayData.count animated:NO];
    }
}
-(UICollectionViewScrollPosition)getScrollPosition
{
    if ([self isDVertical]) {
        return UICollectionViewScrollPositionTop;
    }else{
        return UICollectionViewScrollPositionLeft;
    }
}
-(void)jl_setContentOffsetAtIndex:(NSInteger)item animated:(BOOL)animated
{
    if (item >=0 && item<[self getNumberOfItemsInSection] ) {
        NSArray *array = [NSArray array];
        if (self.arrayAttributes.count>0) {
            array = [NSArray arrayWithArray:self.arrayAttributes];
        }else {
            array = [NSArray arrayWithArray:self.arrayPlaceholderAttributes];//还未刷新计算出arrayAttributes时
        }
        if (array>0 && item<array.count) {
            UICollectionViewLayoutAttributes *att = array[item];
            if ([self isDVertical]) {
                CGFloat offSet = att.frame.origin.y-self.flowLayout.sectionInset.top;
                [self.collectionView setContentOffset:CGPointMake(0, offSet) animated:animated];
            }else{
//                CGFloat offSet = att.frame.origin.x-self.flowLayout.sectionInset.left;
                CGFloat f = CGRectGetMidX(att.frame);
                CGFloat offSet = f -self.flowLayout.sectionInset.left;
                [self.collectionView setContentOffset:CGPointMake(offSet, 0) animated:animated];
            }
        }
    }
}
-(NSInteger)getCurryPageInteger
{
    return roundf([self getCurryPageFloat]);
}
-(CGFloat)getCurryPageFloat
{
    if ([self isDVertical]) {
        if ([self isItemSizeCustom]) {
            CGFloat contentOffset_Y = self.collectionView.contentOffset.y;
            NSArray *array = [NSArray array];
            if (self.arrayAttributes.count>0) {
                array = [NSArray arrayWithArray:self.arrayAttributes];
            }else {
                array = [NSArray arrayWithArray:self.arrayPlaceholderAttributes];
            }
            for (int i=0;i<array.count; ++i) {
                UICollectionViewLayoutAttributes *att = array[i];
                CGRect frame = att.frame; CGFloat sectionInset_top = self.flowLayout.sectionInset.top;
                if (contentOffset_Y>=CGRectGetMinY(frame)-sectionInset_top && contentOffset_Y<=CGRectGetMaxY(frame)-sectionInset_top) {
                    CGFloat pageFloat = i+(contentOffset_Y-CGRectGetMinY(frame)+sectionInset_top)/frame.size.height;
                    return pageFloat;
                }
            }
            return 0.f;
        }else{
            CGFloat H = self.transformSize?self.jl_height:self.collectionView.jl_height;
            CGFloat page = self.collectionView.contentOffset.y/(H-self.flowLayout.sectionInset.top)*self.cellsOfLine;
            return page;
        }
    }else{
        if ([self isItemSizeCustom]) {
            CGFloat contentOffset_X = self.collectionView.contentOffset.x;
            NSArray *array = [NSArray array];
            if (self.arrayAttributes.count>0) {
                array = [NSArray arrayWithArray:self.arrayAttributes];
            }else {
                array = [NSArray arrayWithArray:self.arrayPlaceholderAttributes];
            }
            for (int i=0;i<array.count; ++i) {
                UICollectionViewLayoutAttributes *att = array[i];
                CGRect frame = att.frame; CGFloat sectionInset_left = self.flowLayout.sectionInset.left;
                if (contentOffset_X>=CGRectGetMinX(frame)-sectionInset_left && contentOffset_X<=CGRectGetMaxX(frame)-sectionInset_left) {
                    CGFloat pageFloat = i+(contentOffset_X-CGRectGetMinX(frame)+sectionInset_left)/frame.size.width;
                    return pageFloat;
                }
            }
            return 0.f;
        }else{
            CGFloat W = self.transformSize?self.jl_width:self.collectionView.jl_width;
            CGFloat page = self.collectionView.contentOffset.x /(W-self.flowLayout.sectionInset.left)*self.cellsOfLine;
            return page;
        }
    }
}
-(void)automaticScrollPage
{
    if (self.transformSize)return;
    if ([self dataIsUnavailable])return;
    NSInteger page = [self getCurryPageInteger];
    if (self.infiniteDragging) {
        if (page<self.arrayData.count+1) {
            [self jl_setContentOffsetAtIndex:page+1 animated:YES];
        }
        if (page >= self.arrayData.count+1) {
            [self jl_setContentOffsetAtIndex:1 animated:NO];
        }
    }else{
        if (page<self.arrayData.count-1 ) {
            [self jl_setContentOffsetAtIndex:page+1 animated:YES];
        }
        if (page == self.arrayData.count-1) {
            [self jl_setContentOffsetAtIndex:0 animated:NO];
        }
    }
}
#pragma mark - -----NSTimer------
-(void)setTimerNeed:(BOOL)timerNeed
{
    _timerNeed = timerNeed;
    if (_timerNeed) {
        [self setupTimer];
    }else{
        [self deallocTimerIfNeed];
    }
}
- (void)setupTimer
{
    [self deallocTimerIfNeed];
    if ([self dataIsUnavailable])return;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.timeDuration+animatedTime target:self selector:@selector(automaticScrollPage) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}
-(void)setTimeDuration:(NSTimeInterval)timeDuration
{
    _timeDuration = timeDuration>=0?timeDuration:0.0;
    if (self.superview&&self.timerNeed) {
        [self setupTimer];
    }
}
-(void)pauseTimer
{
    if(self.timer&&[self.timer isValid]){
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}
-(void)resumeTimerAfterDuration:(NSTimeInterval)duration
{
    if(self.timer&&[self.timer isValid]){
        [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:duration]];
    }
}
-(void)deallocTimerIfNeed
{
    if (self.timer) {
        if (self.timer.isValid) {
            [_timer invalidate];
        }
        _timer=nil;
    }
}
#pragma mark - -----super methods------
-(void)layoutSubviews
{
    [super layoutSubviews];
    if (self.pageControlNeed) {
        [self updataPageControlFrame];
        self.pageControl.numberOfPages = self.arrayData.count;
    }
    if (!CGRectEqualToRect(self.bounds, self.collectionView.frame)) {
        CGFloat item = self.pagingEnabled?[self getCurryPageInteger]:[self getCurryPageFloat];//不分页有问题
        self.transformSize = YES;
        [self.collectionView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initializeArrayAttributes];

            if ([self canInfiniteDrag] && item<1.0) {
                [self jl_setContentOffsetAtIndex:1 animated:NO];
            }else{
                [self jl_setContentOffsetAtIndex:item animated:NO];
            }
            self.transformSize = NO;
        });
        self.collectionView.frame = self.bounds;
    }
}
- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    if (!newWindow) {
        [self deallocTimerIfNeed];
    }
}
-(void)didMoveToWindow
{
    [super didMoveToWindow];
    if (self.window) {
        if (self.timerNeed) {
            [self setupTimer];
        }
    }else{
        if (self.pagingEnabled) {
            if (self.arrayData.count>0) {
                CGFloat item = [self getCurryPageInteger];
                [self jl_setContentOffsetAtIndex:item animated:NO];
            }
        }
    }
}
-(void)applicationWillResignActive
{
    [self deallocTimerIfNeed];
}
-(void)applicationDidBecomeActive
{
    if (self.superview&&self.timerNeed) {
        [self setupTimer];
    }
}
-(void)dealloc
{
    self.collectionView.dataSource = nil;
    self.collectionView.delegate = nil;
    NSLog(@"%s",__FUNCTION__);
}

@end
