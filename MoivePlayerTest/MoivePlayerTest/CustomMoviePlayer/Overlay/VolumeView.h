//
//  VolumeView.h
//  MoivePlayerTest
//
//  Created by 孙可 on 14-3-27.
//  Copyright (c) 2014年 孙可. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VolumeView : UIImageView

@property (nonatomic, retain) UISlider * volumeSlider;

/**
 *改变系统音量
 */
- (void)changeVolume;

@end
