//
//  VideoPlayerViewController.m
//  MoivePlayerTest
//
//  Created by 孙可 on 14-3-23.
//  Copyright (c) 2014年 孙可. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import "BottomProgressView.h"
#import "TopTitleBarView.h"
#import "MovieControlView.h"
#import "RightToolView.h"
#import "BackForwardView.h"
#import "VolumeView.h"

#define DID_SHOW_GUIDE_VIEW @"didShowGuideView"
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
const float kTimerInterval = 0.0f;

const float kBackForwardViewWith = 150.0f;
const float kBackForwardViewHeight = 93.0f;

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
    
    /*用于拖拽进度条和音量*/
    float currentProgressValue;
    
    UIImageView * guideView;
}

- (void)buildBottomOverlayView;
- (void)buildTopOverlayView;
- (void)buildRightOverlayView;
- (void)buildControlOverlayView;
-(void)buildBackForwardOverlayView;
- (void)buildVolumeOverlayView;
- (void)setOverlayViewHiden:(BOOL)hiden;

-(void)installMovieNotificationObservers;

@end

@implementation VideoPlayerViewController

#pragma mark - dealloc

- (void)dealloc
{
    self.moviePlayerController = nil;
    self.bottomProgressView = nil;
    self.topView = nil;
    self.controlView = nil;
    self.rightToolView = nil;
    self.backForwardView = nil;
    self.volumeView = nil;
    [timer invalidate];
    timer = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

#pragma mark - init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (id) initWithContentUrl:(NSURL *)url movieSourceType:(MPMovieSourceType)sourceType
{
    self = [super init];
    if (self) {
        /*注册通知*/
        [self installMovieNotificationObservers];
        
        /*初始化播放器*/
        MPMoviePlayerController * moviePlayerVC = [[MPMoviePlayerController alloc] initWithContentURL:url];
        [moviePlayerVC setMovieSourceType:sourceType];
        self.moviePlayerController = moviePlayerVC;
        [moviePlayerVC release];
        self.moviePlayerController.controlStyle = MPMovieControlStyleNone;
        self.moviePlayerController.scalingMode = MPMovieScalingModeAspectFill;
        self.moviePlayerController.view.userInteractionEnabled = YES;
    }
    return self;
}

#pragma mark - viewDidLoad

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.moviePlayerController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 200);
    [self.view addSubview:self.moviePlayerController.view];
    
    [self buildBottomOverlayView];
    [self buildTopOverlayView];
    [self buildControlOverlayView];
    [self buildRightOverlayView];
    [self buildVolumeOverlayView];
    [self setOverlayViewHiden:NO];
    
    [self play];
}

- (void)tapGestureChanged:(UITapGestureRecognizer *)gesture
{
}

#pragma mark - 横竖屏适配

