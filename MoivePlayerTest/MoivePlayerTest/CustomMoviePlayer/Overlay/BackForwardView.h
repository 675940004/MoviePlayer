//
//  BackForwardView.h
//  MoivePlayerTest
//
//  Created by 孙可 on 14-3-26.
//  Copyright (c) 2014年 孙可. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BackForwardView : UIImageView

@property (nonatomic, retain) UILabel * timeLabel;

- (void)setTimeLabelTextWithcurrentTime:(NSString *)currentTime endTime:(NSString *)duration;

@end
