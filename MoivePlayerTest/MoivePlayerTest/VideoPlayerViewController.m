//
//  VideoPlayerViewController.m
//  MoivePlayerTest
//
//  Created by 孙可 on 14-3-23.
//  Copyright (c) 2014年 孙可. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "BottomProgressView.h"
#import "TopTitleBarView.h"
#import "MovieControlView.h"
#import "RightToolView.h"
#import "BackForwardView.h"

const float kTimerInterval = 0.0f;

@interface VideoPlayerViewController ()
{
    NSTimer * timer;
    BOOL overlayHiden;
    
    /*用与touch事件*/
    CGPoint prePoint;
    CGPoint currentPoint;
    BOOL didTouchMoved;            //用于判断是否应该隐藏覆盖视图
    BOOL isChangingProgress;        //用于判断当前是要改变进度还是音量
    BOOL didJudged;                    //是否已经完成判断
}

- (void)buildBottomOverlayView;
- (void)buildTopOverlayView;
- (void)buildRightOverlayView;
- (void)buildControlOverlayView;
-(void)buildBackForwardOverlayView;
- (void)setOverlayViewHiden:(BOOL)hiden;

-(void)installMovieNotificationObservers;
-(NSURL *)localMovieURL;

@end

@implementation VideoPlayerViewController

#pragma mark - dealloc

- (void)dealloc
{
    self.bottomProgressView = nil;
    self.topView = nil;
    self.controlView = nil;
    self.rightToolView = nil;
    self.backForwardView = nil;
    [timer invalidate];
    timer = nil;
    [super dealloc];
}

#pragma mark - init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self installMovieNotificationObservers];
    }
    return self;
}

#pragma mark - viewDidLoad

- (void)viewDidLoad
{
    [super viewDidLoad];
    MPMoviePlayerController * moviePlayerVC = [[MPMoviePlayerController alloc] initWithContentURL:[self localMovieURL]];
    moviePlayerVC.controlStyle = MPMovieControlStyleNone;
    moviePlayerVC.scalingMode = MPMovieScalingModeAspectFill;
    moviePlayerVC.view.userInteractionEnabled = YES;
    moviePlayerVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 200);
    [self.view addSubview:moviePlayerVC.view];
    self.moviePlayerController = moviePlayerVC;
    [moviePlayerVC release];
    
    [self buildBottomOverlayView];
    [self buildTopOverlayView];
    [self buildControlOverlayView];
    [self buildRightOverlayView];
    [self setOverlayViewHiden:NO];
    
    [self play];
}

- (void)tapGestureChanged:(UITapGestureRecognizer *)gesture
{
}

#pragma mark - 横竖屏适配

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self doLayoutForOrientation:toInterfaceOrientation];
    /*隐藏两侧和顶部视图，只显示底部视图*/
    [self setOverlayViewHiden:overlayHiden];
    NSLog(@"%@",NSStringFromCGRect(self.view.frame));
}

- (void)doLayoutForOrientation:(UIInterfaceOrientation)orientation
{
    /*竖直方向*/
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        self.moviePlayerController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 200);
    }
    /*水平方向*/
    else {
        self.moviePlayerController.view.frame = self.view.bounds;
    }
    
    /*重构*/
    [self buildBottomOverlayView];
    [self buildTopOverlayView];
    [self buildControlOverlayView];
    [self buildRightOverlayView];
    [self buildBackForwardOverlayView];
}

#pragma mark - Control Center

- (void)playPauseButtonPressed:(UIButton *)sender
{
    if (self.controlView.isPlaying) {
        [self pause];
    } else {
        [self play];
    }
}

- (void)play
{
    NSBundle * bundle = [NSBundle mainBundle];
    
    [self.moviePlayerController prepareToPlay];
    [self.moviePlayerController play];
    self.controlView.isPlaying = YES;
    /*切换button图片*/
    [self.controlView.playPauseButton setBackgroundImage:[UIImage imageWithContentsOfFile:
                                [bundle pathForResource:@"suspended_normal" ofType:@"png"]]
                      forState:UIControlStateNormal];
    [self.controlView.playPauseButton setBackgroundImage:[UIImage imageWithContentsOfFile:
                                [bundle pathForResource:@"suspended_on" ofType:@"png"]]
                      forState:UIControlStateHighlighted];
    
    /*开启定时器，刷新进度条进度*/
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval
                                             target:self
                                           selector:@selector(refreshBottomProgressViewstate)
                                           userInfo:nil
                                            repeats:YES];
}

