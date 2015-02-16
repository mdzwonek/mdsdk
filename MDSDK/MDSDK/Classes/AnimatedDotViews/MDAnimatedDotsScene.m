//
//  MDAnimatedDotsScene.m
//  MDSDK
//
//  Created by Mateusz Dzwonek on 23/10/2013.
//  Copyright (c) 2013 Mateusz Dzwonek. All rights reserved.
//

#import "MDAnimatedDotsScene.h"
#import <CoreMotion/CoreMotion.h>
#import "MDDotNode.h"
#import "MDRandom.h"
#import "UIColor+HexColor.h"

#define TOTAL_NUMBER_OF_DOTS (CANVAS_WIDTH_MULTIPLIER * CANVAS_HEIGHT_MULTIPLIER * self.numberOfDots())
// The bigger screen, the more dots; 7 dots for 3.5 inch screen.
#define DEFAULT_NUMBER_OF_DOTS_ON_SCREEN ((NSInteger) ((SCREEN_WIDTH * SCREEN_HEIGHT) * 7.0f / (320.0f * 480.0f)))


static const NSInteger CANVAS_WIDTH_MULTIPLIER  = 2;
static const NSInteger CANVAS_HEIGHT_MULTIPLIER = 2;

static const CGFloat DEFAULT_DOT_NODE_DIAMETER = 150.0f;

static const NSTimeInterval DOT_NODE_LIFETIME_MIN = 20.0;
static const NSTimeInterval DOT_NODE_LIFETIME_MAX = 40.0;

static const double DOT_NODE_DEPTH_MIN = 0.3;
static const double DOT_NODE_DEPTH_MAX = 1.0;

static const CGFloat DOT_NODE_RANDOM_VELOCITY_MIN = -0.01f;
static const CGFloat DOT_NODE_RANDOM_VELOCITY_MAX = 0.01f;

static const double DOT_FADE_ANIMATION_PERCENTAGE = 0.2;


@interface MDAnimatedDotsScene ()

@property (nonatomic, strong) SKSpriteNode *backgroundNode;
@property (nonatomic, strong) NSMutableArray *dotNodes;

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) NSOperationQueue *motionCallbacksOperationQueue;

@property (nonatomic, strong) NSTimer *dotsGenerator;

@property (nonatomic, getter = isStarted) BOOL started;
@property (nonatomic, assign) BOOL isFirstRefreshAfterStop;

@property (nonatomic, assign) UIOffset currentVelocity;
@property (nonatomic, assign) UIOffset lastVelocity;
@property (nonatomic, assign) NSTimeInterval lastRefreshTime;

- (void)initialize;

- (void)refreshDotsColorsWithDuration:(NSTimeInterval)duration;
- (void)refreshBackgroundImageWithDuration:(NSTimeInterval)duration;
- (void)refreshBackgroundImage;

- (void)startGeneratingDotNodes;
- (void)generateDotNode;
- (void)stopGeneratingDotNodes;

- (void)addActionsToDotNodesIncludingFadeIn:(BOOL)includeFadeIn;
- (void)addActionsToDotNode:(MDDotNode *)dotNode includingFadeIn:(BOOL)includeFadeIn;
- (void)removeActionsFromDotNodes;

- (UIImage *)defaultBackgroundImage;
- (NSInteger)defaultNumberOfDots;

- (CGFloat)defaultDotNodeDiameter;
- (NSTimeInterval)defaultAverageDotNodeLifeTime;

- (CGPoint)defaultPositionForNode:(MDDotNode *)dotNode;
- (UIColor *)defaultColorForDotNode:(MDDotNode *)dotNode;
- (CGFloat)defaultDepthForDotNode:(MDDotNode *)dotNode;
- (UIOffset)defaultDestinationVelocityForDotNode:(MDDotNode *)dotNode;
- (NSTimeInterval)defaultLifeTimeForDotNode:(MDDotNode *)dotNode;

@end


@implementation MDAnimatedDotsScene


#pragma mark - Scene lifecycle

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

