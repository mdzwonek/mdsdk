//
//  MDPopupButtonsController.m
//  MDSDK
//
//  Created by Mateusz Dzwonek on 02/12/2013.
//  Copyright (c) 2013 Mateusz Dzwonek. All rights reserved.
//

#import "MDPopupButtonsController.h"
#import "UIImage+Tint.h"
#import <QuartzCore/QuartzCore.h>


static const CGFloat MDPopupButtonSize = 70.0f;
static const CGFloat MDPopupButtonBorderWidth = 1.0f;
static const CGFloat MDPopupButtonBackgroundAlpha = 0.25f;
static const CGFloat MDPopupButtonImageSize = 50.0f;
static const CGFloat MDPopupButtonImageMinAlpha = 0.6f;
static const CGFloat MDPopupButtonImageMaxAlpha = 1.0f;
static const CGFloat MDPopupButtonImageMinScale = 1.0f;
static const CGFloat MDPopupButtonImageMaxScale = 1.40f;
static const CGFloat MDPopupButtonImageFadeOutScale = 1.6f;
static const CGFloat MDPopupButtonLabelHeight = 25.0f;
static const CGFloat MDPopupButtonLabelFontSize = 16.0f;

static const CGFloat MDTouchIndicatorSize = 50.0f;
static const CGFloat MDTouchIndicatorBorderWidth = 1.0f;
static const CGFloat MDTouchIndicatorBackgroundAlpha = 0.1f;
static const CGFloat MDTouchIndicatorMinAlpha = 0.5f;
static const CGFloat MDTouchIndicatorMaxAlpha = 1.0f;
static const CGFloat MDTouchIndicatorMinScale = 1.0f;
static const CGFloat MDTouchIndicatorMaxScale = 1.15f;


@interface PopupButtonView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;

- (instancetype)initWithImage:(UIImage *)image text:(NSString *)text andColor:(UIColor *)color;

@end


@implementation PopupButtonView

- (instancetype)initWithImage:(UIImage *)image text:(NSString *)text andColor:(UIColor *)color {
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, MDPopupButtonSize, MDPopupButtonSize)];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithImage:[image imageTintedWithColor:color]];
        CGFloat sizeDifference = MDPopupButtonSize - MDPopupButtonImageSize;
        self.imageView.frame = CGRectMake(sizeDifference / 2.0f, sizeDifference, MDPopupButtonImageSize, MDPopupButtonImageSize);
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.layer.borderWidth = MDPopupButtonBorderWidth;
        self.imageView.layer.borderColor = color.CGColor;
        self.imageView.layer.cornerRadius = MDPopupButtonImageSize / 2.0f;
        [self addSubview:self.imageView];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, -MDPopupButtonLabelHeight, MDPopupButtonSize, MDPopupButtonLabelHeight)];
        self.label.font = [UIFont systemFontOfSize:MDPopupButtonLabelFontSize];
        self.label.text = text;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.textColor = color;
        self.label.layer.borderWidth = MDPopupButtonBorderWidth;
        self.label.layer.borderColor = color.CGColor;
        self.label.layer.cornerRadius = MDPopupButtonLabelHeight / 2.0f;
        self.label.backgroundColor = [color colorWithAlphaComponent:0.3];
        
        [self.label sizeToFit];
        CGRect frame = self.label.frame;
        frame.size.width += MDPopupButtonLabelHeight;
        frame.size.height = MDPopupButtonLabelHeight;
        frame.origin.x = (MDPopupButtonSize - CGRectGetWidth(frame)) / 2.0f;
        self.label.frame = frame;
        
        [self addSubview:self.label];
    }
    return self;
}

@end


@interface MDPopupButtonsController ()

- (void)initializeValues;

@end


@implementation MDPopupButtonsController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializeValues];
    }
    return self;
}

- (instancetype)initWithButtons:(NSArray *)buttons {
    self = [super initWithButtons:buttons];
    if (self) {
        [self initializeValues];
    }
    return self;
}

