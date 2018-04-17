//
//  JLPageControl.h
//  JLCycleScrollView
//
//  Created by yangjianliang on 2017/9/24.
//  Copyright © 2017年 yangjianliang. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

//Add some properties to the system UIPageControl.
@interface JLPageControl : UIPageControl

//Spacing size
//设置指示器大小
@property (nonatomic, assign) CGSize pageIndicatorSize; // default is CGSizeMake(7, 7);
@property (nonatomic, assign) CGSize currentPageIndicatorSize; // default is CGSizeMake(7, 7);

// indicator Spacing
//设置指示器左右间隙
@property (nonatomic, assign) CGFloat pageIndicatorSpacing; // default is 9.f
@property (nonatomic, assign) CGFloat currentPageIndicatorSpacing; // default is 9.f eg:|o-O-o--o|

//返回计数显示点所需的最小大小
@property(nonatomic, readonly) CGSize minimumSize;
- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount;   // returns minimum size required to display dots for given page count. can be used to size control if page count could change

// indicator image
//设置指示器图片
@property (nullable, nonatomic,strong) UIImage *pageIndicatorImage; // default is nil
@property (nullable, nonatomic,strong) UIImage *currentPageIndicatorImage; // default is nil

// indicator layer.cornerRadius
//设置指示器圆角
@property (nonatomic,assign) CGFloat pageIndicatorRadius; //default is 3.5f
@property (nonatomic,assign) CGFloat currentPageIndicatorRadius; //default is 3.5f

@property(nonatomic ,assign) BOOL pageIndicatorAnimated; // default is NO

// It is necessary to set the property yes or above to be valid. After setting the above properties, it is recommended to set this property yes to update the effect.
//必须设置该属性yes以上新增属性才会有效，建议设置好以上属性后再设置此属性YES来更新生效。
@property(nonatomic ,assign) BOOL allowUpdatePageIndicator; // default is NO

@end
NS_ASSUME_NONNULL_END
