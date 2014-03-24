//
//  BottomProgressView.m
//  MoivePlayerTest
//
//  Created by 孙可 on 14-3-24.
//  Copyright (c) 2014年 孙可. All rights reserved.
//

#import "BottomProgressView.h"

const float kButtonWith = 28.0;

@implementation BottomProgressView

- (void)dealloc
{
    self.bgView = nil;
    self.airplayButton = nil;
    self.progressSlider = nil;
    self.currentTimeLabel = nil;
    self.endTimeLabel = nil;
    self.volumeButton = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        NSBundle  * bundle = [NSBundle mainBundle];
        
        /*半透明黑色背景*/
        _bgView = [[UIImageView alloc] initWithFrame:self.bounds];
        UIImage * bgImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"bottom_bg" ofType:@"png"]];
        [_bgView setImage:[bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0.5, 0, 0, 0) resizingMode:UIImageResizingModeStretch]];
        [self addSubview:_bgView];
        [_bgView release];
        
        /*airplayButton*/
        self.airplayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.airplayButton.frame = CGRectMake(20, (frame.size.height - kButtonWith)/2, kButtonWith, kButtonWith);
        [self.airplayButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"airplay_disable" ofType:@"png"]] forState:UIControlStateNormal];
        [_bgView addSubview:self.airplayButton];
        
        /*_progressSlider*/
        _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(40+kButtonWith,
                                                                    (frame.size.height - 6)/2,
                                                                    frame.size.width - (40+kButtonWith)*2-65,
                                                                     6)];
        UIImage * maxImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"progress_light_gray" ofType:@"png"]];
        UIImage * minImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"progress_blue" ofType:@"png"]];
        UIImage * thumbImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"progress_dot_normal" ofType:@"png"]];
        [_progressSlider setMaximumTrackImage:[maxImage resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)]
                                                            forState:UIControlStateNormal];
        [_progressSlider setMinimumTrackImage:[minImage resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)]
                                                           forState:UIControlStateNormal];
        [_progressSlider setThumbImage:thumbImage forState:UIControlStateNormal];
        [_bgView addSubview:_progressSlider];
        
        /*显示当前播放的时间点*/
        _currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_progressSlider.frame.origin.x+_progressSlider.frame.size.width+5, 0 , 35, frame.size.height)];
        _currentTimeLabel.font = [UIFont systemFontOfSize:12];
        _currentTimeLabel.textAlignment = NSTextAlignmentLeft;
        _currentTimeLabel.textColor = [[self class] colorFromHexRGB:@"ffffff"];
        [_bgView addSubview:_currentTimeLabel];
        
        /*总共播放时长*/
        _endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_currentTimeLabel.frame.origin.x+_currentTimeLabel.frame.size.width+5, 0 , 40, frame.size.height)];
        _endTimeLabel.font = [UIFont systemFontOfSize:12];
        _endTimeLabel.textAlignment = NSTextAlignmentLeft;
        _endTimeLabel.textColor = [[self class] colorFromHexRGB:@"999999"];
        [_bgView addSubview:_endTimeLabel];
        
        /*volume_normal*/
        self.volumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.volumeButton.frame = CGRectMake(frame.size.width - 20 - kButtonWith,
                                             (frame.size.height - kButtonWith)/2,
                                             kButtonWith,
                                             kButtonWith);
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
                                        self.frame.size.width - (40+kButtonWith)*2-65,
                                         6)];
    [_currentTimeLabel setFrame:CGRectMake(_progressSlider.frame.origin.x+_progressSlider.frame.size.width+5, 0 , 35, self.frame.size.height)];
    [_endTimeLabel setFrame:CGRectMake(_currentTimeLabel.frame.origin.x+_currentTimeLabel.frame.size.width, 0 , 40, self.frame.size.height)];
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
    _currentTimeLabel.text = currentTime;
    _endTimeLabel.text = [NSString stringWithFormat:@"/%@",duration];
}
#pragma mark - 工具方法

+ (UIColor *)colorFromHexRGB:(NSString *)inColorString
{
    UIColor *result = nil;
    unsigned int colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString)
    {
        NSScanner *scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char) (colorCode >> 16);
    greenByte = (unsigned char) (colorCode >> 8);
    blueByte = (unsigned char) (colorCode); // masks off high bits
    result = [UIColor
              colorWithRed: (float)redByte / 0xff
              green: (float)greenByte/ 0xff
              blue: (float)blueByte / 0xff
              alpha:1.0];
    return result;
}

@end
