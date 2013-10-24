//
//  RootViewController.m
//  MDSDK
//
//  Created by Mateusz Dzwonek on 14/09/2013.
//  Copyright (c) 2013 Mateusz Dzwonek. All rights reserved.
//

#import "RootViewController.h"
#import "MDAnimatedDotsViewController.h"
#import "MDRandom.h"

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MDAnimatedDotsViewController *animatedDotsViewController = [[MDAnimatedDotsViewController alloc] init];
    [self addChildViewController:animatedDotsViewController];
    animatedDotsViewController.view.frame = self.view.bounds;
    [self.view addSubview:animatedDotsViewController.view];
}

@end
