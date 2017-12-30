//
//  JLCycScrCustomCell.m
//  JLCycleScrollView
//
//  Created by 杨建亮 on 2017/12/7.
//  Copyright © 2017年 yangjianliang. All rights reserved.
//

#import "JLCycScrCustomCell.h"

#import "ExampleModel.h"

#import "UIImageView+WebCache.h"
@implementation JLCycScrCustomCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
/**
 协议方法
 
 @param data 传入的sourceArray[integer]对象
 */
-(void)setJLCycSrollCellData:(id)data
{
    if ([data isKindOfClass:[ExampleModel class]]) { //ExampleTwoController
        ExampleModel *model = data;
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.url] placeholderImage:nil ];
        self.titleLabel.text = model.title;
    }
   
    if ([data isKindOfClass:[NSString class]]) { //ExampleOneController
        NSString *url = data;
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil ];
        self.titleLabel.text = url;
    }
}
@end
