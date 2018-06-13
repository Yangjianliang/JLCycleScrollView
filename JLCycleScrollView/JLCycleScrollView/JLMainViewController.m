//
//  JLMainViewController.m
//  JLCycleScrollView
//
//  Created by 杨建亮 on 2017/12/24.
//  Copyright © 2017年 yangjianliang. All rights reserved.
//

#import "JLMainViewController.h"
#import "JLCycScrCustomCell.h"
#import "ExampleModel.h"
@interface JLMainViewController ()<JLCycleScrollerViewDelegate,JLCycleScrollerViewDatasource>
@property(nonatomic,strong)NSArray *arrayData;

@end

@implementation JLMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"All Functions";
    self.setContentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    
    
    self.arrayData =  @[
                        @"http://public-read-bkt.microants.cn/app/market/face/f_m1.png",
                        @"http://public-read-bkt.microants.cn/app/market/face/f_m2.png",
                        @"http://public-read-bkt.microants.cn/app/market/face/f_m3.png",
                        @"http://public-read-bkt.microants.cn/app/market/face/f_m4.png",
                        @"http://public-read-bkt.microants.cn/app/market/face/f_m5.png",
                        
//                        @"http://public-read-bkt.microants.cn/app/market/face/f_m1.png",
//                        @"http://public-read-bkt.microants.cn/app/market/face/f_m2.png",
//                        @"http://public-read-bkt.microants.cn/app/market/face/f_m3.png",
//                        @"http://public-read-bkt.microants.cn/app/market/face/f_m4.png",
//                        @"http://public-read-bkt.microants.cn/app/market/face/f_m5.png",
//                        @"http://public-read-bkt.microants.cn/app/market/face/f_m1.png",
//                        @"http://public-read-bkt.microants.cn/app/market/face/f_m2.png",
//                        @"http://public-read-bkt.microants.cn/app/market/face/f_m3.png",
//                        @"http://public-read-bkt.microants.cn/app/market/face/f_m4.png",
//                        @"http://public-read-bkt.microants.cn/app/market/face/f_m5.png",
                        ];
    self.jiCycScrollerView.sourceArray = self.arrayData;
    
    self.jiCycScrollerView.pageControl.pageIndicatorTintColor = [UIColor purpleColor];
    self.jiCycScrollerView.pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    
}
#pragma mark - UISwitch
- (IBAction)scrollEnabledSwitch:(UISwitch *)sender {
    self.jiCycScrollerView.scrollEnabled = sender.on;
    if (sender.on) {
        self.scrollEnabledLabel.textColor = [UIColor purpleColor];
    }else{
        self.scrollEnabledLabel.textColor = [UIColor blackColor];
    }
}
- (IBAction)pagingEnabledSwitch:(UISwitch *)sender {
    self.jiCycScrollerView.pagingEnabled = sender.on;
    if (sender.on) {
        self.pagingEnabledLabel.textColor = [UIColor purpleColor];
    }else{
        self.pagingEnabledLabel.textColor = [UIColor blackColor];
    }
}
- (IBAction)infiniteDraggingSwitch:(UISwitch *)sender {
    self.jiCycScrollerView.infiniteDragging = sender.on;
    if (sender.on) {
        self.infiniteDraggingLabel.textColor = [UIColor purpleColor];
    }else{
        self.infiniteDraggingLabel.textColor = [UIColor blackColor];
    }
}
- (IBAction)pageControlNeedSwitch:(UISwitch *)sender {
    self.jiCycScrollerView.pageControlNeed = sender.on;
    if (sender.on) {
        self.pageControlNeedLabel.textColor = [UIColor purpleColor];
    }else{
        self.pageControlNeedLabel.textColor = [UIColor blackColor];
    }
}
- (IBAction)timerNeedSwitch:(UISwitch *)sender {
    self.jiCycScrollerView.timerNeed = sender.on;
    if (sender.on) {
        self.timerNeedLabel.textColor = [UIColor purpleColor];
    }else{
        self.timerNeedLabel.textColor = [UIColor blackColor];
    }
}
- (IBAction)scrollDirectionSwitch:(UISwitch *)sender {
//    self.jiCycScrollerView.scrollDirection = sender.on;
    if (sender.on) {
        self.scrollDirectionLabel.text = @"scrollDirection-H";
        self.scrollDirectionLabel.textColor = [UIColor purpleColor];
    }else{
        self.scrollDirectionLabel.text = @"scrollDirection-V";
        self.scrollDirectionLabel.textColor = [UIColor blackColor];
    }
}
- (IBAction)useCustomCellSwitch:(UISwitch *)sender {
    if (sender.on) {
        NSMutableArray *arrayNewSorece = [NSMutableArray array];
        for (int i=0; i<self.arrayData.count; ++i) {
            ExampleModel *model = [[ExampleModel alloc] init];
            model.title = [NSString stringWithFormat:@"%d-%@",i+1,self.arrayData[i]];
            model.url = self.arrayData[i];
            [arrayNewSorece addObject:model];
        }
        self.jiCycScrollerView.sourceArray = arrayNewSorece;
        [self.jiCycScrollerView setCustomCell:[[JLCycScrCustomCell alloc]init] isXibBuild:YES];
    }else{
        self.jiCycScrollerView.sourceArray = self.arrayData;
        [self.jiCycScrollerView setCustomCell:[[JLCycScrollDefaultCell alloc]init] isXibBuild:NO];
    }
   
}
- (IBAction)cellsOfLineStepper:(UIStepper *)sender {
//    self.jiCycScrollerView.cellsOfLine = sender.value;
    self.cellsOfLineLabel.text = [NSString stringWithFormat:@"cellsOfLine=%.0f",sender.value];
}
#pragma mark - btns
- (IBAction)centerXBtn:(UIButton *)sender {
    self.centerXBtn.selected=YES;
    self.leftBtn.selected=NO;
    self.rightBtn.selected=NO;
    self.jiCycScrollerView.pageControl_centerX = 0;
    self.xslider.value = 0;
}
- (IBAction)leftBtn:(UIButton *)sender {
    self.centerXBtn.selected=NO;
    self.leftBtn.selected=YES;
    self.rightBtn.selected=NO;
    self.jiCycScrollerView.pageControl_left = 0;
    self.xslider.value = 0;
}
- (IBAction)rightBtn:(UIButton *)sender {
    self.centerXBtn.selected=NO;
    self.leftBtn.selected=NO;
    self.rightBtn.selected=YES;
    self.jiCycScrollerView.pageControl_right = 0;
    self.xslider.value = 0;
}
- (IBAction)topBtn:(UIButton *)sender {
    self.centerYBtn.selected=NO;
    self.topBtn.selected=YES;
    self.bottonBtn.selected=NO;
    self.jiCycScrollerView.pageControl_top = 0;
    self.yslider.value = 0;
}
- (IBAction)centerYBtn:(UIButton *)sender {
    self.centerYBtn.selected=YES;
    self.topBtn.selected=NO;
    self.bottonBtn.selected=NO;
    self.jiCycScrollerView.pageControl_centerY = 0;
    self.yslider.value = 0;
}
- (IBAction)bottonBtn:(UIButton *)sender {
    self.centerYBtn.selected=NO;
    self.topBtn.selected=NO;
    self.bottonBtn.selected=YES;
    self.jiCycScrollerView.pageControl_botton= 0;
    self.yslider.value = 0;
}

