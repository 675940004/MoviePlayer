//
//  LetfToolView.m
//  MoivePlayerTest
//
//  Created by 孙可 on 14-3-24.
//  Copyright (c) 2014年 孙可. All rights reserved.
//

#import "RightToolView.h"

@implementation RightToolView

- (void)dealloc
{
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        NSBundle  * bundle = [NSBundle mainBundle];
        
        /*lockButton*/
        _lockButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lockButton setBackgroundImage:[UIImage imageWithContentsOfFile:
                                         [bundle pathForResource:@"lock_normal" ofType:@"png"]]
                               forState:UIControlStateNormal];
        [_lockButton setBackgroundImage:[UIImage imageWithContentsOfFile:
                                         [bundle pathForResource:@"lock_on" ofType:@"png"]]
                               forState:UIControlStateHighlighted];
        [self addSubview:_lockButton];
        
        /*downLoad*/
        _downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downloadButton setBackgroundImage:[UIImage imageWithContentsOfFile:
                                         [bundle pathForResource:@"download_normal" ofType:@"png"]]
                               forState:UIControlStateNormal];
        [_downloadButton setBackgroundImage:[UIImage imageWithContentsOfFile:
                                         [bundle pathForResource:@"download_on" ofType:@"png"]]
                               forState:UIControlStateHighlighted];
        [self addSubview:_downloadButton];
        
    }
    return self;
}

-(void)layoutSubviews
{
    [_lockButton setFrame:CGRectMake(0, 0, 45, 45)];
    [_downloadButton setFrame:CGRectMake(0,_lockButton.frame.origin.y+45+15, 45, 45)];
}

@end
