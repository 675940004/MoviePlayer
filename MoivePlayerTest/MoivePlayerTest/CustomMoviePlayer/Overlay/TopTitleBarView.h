//
//  TopTitleBarView.h
//  MoivePlayerTest
//
//  Created by 孙可 on 14-3-24.
//  Copyright (c) 2014年 孙可. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopTitleBarView : UIView

@property (nonatomic, retain) UIImageView * bgView;

@property (nonatomic, retain) UIButton * backButton;

@property (nonatomic, retain) UILabel * movieNameLabel;

/**
 *初始化方法，title为视频名称
 */
- (id)initWithFrame:(CGRect)frame title:(NSString *)movieName;

@end
