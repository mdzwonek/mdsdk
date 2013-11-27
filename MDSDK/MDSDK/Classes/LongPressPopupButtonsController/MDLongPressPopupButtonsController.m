//
//  MDLongPressPopupButtonsController.m
//  MDSDK
//
//  Created by Mateusz Dzwonek on 21/11/2013.
//  Copyright (c) 2013 Reason. All rights reserved.
//

#import "MDLongPressPopupButtonsController.h"

static const NSTimeInterval MDDefaultMinimumPressDuration = 0.3;

static const CGFloat MDDefaultDistanceBetweenPopupButtonAndIndicator = 100.0f;
static const CGFloat MDDefaultAngleBetweenPopupButton = 45.0f;
static const CGFloat MDDefaultAngleBetweenIndicatorAndCenterOfPopupButtons = -45.0f;

static const NSTimeInterval MDAnimationDuration = 0.3;


@interface MDLongPressPopupButtonsController ()

@property (nonatomic, readwrite) UIView *superview;

@property (nonatomic) UILongPressGestureRecognizer *gestureRecognizer;
@property (nonatomic, readwrite) CGPoint centralPoint;

@property (nonatomic, readwrite) NSMutableArray *mutablePopupButtons;
@property (nonatomic) NSMutableDictionary *popupButtonHighlightedFlags;

@property (nonatomic, getter = isTouchIndicatorHighlighted) BOOL touchIndicatorHighlighted;

@property (nonatomic, readwrite, getter = isVisible) BOOL visible;

- (instancetype)initWithButtons:(NSArray *)buttons;

- (void)initializeDefaultValues;

- (void)longPressGestureRecognized:(UILongPressGestureRecognizer *)recognizer;
- (BOOL)locationOfRecognizer:(UIGestureRecognizer *)recognizer isInView:(UIView *)view;

- (void)showButtons;
- (CGFloat)calculateAngleForFirstPopupButton;
- (CGRect)rectForPopupButton:(UIView *)popupButton atAngleFromCenter:(CGFloat)angle;
- (void)hideButtons;

- (void)setTouchIndicatorHighlighted:(BOOL)highlighted;
- (void)popupButton:(UIView *)popupButton setHighlighted:(BOOL)highlighted;

@end


@implementation MDLongPressPopupButtonsController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializeDefaultValues];
    }
    return self;
}

- (instancetype)initWithButtons:(NSArray *)buttons {
    self = [super init];
    if (self) {
        [self initializeDefaultValues];
        for (UIView *popupButton in buttons) {
            [self addPopupButton:popupButton];
        }
    }
    return self;
}

- (void)initializeDefaultValues {
    self.mutablePopupButtons = [[NSMutableArray alloc] init];
    self.popupButtonHighlightedFlags = [[NSMutableDictionary alloc] init];
    self.minimumPressDuration = MDDefaultMinimumPressDuration;
    self.distanceBetweenPopupButtonAndIndicator = MDDefaultDistanceBetweenPopupButtonAndIndicator;
    self.angleBetweenPopupButtons = MDDefaultAngleBetweenPopupButton;
    self.angleBetweenIndicatorAndCenterOfPopupButtons = MDDefaultAngleBetweenIndicatorAndCenterOfPopupButtons;
}

- (NSArray *)popupButtons {
    return self.mutablePopupButtons;
}

- (void)setTouchIndicatorView:(UIView *)touchIndicatorView {
    NSAssert(!self.isVisible, @"Method 'setTouchIndicatorView:' can be called only when constroller is not diplaying buttons");
    _touchIndicatorView = touchIndicatorView;
}

- (void)addPopupButton:(UIView *)popupButton {
    NSAssert(!self.isVisible, @"Method 'addPopupButton:' can be called only when constroller is not diplaying buttons");
    [self.mutablePopupButtons addObject:popupButton];
}

- (void)removePopupButton:(UIView *)popupButton {
    NSAssert(!self.isVisible, @"Method 'removePopupButton:' can be called only when constroller is not diplaying buttons");
    [self.mutablePopupButtons removeObject:popupButton];
}

- (void)addToView:(UIView *)view {
    [self.superview removeGestureRecognizer:self.gestureRecognizer];
    
    self.superview = view;
    
    self.gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    self.gestureRecognizer.minimumPressDuration = self.minimumPressDuration;
    [self.superview addGestureRecognizer:self.gestureRecognizer];
}

- (void)longPressGestureRecognized:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.visible = YES;
        self.centralPoint = [recognizer locationInView:recognizer.view];
        [self showButtons];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        for (UIView *popupButton in self.popupButtons) {
            BOOL popupButtonShouldBeHighlighted = [self locationOfRecognizer:recognizer isInView:popupButton];
            [self popupButton:popupButton setHighlighted:popupButtonShouldBeHighlighted];
            if (popupButtonShouldBeHighlighted) {
                break;
            }
        }
        BOOL touchIndicatorShouldBeHighlighted = [self locationOfRecognizer:recognizer isInView:self.touchIndicatorView];
        [self setTouchIndicatorHighlighted:touchIndicatorShouldBeHighlighted];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        UIView *selectedPopupButton = nil;
        for (UIView *popupButton in self.popupButtons) {
            if ([self locationOfRecognizer:recognizer isInView:popupButton]) {
                selectedPopupButton = popupButton;
                break;
            }
        }
        if (self.didFinishWithButton) self.didFinishWithButton(selectedPopupButton);
        self.visible = NO;
        [self hideButtons];
    }
}

