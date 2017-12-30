//
//  JLCycleScrollerView.h
//  JLCycleScrollView
//
//  Created by yangjianliang on 2017/9/24.
//  Copyright © 2017年 yangjianliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JLCycScrollDefaultCell.h"
#import "JLCycSrollCellDataProtocol.h"
#import "JLPageControl.h"
#import "UIView+JLFrame.h"

NS_ASSUME_NONNULL_BEGIN

@class JLCycleScrollerView;
@protocol JLCycleScrollerViewDatasource <NSObject>
@optional
/**
 使用默认轮播图cell设置Datasource会执行该方法
 @param cell 可以直接进行cell设置
 @param integer 当前cell的integer<0.1.2...>
 @param sourceArray 传入进来的原始数据
 @return 默认支持数据类型(NSString,NSURL,UIImage)会自动设置展示,其他类型可以在DataSource直接根据代理方法cel进行设置或者return 默认支持数据类型(NSString,NSURL,UIImage)
 1.eg: ExampleModel *model = = sourceArray[integer];
 [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.url] placeholderImage:nil];
 2.eg: ExampleModel *model = = sourceArray[integer];
 return model.url;
 */
-(nullable id)jl_cycleScrollerView:(JLCycleScrollerView*)view  defaultCell:(JLCycScrollDefaultCell*)cell cellForItemAtInteger:(NSInteger) integer sourceArray:(NSArray*)sourceArray;
@end
@protocol JLCycleScrollerViewDelegate <NSObject>
@optional
/**
 点击轮播Cell代理
 @param integer 点击的<0.1.2...>
 @param sourceArray 传入进来的原始数据
 */
-(void)jl_cycleScrollerView:(JLCycleScrollerView*)view didSelectItemAtInteger:(NSInteger)integer sourceArray:(NSArray*)sourceArray;
@end

@interface JLCycleScrollerView : UIView
/**可storyboard/Xib初始化，或[alloc init］方式初始化*/
- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;
/**数据源
 默认支持数据类型(NSString,NSURL,UIImage),其他类型可以在DataSource直接根据代理方法cel进行设置
 eg：
 ExampleModel *model = = sourceArray[integer];
 [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.url] placeholderImage:nil];
 */
@property (nonatomic, strong) NSArray *sourceArray;

#pragma mark ------UICollectionView设置
/**
 使用默认的cell创建轮播图则必须设置datasource,默认cell只添加了imageview子视图
 datasource只用于系统自带默认cell数据的设置，如果使用自定义的cell,即
 [useCustomCell: isXibBuild:]方法后，datasource设置无效，此时需要使用协议设置数据
 eg:参考JLCycScrollDefaultCell
 */
@property (nonatomic, weak, nullable) id<JLCycleScrollerViewDatasource>datasource;
@property (nonatomic, weak, nullable) id<JLCycleScrollerViewDelegate>delegate;

/**
 轮播图使用自定义的cell创建,cell上子控件可高度自定义
 @param cell  自定义cell必须遵循JLCycleScrollDataProtocol协议，cell执行协议方法给cell赋值,使用自定义cell不再需要datasource
 @param isxib 自定义cell是否以xib方式创建
 eg:[self.jLCycleScrollerView useCustomCell:[[JLLunBoCollectionViewCell alloc] init] isXibBuild:YES];
 */
-(void)useCustomCell:(UICollectionViewCell<JLCycSrollCellDataProtocol>*)cell isXibBuild:(BOOL)isxib ;

/** default is UICollectionViewScrollDirectionHorizontal */
@property (nonatomic) UICollectionViewScrollDirection scrollDirection;
/** default is YES. */
@property(nonatomic) BOOL scrollEnabled;
/**每行、列cell个数,default is 1. */
@property(nonatomic) NSInteger cellsOfLine;    
/**当每行、列cell个数大于一个时，是否以单个cell分页, default is YES. */
@property(nonatomic) BOOL pagingEnabled;
/**是否需要无限拖动，default is YES*/
@property(nonatomic) BOOL infiniteDrag;

#pragma mark ------pageControl设置
/**获取pageControl进行属性设置eg:pageControl.currentPageIndicatorTintColor...*/
@property (nonatomic, strong, nullable) JLPageControl* pageControl;
/**是否需要pageControl，默认YES;设置NO后pageControl=nil,如果再次设置为YES,将重新创建默认pageControl*/
@property(nonatomic, assign) BOOL pageControlNeed;

/**距离父视图边距,同一方向(水平/垂直)属性设置互斥，即同一方向上多个设置只有最后一次设置生效
 eg:
 self.jLCycleScrollerView.pageControl_left = 20;
 self.jLCycleScrollerView.pageControl_right = 15;
 最终pageControl在水平方向上距离右边距15,距离底部10，宽高为系统自动计算
 默认 pageControl_centerX=0;pageControl_botton=10;
 */
@property(nonatomic, assign) CGFloat pageControl_centerX;
@property(nonatomic, assign) CGFloat pageControl_left;
@property(nonatomic, assign) CGFloat pageControl_right;

@property(nonatomic, assign) CGFloat pageControl_top;
@property(nonatomic, assign) CGFloat pageControl_botton;
@property(nonatomic, assign) CGFloat pageControl_centerY;

/**是否需要定时器,默认YES*/
@property(nonatomic, assign) BOOL timerNeed;
/**定时器时间间隔(默认2.5s)*/
@property(nonatomic, assign)NSTimeInterval timeDuration;
/**多少秒后启动,note:当视图添加、移除、push-pop等时,定时器会自动重新创建激活、销毁定时器，例如当push时，你不必考虑暂停定时器，当pop回来时，你也不必激活定时器*/
-(void)resumeTimerAfterDuration:(NSTimeInterval)duration;
/**暂停*/
-(void)pauseTimer;

@end
NS_ASSUME_NONNULL_END
