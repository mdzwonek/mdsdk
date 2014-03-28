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

@property (nonatomic) MDAnimatedDotsScene *dotsScene;
@property (nonatomic) SKView *skView;

@end

@implementation MDAnimatedDotsViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.dotsScene = [[MDAnimatedDotsScene alloc] init];
    self.dotsScene.scaleMode = SKSceneScaleModeResizeFill;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (![self.view isKindOfClass:[SKView class]]) {
        self.skView = [[SKView alloc] initWithFrame:self.view.frame];
        self.skView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.view = self.skView;
    } else {
        self.skView = (SKView *) self.view;
    }
    
    self.dotsScene.size = self.skView.bounds.size;
    
    if (!self.skView.scene) {
        [self.skView presentScene:self.dotsScene];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self start];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stop];
}

- (void)start {
    self.skView.paused = NO;
    [self.dotsScene start];
}

- (void)stop {
    self.skView.paused = YES;
    [self.dotsScene stop];
}

@end
