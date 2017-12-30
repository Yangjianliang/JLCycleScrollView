//
//  JLCycScrCustomCell.h
//  JLCycleScrollView
//
//  Created by 杨建亮 on 2017/12/7.
//  Copyright © 2017年 yangjianliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JLCycSrollCellDataProtocol.h"
@interface JLCycScrCustomCell : UICollectionViewCell<JLCycSrollCellDataProtocol>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