-(BOOL)shouldAutorotate
{
    return !_rightToolView.isLocked;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                                                duration:(NSTimeInterval)duration
{
    [self doLayoutForOrientation:toInterfaceOrientation];
    /*隐藏两侧和顶部视图，只显示底部视图*/
    [self setOverlayViewHiden:overlayHiden];
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
        /*判断是否第一次，展示指导图*/
        if (![[NSUserDefaults standardUserDefaults] boolForKey:DID_SHOW_GUIDE_VIEW]) {
            NSBundle * bundle = [NSBundle mainBundle];
            guideView = [[UIImageView alloc] initWithFrame:self.view.bounds];
            guideView.tag = 1000;
            if (iPhone5) {
                [guideView setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"iphone5_frist_help" ofType:@"png"]]];
            } else {
                [guideView setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"iphone4_frist_help" ofType:@"png"]]];
            }
            [self.view addSubview:guideView];
            [guideView release];
        }
    }
    
    /*重构*/
    [self buildBottomOverlayView];
    [self buildTopOverlayView];
    [self buildControlOverlayView];
    [self buildRightOverlayView];
    [self buildBackForwardOverlayView];
    [self buildVolumeOverlayView];
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
    [self performSelector:@selector(setOverlayViewHiden:)
               withObject:[NSNumber numberWithBool:YES]
               afterDelay:3.0];
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(setOverlayViewHiden:)
                                               object:[NSNumber numberWithBool:YES]];
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
        [_bottomProgressView.volumeButton addTarget:self action:@selector(volumeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)refreshBottomProgressByTouch:(float)currentTime
{
    [self.bottomProgressView setPlayerProgressValue:currentTime/_moviePlayerController.duration
                                        currentTime:[self formatTime:currentTime]
                                            endTime:[self formatTime:_moviePlayerController.duration]];
}

- (void)refreshBackForwardViewState
{
    [self.backForwardView setTimeLabelTextWithcurrentTime:[self formatTime:currentProgressValue]
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
        [_topView.backButton addTarget:self
                                               action:@selector(backButtonPressed:)
                              forControlEvents:UIControlEventTouchUpInside];
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
        [_rightToolView.lockButton addTarget:self action:@selector(lockButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_rightToolView];
    }
    [_rightToolView setFrame:CGRectMake((_moviePlayerController.view.frame.size.width - 12-45),
                                        (_moviePlayerController.view.frame.size.height - 105)/2, 45, 105)];
}

- (void)lockButtonPressed:(UIButton *)sender
{
    NSBundle  * bundle = [NSBundle mainBundle];
    if (_rightToolView.isLocked) {
        [_rightToolView.lockButton setBackgroundImage:[UIImage imageWithContentsOfFile:
                                         [bundle pathForResource:@"unlock_normal" ofType:@"png"]]
                               forState:UIControlStateNormal];
        [_rightToolView.lockButton setBackgroundImage:[UIImage imageWithContentsOfFile:
                                         [bundle pathForResource:@"unlock_on" ofType:@"png"]]
                               forState:UIControlStateHighlighted];
        _rightToolView.isLocked = NO;
    } else {
        [_rightToolView.lockButton setBackgroundImage:[UIImage imageWithContentsOfFile:
                                         [bundle pathForResource:@"lock_normal" ofType:@"png"]]
                               forState:UIControlStateNormal];
        [_rightToolView.lockButton setBackgroundImage:[UIImage imageWithContentsOfFile:
                                         [bundle pathForResource:@"lock_on" ofType:@"png"]]
                               forState:UIControlStateHighlighted];
        _rightToolView.isLocked = YES;
    }
    [self setUserInteractionEnabled:!_rightToolView.isLocked];
}

- (void) setUserInteractionEnabled:(BOOL)enabled
{
    self.topView.userInteractionEnabled = enabled;
    self.bottomProgressView.userInteractionEnabled = enabled;
    self.controlView.userInteractionEnabled = enabled;
    self.rightToolView.downloadButton.userInteractionEnabled = enabled;
}

-(void)showLockedState
{
    if (overlayHiden) {
        /*当当前视图隐藏的时候*/
        _rightToolView.hidden = NO;
        _rightToolView.downloadButton.hidden = YES;
        _rightToolView.lockButton.hidden = NO;
        [self performSelector:@selector(dissmisLockedState) withObject:nil afterDelay:3.0];
    }
    else{
    }
}

-(void)dissmisLockedState
{
    _rightToolView.hidden = overlayHiden;
    _rightToolView.downloadButton.hidden = NO;
    _rightToolView.lockButton.hidden = NO;
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
        _backForwardView = [[BackForwardView alloc] initWithFrame:CGRectMake((_moviePlayerController.view.frame.size.width - kBackForwardViewWith)/2,
                                                                             (_moviePlayerController.view.frame.size.height - kBackForwardViewHeight)/2,
                                                                             kBackForwardViewWith, kBackForwardViewHeight)];
        [self.view addSubview:_backForwardView];
    }
    _backForwardView.hidden = YES;
    [_backForwardView setFrame:CGRectMake((_moviePlayerController.view.frame.size.width - kBackForwardViewWith)/2,
                                          (_moviePlayerController.view.frame.size.height - kBackForwardViewHeight)/2,
                                          kBackForwardViewWith,kBackForwardViewHeight)];
}

#pragma mark - 音量条

- (void)buildVolumeOverlayView
{
    if (!_volumeView) {
        _volumeView = [[VolumeView alloc] initWithFrame:CGRectMake(_moviePlayerController.view.frame.size.width-10-48,
                                                                   ( _moviePlayerController.view.frame.size.height-45-174),
                                                                   48, 174)];
        [self.view addSubview:_volumeView];
    }
    
    [ _volumeView setFrame:CGRectMake(_moviePlayerController.view.frame.size.width-10-48,
                                      ( _moviePlayerController.view.frame.size.height-45-174),
                                      48, 174)];
}

- (void)volumeButtonPressed:(UIButton *)sender
{
    if (_bottomProgressView.volumeViewHiden) {
        self.volumeView.hidden = NO;
        _bottomProgressView.volumeViewHiden = NO;
    } else {
        self.volumeView.hidden = YES;
        _bottomProgressView.volumeViewHiden = YES;
    }
}

- (void)systemVolumeChanged:(NSNotification *)noti {
    NSBundle * bundle = [NSBundle mainBundle];
    float volume = [[[noti userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    [_volumeView.volumeSlider  setValue:volume];
    if (volume < 0.01)
    {
        [_bottomProgressView.volumeButton  setBackgroundImage:[UIImage  imageWithContentsOfFile:[bundle pathForResource:@"volume_mute_normal" ofType:@"png"]]
                                                                    forState:UIControlStateNormal];
        [_bottomProgressView.volumeButton  setBackgroundImage:[UIImage  imageWithContentsOfFile:[bundle pathForResource:@"volume_mute_on" ofType:@"png"]]
                                                                     forState:UIControlStateHighlighted];
    }
    else
    {
        [_bottomProgressView.volumeButton  setBackgroundImage:[UIImage  imageWithContentsOfFile:[bundle pathForResource:@"volume_normal" ofType:@"png"]]
                                                                     forState:UIControlStateNormal];
        [_bottomProgressView.volumeButton  setBackgroundImage:[UIImage  imageWithContentsOfFile:[bundle pathForResource:@"volume_on" ofType:@"png"]]
                                                                     forState:UIControlStateHighlighted];
    }
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
    
    // 监听系统音量变化
    [[NSNotificationCenter  defaultCenter]  addObserver:self
                                               selector:@selector(systemVolumeChanged:)
                                                   name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                                 object:nil];
}

- (void) loadStateDidChange:(NSNotification*)notification
{
}

/*播放完成*/
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    /*将播放进度调整到初始状态*/
    if (self.moviePlayerController.playbackState == MPMoviePlaybackStatePaused) {
        if (timer) {
            [timer invalidate];
            timer = nil;
        }
        
        [self.moviePlayerController setCurrentPlaybackTime:0.0f];
        [self refreshBottomProgressViewstate];
        [self pause];
    }
}

- (void) mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    if (_moviePlayerController.playbackState == MPMoviePlaybackStatePaused) {
        [self pause];
    }
}

- (void) moviePlayBackStateDidChange:(NSNotification*)notification
{
}

#pragma mark - touch
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:DID_SHOW_GUIDE_VIEW]) {
        if (guideView) {
            guideView.hidden = YES;
            [guideView removeFromSuperview];
            guideView = nil;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DID_SHOW_GUIDE_VIEW];
        }
    }
    
    if (_rightToolView.isLocked) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dissmisLockedState) object:nil];
        [self showLockedState];
        return;
    }
    UITouch * touch = [touches anyObject];
    currentPoint = [touch locationInView:self.view];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_rightToolView.isLocked) {
        return;
    }
    didTouchMoved = YES;
    prePoint = currentPoint;
    UITouch * touch = [touches anyObject];
    currentPoint = [touch locationInView:self.view];
    if (CGRectContainsPoint(self.moviePlayerController.view.frame, currentPoint)){
        /*判断此次滑动是调整进度还是音量，每次滑动只判断一次，didJudged*/
        if (!didJudged) {
            isChangingProgress = fabs(currentPoint.x - prePoint.x)>=fabs(currentPoint.y-prePoint.y);
            if (isChangingProgress) {
                /*判断是调整进度*/
                [self pause];
                currentProgressValue = _moviePlayerController.currentPlaybackTime;
            } else {
                /*判断是调整音量*/
            }
            didJudged = YES;
        }
        
        if (isChangingProgress) {
            /*改变进度*/
            self.backForwardView.hidden = NO;
            
            if (fabs(currentPoint.x-prePoint.x)/(currentPoint.x-prePoint.x)>0) {
                /*前进*/
                [self.backForwardView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"unlock_screen_forward" ofType:@"png"]]];
                currentProgressValue += 0.2;
            } else if (fabs(currentPoint.x-prePoint.x)/(currentPoint.x-prePoint.x)<0) {
                /*后退*/
                [self.backForwardView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"unlock_screen_back" ofType:@"png"]]];
                currentProgressValue -= 0.2;
            }
            if (currentProgressValue<=0) {
                currentProgressValue = 0.0f;
            } else if (currentProgressValue>=_moviePlayerController.duration){
                currentProgressValue = _moviePlayerController.duration;
            }
            
            [self progressValueDidChanged];
        } else{
            /*改变音量*/
            if (fabs(currentPoint.y-prePoint.y)/(currentPoint.y-prePoint.y)<0) {
                _volumeView.volumeSlider.value += 0.02;
            } else if (fabs(currentPoint.y-prePoint.y)/(currentPoint.y-prePoint.y)>0) {
                _volumeView.volumeSlider.value -= 0.02;
            }
            /*改变系统音量*/
            [_volumeView changeVolume];
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_rightToolView.isLocked) {
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(setOverlayViewHiden:)
                                               object:[NSNumber numberWithBool:YES]];
    
    if (didTouchMoved) {
        if (isChangingProgress) {
            /*当前的手势是在改变进度*/
            self.backForwardView.hidden = YES;
            self.moviePlayerController.currentPlaybackTime = currentProgressValue;
            [self play];
        } else {
            /*当前的手势是在改变音量*/
        }
        /*标志位重置*/
        didTouchMoved = NO;
        isChangingProgress = NO;
        didJudged = NO;
        currentProgressValue = 0.0f;
        return;
    }
    
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    if (CGRectContainsPoint(self.moviePlayerController.view.frame, point)) {
        [self setOverlayViewHiden:!overlayHiden];
        if ((!overlayHiden)&&_moviePlayerController.playbackState == MPMoviePlaybackStatePlaying) {
            [self performSelector:@selector(setOverlayViewHiden:)
                       withObject:[NSNumber numberWithBool:YES]
                       afterDelay:3.0];
        }
    }
}

- (void)progressValueDidChanged
{
    /*调整进度条*/
    [self refreshBottomProgressByTouch:currentProgressValue];
    /*调整时间*/
    [self refreshBackForwardViewState];
}

- (void)voiceValueDidChanged
{
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
        /*当解锁的时候*/
        self.rightToolView.downloadButton.hidden = hiden;
        if (!self.bottomProgressView.volumeViewHiden) {
            self.volumeView.hidden = hiden;
            self.bottomProgressView.volumeViewHiden = hiden;
        }
    }
    /*如果是竖屏，只控制bottomView*/
    else {
        self.topView.hidden = YES;
        self.controlView.hidden = YES;
        self.rightToolView.hidden = YES;
        self.volumeView.hidden = YES;
        self.bottomProgressView.volumeViewHiden = YES;
    }
}

#pragma mark - didReceiveMemoryWarning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
