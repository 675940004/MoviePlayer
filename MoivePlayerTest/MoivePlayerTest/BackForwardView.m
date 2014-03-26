//
//  BackForwardView.m
//  MoivePlayerTest
//
//  Created by 孙可 on 14-3-26.
//  Copyright (c) 2014年 孙可. All rights reserved.
//

#import "BackForwardView.h"
#import "UIColor+hexRGB.h"

@implementation BackForwardView

- (void)dealloc
{
    self.timeLabel = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        /*当前播放时间/总共播放时间*/
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:15];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [UIColor colorFromHexRGB:@"999999"];
        [self addSubview:_timeLabel];
    }
    return self;
}

-(void)layoutSubviews
{
    [_timeLabel setFrame:CGRectMake(0, self.frame.size.width-40, self.frame.size.width, 20)];
}

- (void)setTimeLabelTextWithcurrentTime:(NSString *)currentTime endTime:(NSString *)duration
{
    NSString * string = [NSString stringWithFormat:@"%@/%@",currentTime,duration];
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange range = NSMakeRange(0, [currentTime length]);
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorFromHexRGB:@"ffffff"] range:range];
    _timeLabel.attributedText = attributedString;
    [attributedString release];
}

@end
