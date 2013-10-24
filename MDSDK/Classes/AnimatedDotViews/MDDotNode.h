//
//  MDDotNode.h
//  MDSDK
//
//  Created by Mateusz Dzwonek on 23/10/2013.
//  Copyright (c) 2013 Mateusz Dzwonek. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MDDotNode : SKSpriteNode

@property (nonatomic, strong) UIColor *dotColor;
@property (nonatomic, assign) CGFloat depth;
@property (nonatomic, assign) UIOffset destinationVelocity;

- (instancetype)initWithDiameter:(CGFloat)diameter;

- (void)updatePositionWithDeltaVelocity:(UIOffset)deltaVelocity andDeltaTime:(NSTimeInterval)deltaTime;

@end
