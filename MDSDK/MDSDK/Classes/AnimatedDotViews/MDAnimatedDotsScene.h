//
//  MDAnimatedDotsScene.h
//  MDSDK
//
//  Created by Mateusz Dzwonek on 23/10/2013.
//  Copyright (c) 2013 Mateusz Dzwonek. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class MDDotNode;

@interface MDAnimatedDotsScene : SKScene

@property (nonatomic, copy) UIImage *(^backgroundImage)();
@property (nonatomic, copy) NSInteger (^numberOfDots)();

@property (nonatomic, copy) CGFloat (^dotNodeDiameter)();
@property (nonatomic, copy) NSTimeInterval (^averageDotNodeLifeTime)();

@property (nonatomic, copy) CGPoint (^positionForNode)(MDDotNode *dotNode);
@property (nonatomic, copy) UIColor *(^colorForDotNode)(MDDotNode *dotNode);
@property (nonatomic, copy) CGFloat (^depthForDotNode)(MDDotNode *dotNode);
@property (nonatomic, copy) UIOffset (^destinationVelocityForDotNode)(MDDotNode *dotNode);
@property (nonatomic, copy) NSTimeInterval (^lifeTimeForDotNode)(MDDotNode *dotNode);

- (void)start;
- (void)stop;

- (void)refreshUIWithBackgroundChangeDuration:(NSTimeInterval)backgroundDuration andDotsChangeDuration:(NSTimeInterval)dotsDuration;

@end
