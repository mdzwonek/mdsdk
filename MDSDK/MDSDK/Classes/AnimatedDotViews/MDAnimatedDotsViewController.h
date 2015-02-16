//
//  MDAnimatedDotsViewController.h
//  MDSDK
//
//  Created by Mateusz Dzwonek on 19/09/2013.
//  Copyright (c) 2013 Mateusz Dzwonek. All rights reserved.
//

@class MDAnimatedDotsScene;

@interface MDAnimatedDotsViewController : UIViewController

@property (nonatomic, strong, readonly) MDAnimatedDotsScene *dotsScene;
@property (nonatomic, readonly) BOOL isStarted;

- (void)start;
- (void)stop;
- (void)reset;

@end