- (void)pause
{
    NSBundle * bundle = [NSBundle mainBundle];
    
    [self.moviePlayerController pause];
    self.controlView.isPlaying = NO;
    /*切换button图片*/
    [self.controlView.playPauseButton setBackgroundImage:[UIImage imageWithContentsOfFile:
                                [bundle pathForResource:@"play_normal" ofType:@"png"]]
                      forState:UIControlStateNormal];
    [self.controlView.playPauseButton setBackgroundImage:[UIImage imageWithContentsOfFile:
                                [bundle pathForResource:@"play_on" ofType:@"png"]]
                      forState:UIControlStateHighlighted];
    
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

#pragma mark - 底部进度条相关

/*添加底部进度条*/
-(void)buildBottomOverlayView
{
    if (!_bottomProgressView) {
        _bottomProgressView = [[BottomProgressView alloc] initWithFrame:CGRectMake(0,
                                                                                   self.moviePlayerController.view.frame.size.height - 45,
                                                                                   self.moviePlayerController.view.frame.size.width,
                                                                                   45)];
        [self.view addSubview:_bottomProgressView];
    }
    
    /*用于重构*/
    [_bottomProgressView setFrame:CGRectMake(0,
                                            self.moviePlayerController.view.frame.size.height - 45,
                                            self.moviePlayerController.view.frame.size.width,
                                             45)];
}

- (void)refreshBottomProgressViewstate
{
    [self.bottomProgressView setPlayerProgressValue:_moviePlayerController.currentPlaybackTime/_moviePlayerController.duration
                                        currentTime:[self formatTime:_moviePlayerController.currentPlaybackTime]
                                            endTime:[self formatTime:_moviePlayerController.duration]];
    //NSLog(@"%f,%f",_moviePlayerController.currentPlaybackTime,_moviePlayerController.duration);
}

- (void)refreshBackForwardViewState
{
    [self.backForwardView setTimeLabelTextWithcurrentTime:[self formatTime:_moviePlayerController.currentPlaybackTime]
                                                  endTime:[self formatTime:_moviePlayerController.duration]];
}

- (NSString *)formatTime:(double)time {
    
    //int currentTime = ceilf(time);
    int currentTime = time;
    
    int hour = currentTime/60/60;
    int minute = (currentTime/60)%60;
    int second = currentTime%60;
    
    NSString  *hourStr = [NSString  stringWithFormat:@"%.2f",hour/100.f];
    hourStr = [hourStr  substringFromIndex:2];
    
    NSString  *minuteStr = [NSString  stringWithFormat:@"%.2f",minute/100.f];
    minuteStr = [minuteStr  substringFromIndex:2];
    
    NSString  *secondStr = [NSString  stringWithFormat:@"%.2f",second/100.f];
    secondStr = [secondStr  substringFromIndex:2];
    
    if (hour > 0) {
        
        return [NSString  stringWithFormat:@"%@:%@:%@",hourStr,minuteStr,secondStr];
    }
    
    return [NSString  stringWithFormat:@"%@:%@",minuteStr,secondStr];
}

#pragma mark - 顶部title相关

- (void)buildTopOverlayView
{
    if (!_topView) {
        _topView = [[TopTitleBarView alloc] initWithFrame:CGRectMake(0, 0, _moviePlayerController.view.frame.size.width, 64)
                                                                               title:@"来自星星的你  第01集"];
        [_topView.backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_topView];
    }
    
    /*重构*/
    [_topView setFrame:CGRectMake(0, 0, _moviePlayerController.view.frame.size.width, 64)];
}

- (void)backButtonPressed:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 右侧下载和锁屏

- (void)buildRightOverlayView
{
    if (!_rightToolView) {
        _rightToolView = [[RightToolView alloc] initWithFrame:CGRectMake((_moviePlayerController.view.frame.size.width - 12-45),
                                                                         (_moviePlayerController.view.frame.size.height - 105)/2, 45, 105)];
        [self.view addSubview:_rightToolView];
    }
    [_rightToolView setFrame:CGRectMake((_moviePlayerController.view.frame.size.width - 12-45),
                                        (_moviePlayerController.view.frame.size.height - 105)/2, 45, 105)];
}

#pragma mark - 前进、后退、暂停和播放

- (void)buildControlOverlayView
{
    if (!_controlView) {
         _controlView = [[MovieControlView alloc] initWithFrame:CGRectMake((_moviePlayerController.view.frame.size.width - 165)/2, _moviePlayerController.view.frame.size.width - 45 - 65, 165, 55)];
        [_controlView.playPauseButton addTarget:self action:@selector(playPauseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_controlView];
    }
    [_controlView setFrame:CGRectMake((_moviePlayerController.view.frame.size.width - 165)/2, _moviePlayerController.view.frame.size.height - 45 - 65, 165, 55)];
}

- (void)buildBackForwardOverlayView
{
    if (!_backForwardView) {
        _backForwardView = [[BackForwardView alloc] initWithFrame:CGRectMake((_moviePlayerController.view.frame.size.width - 150)/2,
                                                                             (_moviePlayerController.view.frame.size.height - 143)/2,
                                                                             150, 143)];
        [self.view addSubview:_backForwardView];
    }
    _backForwardView.hidden = YES;
    [_backForwardView setFrame:CGRectMake((_moviePlayerController.view.frame.size.width - 150)/2,
                                          (_moviePlayerController.view.frame.size.height - 143)/2,
                                          150,143)];
}

#pragma mark - 注册通知

-(void)installMovieNotificationObservers
{
    MPMoviePlayerController *player = [self moviePlayerController];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:player];
}

- (void) loadStateDidChange:(NSNotification*)notification
{
}

/*播放完成*/
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    /*将播放进度调整到初始状态*/
    [self.moviePlayerController setCurrentPlaybackTime:0.0f];
    [self refreshBottomProgressViewstate];
    [self pause];
}

