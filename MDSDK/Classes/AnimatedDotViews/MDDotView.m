//
//  MDDotView.m
//  MDSDK
//
//  Created by Mateusz Dzwonek on 14/09/2013.
//  Copyright (c) 2013 Mateusz Dzwonek. All rights reserved.
//

#import "MDDotView.h"
#import "MDRandom.h"

#define UIOffsetAdd(firstOffset, secondOffset) UIOffsetMake(firstOffset.horizontal + secondOffset.horizontal, firstOffset.vertical + secondOffset.vertical)
#define UIOffsetMultiply(offset, multiplier) UIOffsetMake(multiplier * offset.horizontal, multiplier * offset.vertical)
#define UIOffsetSubstract(firstOffset, secondOffset) UIOffsetAdd(firstOffset, UIOffsetMultiply(secondOffset, -1.0f))


static const CGFloat RANDOM_VELOCITY_MIN = -0.01f;
static const CGFloat RANDOM_VELOCITY_MAX = 0.01f;

static const CGFloat STROKE_RADIUS_MIN = 0.3f;
static const CGFloat STROKE_RADIUS_MAX = 0.925f;

static const CGFloat MATEUSZ_CONSTANT = 400.0f;

CGFloat DEFAULT_DOT_VIEW_SIZE = 150.0f;


@interface MDDotView ()

@property (nonatomic, assign) UIOffset randomVelocity;
@property (nonatomic, assign) UIOffset velocity;

@property (nonatomic, strong) UIImageView *imageView;

@end


@implementation MDDotView

- (id)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        CGRect frame = self.frame;
        frame.size = CGSizeMake(DEFAULT_DOT_VIEW_SIZE, DEFAULT_DOT_VIEW_SIZE);
        self.frame = frame;
        self.depth = 1.0f;
        
        CGFloat randomVelocityHorizontal = [MDRandom randomDoubleBetween:RANDOM_VELOCITY_MIN and:RANDOM_VELOCITY_MAX];
        CGFloat randomVelocityVertical = [MDRandom randomDoubleBetween:RANDOM_VELOCITY_MIN and:RANDOM_VELOCITY_MAX];
        self.randomVelocity = UIOffsetMake(randomVelocityHorizontal, randomVelocityVertical);
        self.velocity = UIOffsetMake(0.0f, 0.0f);
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.imageView];
        
        [self generateInternalImage];
    }
    return self;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    [self generateInternalImage];
}

- (void)setDepth:(CGFloat)depth {
    _depth = depth;
    
    CGRect frame = self.frame;
    frame.size = CGSizeMake(self.depth * DEFAULT_DOT_VIEW_SIZE, self.depth * DEFAULT_DOT_VIEW_SIZE);
    self.frame = frame;
    
    self.imageView.alpha = self.depth;
    
    [self generateInternalImage];
}

- (void)generateInternalImage {
    if (self.color != nil) {
        UIGraphicsBeginImageContext(self.frame.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGFloat locations[2] = {0.0 ,1.0};
        CGFloat r, g, b, a;
        [self.color getRed:&r green:&g blue:&b alpha:&a];
        UIColor *clearColor = [UIColor colorWithRed:r green:g blue:b alpha:0.0f];
        CFArrayRef colors = (__bridge CFArrayRef) [NSArray arrayWithObjects:(id)self.color.CGColor, (id)clearColor.CGColor, nil];
        
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
        self.imageView.image = image;
    }
}

- (void)updatePositionWithDeltaVelocity:(UIOffset)deltaVelocity andDeltaTime:(NSTimeInterval)deltaTime {
    self.velocity = UIOffsetAdd(self.velocity, deltaVelocity);
    UIOffset relativeVelocity = UIOffsetSubstract(self.velocity, self.randomVelocity);
    self.velocity = UIOffsetAdd(self.velocity, UIOffsetMultiply(relativeVelocity, -deltaTime));
    
    CGFloat multiplier = powf(self.depth, 2.0f) * MATEUSZ_CONSTANT * deltaTime;
    self.frame = CGRectOffset(self.frame, multiplier * self.velocity.horizontal, multiplier * self.velocity.vertical);
}


@end
