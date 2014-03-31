//
//  VolumeView.m
//  MoivePlayerTest
//
//  Created by 孙可 on 14-3-27.
//  Copyright (c) 2014年 孙可. All rights reserved.
//

#import "VolumeView.h"
#import <MediaPlayer/MediaPlayer.h>
@implementation VolumeView

- (void)dealloc
{
    self.volumeSlider = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.hidden = YES;
        NSBundle  * bundle = [NSBundle mainBundle];
        [self setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"vol_bg" ofType:@"png"]]];
        
        /*volumeSlider*/
        _volumeSlider = [[UISlider alloc] init];
        UIImage * maxImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"progress_light_gray" ofType:@"png"]];
        UIImage * minImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"progress_blue" ofType:@"png"]];
        UIImage * thumbImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"progress_dot_normal" ofType:@"png"]];
        [_volumeSlider setMaximumTrackImage:[maxImage resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)]
                                     forState:UIControlStateNormal];
        [_volumeSlider setMinimumTrackImage:[minImage resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)]
                                     forState:UIControlStateNormal];
        [_volumeSlider setThumbImage:thumbImage forState:UIControlStateNormal];
        [_volumeSlider addTarget:self action:@selector(changeVolume) forControlEvents:UIControlEventTouchDragInside];
        _volumeSlider.value = [MPMusicPlayerController iPodMusicPlayer].volume;
        [self addSubview:_volumeSlider];
    }
    return self;
}

-(void)layoutSubviews
{
    [_volumeSlider setFrame:CGRectMake(24-69.5, 15+69.5, self.frame.size.height-35, 6)];
   _volumeSlider.transform = CGAffineTransformMakeRotation(-M_PI/2);
}

-(void)changeVolume
{
    [MPMusicPlayerController iPodMusicPlayer].volume = _volumeSlider.value;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}

@end
