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

@interface RootViewController () <MDAnimatedDotsViewControllerDelegate>

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MDAnimatedDotsViewController *animatedDotsViewController = [[MDAnimatedDotsViewController alloc] init];
    animatedDotsViewController.delegate = self;
    [self addChildViewController:animatedDotsViewController];
    animatedDotsViewController.view.frame = self.view.bounds;
    [self.view addSubview:animatedDotsViewController.view];
}

- (UIColor *)colorForDotViewForAnimatedDotsViewController:(MDAnimatedDotsViewController *)controller {
    UIColor *firstColor = [UIColor colorWithRed:157.0f / 255.0f green:201.0f / 255.0f blue:248.0f / 255.0f alpha:192.0f / 255.0f];
    UIColor *secondColor = [UIColor colorWithRed:231.0f / 255.0f green:245.0f / 255.0f blue:1.0f alpha:192.0f / 255.0f];
    return [MDRandom randomColorBetween:firstColor and:secondColor];
}

@end
