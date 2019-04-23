//
//  JLCycleScrollerView.m
//  JLCycleScrollView
//
//  Created by yangjianliang on 2017/9/24.
//  Copyright © 2017年 yangjianliang. All rights reserved.
//test


#import "JLCycleScrollerView.h"

@interface JLCycleScrollerView ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) JLPageManager *pageManager;
@property (nonatomic, strong, nullable) NSMutableArray<__kindof UICollectionViewLayoutAttributes *> * arrayPlaceholderAttributes;
@property (nonatomic, strong) NSArray *arrayData;
@property (nonatomic, copy) NSString *reuseIdentifier;
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic) PageControlMode pageControl_X;
@property (nonatomic) PageControlMode pageControl_Y;

@property (nonatomic) JLIndexPath lastIndexPath;

@property (nonatomic) BOOL isAutoLayoutItemSize;

@end
static NSTimeInterval const animatedTime = 0.35;
static NSString * const JLCycScrollDefaultCellResign = @"JLCycScrollDefaultCellResign";
@implementation JLCycleScrollerView
@synthesize pageControl = _pageControl;
@synthesize itemSize = _itemSize;
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
-(void)awakeFromNib
{
    [super awakeFromNib];
    [self calculateCellSizeIfNeed];
}
-(void)initDefaultData
{
    _cellScrollPosition = JLCycScrollPositionLeftTop;
    _cellsOfLine = 1.0 ;
    _itemSpacing = 0.0;
    _timeDuration = 3.0;
    _timerNeed = YES;
    _infiniteDragging = YES;
    _infiniteDraggingForSinglePage = NO;
    _keepContentOffsetWhenUpdateLayout = NO;
    _pageControlNeed = YES;
    _scrollEnabled = YES;
    _pagingEnabled = YES;
    _pageControl_centerX = 0.f;
    _pageControl_botton = 10.f;
    self.arrayData = [NSArray array];
    self.lastIndexPath = JLMakeIndexPath(0, 0, 0);
    self.pageControl_X = PageControlModeCenterX;
    self.pageControl_Y = PageControlModeBottom;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.isAutoLayoutItemSize = YES;
    [self calculateCellSizeIfNeed];
}
-(void)initUI
{
    JLCycScrollFlowLayout* flowLayout = [[JLCycScrollFlowLayout alloc] init];
    _flowLayout = flowLayout;
    
    UICollectionView*collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
    collectionView.pagingEnabled = self.pagingEnabled;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.scrollsToTop = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor redColor];
    self.collectionView = collectionView;
    [self.collectionView registerClass:[JLCycScrollDefaultCell class] forCellWithReuseIdentifier:JLCycScrollDefaultCellResign];
    [self addSubview:self.collectionView];
    
    if (@available(iOS 11.0, *)){
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self addSubview:self.pageControl];
    self.pageManager = [[JLPageManager alloc] initWithCollView:self.collectionView layout:self.flowLayout cycView:self];
    
    __weak __typeof(&*self)weakSelf = self;
    self.flowLayout.didUpdateJLCycScrollFlowLayout = ^(NSString *property) {
        [weakSelf reloadDataAtItem:0.0];
    };
}
#pragma mark  - reloadData
-(void)setSourceArray:(NSArray *)sourceArray
{
    [self deallocTimerIfNeed];
    if (self.arrayData.count>0) {
        BOOL same = [sourceArray isEqualToArray:self.arrayData];
        CGFloat scrollAtItem = 0.0;
        if (same) {
            scrollAtItem = self.pagingEnabled?[self.pageManager getCurryPageInteger]:[self.pageManager getCurryPageFloat];
        }
        self.arrayData = [NSArray arrayWithArray:sourceArray];
        [self reloadDataAtItem:scrollAtItem];
    }else{
        self.arrayData = [NSArray arrayWithArray:sourceArray];
        [self reloadDataAtItem:0.0];
    }
}
-(NSArray *)sourceArray
{
    return [NSArray arrayWithArray:self.arrayData];
}
-(void)reloadDataAtItem:(CGFloat)item
{
    [self deallocTimerIfNeed];
    if (self.pageControlNeed) {
        self.pageControl.numberOfPages = self.arrayData.count;
        [self updataPageControlFrame];
    }
    [self calculateCellSizeIfNeed];
    _cellsOfLine =  [self.pageManager prepareCalculateCellsOfLine];
    [self updateCustomPagingEnabled];//
    if ([self canInfiniteDrag] && item<=1.0) {
        [self jl_setContentOffsetAtIndex:1.0 animated:NO];
    }else{
        [self jl_setContentOffsetAtIndex:item animated:NO];
    }
    [self.collectionView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.superview&&self.timerNeed) {
            [self setupTimer];
        }
    });
}
#pragma mark - -----PageControl------
-(void)setPageControl:(JLPageControl *)pageControl
{
    if (!pageControl) {
        self.pageControlNeed = NO;
    }
    if ([pageControl isKindOfClass:[JLPageControl class]]) {
        self.pageControlNeed = NO;
        [self addSubview:pageControl];
        _pageControl = pageControl;
    }
}
-(JLPageControl *)pageControl
{
    if (!_pageControl && _pageControlNeed) {
        JLPageControl* pageControl = [[JLPageControl alloc] init];
        pageControl.hidesForSinglePage = YES;
        _pageControl = pageControl;
    }
    return _pageControl;
}
-(void)updataPageControlFrame
{
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
-(void)setCustomCell:(UICollectionViewCell<JLCycSrollCellDataProtocol> *)cell isXibBuild:(BOOL)isxib
{
    if (![cell isKindOfClass:[UICollectionViewCell class]]) {
        NSLog(@"\n---------%s cell error----------",__FUNCTION__);
        return;
    }
    NSString* cellName =  NSStringFromClass([cell class]);
    self.reuseIdentifier = [NSString stringWithFormat:@"%@Resign",cellName];
    if (isxib) {
        [self.collectionView registerNib:[UINib nibWithNibName:cellName bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:self.reuseIdentifier];
    }else{
        [self.collectionView registerClass:[cell class] forCellWithReuseIdentifier:self.reuseIdentifier];
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
-(void)setInfiniteDragging:(BOOL)infiniteDragging
{
    BOOL changed =_infiniteDragging==infiniteDragging?NO:YES;
    CGFloat lastItem = self.pagingEnabled?[self.pageManager getCurryPageInteger]:[self.pageManager getCurryPageFloat];
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
    if (self.keepContentOffsetWhenUpdateLayout) {
        [self reloadDataAtItem:lastItem];
    }else{
        [self reloadDataAtItem:0.0];
    }
}
-(void)setCellsOfLine:(CGFloat)cellsOfLine
{
    if ([self isItemSizeCustom]) {
        return;
    }
    self.isAutoLayoutItemSize = YES;
    [self calculateCellSizeIfNeed];

    BOOL last  = [self canInfiniteDrag];
    CGFloat lastItem = self.pagingEnabled?[self.pageManager getCurryPageInteger]:[self.pageManager getCurryPageFloat];
    _cellsOfLine = cellsOfLine>0.0?cellsOfLine:1.0;//cell必须大于0，否则为默认值1
    BOOL curry = [self canInfiniteDrag];
    if (last!=curry) {
        if (last) {
            lastItem++;
        }else{
            lastItem--;
        }
    }
    if (self.keepContentOffsetWhenUpdateLayout) {
        [self reloadDataAtItem:lastItem];
    }else{
        [self reloadDataAtItem:0.0];
    }
    [self updateCustomPagingEnabled];
}
-(void)setItemSpacing:(CGFloat)itemSpacing
{
     CGFloat lastItem = self.pagingEnabled?[self.pageManager getCurryPageInteger]:[self.pageManager getCurryPageFloat];
    _itemSpacing = itemSpacing;
    if (self.keepContentOffsetWhenUpdateLayout) {
        [self reloadDataAtItem:lastItem];
    }else{
        [self reloadDataAtItem:0.0];
    }
}
-(void)setCellScrollPosition:(JLCycScrollPosition)cellScrollPosition
{
    _cellScrollPosition = cellScrollPosition;//JLCycScrollPositionCenterHV is not development
    [self reloadDataAtItem:0.0];
}
-(void)setPagingEnabled:(BOOL)pagingEnabled
{
    _pagingEnabled = pagingEnabled;
    [self updateCustomPagingEnabled];
}
-(void)updateCustomPagingEnabled
{
    if ([self isItemSizeCustom]) {
        self.collectionView.pagingEnabled = NO;//这种不管是否分页，均关闭系统分页效果(不然影响自定义分页),采用自定义实现按cell分页
    }else{
        if (_pagingEnabled && _cellsOfLine > 1.0) {
            self.collectionView.pagingEnabled = NO; //采用自定义实现按cell分页
        }else{
            self.collectionView.pagingEnabled = _pagingEnabled;//系统默认分页效果
        }
    }
}
-(CGFloat)curryIndex
{
    return [self.pageManager getCurryPageFloat];
}
-(void)setCurryIndex:(CGFloat)curryIndex
{
    [self jl_setContentOffsetAtIndex:curryIndex animated:NO];
}
-(void)setItemSize:(CGSize)itemSize
{
    _itemSize = itemSize;
    self.isAutoLayoutItemSize = NO;
    [self reloadDataAtItem:0.0];
}
-(CGSize)itemSize
{
    if ([self isItemSizeCustom]) {
        return CGSizeZero;
    }
    return _itemSize;
}

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
            NSInteger index = [self indexWithIndexPathRow:indexPath.row];
            [cell setJLCycSrollCellData:self.arrayData[index]];
            return cell;
        }
    }else{
        JLCycScrollDefaultCell* defaultCell = [collectionView dequeueReusableCellWithReuseIdentifier:JLCycScrollDefaultCellResign forIndexPath:indexPath];
        NSInteger index = [self indexWithIndexPathRow:indexPath.row];
        if (self.datasource && [self.datasource respondsToSelector:@selector(jl_cycleScrollerView:defaultCell:cellForItemAtIndex:sourceArray:)]) {
            id data = [self.datasource jl_cycleScrollerView:self defaultCell:defaultCell cellForItemAtIndex:index sourceArray:self.arrayData];
            [defaultCell setJLCycSrollCellData:data];
        }else{
            [defaultCell setJLCycSrollCellData:self.arrayData[index]];
        }
        return defaultCell;
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isItemSizeCustom]){
        NSInteger index = [self indexWithIndexPathRow:indexPath.row];
        return [self getDelegateCellSize:index];
    }
    return self.itemSize;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return self.itemSpacing;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return self.itemSpacing;
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(jl_cycleScrollerView:willDisplayCell:forItemAtIndex:)]) {
        NSInteger index = [self indexWithIndexPathRow:indexPath.row];
        [self.delegate jl_cycleScrollerView:self willDisplayCell:cell forItemAtIndex:index];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(jl_cycleScrollerView:didEndDisplayingCell:forItemAtIndex:)]) {
        NSInteger index = [self indexWithIndexPathRow:indexPath.row];
        [self.delegate jl_cycleScrollerView:self didEndDisplayingCell:cell forItemAtIndex:index];
    }
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(jl_cycleScrollerView:didSelectItemAtIndex:sourceArray:)]) {
        NSInteger index = [self indexWithIndexPathRow:indexPath.row];
        [self.delegate jl_cycleScrollerView:self didSelectItemAtIndex:index sourceArray:self.arrayData];
    }
}
-(BOOL)dataIsUnavailable
{
    NSInteger lineCells = ceilf(_cellsOfLine);
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
        return 1+ self.arrayData.count +ceilf(_cellsOfLine);
    }else{
        return self.arrayData.count;
    }
}
-(NSInteger )indexWithIndexPathRow:(NSInteger)row
{
    if ([self canInfiniteDrag]) {
        if (row == 0) {
            return self.arrayData.count-1;
        }else{
            NSInteger item = (row-1)%self.arrayData.count;
            return item;
        }
    }else{
        return row%self.arrayData.count;
    }
}
-(BOOL)isDVertical
{
    return self.flowLayout.scrollDirection == UICollectionViewScrollDirectionVertical;
}
-(BOOL)isItemSizeCustom
{
    return self.delegate&&[self.delegate respondsToSelector:@selector(jl_cycleScrollerView:sizeForItemAtIndex:preLayout:)] ;
}
-(CGSize)getDelegateCellSize:(NSInteger)integer
{
    CGSize size = [self.delegate jl_cycleScrollerView:self sizeForItemAtIndex:integer preLayout:NO];
    if ([self isDVertical]) {
        return CGSizeMake([self getCellWidth],size.height);
    }else{
        return CGSizeMake(size.width,[self getCellHeight]);
    }
}
-(void)calculateCellSizeIfNeed
{
    CGSize size = self.itemSize;
    if ([self isDVertical]) {
        size.width = [self getCellWidth];
        if (self.isAutoLayoutItemSize) {
            size.height = [self getCellHeight];
        }
    }else{
        if (self.isAutoLayoutItemSize) {
            size.width = [self getCellWidth];
        }
        size.height = [self getCellHeight];
    }
    _itemSize = size;
}
-(CGFloat)getCellWidth
{
    if ([self isDVertical]) {
        CGFloat sectionInset_left_right = self.flowLayout.sectionInset.left+self.flowLayout.sectionInset.right;
        return self.jl_width-sectionInset_left_right;
    }else{
        CGFloat sectionInset_left = self.flowLayout.sectionInset.left;
        NSInteger lineCells = ceilf(self.cellsOfLine);
        CGFloat LineSpacing = (lineCells-1.0)*self.itemSpacing;
        return ceilf((self.jl_width-sectionInset_left-LineSpacing)/self.cellsOfLine);
    }
}
-(CGFloat)getCellHeight
{
    if ([self isDVertical]) {
        CGFloat sectionInset_top = self.flowLayout.sectionInset.top;
        NSInteger lineCells = ceilf(self.cellsOfLine);
        CGFloat LineSpacing = (lineCells-1.0)*self.itemSpacing;
        return ceilf((self.jl_height-sectionInset_top-LineSpacing)/self.cellsOfLine);
    }else{
        CGFloat sectionInset_top_bottom = self.flowLayout.sectionInset.top+self.flowLayout.sectionInset.bottom;
        return self.jl_height-sectionInset_top_bottom;
    }
}

