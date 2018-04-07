//
//  JLTestViewController.m
//  JLCycleScrollView
//
//  Created by 杨建亮 on 2018/4/7.
//  Copyright © 2018年 yangjianliang. All rights reserved.
//

#import "JLTestViewController.h"
#import "JLCycleScrollerView.h"
#import "ExampleModel.h"

@interface JLTestViewController ()<JLCycleScrollerViewDelegate,JLCycleScrollerViewDatasource>
@property (strong, nonatomic) JLCycleScrollerView *testView;
@property(nonatomic,strong)NSMutableArray *arrayData;

@end

@implementation JLTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initArrayData];
//    [self buildUI];

   
}
- (IBAction)testOne:(id)sender {
//    self.testView.sourceArray = self.arrayData;
    
    [self buildUI];

}
- (IBAction)testTwo:(id)sender {
    self.testView.frame = CGRectMake(40, 300, 250, 160);
}
- (IBAction)testThree:(id)sender {
    self.testView.frame = CGRectMake(40, 300, 250, 180);

}
- (IBAction)testFour:(id)sender {
    self.testView.frame = CGRectMake(40, 100, 150, 100);

}



-(void)initArrayData
{
    NSArray *array =  @[
                        @"http://public-read-bkt.microants.cn/app/market/face/f_m1.png",
                        @"http://public-read-bkt.microants.cn/app/market/face/f_m2.png",
                        @"http://public-read-bkt.microants.cn/app/market/face/f_m3.png",
                        @"http://public-read-bkt.microants.cn/app/market/face/f_m4.png",
                        @"http://public-read-bkt.microants.cn/app/market/face/f_m5.png",
                        
                        ];
    self.arrayData = [NSMutableArray array];//NSArray<ExampleModel *>
    for (int i=0; i<array.count; ++i) {
        ExampleModel *model = [[ExampleModel alloc] init];
        model.url = array[i];
        model.title = array[i];
        [self.arrayData addObject:model];
    }
}
-(void)buildUI
{
    self.testView = [[JLCycleScrollerView alloc] initWithFrame:CGRectMake(40, 300, 250, 180)];
    self.testView.datasource = self;
    self.testView.delegate = self;
    [self.view addSubview:self.testView];

    self.testView.pageControl.pageIndicatorTintColor = [UIColor purpleColor];
    self.testView.pageControl.currentPageIndicatorTintColor = [UIColor redColor];

    self.testView.sourceArray = self.arrayData;

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - -----代理-----
//使用系统cell才需要
-(id)jl_cycleScrollerView:(JLCycleScrollerView *)view defaultCell:(JLCycScrollDefaultCell *)cell cellForItemAtIndex:(NSInteger)index sourceArray:(nonnull NSArray *)sourceArray
{
    //    id 类型支持NSString、NSURL、UIImage
    ExampleModel *model = sourceArray[index];
    return model.url;
}
//- (CGSize)jl_cycleScrollerView:(JLCycleScrollerView*)view sizeForItemAtIndex:(NSInteger)index
//{
//    if (index==0) {
//        return CGSizeMake(100, 0);
//    }
//    if (index==1) {
//        return CGSizeMake(50, 0);
//    }
//    if (index==2) {
//        return CGSizeMake(200, 0);
//    }
//    return CGSizeMake(350, 0);
//
//}
- (void)jl_cycleScrollerView:(JLCycleScrollerView *)view didSelectItemAtIndex:(NSInteger)index sourceArray:(nonnull NSArray *)sourceArray
{
    NSLog(@"点击%ld",index);
}

- (void)jl_cycleScrollerView:(JLCycleScrollerView *)view willChangeCurryCell:(UICollectionViewCell *)cell curryPage:(NSInteger)curryPage
{
    NSLog(@"willChangeCurryCell:%ld",curryPage);
}
- (void)jl_cycleScrollerView:(JLCycleScrollerView *)view didChangeCurryCell:(UICollectionViewCell *)cell curryPage:(NSInteger)curryPage
{
    NSLog(@"didChangeCurryCell:%ld",curryPage);

}
- (void)jl_cycleScrollerView:(JLCycleScrollerView *)view willBeginAutomaticPageingCell:(UICollectionViewCell *)cell curryIndex:(NSInteger)curryIndex
{
    NSLog(@"willBeginAutomaticPageingCell:%ld",curryIndex);

}
- (void)jl_cycleScrollerView:(JLCycleScrollerView *)view didEndAutomaticPageingCell:(UICollectionViewCell *)cell curryIndex:(NSInteger)curryIndex
{
    NSLog(@"didEndAutomaticPageingCell:%ld \n",curryIndex);

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
