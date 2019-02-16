//
//  SplashViewController.m
//  ZixiPlayerSDKTester
//
//  Created by Dmitry Kuzin on 15/02/2019.
//  Copyright © 2019 zixi. All rights reserved.
//

#import "SplashViewController.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier: @"start" sender: self];
    });
}

@end
