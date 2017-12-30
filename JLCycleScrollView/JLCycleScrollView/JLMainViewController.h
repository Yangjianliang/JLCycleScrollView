//
//  JLMainViewController.h
//  JLCycleScrollView
//
//  Created by 杨建亮 on 2017/12/24.
//  Copyright © 2017年 yangjianliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JLCycleScrollerView.h"
@interface JLMainViewController : UIViewController
@property (weak, nonatomic) IBOutlet JLCycleScrollerView *jiCycScrollerView;

@property (weak, nonatomic) IBOutlet UILabel *scrollEnabledLabel;
@property (weak, nonatomic) IBOutlet UILabel *pagingEnabledLabel;
@property (weak, nonatomic) IBOutlet UILabel *infiniteDraggingLabel;
@property (weak, nonatomic) IBOutlet UILabel *pageControlNeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerNeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *scrollDirectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellsOfLineLabel;
@property (weak, nonatomic) IBOutlet UILabel *useCustomCellLabel;

@property (weak, nonatomic) IBOutlet UIButton *centerXBtn;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UIButton *topBtn;
@property (weak, nonatomic) IBOutlet UIButton *centerYBtn;
@property (weak, nonatomic) IBOutlet UIButton *bottonBtn;

@property (weak, nonatomic) IBOutlet UISlider *xslider;
@property (weak, nonatomic) IBOutlet UISlider *yslider;

#pragma mark -
@property (weak, nonatomic) IBOutlet UIView *setContentView;
@property (weak, nonatomic) IBOutlet UILabel *norLabel;
@property (weak, nonatomic) IBOutlet UILabel *selLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *norSegmentC;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selSegmentC;
@property (weak, nonatomic) IBOutlet UISlider *norSlider;
@property (weak, nonatomic) IBOutlet UISlider *selSlider;

@end