#pragma mark - -----UIScrollView Delegate------
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"scrollViewDidScroll----%.2f",[self.pageManager getCurryPageFloat]);
    JLIndexPath indexPath = [self getCurryIndexPath];
    if (indexPath.index != self.lastIndexPath.index) {
        [self delegateDidChangeCurryCell:indexPath];
    }
    [self draggingSwitchTheForeAndAft];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self pauseTimer];
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
//    NSLog(@"AA__RR_%s",__FUNCTION__);

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
        [self automaticSwitchTheForeAndAft:NO];
    }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self delegateDidEndAutomaticPageingCell:[self getCurryIndexPath]];
    if (self.infiniteDragging) {
        [self automaticSwitchTheForeAndAft:YES];
    }
}
#pragma mark func
-(BOOL)isDelegateWillChangeCurryCell
{
    BOOL willD = self.delegate&&[self.delegate respondsToSelector:@selector(jl_cycleScrollerView:willChangeCurryCell:curryPage:)] ;
    return willD ;
}
-(BOOL)isDelegateDidChangeCurryCell
{
    BOOL didD = self.delegate&&[self.delegate respondsToSelector:@selector(jl_cycleScrollerView:didChangeCurryCell:curryPage:)] ;
    return didD ;
}
-(void)delegateDidChangeCurryCell:(JLIndexPath)curryIndexPath
{
    if (self.pageControlNeed) {
        self.pageControl.currentPage = curryIndexPath.index;
    }
    if ([self isDelegateWillChangeCurryCell]) {
        UICollectionViewCell * cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.lastIndexPath.row inSection:curryIndexPath.section]];
        [self.delegate jl_cycleScrollerView:self willChangeCurryCell:cell curryPage:self.lastIndexPath.index];
    }
