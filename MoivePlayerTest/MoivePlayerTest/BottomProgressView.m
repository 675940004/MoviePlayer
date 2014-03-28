//
//  BottomProgressView.m
//  MoivePlayerTest
//
//  Created by 孙可 on 14-3-24.
//  Copyright (c) 2014年 孙可. All rights reserved.
//

#import "BottomProgressView.h"
#import "UIColor+hexRGB.h"

const float kButtonWith = 28.0;

@interface BottomProgressView ()

@end

@implementation BottomProgressView

- (void)dealloc
{
    self.bgView = nil;
    self.airplayButton = nil;
    self.progressSlider = nil;
    self.timeLabel = nil;
    self.volumeButton = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.volumeViewHiden = YES;
        NSBundle  * bundle = [NSBundle mainBundle];
        
        /*半透明黑色背景*/
        _bgView = [[UIImageView alloc] init];
        _bgView.userInteractionEnabled = YES;
        UIImage * bgImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"bottom_bg" ofType:@"png"]];
        [_bgView setImage:[bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0.5, 0, 0, 0) resizingMode:UIImageResizingModeStretch]];
        [self addSubview:_bgView];
        
        /*airplayButton*/
        self.airplayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.airplayButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"airplay_disable" ofType:@"png"]] forState:UIControlStateNormal];
        [_bgView addSubview:self.airplayButton];
        
        /*_progressSlider*/
        _progressSlider = [[UISlider alloc] init];
        UIImage * maxImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"progress_light_gray" ofType:@"png"]];
        UIImage * minImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"progress_blue" ofType:@"png"]];
        UIImage * thumbImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"progress_dot_normal" ofType:@"png"]];
        [_progressSlider setMaximumTrackImage:[maxImage resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)]
                                                            forState:UIControlStateNormal];
        [_progressSlider setMinimumTrackImage:[minImage resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)]
                                                           forState:UIControlStateNormal];
        [_progressSlider setThumbImage:thumbImage forState:UIControlStateNormal];
        [_bgView addSubview:_progressSlider];
        
        /*当前播放时间/总共播放时间*/
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        _timeLabel.textColor = [UIColor colorFromHexRGB:@"999999"];
        [_bgView addSubview:_timeLabel];
        
        /*volume_normal*/
        self.volumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.volumeButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"volume_normal" ofType:@"png"]] forState:UIControlStateNormal];
        [_bgView addSubview:self.volumeButton];
    }
    return self;
}

-(void)layoutSubviews
{
    [_bgView setFrame:self.bounds];
    [_airplayButton setFrame:CGRectMake(20, (self.frame.size.height - kButtonWith)/2, kButtonWith, kButtonWith)];
    [_progressSlider setFrame:CGRectMake(40+kButtonWith,
                                        (self.frame.size.height - 6)/2,
                                        self.frame.size.width - (40+kButtonWith)*2-100,
                                         6)];
    [_timeLabel setFrame:CGRectMake(_progressSlider.frame.origin.x+_progressSlider.frame.size.width+5, 0 , 100, self.frame.size.height)];
    [_volumeButton setFrame:CGRectMake(self.frame.size.width - 20 - kButtonWith,
                                       (self.frame.size.height - kButtonWith)/2,
                                       kButtonWith,
                                       kButtonWith)];
}

-(void)setPlayerProgressValue:(float)value
                  currentTime:(NSString *)currentTime
                      endTime:(NSString *)duration
{
    
    [_progressSlider setValue:value];
    
    NSString * string = [NSString stringWithFormat:@"%@/%@",currentTime,duration];
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange range = NSMakeRange(0, [currentTime length]);
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorFromHexRGB:@"ffffff"] range:range];
    _timeLabel.attributedText = attributedString;
    [attributedString release];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

@end
