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
    
    SKView *skView;
    
    if (![self.view isKindOfClass:[SKView class]]) {
        skView = [[SKView alloc] initWithFrame:self.view.frame];
        skView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.view = skView;
    } else {
        skView = (SKView *) self.view;
    }
    
    self.dotsScene.size = skView.bounds.size;
    
    if (!skView.scene) {
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