//        NSLog(@"========%ld",curryIndexPath.index);
//    NSLog(@"%ld>>>>>%ld",self.lastIndexPath.index,curryIndexPath.index);
    if ([self isDelegateDidChangeCurryCell]){
        UICollectionViewCell * cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:curryIndexPath.row inSection:curryIndexPath.section]];
        [self.delegate jl_cycleScrollerView:self didChangeCurryCell:cell curryPage:curryIndexPath.index];
    }
    self.lastIndexPath = curryIndexPath;
}
- (void)draggingSwitchTheForeAndAft
{
    if (self.collectionView.tracking && [self canInfiniteDrag]) {
        CGFloat pageFloat = [self.pageManager getCurryPageFloat];
        if (pageFloat > self.arrayData.count+1.0) {
            [self jl_setContentOffsetAtIndex:1 animated:NO];
        }
        if (pageFloat < 0.0 ) {
            [self jl_setContentOffsetAtIndex:self.arrayData.count animated:NO];
        }
    }
}
-(void)automaticSwitchTheForeAndAft:(BOOL)isScrollingAnimation
{
    NSInteger page = [self.pageManager getCurryPageInteger];
    if (page == self.arrayData.count+1 && ![self dataIsUnavailable]) {
        if (isScrollingAnimation) {
            [self delegateWillBeginAutomaticPageingCell:[self getCurryIndexPath]];
        }
        [self jl_setContentOffsetAtIndex:1 animated:NO];
        if (isScrollingAnimation) {
            JLIndexPath indexPath = [self getCurryIndexPath];
            [self delegateDidEndAutomaticPageingCell:indexPath];//待优化
        }
    }
    if (page == 0 && ![self dataIsUnavailable]) {
        [self jl_setContentOffsetAtIndex:self.arrayData.count animated:NO];
    }
}
-(void)jl_setContentOffsetAtIndex:(CGFloat)item animated:(BOOL)animated
{
    [self.pageManager jl_setContentOffsetAtIndex:item animated:animated];
}
-(JLIndexPath)getCurryIndexPath
{
    NSInteger curryRow = [self.pageManager getCurryPageInteger];
    NSInteger index = [self indexWithIndexPathRow:curryRow];
    JLIndexPath indexPath = JLMakeIndexPath(index, 0, curryRow);
//    NSLog(@"indexPath.index=%ld  indexPath.section=%ld  indexPath.row=%ld",indexPath.index,indexPath.section,indexPath.row);
    return indexPath;
}

