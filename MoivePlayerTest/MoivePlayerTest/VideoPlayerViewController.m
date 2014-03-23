//
//  VideoPlayerViewController.m
//  MoivePlayerTest
//
//  Created by 孙可 on 14-3-23.
//  Copyright (c) 2014年 孙可. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface VideoPlayerViewController (OverlayView)

@end

@interface VideoPlayerViewController (MoviePlayer)

-(void)installMovieNotificationObservers;
-(NSURL *)localMovieURL;

@end

@interface VideoPlayerViewController (ViewController)

@end

@implementation VideoPlayerViewController

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
    moviePlayerVC.controlStyle = MPMovieControlStyleFullscreen;
    moviePlayerVC.scalingMode = MPMovieScalingModeAspectFill;
    moviePlayerVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 200);
    [self.view addSubview:moviePlayerVC.view];
    self.moviePlayerController = moviePlayerVC;
    [moviePlayerVC release];
    
    [moviePlayerVC prepareToPlay];
    [moviePlayerVC play];
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

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self doLayoutForOrientation:toInterfaceOrientation];
}

- (void)doLayoutForOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        self.moviePlayerController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 200);
    } else {
        self.moviePlayerController.view.frame = self.view.bounds;
    }
}

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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
}

- (void) moviePlayBackStateDidChange:(NSNotification*)notification
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}


@end
