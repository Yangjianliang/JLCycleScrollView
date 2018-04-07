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
typedef NS_ENUM(NSInteger, PageControlMode) {
    PageControlModeCenterX = 0,
    PageControlModeLeft    = 1,
    PageControlModeRight   = 2 ,
    
    PageControlModeTop     = 3,
    PageControlModeBottom  = 4,
    PageControlModeCenterY = 5,
};
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
    _sectionInset = UIEdgeInsetsZero;
    _cellsOfLine = 1 ;
    _cellsLineSpacing = 0.0;
    _timeDuration = 3.0;
    _timerNeed = NO;
    _infiniteDragging = YES;
    _infiniteDraggingForSinglePage = NO;
    _scrollEnabled = NO;
    _pageControlNeed = YES;
    _pagingEnabled = YES;
    _pageControl_centerX = 0.f;
    _pageControl_botton = 10.f;
    self.arrayData = [NSArray array];
    self.lastIndexPath = JLMakeIndexPath(0, 0, 0);
    self.transformSize = NO;
    self.pageControl_X = PageControlModeCenterX;
    self.pageControl_Y = PageControlModeBottom;
    self.arrayAttributes = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializeArrayAttributes)
                                                 name:JLCycScrollFlowLayoutPrepareLayout object:nil];
}
-(void)initUI
{
    JLCycScrollFlowLayout* flowLayout = [[JLCycScrollFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = self.cellsLineSpacing;
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
        [self prepareCalculateCellsOfLine];
        if (item ==0) {
            self.lastIndexPath = JLMakeIndexPath(0, 0, 0);
        }
        if ([self canInfiniteDrag] && [self getCurryPageFloat]<1.0) {
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
-(UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index
{
    if (index>=0 && index<self.arrayData.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        return cell;
    }
    return nil;
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
    if (_pagingEnabled && _cellsOfLine > 1.0) {//????==1
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
}
-(void)setCellsLineSpacing:(CGFloat)cellsLineSpacing
{
    _cellsLineSpacing = cellsLineSpacing>0.0?cellsLineSpacing:0.0;
    self.flowLayout.minimumLineSpacing = _cellsLineSpacing;
}
-(void)setSectionInset:(UIEdgeInsets)sectionInset
{
    _sectionInset = sectionInset;
    self.flowLayout.sectionInset = _sectionInset;
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
        CGFloat LineSpacing = (lineCells-1.0)*self.cellsLineSpacing;
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
        CGFloat LineSpacing = (lineCells-1.0)*self.cellsLineSpacing;
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
    [self.arrayAttributes removeAllObjects];
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
            item_XY = item_XY+ LWH +self.cellsLineSpacing;
            
            for (int i=0; i<self.arrayData.count; ++i) {
                CGSize size = [self.delegate jl_cycleScrollerView:self sizeForItemAtIndex:i];
                UICollectionViewLayoutAttributes *att  = [[UICollectionViewLayoutAttributes alloc] init];
                att.frame = CGRectMake(item_XY, item_XY,size.width, size.height);
                [self.arrayPlaceholderAttributes addObject:att];
                CGFloat IWH = [self isDVertical]?size.height:size.width;
                item_XY = item_XY+ IWH +self.cellsLineSpacing;
                
                CGFloat max_XY = [self isDVertical]?CGRectGetMaxY(att.frame):CGRectGetMaxX(att.frame);
                UICollectionViewLayoutAttributes *attrFirst = self.arrayPlaceholderAttributes.firstObject;
                CGFloat FWH = [self isDVertical]?attrFirst.frame.size.height:attrFirst.frame.size.width;
                max_XY = max_XY-FWH-self.cellsLineSpacing;
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
                    att.frame = CGRectMake(0, item_XY+([self getCellHeight]+self.cellsLineSpacing)*i, 0, [self getCellHeight]);
                }else{
                    att.frame = CGRectMake(item_XY+([self getCellWidth]+self.cellsLineSpacing) *i, 0, [self getCellWidth], 0);
                }
                [self.arrayPlaceholderAttributes addObject:att];
            }
        }
    }
}
-(void)initializeArrayAttributes
{
    [self.arrayAttributes removeAllObjects];
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
        [self automaticSwitchTheForeAndAft];
    }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (self.infiniteDragging) {
        [self automaticSwitchTheForeAndAft];
    }
    [self delegateDidEndAutomaticPageingCell:[self getCurryIndexPath]];
}
#pragma mark func
-(void)delegateDidChangeCurryCell:(JLIndexPath)curryIndexPath
{
    if (self.pageControlNeed) {
        self.pageControl.currentPage = curryIndexPath.index;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(jl_cycleScrollerView:willChangeCurryCell:curryPage:)]){
        UICollectionViewCell * cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.lastIndexPath.row inSection:curryIndexPath.section]];
        [self.delegate jl_cycleScrollerView:self willChangeCurryCell:cell curryPage:self.lastIndexPath.index];
    }
    NSLog(@"%ld>>>>>%ld",self.lastIndexPath.index,curryIndexPath.index);
    if (self.delegate && [self.delegate respondsToSelector:@selector(jl_cycleScrollerView:didChangeCurryCell:curryPage:)]){
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
-(void)automaticSwitchTheForeAndAft
{
    NSInteger page = [self getCurryPageInteger];
    if (page == self.arrayData.count+1 && ![self dataIsUnavailable]) {
        [self jl_setContentOffsetAtIndex:1 animated:NO];
    }
    if (page == 0 && ![self dataIsUnavailable]) {
        [self jl_setContentOffsetAtIndex:self.arrayData.count animated:NO];
    }
}
-(void)jl_setContentOffsetAtIndex:(NSInteger)item animated:(BOOL)animated
{
    if (item >=0 && item<[self getNumberOfItemsInSection] ) {
        NSMutableArray *array = [NSMutableArray array];
        if (self.arrayAttributes.count>0) {
            array = [NSMutableArray arrayWithArray:self.arrayAttributes];
        }else {
            array = [NSMutableArray arrayWithArray:self.arrayPlaceholderAttributes];//还未刷新计算出arrayAttributes时
        }
        if (array.count>0 && item<array.count) {
            UICollectionViewLayoutAttributes *att = array[item];
            if ([self isDVertical]) {
                CGFloat offSet = att.frame.origin.y-self.flowLayout.sectionInset.top;
                [self.collectionView setContentOffset:CGPointMake(0, offSet) animated:animated];
            }else{
                CGFloat offSet = att.frame.origin.x-self.flowLayout.sectionInset.left;
//                CGFloat f = CGRectGetMidX(att.frame);
//                CGFloat offSet = f -self.flowLayout.sectionInset.left;
                [self.collectionView setContentOffset:CGPointMake(offSet, 0) animated:animated];
            }
        }
    }
}
-(JLIndexPath)getCurryIndexPath
{
    NSInteger curryPage = [self getCurryPageInteger];
    NSInteger index = [self indexWithIndexPathRow:curryPage];
    JLIndexPath indexPath = JLMakeIndexPath(index, 0, curryPage);
    return indexPath;
}
-(NSInteger)getCurryPageInteger
{
    return roundf([self getCurryPageFloat]);
}
-(CGFloat)getCurryPageFloat
{
    if ([self isItemSizeCustom])
    {
        CGFloat contentOffset_XY = [self isDVertical]?self.collectionView.contentOffset.y :self.collectionView.contentOffset.x ;
        CGFloat sectionInset_LeftTop = [self isDVertical]?self.flowLayout.sectionInset.top :self.flowLayout.sectionInset.left;
        NSMutableArray *arr = self.arrayPlaceholderAttributes?self.arrayPlaceholderAttributes:self.arrayAttributes;
        if (arr.count==0) {
            NSLog(@"not initialized");
            return 0;
        }
        BOOL bigger = arr.count-self.lastIndexPath.row>self.lastIndexPath.row?YES:NO;
        NSLog(@"%ld------%ld",arr.count,self.lastIndexPath.row);
        if (bigger) {
            int j = (int)self.lastIndexPath.row;//[getCurryPageFloat]作为核心及调用最为频繁的一个方法，优化查找效率
            for (int i= (int)self.lastIndexPath.row;i<arr.count; ++i) {
                UICollectionViewLayoutAttributes *biggerAttr = arr[i];
                CGFloat biggerMinXY = [self isDVertical]?CGRectGetMinY(biggerAttr.frame):CGRectGetMinX(biggerAttr.frame);
                CGFloat biggerMaxXY = [self isDVertical]?CGRectGetMaxY(biggerAttr.frame):CGRectGetMaxX(biggerAttr.frame);
                CGFloat biggerSizeWH = [self isDVertical]?biggerAttr.frame.size.height:biggerAttr.frame.size.width;
                BOOL isInRange = contentOffset_XY>=biggerMinXY-sectionInset_LeftTop && contentOffset_XY<=biggerMaxXY-sectionInset_LeftTop;
                if (isInRange) {
                    CGFloat biggerPageFloat = i+(contentOffset_XY-biggerMinXY+sectionInset_LeftTop)/biggerSizeWH;
                    NSLog(@"bigger大%f",biggerPageFloat);
                    return biggerPageFloat;
                }else{
                    j--;
                    if (j>=0) {
                        UICollectionViewLayoutAttributes *smallerAttr = arr[j];
                        CGFloat smallerMinXY = [self isDVertical]?CGRectGetMinY(smallerAttr.frame):CGRectGetMinX(smallerAttr.frame);
                        CGFloat smallerMaxXY = [self isDVertical]?CGRectGetMaxY(smallerAttr.frame):CGRectGetMaxX(smallerAttr.frame);
                        CGFloat smallerSizeWH = [self isDVertical]?smallerAttr.frame.size.height:smallerAttr.frame.size.width;
                        BOOL isInRange_smaller = contentOffset_XY>=smallerMinXY-sectionInset_LeftTop && contentOffset_XY<=smallerMaxXY-sectionInset_LeftTop;
                        if (isInRange_smaller) {
                            CGFloat smallerPageFloat = j+(contentOffset_XY-smallerMinXY+sectionInset_LeftTop)/smallerSizeWH;
                            NSLog(@"bigger小%f",smallerPageFloat);
                            return smallerPageFloat;
                        }
                    }
                }
            }
        }else{
            int j = arr.count-self.lastIndexPath.row<=0?(int)arr.count-1:(int)self.lastIndexPath.row;
            for (int i= (int)self.lastIndexPath.row;i>=0; --i) {
                UICollectionViewLayoutAttributes *smallerAttr = arr[i];
                CGFloat smallerMinXY = [self isDVertical]?CGRectGetMinY(smallerAttr.frame):CGRectGetMinX(smallerAttr.frame);
                CGFloat smallerMaxXY = [self isDVertical]?CGRectGetMaxY(smallerAttr.frame):CGRectGetMaxX(smallerAttr.frame);
                CGFloat smallerSizeWH = [self isDVertical]?smallerAttr.frame.size.height:smallerAttr.frame.size.width;
                BOOL isInRange_smaller = contentOffset_XY>=smallerMinXY-sectionInset_LeftTop && contentOffset_XY<=smallerMaxXY-sectionInset_LeftTop;
                if (isInRange_smaller) {
                    CGFloat smallerPageFloat = i+(contentOffset_XY-smallerMinXY+sectionInset_LeftTop)/smallerSizeWH;
                    NSLog(@"smaller小%f",smallerPageFloat);
                    return smallerPageFloat;
                }else{
                    j++;
                    if (j<arr.count) {
                        UICollectionViewLayoutAttributes *biggerAttr = arr[j];
                        CGFloat biggerMinXY = [self isDVertical]?CGRectGetMinY(biggerAttr.frame):CGRectGetMinX(biggerAttr.frame);
                        CGFloat biggerMaxXY = [self isDVertical]?CGRectGetMaxY(biggerAttr.frame):CGRectGetMaxX(biggerAttr.frame);
                        CGFloat biggerSizeWH = [self isDVertical]?biggerAttr.frame.size.height:biggerAttr.frame.size.width;
                        BOOL isInRange = contentOffset_XY>=biggerMinXY-sectionInset_LeftTop && contentOffset_XY<=biggerMaxXY-sectionInset_LeftTop;
                        if (isInRange) {
                            CGFloat biggerPageFloat = j+(contentOffset_XY-biggerMinXY+sectionInset_LeftTop)/biggerSizeWH;
                            NSLog(@"smaller大%f",biggerPageFloat);
                            return biggerPageFloat;
                        }
                    }
                }
            }
        }
        return 0.0;
    }
    else
    {
        if ([self isDVertical]) {
            CGFloat H = self.transformSize?self.jl_height:self.collectionView.jl_height;
            CGFloat page = self.collectionView.contentOffset.y/(H-self.flowLayout.sectionInset.top)*self.cellsOfLine;
            return page;
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
    JLIndexPath indexPath = [self getCurryIndexPath];
    if (self.infiniteDragging) {
        if (indexPath.row<self.arrayData.count+1) {
            [self delegateWillBeginAutomaticPageingCell:indexPath];
            [self jl_setContentOffsetAtIndex:indexPath.row+1 animated:YES];
        }
        if (indexPath.row >= self.arrayData.count+1) {
            [self jl_setContentOffsetAtIndex:1 animated:NO];
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
        [self.collectionView reloadData];//优化是否可以解决
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"===========");
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
