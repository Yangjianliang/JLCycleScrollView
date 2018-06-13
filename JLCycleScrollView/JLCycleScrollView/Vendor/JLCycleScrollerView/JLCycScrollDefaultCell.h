//
//  JLCycScrollDefaultCell.h
//  JLCycleScrollView
//
//  Created by yangjianliang on 2017/9/24.
//  Copyright © 2017年 yangjianliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JLCycSrollCellDataProtocol.h"
@interface JLCycScrollDefaultCell : UICollectionViewCell<JLCycSrollCellDataProtocol>
@property (nonatomic, strong) UIImageView *imageView;
@end
