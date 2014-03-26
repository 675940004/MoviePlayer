//
//  BottomProgressView.h
//  MoivePlayerTest
//
//  Created by 孙可 on 14-3-24.
//  Copyright (c) 2014年 孙可. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BottomProgressView : UIView

@property (nonatomic, retain) UIImageView * bgView;

@property (nonatomic, retain) UIButton * airplayButton;

@property (nonatomic, retain) UISlider * progressSlider;

@property (nonatomic, retain) UILabel * timeLabel;

@property (nonatomic, retain) UIButton * volumeButton;

- (void)setPlayerProgressValue:(float)value currentTime:(NSString *)currentTime endTime:(NSString *)duration;

@end