- (void) mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
}

- (void) moviePlayBackStateDidChange:(NSNotification*)notification
{
}

#pragma mark - touch
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    currentPoint = [touch locationInView:self.view];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    didTouchMoved = YES;
    prePoint = currentPoint;
    UITouch * touch = [touches anyObject];
    currentPoint = [touch locationInView:self.view];
    if (CGRectContainsPoint(self.moviePlayerController.view.frame, currentPoint)){
        if (!didJudged) {
            isChangingProgress = fabs(currentPoint.x - prePoint.x)>=fabs(currentPoint.y-prePoint.y);
            if (isChangingProgress) {
                [self pause];
            }
            didJudged = YES;
        }
        
        if (isChangingProgress) {
            /*改变进度*/
            self.backForwardView.hidden = NO;
            if (fabs(currentPoint.x-prePoint.x)/(currentPoint.x-prePoint.x)>0) {
                /*前进*/
                [self.backForwardView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"unlock_screen_forward" ofType:@"png"]]];
                _moviePlayerController.currentPlaybackTime++;
                NSLog(@"%f",_moviePlayerController.currentPlaybackTime);
            } else if (fabs(currentPoint.x-prePoint.x)/(currentPoint.x-prePoint.x)<0) {
                /*后退*/
                [self.backForwardView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"unlock_screen_back" ofType:@"png"]]];
                _moviePlayerController.currentPlaybackTime--;
                NSLog(@"%f",_moviePlayerController.currentPlaybackTime);
            }

            [self progressValueDidChanged];
        } else{
            /*改变音量*/
        }
    }
}

- (void)progressValueDidChanged
{
    /*调整进度条*/
    [self refreshBottomProgressViewstate];
    /*调整时间*/
    [self refreshBackForwardViewState];
}

- (void)voiceValueDidChanged
{
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (didTouchMoved) {
        if (isChangingProgress) {
            self.backForwardView.hidden = YES;
            [self play];
        } else{
        }
        /*标志位复原*/
        didTouchMoved = NO;
        isChangingProgress = NO;
        didJudged = NO;
        return;
    }
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    if (CGRectContainsPoint(self.moviePlayerController.view.frame, point)) {
        [self setOverlayViewHiden:!overlayHiden];
    }
}

-(void)setOverlayViewHiden:(BOOL)hiden
{
    /*维护标志位*/
    overlayHiden = hiden;
    
    self.bottomProgressView.hidden = hiden;
    /*如果是横屏，控制全部子视图*/
    if (_moviePlayerController.view.frame.size.height == self.view.frame.size.width) {
        self.topView.hidden = hiden;
        self.controlView.hidden = hiden;
        self.rightToolView.hidden = hiden;
    }
    /*如果是竖屏，只控制bottomView*/
    else {
        self.topView.hidden = YES;
        self.controlView.hidden = YES;
        self.rightToolView.hidden = YES;
    }
}

#pragma mark - didReceiveMemoryWarning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -

-(NSURL *)localMovieURL
{
	NSURL *theMovieURL = nil;
	NSBundle *bundle = [NSBundle mainBundle];
	if (bundle)
	{
		NSString *moviePath = [bundle pathForResource:@"Movie" ofType:@"m4v"];
		if (moviePath)
		{
			theMovieURL = [NSURL fileURLWithPath:moviePath];
		}
	}
    return theMovieURL;
}

@end