- (BOOL)locationOfRecognizer:(UIGestureRecognizer *)recognizer isInView:(UIView *)view {
    CGPoint locationInSuperview = [recognizer locationInView:view.superview];
    return CGRectContainsPoint(view.frame, locationInSuperview);
}

- (void)showButtons {
    NSMutableArray *allViewsToShow = [[NSMutableArray alloc] initWithArray:self.popupButtons];
    [allViewsToShow addObject:self.touchIndicatorView];
    for (UIView *viewToShow in allViewsToShow) {
        viewToShow.alpha = 0.0f;
        [self.superview addSubview:viewToShow];
    }
    
    CGFloat angleOfFirstPopupButton = [self calculateAngleForFirstPopupButton];
    for (NSInteger i = 0; i < self.popupButtons.count; i++) {
        UIView *popupButton = [self.popupButtons objectAtIndex:i];
        CGFloat angle = angleOfFirstPopupButton + i * self.angleBetweenPopupButtons;
        popupButton.frame = [self rectForPopupButton:popupButton atAngleFromCenter:angle];
        [self popupButton:popupButton setHighlighted:NO];
    }
    self.touchIndicatorView.center = self.centralPoint;
    [self setTouchIndicatorHighlighted:YES];

    [UIView animateWithDuration:MDAnimationDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        for (UIView *viewToShow in allViewsToShow) {
            viewToShow.alpha = 1.0f;
        }
    } completion:nil];
}

- (CGFloat)calculateAngleForFirstPopupButton {
    CGFloat angle = self.angleBetweenIndicatorAndCenterOfPopupButtons;
    angle -= ((self.popupButtons.count - 1) * self.angleBetweenPopupButtons) / 2.0f;
    CGFloat potentialAngle = angle;
    do {
        BOOL allButtonsAreInsideSuperView = YES;
        for (NSInteger i = 0; i < self.popupButtons.count; i++) {
            CGFloat angle = potentialAngle + i * self.angleBetweenPopupButtons;
            CGRect frame = [self rectForPopupButton:[self.popupButtons objectAtIndex:i] atAngleFromCenter:angle];
            if (!CGRectContainsRect(self.superview.bounds, frame)) {
                allButtonsAreInsideSuperView = NO;
                break;
            }
        }
        if (allButtonsAreInsideSuperView) {
            return potentialAngle;
        }
        potentialAngle += 10.0f;
    } while (potentialAngle != angle);
    return angle;
}

- (CGRect)rectForPopupButton:(UIView *)popupButton atAngleFromCenter:(CGFloat)angle {
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0f, -self.distanceBetweenPopupButtonAndIndicator);
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(angle)));
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(self.centralPoint.x, self.centralPoint.y));
    CGPoint popupCetralPoint = CGPointApplyAffineTransform(CGPointZero, transform);
    CGFloat width = CGRectGetWidth(popupButton.frame);
    CGFloat height = CGRectGetHeight(popupButton.frame);
    return CGRectMake(popupCetralPoint.x - width / 2.0f, popupCetralPoint.y - height / 2.0f, width, height);
}

- (void)hideButtons {
    NSMutableArray *allViewsToShow = [[NSMutableArray alloc] initWithArray:self.popupButtons];
    [allViewsToShow addObject:self.touchIndicatorView];
    
    for (UIView *popupButton in self.popupButtons) {
        [self popupButton:popupButton setHighlighted:NO];
    }
    [self setTouchIndicatorHighlighted:NO];
    
    [UIView animateWithDuration:MDAnimationDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        for (UIView *viewToShow in allViewsToShow) {
            viewToShow.alpha = 0.0f;
        }
    } completion:^(BOOL finished) {
        for (UIView *viewToShow in allViewsToShow) {
            [viewToShow removeFromSuperview];
        }
    }];
}

- (void)setTouchIndicatorHighlighted:(BOOL)highlighted {
    if (self.isTouchIndicatorHighlighted == highlighted) {
        return;
    }
    
    if (self.touchIndicatorWillChangeHighlightedState) self.touchIndicatorWillChangeHighlightedState(self.touchIndicatorView, highlighted);
 
    _touchIndicatorHighlighted = highlighted;
    
    [UIView animateWithDuration:MDAnimationDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        if (self.touchIndicatorHighlightedStateChangeAnimations) self.touchIndicatorHighlightedStateChangeAnimations(self.touchIndicatorView, highlighted);
    } completion:^(BOOL finished) {
        if (self.touchIndicatorDidChangeHighlightedState) self.touchIndicatorDidChangeHighlightedState(self.touchIndicatorView, highlighted);
    }];
}

- (void)popupButton:(UIView *)popupButton setHighlighted:(BOOL)highlighted {
    BOOL wasDisplayedBefore = [self.popupButtonHighlightedFlags.allKeys containsObject:@(popupButton.hash)];
    BOOL isPopupButtonHighlighted = [[self.popupButtonHighlightedFlags objectForKey:@(popupButton.hash)] boolValue];
    if (wasDisplayedBefore && isPopupButtonHighlighted == highlighted) {
        return;
    }
    
    if (self.popupButtonWillChangeHighlightedState) self.popupButtonWillChangeHighlightedState(popupButton, highlighted);
    
    [self.popupButtonHighlightedFlags setObject:@(highlighted) forKey:@(popupButton.hash)];
    
    [UIView animateWithDuration:MDAnimationDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        if (self.popupButtonHighlightedStateChangeAnimations) self.popupButtonHighlightedStateChangeAnimations(popupButton, highlighted);
    } completion:^(BOOL finished) {
        if (self.popupButtonDidChangeHighlightedState) self.popupButtonDidChangeHighlightedState(popupButton, highlighted);
    }];
}

@end