- (void)initializeValues {
    self.touchIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, MDTouchIndicatorSize, MDTouchIndicatorSize)];
    self.touchIndicatorView.layer.borderWidth = MDTouchIndicatorBorderWidth;
    self.touchIndicatorView.layer.cornerRadius = MDTouchIndicatorSize / 2.0f;
    
    self.tintColor = [UIColor whiteColor];
    
    __weak MDPopupButtonsController *weakSelf = self;
    
    self.popupButtonHighlightedStateChangeAnimations = ^(UIView *popupButton, BOOL highlighted) {
        if ([popupButton isKindOfClass:[PopupButtonView class]]) {
            PopupButtonView *popupButtonView = (PopupButtonView *)popupButton;
            popupButtonView.imageView.alpha = highlighted ? MDPopupButtonImageMaxAlpha : MDPopupButtonImageMinAlpha;
            CGFloat scale = highlighted ? MDPopupButtonImageMaxScale : MDPopupButtonImageMinScale;
            popupButtonView.imageView.transform = CGAffineTransformMakeScale(scale, scale);
            UIColor *desaturatedTintColor = [weakSelf.tintColor colorWithAlphaComponent:MDPopupButtonBackgroundAlpha];
            popupButtonView.imageView.backgroundColor = highlighted ? desaturatedTintColor : [UIColor clearColor];
            popupButtonView.label.alpha = highlighted ? 1.0f : 0.0f;
        }
    };
    self.touchIndicatorHighlightedStateChangeAnimations = ^(UIView *touchIndicatorView, BOOL highlighted) {
        touchIndicatorView.alpha = highlighted ? MDTouchIndicatorMaxAlpha : MDTouchIndicatorMinAlpha;
        CGFloat scale = highlighted ? MDTouchIndicatorMaxScale : MDTouchIndicatorMinScale;
        touchIndicatorView.transform = CGAffineTransformMakeScale(scale, scale);
    };
    self.didFinishWithButton = ^(UIView *view) {
        PopupButtonView *popupButton = (PopupButtonView *) view;
        if (weakSelf.didFinishWithPopupButtonWithText) weakSelf.didFinishWithPopupButtonWithText(popupButton.label.text);
        [UIView animateWithDuration:weakSelf.animationsDuration animations:^{
            view.transform = CGAffineTransformMakeScale(MDPopupButtonImageFadeOutScale, MDPopupButtonImageFadeOutScale);
        } completion:^(BOOL finished) {
            view.transform = CGAffineTransformIdentity;
        }];
    };
}

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    self.touchIndicatorView.layer.borderColor = self.tintColor.CGColor;
    self.touchIndicatorView.backgroundColor = [self.tintColor colorWithAlphaComponent:MDTouchIndicatorBackgroundAlpha];
    for (UIView *popupButton in self.popupButtons) {
        if ([popupButton isKindOfClass:[PopupButtonView class]]) {
            PopupButtonView *popupButtonView = (PopupButtonView *)popupButton;
            popupButtonView.imageView.layer.borderColor = self.tintColor.CGColor;
            popupButtonView.label.textColor = self.tintColor;
            popupButtonView.label.layer.borderColor = self.tintColor.CGColor;
        }
    }
}

- (UIView *)addPopupButtonWithImage:(UIImage *)image andText:(NSString *)text {
    PopupButtonView *popupButtonView = [[PopupButtonView alloc] initWithImage:image text:text andColor:self.tintColor];
    [super addPopupButton:popupButtonView];
    return popupButtonView;
}

- (UIView *)insertPopupButtonWithImage:(UIImage *)image andText:(NSString *)text atIndex:(NSInteger)index {
    PopupButtonView *popupButtonView = [[PopupButtonView alloc] initWithImage:image text:text andColor:self.tintColor];
    [super insertPopupButton:popupButtonView atIndex:index];
    return popupButtonView;
}

@end
