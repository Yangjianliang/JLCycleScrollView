//
//  JLCycScrViewController.m
//  JLCycleScrollView
//
//  Created by 杨建亮 on 2017/10/17.
//  Copyright © 2017年 yangjianliang. All rights reserved.
//


#define SCR_W [UIScreen mainScreen].bounds.size.width
#define SCR_H [UIScreen mainScreen].bounds.size.height

#import "ExampleOneController.h"

#import "JLCycleScrollerView.h"
#import "JLCycScrCustomCell.h"

#import "ExampleModel.h"
@interface ExampleOneController ()<JLCycleScrollerViewDatasource,JLCycleScrollerViewDelegate>
@property(nonatomic,strong)NSArray *arrayData;
@end

@implementation ExampleOneController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.arrayData =  @[
      @"http://public-read-bkt.microants.cn/app/market/face/f_m1.png",
      @"http://public-read-bkt.microants.cn/app/market/face/f_m2.png",
      @"http://public-read-bkt.microants.cn/app/market/face/f_m3.png",
      @"http://public-read-bkt.microants.cn/app/market/face/f_m4.png",
      @"http://public-read-bkt.microants.cn/app/market/face/f_m5.png",
      
  
      ];
   
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, SCR_H-50-60, SCR_W/2-10, 50)];
    [btn setTitle:@"轮播图1" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(clcikb1:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(SCR_W-SCR_W/2+20, SCR_H-50-60, SCR_W/2-10, 50)];
    [btn2 setTitle:@"轮播图2" forState:UIControlStateNormal];
    btn2.backgroundColor = [UIColor redColor];
    [btn2 addTarget:self action:@selector(clcikb2:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
}
-(void)clcikb1:(UIButton*)sender
{
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor redColor];
    [self.navigationController pushViewController:vc animated:YES];
//    JLCycleScrollerView *jlview= [[JLCycleScrollerView alloc] initWithFrame:CGRectMake(40, 100, SCR_W-80, 200)];
//    jlview.delegate = self;
//    [self.view addSubview:jlview];
//    jlview.sourceArray = _arrayData;
}
-(void)clcikb2:(UIButton*)sender
{
    JLCycleScrollerView *jlview = [[JLCycleScrollerView alloc] initWithFrame:CGRectMake(40, 350,  SCR_W-80, 60)];
    [jlview useCustomCell:[JLCycScrCustomCell new] isXibBuild:YES];
    jlview.delegate = self;
    
    jlview.scrollDirection =  UICollectionViewScrollDirectionVertical;
    jlview.scrollEnabled = NO;
    
    jlview.pageControl.jl_selDotSize = CGSizeMake(15, 5);
    jlview.pageControl.jl_norDotSize = CGSizeMake(15, 5);
    jlview.pageControl.jl_norMagrin = 4;
    jlview.pageControl.jl_selMagrin = 4;
    jlview.pageControl.jl_selDotCornerRadius = 0;
    jlview.pageControl.jl_norDotCornerRadius = 0;
    jlview.pageControl.allowChangeFrame = YES;

//    jlview.pageControlNeed = NO;

//    jlview.pageControl_right = 15;
    jlview.pageControl_centerX= 0;
    jlview.pageControl_botton = 20;
    
    [self.view addSubview:jlview];
    
    jlview.sourceArray = self.arrayData;

}
- (void)jl_cycleScrollerView:(JLCycleScrollerView *)view didSelectItemAtIndex:(NSInteger)index sourceArray:(nonnull NSArray *)sourceArray
{
    NSLog(@"点击%ld",index);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
