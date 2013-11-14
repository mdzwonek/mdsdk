//
//  MDAnimatedDotsViewController.m
//  MDSDK
//
//  Created by Mateusz Dzwonek on 19/09/2013.
//  Copyright (c) 2013 Mateusz Dzwonek. All rights reserved.
//

#import "MDAnimatedDotsViewController.h"
#import "MDAnimatedDotsScene.h"

@interface MDAnimatedDotsViewController ()

@property (nonatomic, strong) MDAnimatedDotsScene *dotsScene;

@end

@implementation MDAnimatedDotsViewController

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    SKView *skView = (SKView *)self.view;
    if (!skView.scene) {
        self.dotsScene = [[MDAnimatedDotsScene alloc] initWithSize:skView.bounds.size];
        self.dotsScene.scaleMode = SKSceneScaleModeResizeFill;
        [skView presentScene:self.dotsScene];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.dotsScene start];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.dotsScene stop];
}

@end