- (instancetype)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.backgroundNode = [[SKSpriteNode alloc] init];
    [self addChild:self.backgroundNode];
    
    __weak MDAnimatedDotsScene *weakSelf = self;
    self.backgroundImage = ^() { return [weakSelf defaultBackgroundImage]; };
    self.numberOfDots = ^() { return [weakSelf defaultNumberOfDots]; };
    
    self.dotNodeDiameter = ^() { return [weakSelf defaultDotNodeDiameter]; };
    self.averageDotNodeLifeTime = ^() { return [weakSelf defaultAverageDotNodeLifeTime]; };
    
    self.positionForNode = ^(MDDotNode *dotNode) { return [weakSelf defaultPositionForNode:dotNode]; };
    self.colorForDotNode = ^(MDDotNode *dotNode) { return [weakSelf defaultColorForDotNode:dotNode]; };
    self.depthForDotNode = ^(MDDotNode *dotNode) { return [weakSelf defaultDepthForDotNode:dotNode]; };
    self.destinationVelocityForDotNode = ^(MDDotNode *dotNode) { return [weakSelf defaultDestinationVelocityForDotNode:dotNode]; };
    self.lifeTimeForDotNode = ^(MDDotNode *dotNode) { return [weakSelf defaultLifeTimeForDotNode:dotNode]; };
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionCallbacksOperationQueue = [[NSOperationQueue alloc] init];
}

- (void)didMoveToView:(SKView *)view {
    [super didMoveToView:view];
    
    [self refreshBackgroundImage];
    
    if (self.dotNodes == nil) {
        self.dotNodes = [[NSMutableArray alloc] init];
        for (int i = 0; i < TOTAL_NUMBER_OF_DOTS; i++) {
            [self generateDotNode];
        }
    }
    [self start];
}

- (void)willMoveFromView:(SKView *)view {
    [super willMoveFromView:view];
    [self stop];
}

- (void)refreshUIWithBackgroundChangeDuration:(NSTimeInterval)backgroundDuration andDotsChangeDuration:(NSTimeInterval)dotsDuration {
    [self refreshDotsColorsWithDuration:dotsDuration];
    [self refreshBackgroundImageWithDuration:backgroundDuration];
}

- (void)refreshDotsColorsWithDuration:(NSTimeInterval)duration {
    for (MDDotNode *dotNode in self.dotNodes) {
        [dotNode updateDotColor:self.colorForDotNode(dotNode) withDuration:duration];
    }
}

- (void)didChangeSize:(CGSize)oldSize {
    [self refreshBackgroundImage];
}

- (void)setBackgroundImage:(UIImage *(^)())backgroundImage {
    _backgroundImage = backgroundImage;
    [self refreshBackgroundImage];
}

- (void)refreshBackgroundImageWithDuration:(NSTimeInterval)duration {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SKTexture *texture = [SKTexture textureWithImage:self.backgroundImage != nil ? self.backgroundImage() : [self defaultBackgroundImage]];
        dispatch_async(dispatch_get_main_queue(), ^{
            SKSpriteNode *tempBackgroundNode = [[SKSpriteNode alloc] initWithTexture:self.backgroundNode.texture];
            tempBackgroundNode.position = self.backgroundNode.position;
            // insert temp background in front of current one
            [self insertChild:tempBackgroundNode atIndex:[self.children indexOfObject:self.backgroundNode] + 1];
            
            self.backgroundNode.texture = texture;
            
            [tempBackgroundNode runAction:[SKAction fadeOutWithDuration:duration] completion:^{
                [tempBackgroundNode removeFromParent];
            }];
        });
    });
}

- (void)refreshBackgroundImage {
    self.backgroundNode.size = self.size;
    self.backgroundNode.texture = [SKTexture textureWithImage:self.backgroundImage != nil ? self.backgroundImage() : [self defaultBackgroundImage]];
    self.backgroundNode.position = CGPointMake(self.size.width / 2.0f, self.size.height / 2.0f);
}


#pragma mark - Start / stop

