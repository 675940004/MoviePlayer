//
//  VideoPlayerViewController.h
//  MoivePlayerTest
//
//  Created by 孙可 on 14-3-23.
//  Copyright (c) 2014年 孙可. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class BottomProgressView;
@class TopTitleBarView;
@class MovieControlView;
@class RightToolView;
@class BackForwardView;
@class VolumeView;

@interface VideoPlayerViewController : UIViewController

/**
 *系统视频播放器
 */
@property (nonatomic, retain) MPMoviePlayerController * moviePlayerController;

/**
 *底部视图，包括airplay、进度条、音量
 */
@property (nonatomic, retain) BottomProgressView * bottomProgressView;

/**
 *顶部视图，包括返回按钮、影片name
 */
@property (nonatomic, retain) TopTitleBarView * topView;

/**
 *控制视图，包括暂停、播放、快进、快退
 */
@property (nonatomic, retain) MovieControlView * controlView;

/**
 *锁屏和下载
 */
@property (nonatomic, retain) RightToolView * rightToolView;

/**
 *用于显示前进后退的状态和时间
 */
@property (nonatomic, retain) BackForwardView * backForwardView;

/**
 *音量调
 */
@property (nonatomic, retain) VolumeView * volumeView;

/**
 *初始化播放器方法，传入视频播放url和视频来源类型
 */
- (id) initWithContentUrl:(NSURL *)url movieSourceType:(MPMovieSourceType)sourceType;

@end
