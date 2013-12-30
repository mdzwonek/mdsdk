//
//  MDLongPressPopupButtonsController.h
//  MDSDK
//
//  Created by Mateusz Dzwonek on 21/11/2013.
//  Copyright (c) 2013 Mateusz Dzwonek. All rights reserved.
//

typedef void (^MDEmptyBlock)();
typedef void (^MDPopupButtonBlock)(UIView *view);
typedef void (^MDPopupButtonHighlighedBlock)(UIView *view, BOOL highlighted);

@interface MDLongPressPopupButtonsController : NSObject

@property (nonatomic) NSTimeInterval minimumPressDuration;
@property (nonatomic) NSTimeInterval animationsDuration;

@property (nonatomic, readonly) UIView *superview;

@property (nonatomic) UIView *touchIndicatorView;

@property (nonatomic, readonly) NSArray *popupButtons;
@property (nonatomic) CGFloat distanceBetweenPopupButtonAndIndicator;
@property (nonatomic) CGFloat angleBetweenPopupButtons;
@property (nonatomic) CGFloat angleBetweenIndicatorAndCenterOfPopupButtons;

@property (nonatomic, readonly, getter = isVisible) BOOL visible;

@property (nonatomic, copy) MDPopupButtonHighlighedBlock touchIndicatorWillChangeHighlightedState;
@property (nonatomic, copy) MDPopupButtonHighlighedBlock touchIndicatorHighlightedStateChangeAnimations;
@property (nonatomic, copy) MDPopupButtonHighlighedBlock touchIndicatorDidChangeHighlightedState;

@property (nonatomic, copy) MDPopupButtonHighlighedBlock popupButtonWillChangeHighlightedState;
@property (nonatomic, copy) MDPopupButtonHighlighedBlock popupButtonHighlightedStateChangeAnimations;
@property (nonatomic, copy) MDPopupButtonHighlighedBlock popupButtonDidChangeHighlightedState;

@property (nonatomic, copy) MDEmptyBlock willBeVisible;
@property (nonatomic, copy) MDPopupButtonBlock didFinishWithButton;

- (instancetype)initWithButtons:(NSArray *)buttons;

- (void)addPopupButton:(UIView *)popupButton;
- (void)insertPopupButton:(UIView *)popupButton atIndex:(NSInteger)index;
- (void)removePopupButton:(UIView *)popupButton;
- (void)removePopupButtonAtIndex:(NSInteger)index;

- (void)addToView:(UIView *)view;

@end