- (void)start {
    if (self.isStarted) {
        return;
    }
    self.started = YES;
    
    self.isFirstRefreshAfterStop = YES;
    [self.motionManager startDeviceMotionUpdatesToQueue:self.motionCallbacksOperationQueue withHandler:^(CMDeviceMotion *motion, NSError *error) {
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        
        UIApplication *application = [UIApplication sharedApplication];
        NSUInteger supportedInterfaceOrientations = [application supportedInterfaceOrientationsForWindow:self.view.window];
        
        UIOffset velocity = UIOffsetMake(motion.gravity.x, motion.gravity.y);
        if (orientation == UIDeviceOrientationLandscapeLeft && supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeLeft) {
            velocity.horizontal *= -1;
        } else if (orientation == UIDeviceOrientationLandscapeRight && supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeRight) {
            velocity.vertical *= -1;
        } else if (orientation == UIDeviceOrientationPortraitUpsideDown && supportedInterfaceOrientations & UIInterfaceOrientationPortraitUpsideDown) {
            velocity.horizontal *= -1;
            velocity.vertical *= -1;
        }
        self.currentVelocity = velocity;
    }];
    
    [self addActionsToDotNodesIncludingFadeIn:NO];
    [self startGeneratingDotNodes];
}

- (void)stop {
    if (!self.isStarted) {
        return;
    }
    self.started = NO;
    
    [self.motionManager stopDeviceMotionUpdates];
    [self stopGeneratingDotNodes];
    [self removeActionsFromDotNodes];
}

- (void)reset {
    [self removeDotNodes];
}


#pragma mark - Executing the Animation Loop

- (void)update:(NSTimeInterval)currentTime {
    [super update:currentTime];
    
    if (!self.isStarted) {
        return;
    }
    
    UIOffset deltaVelocity = UIOffsetSubstract(self.currentVelocity, self.lastVelocity);
    self.lastVelocity = self.currentVelocity;
    
    if (self.isFirstRefreshAfterStop) {// reset lastRefreshTime before first refresh after stop
        self.lastRefreshTime = self.lastRefreshTime == 0 ? 0 : currentTime;
        self.isFirstRefreshAfterStop = NO;
    }
    
    if (self.lastRefreshTime != 0) {
        NSTimeInterval deltaTime = currentTime - self.lastRefreshTime;
        for (MDDotNode *dotNode in self.dotNodes) {
            [dotNode updatePositionWithDeltaVelocity:deltaVelocity andDeltaTime:deltaTime];
        }
    }
    
    self.lastRefreshTime = currentTime;
}


#pragma mark - Dot views

- (void)startGeneratingDotNodes {
    [self generateDotNode];
    
    NSTimeInterval dotViewLifeTime = self.averageDotNodeLifeTime();
    double delayInSecs = dotViewLifeTime / (double)TOTAL_NUMBER_OF_DOTS;
    
    self.dotsGenerator = [NSTimer scheduledTimerWithTimeInterval:delayInSecs target:self selector:@selector(startGeneratingDotNodes) userInfo:nil repeats:NO];
}

- (void)generateDotNode {
    if (self.dotNodes == nil) {
        return;// not ready yet
    }
    
    MDDotNode *dotNode = [[MDDotNode alloc] initWithDiameter:self.dotNodeDiameter()];
    dotNode.position = self.positionForNode(dotNode);
    dotNode.dotColor = self.colorForDotNode(dotNode);
    dotNode.depth = self.depthForDotNode(dotNode);
    dotNode.destinationVelocity = self.destinationVelocityForDotNode(dotNode);
    
    [self addChild:dotNode];
    [self.dotNodes addObject:dotNode];

    [self addActionsToDotNode:dotNode includingFadeIn:YES];
}

- (void)stopGeneratingDotNodes {
    if ([self.dotsGenerator isValid]) {
        [self.dotsGenerator invalidate];
        self.dotsGenerator = nil;
    }
}

- (void)addActionsToDotNodesIncludingFadeIn:(BOOL)includeFadeIn {
    for (MDDotNode *dotNode in self.dotNodes) {
        [self addActionsToDotNode:dotNode includingFadeIn:includeFadeIn];
    }
}

