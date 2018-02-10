//
//  JLCycleScrollerView.m
//  JLCycleScrollView
//
//  Created by yangjianliang on 2017/9/24.
//  Copyright © 2017年 yangjianliang. All rights reserved.
//


#import "JLCycleScrollerView.h"
typedef NS_ENUM(NSInteger, PageControlMode) {
    PageControlModeCenterX = 0,
    PageControlModeLeft    = 1,
    PageControlModeRight   = 2 ,
    
    PageControlModeTop     = 3,
    PageControlModeBottom  = 4,
    PageControlModeCenterY = 5,

};
@interface JLCycleScrollerView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong ) UICollectionView *collectionView;
@property (nonatomic, strong ) UICollectionViewFlowLayout *flowLayout;
@property(nonatomic, strong) UICollectionViewCell<JLCycSrollCellDataProtocol>*custonCollectioncell;
@property(nonatomic, strong) NSArray*arrayData;
@property(nonatomic, weak) NSTimer *timer;
@property(nonatomic, assign) PageControlMode pageControl_X;
@property(nonatomic, assign) PageControlMode pageControl_Y;
@property(nonatomic, assign) CGFloat pageControl_BH;
@property(nonatomic, copy) NSString *reuseIdentifier;
@property(nonatomic, strong) NSString *minCellValue;
@property(nonatomic, assign) BOOL invalidPage;


