//
//  MDColorPickerView.m
//  MDSDK
//
//  Created by Mateusz Dzwonek on 06/03/2015.
//  Copyright (c) 2015 Mateusz Dzwonek. All rights reserved.
//

#import "MDColorPickerView.h"
#import "UIColor+Equal.h"


static const NSInteger MDGradientViewInterpolationBlockCount = 256;
static const CGFloat MDGradientViewColorTolerance = 0.01f;


@interface MDColorPickerView ()

@property (nonatomic) UIView *indicatorView;

@end


@implementation MDColorPickerView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    [self setUpIndicatorView];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeGesture:)]];
    [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeGesture:)]];
}

- (void)setUpIndicatorView {
    _indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
    _indicatorView.layer.cornerRadius = CGRectGetWidth(_indicatorView.frame) / 2.0f;
    _indicatorView.clipsToBounds = YES;
    _indicatorView.layer.borderWidth = 3.0f;
    _indicatorView.layer.borderColor = [UIColor whiteColor].CGColor;
    _indicatorView.hidden = YES;
    [self addSubview:_indicatorView];
}

- (void)setColor:(UIColor *)color withReverseColorGenerator:(MDReverseColorGenerator)reverseColorGenerator {
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGPoint currentLocation = _indicatorView.center;
    CGFloat distance = sqrtf(powf(center.x - currentLocation.x, 2.0f) + powf(center.y - currentLocation.y, 2.0f));
    CGFloat radius = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) / 2.0f;
    if (distance < _innerRadiusMultiplier * radius || distance > _outerRadiusMultiplier * radius) {
        distance = radius * (_innerRadiusMultiplier + _outerRadiusMultiplier) / 2.0f;
    }
    
    CGFloat progress = reverseColorGenerator(color);
    UIColor *generatedColor = _colorGenerator(progress);
    if (![generatedColor isEqualToColor:color withTolerance:MDGradientViewColorTolerance]) {
        _indicatorView.hidden = YES;
        return;
    }
    
    CGFloat angle = DEGREES_TO_RADIANS(_startAngle + (_endAngle - _startAngle) * progress);
    CGPoint point = [self pointWithAngle:angle radius:distance center:center];
    [self moveColorIndicatorToPoint:point andChangeColorTo:color];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawGradientInContext:context rect:rect interpolationBlockCount:MDGradientViewInterpolationBlockCount];
}

- (void)drawGradientInContext:(CGContextRef)context rect:(CGRect)rect interpolationBlockCount:(NSInteger)interpolationBlockCount {
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGFloat radius = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect)) / 2.0f;
    CGFloat innerRadius = _innerRadiusMultiplier * radius;
    CGFloat outerRadius = _outerRadiusMultiplier * radius;

    float angleDelta = DEGREES_TO_RADIANS((_endAngle - _startAngle) / (float)interpolationBlockCount);

    for (int i = 0; i < interpolationBlockCount; i++) {
        float fraction = (float) i / (float)interpolationBlockCount;
        float stepStartingAngle = DEGREES_TO_RADIANS(_startAngle) + i * angleDelta;
        float stepEndingAngle   = stepStartingAngle + angleDelta;

        CGMutablePathRef trapezoid = CGPathCreateMutable();
        CGPoint p0 = [self pointWithAngle:stepStartingAngle radius:innerRadius center:center];
        CGPoint p1 = [self pointWithAngle:stepStartingAngle radius:outerRadius center:center];
        CGPoint p2 = [self pointWithAngle:stepEndingAngle   radius:outerRadius center:center];
        CGPoint p3 = [self pointWithAngle:stepEndingAngle   radius:innerRadius center:center];

        CGPathMoveToPoint(trapezoid, NULL, p0.x, p0.y);
        CGPathAddLineToPoint(trapezoid, NULL, p1.x, p1.y);
        CGPathAddLineToPoint(trapezoid, NULL, p2.x, p2.y);
        CGPathAddLineToPoint(trapezoid, NULL, p3.x, p3.y);
        CGPathCloseSubpath(trapezoid);

        CGContextAddPath(context, trapezoid);
        CGContextSetFillColorWithColor(context, _colorGenerator(fraction).CGColor);
        CGContextSetStrokeColorWithColor(context, _colorGenerator(fraction).CGColor);
        CGContextSetMiterLimit(context, 0);
        CGContextDrawPath(context, kCGPathFillStroke);

        CGPathRelease(trapezoid);
    }
}

- (CGPoint)pointWithAngle:(float)angle radius:(float)radius center:(CGPoint)center {
    return CGPointMake(center.x + radius * cos(angle), center.y + radius * sin(angle));
}

- (void)didRecognizeGesture:(UIPanGestureRecognizer *)recognizer {
    CGPoint touchLocation = [recognizer locationInView:self];
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat x = touchLocation.x - center.x;
    CGFloat y = touchLocation.y - center.y;
    CGFloat angle = RADIANS_TO_DEGREES(atan2f(y, x));
    while (angle < _startAngle) {
        angle += 360.0f;
    }
    
    CGFloat progress = (angle - _startAngle) / (_endAngle - _startAngle);
    if (progress < 0.0f || progress > 1.0f) {
        return;
    }
    
    CGFloat distance = sqrtf(powf(center.x - touchLocation.x, 2.0f) + powf(center.y - touchLocation.y, 2.0f));
    CGFloat radius = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) / 2.0f;
    CGFloat innerRadius = _innerRadiusMultiplier * radius;
    CGFloat outerRadius = _outerRadiusMultiplier * radius;
    if (distance < innerRadius || distance > outerRadius) {
        return;
    }
    
    UIColor *color = _colorGenerator(progress);
    [self moveColorIndicatorToPoint:touchLocation andChangeColorTo:color];
    [self.delegate colorPickerView:self didPickColor:color];
}

- (void)moveColorIndicatorToPoint:(CGPoint)point andChangeColorTo:(UIColor *)color {
    _indicatorView.backgroundColor = color;
    _indicatorView.center = point;
    [self bringSubviewToFront:_indicatorView];
    _indicatorView.hidden = NO;
}

- (UIColor *)indicatorViewBorderColor {
    return [UIColor colorWithCGColor:_indicatorView.layer.borderColor];
}

- (void)setIndicatorViewBorderColor:(UIColor *)indicatorViewBorderColor {
    _indicatorView.layer.borderColor = indicatorViewBorderColor.CGColor;
}

@end