- (void)addActionsToDotNode:(MDDotNode *)dotNode includingFadeIn:(BOOL)includeFadeIn {
    if (includeFadeIn) {
        dotNode.alpha = 0.0f;
    }
    
    NSTimeInterval dotViewLifeTime = self.lifeTimeForDotNode(dotNode);
    
    SKAction *fadeIn = [SKAction fadeInWithDuration:DOT_FADE_ANIMATION_PERCENTAGE * dotViewLifeTime];
    SKAction *wait = [SKAction waitForDuration:(1.0 - 2 * DOT_FADE_ANIMATION_PERCENTAGE) * dotViewLifeTime];
    SKAction *fadeOut = [SKAction fadeOutWithDuration:DOT_FADE_ANIMATION_PERCENTAGE * dotViewLifeTime];
    SKAction *sequence = includeFadeIn ? [SKAction sequence:@[fadeIn, wait, fadeOut]] : [SKAction sequence:@[wait, fadeOut]];
    [dotNode runAction:sequence completion:^{
        [dotNode removeFromParent];
        [self.dotNodes removeObject:dotNode];
    }];
}

- (void)removeActionsFromDotNodes {
    for (MDDotNode *dotNode in self.dotNodes) {
        [dotNode removeAllActions];
    }
}

- (void)removeDotNodes {
    [self removeChildrenInArray:self.dotNodes];
    self.dotNodes = [NSMutableArray new];
}


#pragma mark - Default implementations of block properties

- (UIImage *)defaultBackgroundImage {
    NSArray *cgColors = @[(id)[UIColor colorWithHexString:@"41759e"].CGColor, (id)[UIColor colorWithHexString:@"81b4c4"].CGColor,
                          (id)[UIColor colorWithHexString:@"90bdd2"].CGColor, (id)[UIColor colorWithHexString:@"8e9cd3"].CGColor,
                          (id)[UIColor colorWithHexString:@"28437a"].CGColor];
    
    
    CFArrayRef colors = (__bridge CFArrayRef) cgColors;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, NULL);
    
    UIGraphicsBeginImageContext(self.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (context == nil) {
        CGColorSpaceRelease(colorSpace);
        CGGradientRelease(gradient);
        return nil;
    }
    
    CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(0.0f, CGRectGetHeight(self.view.frame)), 0);
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (NSInteger)defaultNumberOfDots {
    return DEFAULT_NUMBER_OF_DOTS_ON_SCREEN;
}

- (CGFloat)defaultDotNodeDiameter {
    return DEFAULT_DOT_NODE_DIAMETER;
}

- (NSTimeInterval)defaultAverageDotNodeLifeTime {
    return [self defaultLifeTimeForDotNode:nil];
}

- (CGPoint)defaultPositionForNode:(MDDotNode *)dotNode {
    CGFloat x = ([MDRandom randomDouble] - 0.5f) * CANVAS_WIDTH_MULTIPLIER * CGRectGetWidth(self.view.frame);
    CGFloat y = ([MDRandom randomDouble] - 0.5f) * CANVAS_HEIGHT_MULTIPLIER * CGRectGetHeight(self.view.frame);
    return CGPointMake(x, y);
}

- (UIColor *)defaultColorForDotNode:(MDDotNode *)dotNode {
    UIColor *firstColor = [UIColor colorWithRed:157.0f / 255.0f green:201.0f / 255.0f blue:248.0f / 255.0f alpha:192.0f / 255.0f];
    UIColor *secondColor = [UIColor colorWithRed:231.0f / 255.0f green:245.0f / 255.0f blue:1.0f alpha:192.0f / 255.0f];
    return [MDRandom randomColorBetween:firstColor and:secondColor];
}

- (CGFloat)defaultDepthForDotNode:(MDDotNode *)dotNode {
    return [MDRandom randomDoubleBetween:DOT_NODE_DEPTH_MIN and:DOT_NODE_DEPTH_MAX];
}

- (UIOffset)defaultDestinationVelocityForDotNode:(MDDotNode *)dotNode {
    CGFloat randomVelocityHorizontal = [MDRandom randomDoubleBetween:DOT_NODE_RANDOM_VELOCITY_MIN and:DOT_NODE_RANDOM_VELOCITY_MAX];
    CGFloat randomVelocityVertical = [MDRandom randomDoubleBetween:DOT_NODE_RANDOM_VELOCITY_MIN and:DOT_NODE_RANDOM_VELOCITY_MAX];
    return UIOffsetMake(randomVelocityHorizontal, randomVelocityVertical);
}

- (NSTimeInterval)defaultLifeTimeForDotNode:(MDDotNode *)dotNode {
    return [MDRandom randomDoubleBetween:DOT_NODE_LIFETIME_MIN and:DOT_NODE_LIFETIME_MAX];
}

@end
