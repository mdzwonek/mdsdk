//
//  AppDelegate.m
//  MDSDK
//
//  Created by Mateusz Dzwonek on 14/09/2013.
//  Copyright (c) 2013 Mateusz Dzwonek. All rights reserved.
//

#import "AppDelegate.h"
#import "MDSDK.h"
#import "RootViewController.h"

static const CGFloat CORNER_RADIUS = 3.0f;

@interface AppDelegate ()

@property (nonatomic) MDPopupButtonsController *controller;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UIViewController *rootVC = [[UIViewController alloc] init];
    self.window.rootViewController = rootVC;
    
    MDAnimatedDotsViewController *animatedDotsViewController = [[MDAnimatedDotsViewController alloc] init];
    [rootVC addChildViewController:animatedDotsViewController];
    animatedDotsViewController.view.frame = rootVC.view.frame;
    [rootVC.view addSubview:animatedDotsViewController.view];
    
    UIViewController *leftMenuVC = [[UIViewController alloc] init];
    leftMenuVC.view.layer.cornerRadius = CORNER_RADIUS;
    leftMenuVC.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
    
    UIViewController *rightMenuVC = [[UIViewController alloc] init];
    rightMenuVC.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
    
    RootViewController *contentVC = [[RootViewController alloc] init];
    contentVC.view.layer.cornerRadius = CORNER_RADIUS;
    
    MDSideMenuViewController *sideMenuVC = [[MDSideMenuViewController alloc] initWithLeftMenuVC:leftMenuVC rightMenuVC:rightMenuVC andContentVC:contentVC];
    [rootVC addChildViewController:sideMenuVC];
    sideMenuVC.view.frame = rootVC.view.frame;
    [rootVC.view addSubview:sideMenuVC.view];
    [self addDelegateBlocksToSideMenuVC:sideMenuVC];
    
    contentVC.didTapLeftMenuButtonBlock = ^{
        [sideMenuVC toggleLeftMenu];
    };
    contentVC.didTapRightMenuButtonBlock = ^{
        [sideMenuVC toggleRightMenu];
    };
    
    // move content below status bar
    // TODO do it for menus too
    CGRect frame = contentVC.view.frame;
    frame.origin.y += 22.0f;
    frame.size.height -= 2.0f * 22.0f;
    contentVC.view.frame = frame;
    
    self.controller = [[MDPopupButtonsController alloc] init];
    NSArray *texts = @[@"camera", @"edit", @"gallery", @"share"];
    NSArray *imageNames = @[@"button_camera", @"button_edit", @"button_gallery", @"button_share"];
    for (NSInteger i = 0; i < imageNames.count && texts.count; i++) {
        UIImage *image = [UIImage imageNamed:[imageNames objectAtIndex:i]];
        [self.controller addPopupButtonWithImage:image andText:[texts objectAtIndex:i]];
    }
    self.controller.didFinishWithPopupButtonWithText = ^(NSString *text) {
        NSLog(@"Did choose '%@'", text);
    };
    [self.controller addToView:leftMenuVC.view];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)addDelegateBlocksToSideMenuVC:(MDSideMenuViewController *)sideMenuVC {
    sideMenuVC.didToggleLeftMenuBlock = ^(MDSideMenuViewController *sideMenuVC) {
        NSLog(@"Did toggle left menu. Is hidden now %d.", sideMenuVC.leftMenuHidden);
    };
    sideMenuVC.didToggleRightMenuBlock = ^(MDSideMenuViewController *sideMenuVC) {
        NSLog(@"Did toggle right menu. Is hidden now %d.", sideMenuVC.rightMenuHidden);
    };
}

@end
