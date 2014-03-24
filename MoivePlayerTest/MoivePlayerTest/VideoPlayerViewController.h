//
//  VideoPlayerViewController.h
//  MoivePlayerTest
//
//  Created by 孙可 on 14-3-23.
//  Copyright (c) 2014年 孙可. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MPMoviePlayerController;
@class BottomProgressView;

@interface VideoPlayerViewController : UIViewController
{
    NSTimer * timer;
}

@property (nonatomic, retain) MPMoviePlayerController * moviePlayerController;

@property (nonatomic, retain) BottomProgressView * bottomProgressView;

@end
