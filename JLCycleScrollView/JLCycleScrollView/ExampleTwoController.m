//
//  ExampleTwoController.m
//  JLCycleScrollView
//
//  Created by 杨建亮 on 2017/12/7.
//  Copyright © 2017年 yangjianliang. All rights reserved.
//

#import "ExampleTwoController.h"

#import "JLCycleScrollerView.h"
#import "JLCycScrCustomCell.h"
#import "ExampleModel.h"

@interface ExampleTwoController ()<JLCycleScrollerViewDatasource,JLCycleScrollerViewDelegate>
@property (weak, nonatomic) IBOutlet JLCycleScrollerView *firstJLView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstheight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstright;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstLeft;


@property(nonatomic,strong)NSMutableArray *arrayData;
@end

@implementation ExampleTwoController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    NSArray *array =  @[
                        @"http://public-read-bkt.microants.cn/app/market/face/f_m1.png",
                        @"http://public-read-bkt.microants.cn/app/market/face/f_m2.png",
                        @"http://public-read-bkt.microants.cn/app/market/face/f_m3.png",
                        @"http://public-read-bkt.microants.cn/app/market/face/f_m4.png",
                        @"http://public-read-bkt.microants.cn/app/market/face/f_m5.png",
                        
                        ];
    //NSArray<ExampleModel *>
    self.arrayData = [NSMutableArray array];
    for (int i=0; i<array.count; ++i) {
        ExampleModel *model = [[ExampleModel alloc] init];
        model.url = array[i];
        model.title = array[i];
        [self.arrayData addObject:model];
    }
    self.firstJLView.datasource = self;
     self.firstJLView.delegate = self;
//    self.firstJLView.cellFooterHeight = 20;

//    self.firstJLView.sourceArray = @[self.arrayData.lastObject];
    self.firstJLView.sourceArray = self.arrayData;

    self.firstJLView.pageControl.pageIndicatorTintColor = [UIColor purpleColor];
    self.firstJLView.pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    
//    self.firstJLView.pageControl.jl_norImage = [UIImage imageNamed:@"nor"];
//    self.firstJLView.pageControl.jl_selImage = [UIImage imageNamed:@"sel"];
//    self.firstJLView.pageControl.allowChangeFrame = YES;
    

}
- (IBAction)firstClcik:(UIButton *)sender {

    //1.
//    sender.selected = !sender.selected;
//    self.firstJLView.placeholderImage = sender.selected?nil: [UIImage imageNamed:@"placeholderImage"];

    //2.
//   NSMutableArray *arr = [NSMutableArray arrayWithArray:self.arrayData];
//    [arr removeLastObject];
//    self.firstJLView.sourceArray = arr;

//    self.firstJLView.sourceArray = self.arrayData;

    //3.
//    self.firstJLView.cellsOfLine = 1.7;
    
    //4.
//    self.firstJLView.curryIndex = 3;
    
//    self.firstJLView.infiniteDraggingForSinglePage = YES;
//    self.firstJLView.sourceArray = @[self.arrayData.lastObject];

    //5.
//    [self.firstJLView removeFromSuperview];

//    self.testJLCYCView.sourceArray = self.arrayData;
        self.firstJLView.sectionInset = UIEdgeInsetsMake(10, 20, 10, 20);

}
- (IBAction)secondClick:(id)sender {
    
    self.firstJLView.cellsLineSpacing = 20;
//    self.firstJLView.sectionInset = UIEdgeInsetsMake(10, 20, 10, 20);
//    self.firstJLView.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    
//    self.firstJLView.scrollEnabled = NO;
//
//    self.firstJLView.pageControl.jl_selDotSize = CGSizeMake(14, 14);
//    self.firstJLView.pageControl.jl_norDotSize = CGSizeMake(14, 14);
//    self.firstJLView.pageControl.jl_norMagrin = 6;
//    self.firstJLView.pageControl.jl_selMagrin = 6;
//    self.firstJLView.pageControl.jl_selDotCornerRadius = 0;
//    self.firstJLView.pageControl.jl_norDotCornerRadius = 0;
//    self.firstJLView.pageControl.allowChangeFrame = YES;
//
//    self.firstJLView.pageControl_botton = 25;
//    self.firstJLView.pageControl_right = 25;
////    self.firstJLView.pageControl_centerX = -10;
//
//    self.firstJLView.sourceArray = self.arrayData;
//
//    self.firstJLView.pageControlNeed = YES;
    
}

- (IBAction)threeClcik:(id)sender {
//        self.firstJLView.scrollDirection = UICollectionViewScrollDirectionVertical;

    self.firstheight.constant = 450;
    self.firstLeft.constant = 65;
    self.firstright.constant = 35;
//    self.firstJLView.sourceArray = self.arrayData;
//    self.firstJLView.sectionInset = UIEdgeInsetsMake(10, 20, 10, 20);

//    self.firstJLView.cellsOfLine = 5;
//    [self.firstJLView useCustomCell:[JLCycScrCustomCell new] isXibBuild:YES];//cell协议赋值;使用自定义cell的话self.firstJLView.datasource = self; 这个不再需要设置，设置了也没什么用

//    self.firstJLView.pageControlNeed = NO;

}

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
