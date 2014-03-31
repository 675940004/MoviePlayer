//
//  TopTitleBarView.m
//  MoivePlayerTest
//
//  Created by 孙可 on 14-3-24.
//  Copyright (c) 2014年 孙可. All rights reserved.
//

#import "TopTitleBarView.h"

const float kButtonHeight = 44;
const float kNameLabelWith = 320;

@implementation TopTitleBarView

- (void)dealloc
{
    self.bgView = nil;
    self.movieNameLabel = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)movieName
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        NSBundle  * bundle = [NSBundle mainBundle];
        
        /*半透明黑色背景*/
        _bgView = [[UIImageView alloc] init];
        _bgView.userInteractionEnabled = YES;
        UIImage * bgImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"top_bg" ofType:@"png"]];
        [_bgView setImage:[bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0.5, 0) resizingMode:UIImageResizingModeStretch]];
        [self addSubview:_bgView];
        
        /*back*/
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setBackgroundImage:[UIImage imageWithContentsOfFile:
                                         [bundle pathForResource:@"top_title_back_white_normal" ofType:@"png"]]
                               forState:UIControlStateNormal];
        [_backButton setBackgroundImage:[UIImage imageWithContentsOfFile:
                                         [bundle pathForResource:@"top_title_back_white_on" ofType:@"png"]]
                                                 forState:UIControlStateHighlighted];
        [_bgView addSubview:_backButton];
        
        /*影片名称*/
        _movieNameLabel = [[UILabel alloc] init];
        _movieNameLabel.font = [UIFont systemFontOfSize:20];
        _movieNameLabel.textAlignment = NSTextAlignmentCenter;
        _movieNameLabel.textColor = [UIColor whiteColor];
        _movieNameLabel.text = movieName;
        [_bgView addSubview:_movieNameLabel];
    }
    return self;
}

-(void)layoutSubviews
{
    [_bgView setFrame:self.bounds];
    [_backButton setFrame:CGRectMake(7, 20, kButtonHeight, kButtonHeight)];
    [_movieNameLabel setFrame:CGRectMake((self.frame.size.width - kNameLabelWith)/2,
                                        20,
                                        kNameLabelWith,
                                         kButtonHeight)];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

@end