-(void)automaticScrollPage
{
    if ([self dataIsUnavailable])return;
    JLIndexPath indexPath = [self getCurryIndexPath];
    if (self.infiniteDragging) {
        if (indexPath.row<self.arrayData.count+1) {
            [self delegateWillBeginAutomaticPageingCell:indexPath];
            [self jl_setContentOffsetAtIndex:indexPath.row+1 animated:YES];
        }
        if (indexPath.row >= self.arrayData.count+1) {
            [self delegateWillBeginAutomaticPageingCell:indexPath];
            [self jl_setContentOffsetAtIndex:1 animated:NO];
            [self delegateDidEndAutomaticPageingCell:[self getCurryIndexPath]];
        }
    }else{
        if (indexPath.row<self.arrayData.count-_cellsOfLine) {
            [self delegateWillBeginAutomaticPageingCell:indexPath];
            [self jl_setContentOffsetAtIndex:indexPath.row+1 animated:YES];
        }
        if (indexPath.row == self.arrayData.count-_cellsOfLine) {
            [self delegateWillBeginAutomaticPageingCell:indexPath];
            [self jl_setContentOffsetAtIndex:0 animated:NO];
            [self delegateDidEndAutomaticPageingCell:[self getCurryIndexPath]];
        }
    }
}
-(void)delegateWillBeginAutomaticPageingCell:(JLIndexPath)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(jl_cycleScrollerView:willBeginAutomaticPageingCell:curryIndex:)]) {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        [self.delegate jl_cycleScrollerView:self willBeginAutomaticPageingCell:cell curryIndex:indexPath.index];
    }
}
-(void)delegateDidEndAutomaticPageingCell:(JLIndexPath)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(jl_cycleScrollerView:didEndAutomaticPageingCell:curryIndex:)]) {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        [self.delegate jl_cycleScrollerView:self didEndAutomaticPageingCell:cell curryIndex:indexPath.index];
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
        self.pageControl.numberOfPages = self.arrayData.count;
        [self updataPageControlFrame];
    }

    [self calculateCellSizeIfNeed];
    _cellsOfLine =  [self.pageManager prepareCalculateCellsOfLine];
    if (!CGRectEqualToRect(self.bounds, self.collectionView.frame)) {
        CGFloat item = self.pagingEnabled?[self.pageManager getCurryPageInteger]:[self.pageManager getCurryPageFloat];
        [self.collectionView reloadData];
        self.collectionView.frame = self.bounds;//Frame改变时系统刷新会先设置frame再刷新，所以Frame改变前手动刷新
        if ([self canInfiniteDrag] && item<1.0) {
            [self jl_setContentOffsetAtIndex:1.0 animated:NO];
        }else{
            [self jl_setContentOffsetAtIndex:item animated:NO];
        }
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
                CGFloat item = [self.pageManager getCurryPageFloat];
                CGFloat page = roundf(item)*1.0;
                if (item!=page) {
                    NSLog(@"刚好滚动卡住啦，正在修正");
                    [self jl_setContentOffsetAtIndex:item animated:NO];
                }
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



