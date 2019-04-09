//
//  JLCycScrollDefaultCell.m
//  JLCycleScrollView
//
//  Created by yangjianliang on 2017/9/24.
//  Copyright © 2017年 yangjianliang. All rights reserved.
//

#import "JLCycScrollDefaultCell.h"

#import "UIImageView+WebCache.h"

@implementation JLCycScrollDefaultCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
- (UIImageView *)imageView
{
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        _imageView = imageView;
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    if (_imageView) {
        _imageView.frame = self.bounds;
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

/**
 协议方法
 
 @param data 传入的sourceArray[index]
 */
-(void)setJLCycSrollCellData:(id)data
{
    if (data) {
        if ([data isKindOfClass:[NSString class]]) {
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:data] placeholderImage:nil ];
        }else if ([data isKindOfClass:[NSURL class]]) {
            [self.imageView sd_setImageWithURL:data placeholderImage:nil];
        }else if ([data isKindOfClass:[UIImage class]]) {
            self.imageView.image = data;
        }else{
            NSLog(@"只支持数据类型(NSString,NSURL,UIImage),其他类型可以在DataSource直接根据代理方法[rerturn NSString、NSURL、UIImage],或者return nil然后cel直接设置eg：cell.imageView...");
        }
    }
}
@end