@end
static NSString* JLCycScrollDefaultCellResign = @"JLCycScrollDefaultCellResign";
@implementation JLCycleScrollerView
@synthesize pageControl = _pageControl;
@synthesize curryIndex = _curryIndex;
#pragma mark ----初始化JLCycleScrollerView
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
    self.arrayData = [NSArray array];
    _scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _timeDuration = 2.5;
    _pageControl_botton = 10.f;
    _pageControl_centerX = 0.f;
    _cellsOfLine = 1.0 ;
    _timerNeed = YES;
    _infiniteDragging = YES;
    _infiniteDraggingForSinglePage = NO;
    _scrollEnabled = YES;
    _pageControlNeed = YES;
    _pagingEnabled = YES;
    self.pageControl_BH = 10.f;
    self.invalidPage = NO;
    self.pageControl_X = PageControlModeCenterX;
    self.pageControl_Y = PageControlModeBottom;
}
#pragma mark  - reloadData
-(void)reloadDataAtItem:(CGFloat)item
{
    [self deallocTimerIfNeed];
    [self layoutIfNeeded];
    if (self.pageControlNeed) {
        self.pageControl.numberOfPages = self.arrayData.count;//layoutIfNeeded异步相关细节
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL scrollToFirst = self.infiniteDragging&&![self dataIsUnavailable]?YES:NO;
        if (scrollToFirst && [self getCurryPageFloat]<1.0) {
            [self setContentOffsetAtIndex:1.0 animated:NO];
        }else{
            [self setContentOffsetAtIndex:item animated:NO];
        }
        [self.collectionView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.superview&&self.timerNeed) {
                [self setupTimer];
            }
        });
    });
}
-(NSArray *)sourceArray
{
    return [NSArray arrayWithArray:self.arrayData];
}
-(void)setSourceArray:(NSArray *)sourceArray
{
    [self deallocTimerIfNeed];
    BOOL sameMemory = [sourceArray isEqualToArray:self.arrayData];
    CGFloat item = self.pagingEnabled?[self getCurryPageInteger]:[self getCurryPageFloat];
    CGFloat scrollAtItem = sameMemory?item:0.0;
    self.arrayData = [NSArray arrayWithArray:sourceArray];
    [self reloadDataAtItem:scrollAtItem];
}
#pragma mark - ------UI-------
-(void)initUI
{
    [self addSubview:self.collectionView];
}
-(UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.sectionInset =  UIEdgeInsetsZero;
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
        _collectionView = collectionView;
        [self.collectionView registerClass:[JLCycScrollDefaultCell class] forCellWithReuseIdentifier:JLCycScrollDefaultCellResign];
    }
    return _collectionView;
}
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
        pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        pageControl.currentPageIndicatorTintColor = [UIColor redColor];
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
#pragma mark - -----pageControl设置------
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
#pragma park mark - ----CollectionView设置----
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
    if (_pagingEnabled && self.cellsOfLine > 1.0) {
        self.collectionView.pagingEnabled = NO;
    }else{
        self.collectionView.pagingEnabled = _pagingEnabled;
    }
}
-(void)setCellsOfLine:(CGFloat)cellsOfLine
{
    BOOL last = [self dataIsUnavailable];
    NSInteger lastItem = [self getCurryPageInteger];
    _cellsOfLine = cellsOfLine>0.0?cellsOfLine:1.0;
    BOOL curry = [self dataIsUnavailable];
    if (last!=curry) {
        if (last) {
            lastItem++;
        }else{
            lastItem--;
        }
    }
    [self reloadDataAtItem:lastItem];
    if (self.pagingEnabled && _cellsOfLine > 1.0) {
        self.collectionView.pagingEnabled = NO;
    }else{
        self.collectionView.pagingEnabled = self.pagingEnabled;
    }
}
-(NSInteger)curryIndex
{
    return [self getCurryPageInteger];
}
-(void)setCurryIndex:(NSInteger)curryIndex
{
    if (self.arrayData.count==0) {
        _curryIndex = 0.0;
        return;
    }else{
        NSInteger idex = curryIndex>0?curryIndex:0;
        _curryIndex = idex>self.arrayData.count-1?self.arrayData.count-1:curryIndex;
    }
    self.invalidPage = YES;
    if (_curryIndex==0) {
        BOOL scrollToFirst = self.infiniteDragging&&![self dataIsUnavailable]?YES:NO;
        if (scrollToFirst) {
            [self setContentOffsetAtIndex:1.0 animated:NO];
        }else{
            [self setContentOffsetAtIndex:0.0 animated:NO];
        }
    }else{
        [self setContentOffsetAtIndex:_curryIndex animated:NO];
    }
    self.invalidPage = NO;
}
#pragma mark - -----UICollectionView Delegate------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self getNumberOfItemsInSection];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.reuseIdentifier) {
        self.custonCollectioncell = [collectionView dequeueReusableCellWithReuseIdentifier:self.reuseIdentifier forIndexPath:indexPath];
        if (self.infiniteDragging) {
            if ([self dataIsUnavailable]) {
                [self.custonCollectioncell setJLCycSrollCellData:self.arrayData[indexPath.row]];
            }else{
                if (indexPath.row == 0) {
                    [self.custonCollectioncell setJLCycSrollCellData:self.arrayData[self.arrayData.count-1]];
                }else{
                    NSInteger item = (indexPath.row-1)%self.arrayData.count;
                    [self.custonCollectioncell setJLCycSrollCellData:self.arrayData[item]];
                }
            }
        }else{
            [self.custonCollectioncell setJLCycSrollCellData:self.arrayData[indexPath.row]];
        }
        return (UICollectionViewCell*)self.custonCollectioncell;
    }else{
        JLCycScrollDefaultCell* defaultCell = [collectionView dequeueReusableCellWithReuseIdentifier:JLCycScrollDefaultCellResign forIndexPath:indexPath];
        if (self.datasource && [self.datasource respondsToSelector:@selector(jl_cycleScrollerView:defaultCell:cellForItemAtInteger:sourceArray:)]) {
            if (self.infiniteDragging) {
                if ([self dataIsUnavailable]) {
                    [defaultCell setJLCycSrollCellData:[self.datasource jl_cycleScrollerView:self defaultCell:defaultCell cellForItemAtInteger:indexPath.row sourceArray:self.arrayData]];
                }else{
                    if (indexPath.row == 0) {
                        id data = [self.datasource jl_cycleScrollerView:self defaultCell:defaultCell cellForItemAtInteger:self.arrayData.count-1 sourceArray:self.arrayData];
                        [defaultCell setJLCycSrollCellData:data];
                    }else{
                        NSInteger item = (indexPath.row-1)%self.arrayData.count;
                        id data = [self.datasource jl_cycleScrollerView:self defaultCell:defaultCell cellForItemAtInteger:item sourceArray:self.arrayData];
                        [defaultCell setJLCycSrollCellData:data];
                    }
                }
            }else{
                id data = [self.datasource jl_cycleScrollerView:self defaultCell:defaultCell cellForItemAtInteger:indexPath.row sourceArray:self.arrayData];
                [defaultCell setJLCycSrollCellData:data];
            }
            
        }else{
            if (self.infiniteDragging) {
                if ([self dataIsUnavailable]) {
                    [defaultCell setJLCycSrollCellData:self.arrayData[indexPath.row]];
                }else{
                    if (indexPath.row == 0) {
                        [defaultCell setJLCycSrollCellData:self.arrayData[self.arrayData.count-1]];
                    }else{
                        NSInteger item = (indexPath.row-1)%self.arrayData.count;
                        [defaultCell setJLCycSrollCellData:self.arrayData[item]];
                    }
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
    return CGSizeMake([self getCellWidth], [self getCellHeight]);
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(jl_cycleScrollerView:didSelectItemAtInteger:sourceArray:)]) {
        if (self.infiniteDragging) {
            if ([self dataIsUnavailable]) {
                [self.delegate jl_cycleScrollerView:self didSelectItemAtInteger:indexPath.row sourceArray:self.arrayData];
            }else{
                if (indexPath.row == 0) {
                    [self.delegate jl_cycleScrollerView:self didSelectItemAtInteger:self.arrayData.count-1 sourceArray:self.arrayData];
                }else{
                    NSInteger item = (indexPath.row-1)%self.arrayData.count;
                    [self.delegate jl_cycleScrollerView:self didSelectItemAtInteger:item sourceArray:self.arrayData];
                }
            }
        }else{
            [self.delegate jl_cycleScrollerView:self didSelectItemAtInteger:indexPath.row sourceArray:self.arrayData];
        }
    }
}
-(NSInteger)getNumberOfItemsInSection
{
    if (self.infiniteDragging) {
        if ([self dataIsUnavailable]) {
            return self.arrayData.count;
        }else{
            return self.arrayData.count+ceilf(self.cellsOfLine)+1;
        }
    }else{
        return self.arrayData.count;
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
-(CGFloat)getCellWidth
{
    if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionVertical) {
        if (self.minCellValue) {
            return self.minCellValue.floatValue;
        }
        return self.collectionView.jl_width;
    }else{
        return ceilf(self.collectionView.jl_width/self.cellsOfLine);
    }
}
-(CGFloat)getCellHeight
{
    if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionVertical) {
        return ceilf(self.collectionView.jl_height/self.cellsOfLine);
    }else{
        if (self.minCellValue) {
            return self.minCellValue.floatValue;
        }
        return self.collectionView.jl_height;
    }
}
#pragma mark - -----UIScrollView Delegate------
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.pageControlNeed) {
        NSInteger page = [self getCurryPageInteger];
        if (self.infiniteDragging) {
            if ([self dataIsUnavailable]) {
                if (self.pageControl.currentPage != page) {
                    self.pageControl.currentPage = page; //减少set方法调用次数
                }
            }else{
                if (page == 0) {
                    if (self.pageControl.currentPage != self.arrayData.count-1) {
                        self.pageControl.currentPage = self.arrayData.count-1;
                    }
                }else{
                    NSInteger curryPage = (page-1)%self.arrayData.count;
                    if (self.pageControl.currentPage != curryPage) {
                        self.pageControl.currentPage = curryPage;
                    }
                }
            }
        }else{
            if (self.pageControl.currentPage != page) {
                self.pageControl.currentPage = page;
            }
        }
    }
    if (self.collectionView.tracking && ![self dataIsUnavailable] &&self.infiniteDragging) {
        CGFloat pageFloat = [self getCurryPageFloat];
        if (pageFloat > self.arrayData.count+1) {
            [self scrollToItemAtIndex:1 animated:NO];
        }
        if (pageFloat < 0 ) {
            [self scrollToItemAtIndex:self.arrayData.count animated:NO];
        }
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self pauseTimer];
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (self.pagingEnabled && self.cellsOfLine>1.0) {
        if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionVertical) {
            CGPoint targetContentOffsetCopy = CGPointMake(targetContentOffset->x, targetContentOffset->y);
            NSInteger page = roundf(targetContentOffsetCopy.y/self.collectionView.jl_height*self.cellsOfLine);
            CGFloat Y = [self getCellHeight]*page;
            *targetContentOffset = CGPointMake(targetContentOffsetCopy.x, Y);
        }else{
            CGPoint targetContentOffsetCopy = CGPointMake(targetContentOffset->x, targetContentOffset->y);
            CGFloat page = roundf(targetContentOffsetCopy.x/self.collectionView.jl_width*(CGFloat)self.cellsOfLine);
            CGFloat X = [self getCellWidth]*page;
            *targetContentOffset = CGPointMake(X, targetContentOffsetCopy.y);
        }
    }
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
-(void)switchTheForeAndAft
{
    NSInteger page = [self getCurryPageInteger];
    if (page == self.arrayData.count+1 && ![self dataIsUnavailable]) {
        [self scrollToItemAtIndex:1 animated:NO];
    }
    if (page == 0 && ![self dataIsUnavailable]) {
        [self scrollToItemAtIndex:self.arrayData.count animated:NO];
    }
}
-(UICollectionViewScrollPosition)getScrollPosition
{
    if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionVertical) {
        return UICollectionViewScrollPositionTop;
    }else{
        return UICollectionViewScrollPositionLeft;
    }
}
-(void)setContentOffsetAtIndex:(CGFloat)item animated:(BOOL)animated
{
    if (item >=0 && item<[self getNumberOfItemsInSection]) {
        if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionVertical) {
            CGFloat offSet = [self getCellHeight]*item;
            [self.collectionView setContentOffset:CGPointMake(0, offSet) animated:animated];
        }else{
            CGFloat offSet = [self getCellWidth]*item;
            [self.collectionView setContentOffset:CGPointMake(offSet, 0) animated:animated];
        }
    }
}
-(void)scrollToItemAtIndex:(NSInteger)item animated:(BOOL)animated
{
    if (item >=0 && item<[self getNumberOfItemsInSection]) {
        NSIndexPath *IndexPathDefault = [NSIndexPath indexPathForItem:item inSection:0];
        [self.collectionView scrollToItemAtIndexPath:IndexPathDefault atScrollPosition:[self getScrollPosition] animated:animated];
    }
}
-(NSInteger)getCurryPageInteger
{
    return roundf([self getCurryPageFloat]);
}
-(CGFloat)getCurryPageFloat
{
    if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionVertical) {
        CGFloat page = self.collectionView.contentOffset.y / self.collectionView.jl_height*self.cellsOfLine;
        return page;
    }else{
        CGFloat page = self.collectionView.contentOffset.x / self.collectionView.jl_width*self.cellsOfLine;
        return page;
    }
}
-(void)automaticScrollPage
{
    if (self.invalidPage)return;
    if ([self dataIsUnavailable])return;
    NSInteger page = [self getCurryPageInteger];
    if (self.infiniteDragging) {
        if (page<self.arrayData.count+1) {
            [self scrollToItemAtIndex:page+1 animated:YES];
        }
        if (page >= self.arrayData.count+1) {
            [self scrollToItemAtIndex:1 animated:NO];
        }
    }else{
        if (page<self.arrayData.count-1 ) {
            [self scrollToItemAtIndex:page+1 animated:YES];
        }
        if (page == self.arrayData.count-1) {
            [self scrollToItemAtIndex:0 animated:NO];
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
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.timeDuration target:self selector:@selector(automaticScrollPage) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}
-(void)setTimeDuration:(NSTimeInterval)timeDuration
{
    _timeDuration = timeDuration>=0?timeDuration:0;
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
#pragma mark - layoutSubviews
-(void)layoutSubviews
{
    [super layoutSubviews];
    if (self.pageControlNeed) {
        [self updataPageControlFrame];
        self.pageControl.numberOfPages = self.arrayData.count;
    }
    if (!CGRectEqualToRect(self.bounds, self.collectionView.frame)) {
        if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionVertical) {
            if (self.jl_width<self.collectionView.jl_width) {//非滚动方向布局变小collectionView优化处理
                self.minCellValue = [NSString stringWithFormat:@"%f",self.jl_width];
            }
        }else{
            if (self.jl_height<self.collectionView.jl_height) {
                self.minCellValue = [NSString stringWithFormat:@"%f",self.jl_height];
            }
        }
        CGFloat item = self.pagingEnabled?[self getCurryPageInteger]:[self getCurryPageFloat];
        self.invalidPage = YES;
        [self.collectionView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.minCellValue = nil;
            self.collectionView.frame = self.bounds;
            BOOL scrollToFirst = self.infiniteDragging&&![self dataIsUnavailable]?YES:NO;
            if (scrollToFirst && item<1.0) {
                [self setContentOffsetAtIndex:1.0 animated:NO];
            }else{
                [self setContentOffsetAtIndex:item animated:NO];
            }
            self.invalidPage = NO;
        });
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
                [self setContentOffsetAtIndex:item animated:NO];
            }
        }
    }
}
-(void)dealloc
{
    self.collectionView.dataSource = nil;
    self.collectionView.delegate = nil;
    NSLog(@"%s",__FUNCTION__);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
