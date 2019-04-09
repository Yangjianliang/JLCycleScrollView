//
//  JLCycScrollFlowLayout.h
//  JLCycleScrollView
//
//  Created by 杨建亮 on 2018/4/6.
//  Copyright © 2018年 yangjianliang. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^WillUpdateJLCycScrollFlowLayout)(NSString *property);
typedef void(^DidUpdateJLCycScrollFlowLayout)(NSString *property);
@interface JLCycScrollFlowLayout : UICollectionViewFlowLayout
@property (nonatomic, copy)WillUpdateJLCycScrollFlowLayout willUpdateJLCycScrollFlowLayout;
@property (nonatomic, copy)DidUpdateJLCycScrollFlowLayout didUpdateJLCycScrollFlowLayout;

@property (nonatomic) UICollectionViewScrollDirection scrollDirection;
@property (nonatomic) UIEdgeInsets sectionInset;

@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber *, UICollectionViewLayoutAttributes*>  *allAttributesInRect;


@end
