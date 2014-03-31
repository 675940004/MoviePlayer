//
//  MovieControlView.m
//  MoivePlayerTest
//
//  Created by 孙可 on 14-3-25.
//  Copyright (c) 2014年 孙可. All rights reserved.
//

#import "MovieControlView.h"
const float kLittleButtonWith = 45;
const float kBiggerButtonWith = 55;
const float kBitch = 10;

@implementation MovieControlView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        NSBundle * bundle = [NSBundle mainBundle];
        /*快退*/
        _playPreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playPreButton setBackgroundImage:[UIImage imageWithContentsOfFile:
                                         [bundle pathForResource:@"play_previous_normal" ofType:@"png"]]
                               forState:UIControlStateNormal];
        [_playPreButton setBackgroundImage:[UIImage imageWithContentsOfFile:
                                         [bundle pathForResource:@"play_previous_on" ofType:@"png"]]
                               forState:UIControlStateHighlighted];
        [self addSubview:_playPreButton];
        
        /*暂停和播放*/
        _playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playPauseButton setBackgroundImage:[UIImage imageWithContentsOfFile:
                                            [bundle pathForResource:@"suspended_normal" ofType:@"png"]]
                                  forState:UIControlStateNormal];
        [_playPauseButton setBackgroundImage:[UIImage imageWithContentsOfFile:
                                            [bundle pathForResource:@"suspended_on" ofType:@"png"]]
                                  forState:UIControlStateHighlighted];
        [self addSubview:_playPauseButton];
        
        /*快进*/
        _playNextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playNextButton setBackgroundImage:[UIImage imageWithContentsOfFile:
                                              [bundle pathForResource:@"play_next_one_normal" ofType:@"png"]]
                                    forState:UIControlStateNormal];
        [_playNextButton setBackgroundImage:[UIImage imageWithContentsOfFile:
                                              [bundle pathForResource:@"play_next_one_on" ofType:@"png"]]
                                    forState:UIControlStateHighlighted];
        [self addSubview:_playNextButton];
    }
    return self;
}

-(void)layoutSubviews
{
    [_playPreButton setFrame:CGRectMake(0, 5, kLittleButtonWith, kLittleButtonWith)];
    [_playPauseButton setFrame:CGRectMake(_playPreButton.frame.origin.x+kLittleButtonWith+kBitch, 0, kBiggerButtonWith, kBiggerButtonWith)];
    [_playNextButton setFrame:CGRectMake(_playPauseButton.frame.origin.x+kBiggerButtonWith+kBitch, 5, kLittleButtonWith, kLittleButtonWith)];
}

@end
