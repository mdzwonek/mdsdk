//
//  MDDotNode.m
//  MDSDK
//
//  Created by Mateusz Dzwonek on 23/10/2013.
//  Copyright (c) 2013 Mateusz Dzwonek. All rights reserved.
//

#import "MDDotNode.h"

#define MATEUSZ_CONSTANT ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? 400.0f : 700.0f)


static const CGFloat STROKE_RADIUS_MIN = 0.3f;
static const CGFloat STROKE_RADIUS_MAX = 0.925f;


@interface MDDotNode ()

@property (nonatomic, assign) CGFloat diameter;

@property (nonatomic, strong) SKSpriteNode *textureNode;

@property (nonatomic, assign) UIOffset velocity;

- (UIImage *)generateInternalImage;

@end


@implementation MDDotNode

- (instancetype)initWithDiameter:(CGFloat)diameter {
    self = [super initWithColor:[UIColor clearColor] size:CGSizeMake(diameter, diameter)];
    if (self) {
        self.diameter = diameter;
        
        self.textureNode = [[SKSpriteNode alloc] init];
        [self addChild:self.textureNode];
        
        self.depth = 1.0f;
        
        self.velocity = UIOffsetMake(0.0f, 0.0f);
        self.destinationVelocity = UIOffsetMake(0.0f, 0.0f);
        
        [self generateInternalImage];
    }
    return self;
}

- (void)setDotColor:(UIColor *)dotColor {
    _dotColor = dotColor;
    self.textureNode.texture = [SKTexture textureWithImage:[self generateInternalImage]];
}

- (void)setDepth:(CGFloat)depth {
    _depth = depth;
    
    self.size = CGSizeMake(self.depth * self.diameter, self.depth * self.diameter);
    
    self.textureNode.alpha = self.depth;
    self.textureNode.size = self.size;
    self.textureNode.texture = [SKTexture textureWithImage:[self generateInternalImage]];
}

- (UIImage *)generateInternalImage {
    if (self.dotColor == nil) {
        return nil;
    }
    UIGraphicsBeginImageContext(self.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat locations[2] = {0.0 ,1.0};
    UIColor *clearColor = [self.dotColor colorWithAlphaComponent:0.0f];
    CFArrayRef colors = (__bridge CFArrayRef) [NSArray arrayWithObjects:(id)self.dotColor.CGColor, (id)clearColor.CGColor, nil];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, locations);
    
    CGPoint center = CGPointMake(CGRectGetWidth(self.frame) / 2.0f, CGRectGetHeight(self.frame) / 2.0f);
    CGFloat fullRadius = CGRectGetWidth(self.frame) / 2.0f;
    CGFloat strokeRadiusMultiplier = MAX(STROKE_RADIUS_MIN, MIN(STROKE_RADIUS_MAX, self.depth));
    CGContextDrawRadialGradient(context, gradient, center, strokeRadiusMultiplier * fullRadius, center, fullRadius, kCGGradientDrawsBeforeStartLocation);
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)updatePositionWithDeltaVelocity:(UIOffset)deltaVelocity andDeltaTime:(NSTimeInterval)deltaTime {
    self.velocity = UIOffsetAdd(self.velocity, deltaVelocity);
    UIOffset relativeVelocity = UIOffsetSubstract(self.velocity, self.destinationVelocity);
    self.velocity = UIOffsetAdd(self.velocity, UIOffsetMultiply(relativeVelocity, -deltaTime));
    
    CGFloat multiplier = powf(self.depth, 2.0f) * MATEUSZ_CONSTANT * deltaTime;
    self.position = CGPointMake(self.position.x + multiplier * self.velocity.horizontal, self.position.y + multiplier * self.velocity.vertical);
}

- (void)updateDotColor:(UIColor *)color withDuration:(NSTimeInterval)duration {
    _dotColor = color;
    NSTimeInterval halfDuration = duration / 2.0;
    SKAction *fadeOutAction = [SKAction fadeOutWithDuration:halfDuration];
    SKAction *setTextureAction = [SKAction setTexture:[SKTexture textureWithImage:[self generateInternalImage]]];
    SKAction *fadeInAction = [SKAction fadeAlphaTo:self.textureNode.alpha duration:halfDuration];
    [self.textureNode runAction:[SKAction sequence:@[ fadeOutAction, setTextureAction, fadeInAction ]]];
}

@end
