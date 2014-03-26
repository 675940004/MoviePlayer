//
//  MovieControlView.h
//  MoivePlayerTest
//
//  Created by 孙可 on 14-3-25.
//  Copyright (c) 2014年 孙可. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieControlView : UIView

/**
 *播放和暂停
 */
@property (nonatomic, retain) UIButton * playPauseButton;

/**
 *快退
 */
@property (nonatomic, retain) UIButton * playPreButton;

/**
 *快进
 */
@property (nonatomic, retain) UIButton * playNextButton;

/**
 *播放状态标志位
 */
@property (nonatomic, assign) BOOL  isPlaying;

@end
