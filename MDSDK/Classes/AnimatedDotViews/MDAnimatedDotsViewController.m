//
//  MDAnimatedDotsViewController.m
//  MDSDK
//
//  Created by Mateusz Dzwonek on 19/09/2013.
//  Copyright (c) 2013 Mateusz Dzwonek. All rights reserved.
//

#import "MDAnimatedDotsViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "MDDotView.h"
#import "MDRandom.h"
#import "UIColor+HexColor.h"

// TODO consider using iOS 7 sprite framework instead of UIViews for MDDotView


static const NSInteger DOTS_PER_SCREEN = 7;

static const NSInteger CANVAS_WIDTH_MULTIPLIER = 2;
static const NSInteger CANVAS_HEIGHT_MULTIPLIER = 2;

static const NSTimeInterval DOT_VIEW_MIN_LIFETIME = 20.0;
static const NSTimeInterval DOT_VIEW_MAX_LIFETIME = 40.0;

static const double DOT_VIEW_MIN_DEPTH = 0.3;
static const double DOT_VIEW_MAX_DEPTH = 1.0;

static const double DOT_FADE_MULTIPLIER = 0.2;

static const CGFloat MATEUSZ_CONSTANT = 400.0f;


@interface MDAnimatedDotsViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) NSArray *backgroundGradientColors;

@property (nonatomic, strong) NSMutableArray *dotViews;

@property (nonatomic, strong) CMMotionManager *motionManager;

@property (nonatomic, strong) NSTimer *dotsGenerator;

@property (nonatomic, strong) NSDate *lastRefreshDate;
@property (nonatomic, assign) UIOffset lastOffset;

- (void)initialize;

- (void)generateDotView;

- (void)startGeneratingDotViews;
- (void)updateDotViewPositionWithAcceleration:(CMAcceleration)acceleration;
- (void)stopGeneratingDotViews;

@end


@implementation MDAnimatedDotsViewController


#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithDelegate:(id<MDAnimatedDotsViewControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        [self initialize];
        self.delegate = delegate;
    }
    return self;
}

- (void)initialize {
    self.backgroundGradientColors = @[[UIColor colorWithHexString:@"41759e"], [UIColor colorWithHexString:@"81b4c4"], [UIColor colorWithHexString:@"90bdd2"],
                                      [UIColor colorWithHexString:@"8e9cd3"], [UIColor colorWithHexString:@"28437a"]];
    self.dotViews = [[NSMutableArray alloc] init];
    self.motionManager = [[CMMotionManager alloc] init];
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    for (int i = 0; i < CANVAS_WIDTH_MULTIPLIER * CANVAS_HEIGHT_MULTIPLIER * DOTS_PER_SCREEN; i++) {
        [self generateDotView];
    }
    
    [self generateBackgroundImage];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.lastRefreshDate = self.lastRefreshDate == nil ? nil : [NSDate new];
    
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
        [self updateDotViewPositionWithAcceleration:motion.gravity];
    }];
    
    [self startGeneratingDotViews];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.motionManager stopDeviceMotionUpdates];
    [self stopGeneratingDotViews];
}


#pragma mark - Background gradient

- (void)generateBackgroundImage {
    NSMutableArray *cgColors = [[NSMutableArray alloc] init];
    for (UIColor *color in self.backgroundGradientColors) {
        [cgColors addObject:(id)color.CGColor];
    }
    CFArrayRef colors = (__bridge CFArrayRef) cgColors;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, NULL);
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(0.0f, CGRectGetHeight(self.view.frame)), 0);
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.backgroundImageView.image = image;
}


#pragma mark - Dot views

- (void)generateDotView {
    MDDotView *dotView = [[MDDotView alloc] init];
    
    dotView.color = [self.delegate colorForDotViewForAnimatedDotsViewController:self];
    
    CGRect frame = dotView.frame;
    frame.origin.x = ([MDRandom randomDouble] - 0.5f) * CANVAS_WIDTH_MULTIPLIER * CGRectGetWidth(self.view.frame);
    frame.origin.y = ([MDRandom randomDouble] - 0.5f) * CANVAS_HEIGHT_MULTIPLIER * CGRectGetHeight(self.view.frame);
    dotView.frame = frame;
    
    dotView.depth = [MDRandom randomDoubleBetween:DOT_VIEW_MIN_DEPTH and:DOT_VIEW_MAX_DEPTH];

    dotView.alpha = 0.0f;
    [self.view addSubview:dotView];
    [self.dotViews addObject:dotView];

    NSTimeInterval dotViewLifeTime = [MDRandom randomDoubleBetween:DOT_VIEW_MIN_LIFETIME and:DOT_VIEW_MAX_LIFETIME];
    [UIView animateWithDuration:DOT_FADE_MULTIPLIER * dotViewLifeTime animations:^{
        dotView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)((1.0 - 2 * DOT_FADE_MULTIPLIER) * dotViewLifeTime * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [UIView animateWithDuration:DOT_FADE_MULTIPLIER * dotViewLifeTime animations:^{
                dotView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [dotView removeFromSuperview];
                [self.dotViews removeObject:dotView];
            }];
        });
    }];
}

- (void)startGeneratingDotViews {
    [self generateDotView];

    NSTimeInterval dotViewLifeTime = [MDRandom randomDoubleBetween:DOT_VIEW_MIN_LIFETIME and:DOT_VIEW_MAX_LIFETIME];
    NSInteger totalNumberOfDots = DOTS_PER_SCREEN * CANVAS_WIDTH_MULTIPLIER * CANVAS_HEIGHT_MULTIPLIER;
    double delayInSeconds = dotViewLifeTime / (double)totalNumberOfDots;
    
    self.dotsGenerator = [NSTimer scheduledTimerWithTimeInterval:delayInSeconds target:self selector:@selector(startGeneratingDotViews) userInfo:nil repeats:NO];
}

- (void)updateDotViewPositionWithAcceleration:(CMAcceleration)acceleration {
    UIOffset offset = UIOffsetMake(acceleration.x, -acceleration.y);
    UIOffset deltaVelocity = UIOffsetMake(offset.horizontal - self.lastOffset.horizontal, offset.vertical - self.lastOffset.vertical);
    self.lastOffset = offset;
    
    NSDate *now = [NSDate date];
    if (self.lastRefreshDate) {
        NSTimeInterval deltaTime = [now timeIntervalSinceDate:self.lastRefreshDate];
        for (MDDotView *dotView in self.dotViews) {
            [dotView updatePositionWithDeltaVelocity:deltaVelocity andDeltaTime:deltaTime];
        }
    }
    self.lastRefreshDate = now;
}

- (void)stopGeneratingDotViews {
    if ([self.dotsGenerator isValid]) {
        [self.dotsGenerator invalidate];
        self.dotsGenerator = nil;
    }
}


@end