- (IBAction)XSlider:(UISlider *)sender {
    if (self.centerXBtn.selected) {
        self.jiCycScrollerView.pageControl_centerX = sender.value;
    }
    if (self.leftBtn.selected) {
        self.jiCycScrollerView.pageControl_left = sender.value;
    }
    if (self.rightBtn.selected) {
        self.jiCycScrollerView.pageControl_right= sender.value;
    }
}

- (IBAction)Yslider:(UISlider *)sender {
    if (self.centerYBtn.selected) {
        self.jiCycScrollerView.pageControl_centerY = sender.value;
    }
    if (self.topBtn.selected) {
        self.jiCycScrollerView.pageControl_top = sender.value;
    }
    if (self.bottonBtn.selected) {
        self.jiCycScrollerView.pageControl_botton= sender.value;
    }
}

- (IBAction)pageControlBtnSet:(UIButton *)sender {
    self.setContentView.hidden = NO;
}

#pragma mark - setContentView
- (IBAction)norsegmentC:(UISegmentedControl *)sender {
    JLPageControl * pageC = self.jiCycScrollerView.pageControl;
    CGSize size = pageC.pageIndicatorSize;
    switch (self.norSegmentC.selectedSegmentIndex) {
        case 0:
           self.norSlider.value = size.width;
            break;
        case 1:
            self.norSlider.value = size.height;
            break;
        case 2:
            self.norSlider.value = pageC.pageIndicatorRadius;
            break;
        case 3:
            self.norSlider.value = pageC.pageIndicatorSpacing;
            break;
        default:
            break;
    }
    [self updataData];
}
- (IBAction)selsegmentc:(UISegmentedControl *)sender {
    JLPageControl * pageC = self.jiCycScrollerView.pageControl;
    CGSize size = pageC.currentPageIndicatorSize;
    switch (self.selSegmentC.selectedSegmentIndex) {
        case 0:
            self.selSlider.value = size.width;
            break;
        case 1:
            self.selSlider.value = size.height;
            break;
        case 2:
            self.selSlider.value = pageC.pageIndicatorRadius;
            break;
        case 3:
            self.selSlider.value = pageC.currentPageIndicatorSpacing;
            break;
        default:
            break;
    }
    [self updataData];
}
- (IBAction)norSlider:(UISlider *)sender {
    JLPageControl * pageC = self.jiCycScrollerView.pageControl;
    CGSize size = pageC.pageIndicatorSize;
    switch (self.norSegmentC.selectedSegmentIndex) {
        case 0:
            size.width = sender.value;
            pageC.pageIndicatorSize = size;
            break;
        case 1:
            size.height = sender.value;
            pageC.pageIndicatorSize = size;
            break;
        case 2:
            pageC.pageIndicatorRadius = sender.value;
            break;
        case 3:
            pageC.pageIndicatorSpacing = sender.value;
            break;
        default:
            break;
    }
    [self updataData];
}
- (IBAction)selSlider:(UISlider *)sender {
    JLPageControl * pageC = self.jiCycScrollerView.pageControl;
    CGSize size = pageC.currentPageIndicatorSize;
    switch (self.selSegmentC.selectedSegmentIndex) {
        case 0:
            size.width = sender.value;
            pageC.currentPageIndicatorSize = size;
            break;
        case 1:
            size.height = sender.value;
            pageC.currentPageIndicatorSize = size;
            break;
        case 2:
            pageC.currentPageIndicatorRadius = sender.value;
            break;
        case 3:
            pageC.currentPageIndicatorSpacing = sender.value;
            break;
        default:
            break;
    }
    [self updataData];
}
- (IBAction)userImageSwitch:(UISwitch *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.jiCycScrollerView.pageControl.pageIndicatorImage = [UIImage imageNamed:@"nor"];
        self.jiCycScrollerView.pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"sel"];
    }else{
        self.jiCycScrollerView.pageControl.currentPageIndicatorImage = nil;
        self.jiCycScrollerView.pageControl.pageIndicatorImage = nil;

    }
    
    self.jiCycScrollerView.pageControl.allowUpdatePageIndicator = YES;

}
- (IBAction)allowchangeFrameSwitch:(UISwitch *)sender {
    if (sender.on) {
//        self.jiCycScrollerView.pageControl.jl_selDotSize = CGSizeMake(15, 6);
//        self.jiCycScrollerView.pageControl.jl_norDotSize = CGSizeMake(6, 6);
//        self.jiCycScrollerView.pageControl.jl_norMagrin = 4;
//        self.jiCycScrollerView.pageControl.jl_selMagrin = 3;
//        self.jiCycScrollerView.pageControl.jl_selDotCornerRadius = 3;
//        self.jiCycScrollerView.pageControl.jl_norDotCornerRadius = 3;
        self.jiCycScrollerView.pageControl.allowUpdatePageIndicator = YES;

        [self norSlider:self.norSlider];
        [self selSlider:self.selSlider];
    }else{
        self.jiCycScrollerView.pageControl.allowUpdatePageIndicator = NO;
    }
    [self updataData];
}
-(void)updataData
{
    JLPageControl * pageC = self.jiCycScrollerView.pageControl;
    self.norLabel.text = [NSString stringWithFormat:@"Nor:   Size_W=%.2f      Size_H=%.2f \n          Radius=%.2f      Magrin=%.2f",pageC.pageIndicatorSize.width,pageC.pageIndicatorSize.height,pageC.pageIndicatorRadius,pageC.pageIndicatorSpacing];
    self.selLabel.text = [NSString stringWithFormat:@"Sel:  Size_W=%.2f      Size_H=%.2f \n        Radius=%.2f      Magrin=%.2f",pageC.currentPageIndicatorSize.width,pageC.currentPageIndicatorSize.height,pageC.currentPageIndicatorRadius,pageC.currentPageIndicatorSpacing];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.setContentView.hidden = YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
