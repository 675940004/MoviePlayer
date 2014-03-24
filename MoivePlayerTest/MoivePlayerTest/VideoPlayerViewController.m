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

@interface VideoPlayerViewController ()

- (void)buildBottomOverlayView;


-(void)installMovieNotificationObservers;
-(NSURL *)localMovieURL;

@end

@implementation VideoPlayerViewController

- (void)dealloc
{
    self.bottomProgressView = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self installMovieNotificationObservers];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    MPMoviePlayerController * moviePlayerVC = [[MPMoviePlayerController alloc] initWithContentURL:[self localMovieURL]];
    moviePlayerVC.controlStyle = MPMovieControlStyleNone;
    moviePlayerVC.scalingMode = MPMovieScalingModeAspectFill;
    moviePlayerVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 200);
    [self.view addSubview:moviePlayerVC.view];
    self.moviePlayerController = moviePlayerVC;
    [moviePlayerVC release];
    
    [self buildBottomOverlayView];
    
    [self.moviePlayerController play];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self doLayoutForOrientation:toInterfaceOrientation];
}

- (void)doLayoutForOrientation:(UIInterfaceOrientation)orientation
{
    /*竖直方向*/
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        self.moviePlayerController.controlStyle = MPMovieControlStyleDefault;
        self.moviePlayerController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 200);
    }
    /*水平方向*/
    else {
        self.moviePlayerController.controlStyle = MPMovieControlStyleNone;
        self.moviePlayerController.view.frame = self.view.bounds;
    }
    [self buildBottomOverlayView];
}

#pragma mark - OverlayView

/*添加底部进度条*/
-(void)buildBottomOverlayView
{
    if (!_bottomProgressView) {
        _bottomProgressView = [[BottomProgressView alloc] initWithFrame:CGRectMake(0,
                                                                                   self.moviePlayerController.view.frame.size.height - 45,
                                                                                   self.moviePlayerController.view.frame.size.width,
                                                                                   45)];
        [self.moviePlayerController.view addSubview:_bottomProgressView];
    }
    [_bottomProgressView setFrame:CGRectMake(0,
                                            self.moviePlayerController.view.frame.size.height - 45,
                                            self.moviePlayerController.view.frame.size.width,
                                             45)];
    
    NSLog(@"%@,\n%@",NSStringFromCGRect(_moviePlayerController.view.frame),NSStringFromCGRect(_bottomProgressView.frame));
}

#pragma mark - MoviePlayer

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

- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    if (timer) {
        [timer invalidate];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    if (timer) {
        [timer invalidate];
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refreshBottomProgressViewstate) userInfo:nil repeats:YES];
}

- (void) moviePlayBackStateDidChange:(NSNotification*)notification
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

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

- (void)refreshBottomProgressViewstate
{
    [self.bottomProgressView setPlayerProgressValue:_moviePlayerController.currentPlaybackTime/_moviePlayerController.duration
                                                            currentTime:[self formatTime:_moviePlayerController.currentPlaybackTime]
                                                                 endTime:[self formatTime:_moviePlayerController.duration]];
    NSLog(@"%@,%@",[self formatTime:_moviePlayerController.currentPlaybackTime],[self formatTime:_moviePlayerController.duration]);
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

@end
