//
//  RootViewController.m
//  MoivePlayerTest
//
//  Created by 孙可 on 14-3-23.
//  Copyright (c) 2014年 孙可. All rights reserved.
//

#import "RootViewController.h"
#import "VideoPlayerViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton * videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [videoButton setFrame:CGRectMake(0, 0, 100, 100)];
    videoButton.backgroundColor = [UIColor grayColor];
    videoButton.center = self.view.center;
    [videoButton setTitle:@"Touch me" forState:UIControlStateNormal];
    [videoButton addTarget:self action:@selector(videoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:videoButton];
}

- (void)videoButtonPressed:(UIButton *)sender
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
    
    VideoPlayerViewController * playVC = [[VideoPlayerViewController alloc] initWithContentUrl:theMovieURL movieSourceType:MPMovieSourceTypeFile];
    [self presentViewController:playVC animated:YES completion:nil];
    [playVC release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}



@end
