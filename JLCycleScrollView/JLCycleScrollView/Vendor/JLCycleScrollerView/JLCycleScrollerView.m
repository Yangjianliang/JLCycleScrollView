//
//  JLCycleScrollerView.m
//  JLCycleScrollView
//
//  Created by yangjianliang on 2017/9/24.
//  Copyright © 2017年 yangjianliang. All rights reserved.
//


#import "JLCycleScrollerView.h"
#import "MyFlowLayout.h"
#import "JLCycScrollFlowLayout.h"

@interface JLCycleScrollerView ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSMutableArray<__kindof UICollectionViewLayoutAttributes *> *arrayAttributes;
@property (nonatomic, strong, nullable) NSMutableArray<__kindof UICollectionViewLayoutAttributes *> * arrayPlaceholderAttributes;
@property (nonatomic, strong) NSArray *arrayData;
@property (nonatomic) JLIndexPath lastIndexPath;
@property (nonatomic, copy) NSString *reuseIdentifier;
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic) PageControlMode pageControl_X;
@property (nonatomic) PageControlMode pageControl_Y;
@property (nonatomic) BOOL transformSize;
@property (nonatomic) CGFloat outCellSpacing;


@end
static NSTimeInterval const animatedTime = 0.35;
static NSString * const JLCycScrollDefaultCellResign = @"JLCycScrollDefaultCellResign";
static CGFloat const outCellDefaultSpace = -1.0;
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
    _cellScrollPosition = JLCycScrollPositionCenterHV;
    _sectionInset =  UIEdgeInsetsZero; //UIEdgeInsetsMake(40, 40, 40, 40);//
    _cellsOfLine = 3.0 ;
    _cellsSpacing = 0.0;
    _timeDuration = 3.0;
    _timerNeed = NO;
    _infiniteDragging = YES;//
    _infiniteDraggingForSinglePage = NO;
    _scrollEnabled = NO;
    _pageControlNeed = YES;
    _pagingEnabled = NO;
    _pageControl_centerX = 0.f;
    _pageControl_botton = 10.f;
    self.arrayData = [NSArray array];
    self.outCellSpacing = outCellDefaultSpace;
    self.lastIndexPath = JLMakeIndexPath(0, 0, 0);
    self.transformSize = NO;
    self.pageControl_X = PageControlModeCenterX;
    self.pageControl_Y = PageControlModeBottom;
    self.arrayAttributes = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializeArrayAttributes:)
                                                 name:JLCycScrollFlowLayoutPrepareLayout object:nil];
}
-(void)initUI
{
    JLCycScrollFlowLayout* flowLayout = [[JLCycScrollFlowLayout alloc] init];
    flowLayout.sectionInset = self.sectionInset;
    flowLayout.scrollDirection = self.scrollDirection;
    self.flowLayout = flowLayout;
    
    UICollectionView*collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
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
}
#pragma mark  - reloadData
-(void)setSourceArray:(NSArray *)sourceArray
{
    [self deallocTimerIfNeed];
    if (self.arrayData.count>0) {
        BOOL samemMemoryddress = [sourceArray isEqualToArray:self.arrayData];
        CGFloat scrollAtItem = 0.0;
        if (samemMemoryddress) {
            CGFloat item = self.pagingEnabled?[self getCurryPageInteger]:[self getCurryPageFloat];
            scrollAtItem = item;
        }else{
            [self.arrayPlaceholderAttributes removeAllObjects];
            [self.arrayAttributes removeAllObjects];
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
    [self layoutIfNeeded];
    if (self.pageControlNeed) {
        self.pageControl.numberOfPages = self.arrayData.count;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self prepareCalculateCellsOfLine];
        
        NSLog(@">>>%ld",self.lastIndexPath.row);
        if ([self canInfiniteDrag] && item<=1.0) {
            [self jl_setContentOffsetAtIndex:1.0 animated:NO];
        }else{
            [self jl_setContentOffsetAtIndex:item animated:NO];
        }
        [self.collectionView reloadData];
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
-(void)setCustomCell:(UICollectionViewCell<JLCycSrollCellDataProtocol> *)cell isXibBuild:(BOOL)isxib
{
    if (![cell isKindOfClass:[UICollectionViewCell class]]) {
        NSLog(@"\n---------%s cell error----------",__FUNCTION__);
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
    [self setCustomPagingEnabled];
}
-(void)setCustomPagingEnabled
{
    if (_pagingEnabled && _cellsOfLine > 1.0) {//????==1，自定义情况？
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
    [self setCustomPagingEnabled];
}
-(void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
    _scrollDirection = scrollDirection;
    self.flowLayout.scrollDirection = scrollDirection;
    [self reloadDataAtItem:0.0];
}
-(void)setCellsSpacing:(CGFloat)cellsSpacing
{
    _cellsSpacing = cellsSpacing;
    [self reloadDataAtItem:[self getCurryPageFloat]];
}
-(void)setSectionInset:(UIEdgeInsets)sectionInset
{
    _sectionInset = sectionInset;
    self.flowLayout.sectionInset = _sectionInset;
}
-(void)setCellScrollPosition:(JLCycScrollPosition)cellScrollPosition
{
    _cellScrollPosition = cellScrollPosition;
    [self reloadDataAtItem:0.0];
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
        if (self.datasource && [self.datasource respondsToSelector:@selector(jl_cycleScrollerView:defaultCell:cellForItemAtIndex:sourceArray:)]) {
            NSInteger index = [self indexWithIndexPathRow:indexPath.row];
            id data = [self.datasource jl_cycleScrollerView:self defaultCell:defaultCell cellForItemAtIndex:index sourceArray:self.arrayData];
            [defaultCell setJLCycSrollCellData:data];
        }else{
            NSInteger index = [self indexWithIndexPathRow:indexPath.row];
            [defaultCell setJLCycSrollCellData:self.arrayData[index]];
        }
        return defaultCell;
    }
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return self.cellsSpacing;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return self.cellsSpacing;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isItemSizeCustom]){
        NSInteger index = [self indexWithIndexPathRow:indexPath.row];
        return [self getDelegateCellSize:index];
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
        NSInteger index = [self indexWithIndexPathRow:indexPath.row];
        [self.delegate jl_cycleScrollerView:self didSelectItemAtIndex:index sourceArray:self.arrayData];
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
        return row;
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
        NSInteger lineCells = ceilf(self.cellsOfLine);
        CGFloat LineSpacing = (lineCells-1.0)*self.cellsSpacing;
        if (self.transformSize) {
            return ceilf((self.jl_width-sectionInset_left-LineSpacing)/self.cellsOfLine);
        }
        return ceilf((self.collectionView.jl_width-sectionInset_left-LineSpacing)/self.cellsOfLine);
    }
}
-(CGFloat)getCellHeight
{
    if ([self isDVertical]) {
        CGFloat sectionInset_top = self.flowLayout.sectionInset.top;
        NSInteger lineCells = ceilf(self.cellsOfLine);
        CGFloat LineSpacing = (lineCells-1.0)*self.cellsSpacing;
        if (self.transformSize) {
            return ceilf((self.jl_height-sectionInset_top-LineSpacing)/self.cellsOfLine);
        }
        return ceilf((self.collectionView.jl_height-sectionInset_top-LineSpacing)/self.cellsOfLine);
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
-(void)prepareCalculateCellsOfLine
{
    NSLog(@"prepareCalculateCellsOfLine");
    if ([self isItemSizeCustom])
    {
        if (self.infiniteDragging)
        {
            self.arrayPlaceholderAttributes = [NSMutableArray array];
            
            CGFloat item_XY = [self isDVertical]?self.flowLayout.sectionInset.top:self.flowLayout.sectionInset.left;
            CGSize size = [self.delegate jl_cycleScrollerView:self sizeForItemAtIndex:self.arrayData.count-1];
            UICollectionViewLayoutAttributes *att  = [[UICollectionViewLayoutAttributes alloc] init];
            att.frame = CGRectMake(item_XY, item_XY,size.width, size.height);
            [self.arrayPlaceholderAttributes addObject:att];
            CGFloat LWH = [self isDVertical]?size.height:size.width;
            item_XY = item_XY+ LWH +self.cellsSpacing;
            
            for (int i=0; i<self.arrayData.count; ++i) {
                CGSize size = [self.delegate jl_cycleScrollerView:self sizeForItemAtIndex:i];
                UICollectionViewLayoutAttributes *att  = [[UICollectionViewLayoutAttributes alloc] init];
                att.frame = CGRectMake(item_XY, item_XY,size.width, size.height);
                [self.arrayPlaceholderAttributes addObject:att];
                CGFloat IWH = [self isDVertical]?size.height:size.width;
                item_XY = item_XY+ IWH +self.cellsSpacing;
                
                CGFloat max_XY = [self isDVertical]?CGRectGetMaxY(att.frame):CGRectGetMaxX(att.frame);
                UICollectionViewLayoutAttributes *attrFirst = self.arrayPlaceholderAttributes.firstObject;
                CGFloat FWH = [self isDVertical]?attrFirst.frame.size.height:attrFirst.frame.size.width;
                max_XY = max_XY-FWH-self.cellsSpacing;
                CGFloat collectWH = [self isDVertical]?self.collectionView.jl_height:self.collectionView.jl_width;
                
                if (max_XY>=collectWH) {
                    _cellsOfLine = i+1.0;
                    self.collectionView.pagingEnabled = NO;//这种不管是否分页均关闭系统分页效果,采用自定义实现分页
                    break;
                }else{
                    if (i==self.arrayData.count-1) {
                        _cellsOfLine = self.arrayData.count+1;
                        self.collectionView.pagingEnabled = NO;
                    }
                }
            }
        }
    }
    else
    {
        if ([self canInfiniteDrag]) {
            self.arrayPlaceholderAttributes = [NSMutableArray array];
            CGFloat item_XY = [self isDVertical]?self.flowLayout.sectionInset.top:self.flowLayout.sectionInset.left;
            for (int i=0; i<2; ++i) {//只需两个
                UICollectionViewLayoutAttributes *att  = [[UICollectionViewLayoutAttributes alloc] init];
                if ([self isDVertical]) {
                    att.frame = CGRectMake(0, item_XY+([self getCellHeight]+self.cellsSpacing)*i, 0, [self getCellHeight]);
                }else{
                    att.frame = CGRectMake(item_XY+([self getCellWidth]+self.cellsSpacing) *i, 0, [self getCellWidth], 0);
                }
                [self.arrayPlaceholderAttributes addObject:att];
            }
        }
    }
}
-(void)initializeArrayAttributes:(NSNotification *)sender
{
    if (sender.object == self.flowLayout) {
        [self.arrayAttributes removeAllObjects];
        for ( int i=0; i<[self getNumberOfItemsInSection]; ++i) {
            UICollectionViewLayoutAttributes *att = [self.flowLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [self.arrayAttributes addObject:att];
        }
        NSLog(@"initializeArrayAttributes");
//        NSLog(@"arrayAttributes:\n%@\narrayPlaceholderAttributes:\n%@",self.arrayAttributes,self.arrayPlaceholderAttributes);
        self.arrayPlaceholderAttributes = nil;
    }
}
#pragma mark - -----UIScrollView Delegate------
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
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
        NSLog(@"========%ld",curryIndexPath.index);
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
        CGFloat pageFloat = [self getCurryPageFloat];
        if (pageFloat > self.arrayData.count+1.0) {
            [self jl_setContentOffsetAtIndex:1 animated:NO];
        }
        if (pageFloat < 0.0 ) {
            [self jl_setContentOffsetAtIndex:self.arrayData.count animated:NO];
        }
    }
}
-(void)automaticSwitchTheForeAndAft:(BOOL)delegate
{
    NSInteger page = [self getCurryPageInteger];
    if (page == self.arrayData.count+1 && ![self dataIsUnavailable]) {
        [self delegateWillBeginAutomaticPageingCell:[self getCurryIndexPath]];
        [self jl_setContentOffsetAtIndex:1 animated:NO];
        JLIndexPath indexPath = [self getCurryIndexPath];
        [self delegateDidEndAutomaticPageingCell:indexPath];//带优化
    }
    if (page == 0 && ![self dataIsUnavailable]) {
        [self jl_setContentOffsetAtIndex:self.arrayData.count animated:NO];
    }
}
-(void)jl_setContentOffsetAtIndex:(CGFloat)item animated:(BOOL)animated
{
    if (item >=0 && item<[self getNumberOfItemsInSection] ) {
        NSMutableArray *arr = self.arrayAttributes.count>0?self.arrayAttributes:self.arrayPlaceholderAttributes;
        if (arr.count>0 && item<arr.count) {
            NSInteger row = floorf(item);//只舍不入
            UICollectionViewLayoutAttributes *att = arr[row];
            if ([self isDVertical]) {
                CGFloat offSet = att.frame.origin.y -self.flowLayout.sectionInset.top +(item-row)*(att.frame.size.height);
                if (self.outCellSpacing!=outCellDefaultSpace) {
                    offSet =offSet+ att.frame.size.height+self.outCellSpacing;
                }
                [self.collectionView setContentOffset:CGPointMake(0, offSet) animated:animated];
            }else{
                CGFloat left = self.flowLayout.sectionInset.left;
                CGFloat offSet = att.frame.origin.x -left +(item-row)*(att.frame.size.width);
                if (self.outCellSpacing!=outCellDefaultSpace) {
                    offSet =offSet+ att.frame.size.width+self.outCellSpacing;
                }
                [self.collectionView setContentOffset:CGPointMake(offSet, 0) animated:animated];
                
            }
        }
    }
}
-(JLIndexPath)getCurryIndexPath
{
    NSInteger curryRow = [self getCurryPageInteger];
    NSInteger index = [self indexWithIndexPathRow:curryRow];
    JLIndexPath indexPath = JLMakeIndexPath(index, 0, curryRow);
//    NSLog(@"indexPath.index=%ld  indexPath.section=%ld  indexPath.row=%ld",indexPath.index,indexPath.section,indexPath.row);
    return indexPath;
}
-(NSInteger)getCurryPageInteger
{
    return roundf([self getCurryPageFloat]);
}
-(CGFloat)getCurryPageFloat
{
    NSMutableArray *arr = self.arrayPlaceholderAttributes?self.arrayPlaceholderAttributes:self.arrayAttributes;
    if (arr.count==0)
    {
        NSLog(@"not initialized");
        return 0.0;
    }
    NSInteger idx = (NSInteger)arr.count-self.lastIndexPath.row;
    if (idx <=0 || idx >self.lastIndexPath.row)
    {
        int j = (int)self.lastIndexPath.row;
        for (int i= (int)self.lastIndexPath.row;i<arr.count; ++i) {
            JLPageObject *pageObjc = [self findPageFloat:arr[i]];
            if (pageObjc.isInRange) {
                CGFloat curryP = pageObjc.page+i;
                NSLog(@"后排递增==%f",curryP);//间隙时为i
                return curryP;
            }else{
                j--;
                if (j>=0){
                    JLPageObject *sPageObjc = [self findPageFloat:arr[j]];
                    if (sPageObjc.isInRange) {
                        CGFloat smallerCurryP = sPageObjc.page+j;
                        NSLog(@"后排递减==%f",smallerCurryP);
                        return smallerCurryP;
                    }
                }
            }
        }
    }else{
        int j = (int)self.lastIndexPath.row;
        for (int i= (int)self.lastIndexPath.row;i>=0; --i) {
            JLPageObject *pageObjc = [self findPageFloat:arr[i]];
            if (pageObjc.isInRange) {
                CGFloat curryP = pageObjc.page+i;
                NSLog(@"前排递减==%f",curryP);
                return curryP;
            }else{
                j++;
                if (j<arr.count) {
                    JLPageObject *sPageObjc = [self findPageFloat:arr[j]];
                    if (sPageObjc.isInRange) {
                        CGFloat smallerCurryP = sPageObjc.page+j;
                        NSLog(@"前排递增==%f",smallerCurryP);
                        return smallerCurryP;
                    }
                }
            }
        }
    }
    NSLog(@"有数据但查找不到");
    return 0.0;
}
- (JLPageObject *)findPageFloat:(UICollectionViewLayoutAttributes *)attributes
{
    if ([self isDVertical]) {
        return [self findDVerticalPageFloat:attributes];
    }else{
        return [self findDHorizontalPageFloat:attributes];
    }
}
- (JLPageObject *)findDVerticalPageFloat:(UICollectionViewLayoutAttributes *)attributes
{
    self.outCellSpacing= outCellDefaultSpace;
    CGFloat offsetY = self.collectionView.contentOffset.y ;
    CGFloat top = self.flowLayout.sectionInset.top;
    
    JLPageObject *pageObjct = [[JLPageObject alloc] init];
    CGFloat attMinY = CGRectGetMinY(attributes.frame);
    CGFloat attMaxY = CGRectGetMaxY(attributes.frame);
    BOOL isInRange = attMinY-top <= offsetY && offsetY< (attMaxY+self.cellsSpacing)-top;
    pageObjct.isInRange = isInRange;
    if (isInRange){
        CGFloat sizeH = CGRectGetHeight(attributes.frame);
        CGFloat pageFloat = (offsetY-attMinY+top)/(sizeH);
        BOOL isOutCell = pageFloat>=1.0;
        CGFloat curryPage = isOutCell?0.0:pageFloat;
        pageObjct.page = curryPage;;
        if (isOutCell) {
            self.outCellSpacing = offsetY-attMaxY+top;
            NSLog(@"outCellSpacing:%f",self.outCellSpacing);
        }
    }
    
    
    
    
    return pageObjct;
}
- (JLPageObject *)findDHorizontalPageFloat:(UICollectionViewLayoutAttributes *)attributes
{
    self.outCellSpacing= outCellDefaultSpace;
    CGFloat offsetX = self.collectionView.contentOffset.x ;
    CGFloat left = self.flowLayout.sectionInset.left;
   
    JLPageObject *pageObjct = [[JLPageObject alloc] init];
    CGFloat attMinX = CGRectGetMinX(attributes.frame);
    CGFloat attMaxX = CGRectGetMaxX(attributes.frame);
    BOOL isInRange = attMinX-left <= offsetX && offsetX< (attMaxX+self.cellsSpacing)-left;
    pageObjct.isInRange = isInRange;
    if (isInRange) {
        CGFloat sizeW = CGRectGetWidth(attributes.frame);
        CGFloat pageFloat = (offsetX-attMinX+left)/(sizeW);
        BOOL isOutCell = pageFloat>=1.0;
        CGFloat curryPage = isOutCell?0.0:pageFloat;
        pageObjct.page = curryPage;;
        if (isOutCell) {
            self.outCellSpacing = offsetX-attMaxX+left;
            NSLog(@"outCellSpacing:%f",self.outCellSpacing);
        }
    }
    return pageObjct;
}
-(void)automaticScrollPage
{
    if (self.transformSize)return;
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
        if (indexPath.row<self.arrayData.count-self.cellsOfLine) {
            [self delegateWillBeginAutomaticPageingCell:indexPath];
            [self jl_setContentOffsetAtIndex:indexPath.row+1 animated:YES];
        }
        if (indexPath.row == self.arrayData.count-self.cellsOfLine) {
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
        [self updataPageControlFrame];
        self.pageControl.numberOfPages = self.arrayData.count;
    }
    if (!CGRectEqualToRect(self.bounds, self.collectionView.frame)) {
        CGFloat item = self.pagingEnabled?[self getCurryPageInteger]:[self getCurryPageFloat];//不分页是否有问题
        self.transformSize = YES;
        [self.collectionView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"===========layoutSubviews");
            if ([self canInfiniteDrag] && item<1.0) {
                [self jl_setContentOffsetAtIndex:1 animated:NO];
            }else{
                [self jl_setContentOffsetAtIndex:item animated:NO];
            }
            self.transformSize = NO;
        });
        self.collectionView.frame = self.bounds;//系统先设置frame再刷新，所有改变Frame时手动刷新
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


@implementation JLPageObject
@end
