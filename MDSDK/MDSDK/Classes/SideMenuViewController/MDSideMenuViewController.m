//
//  MDSideMenuViewController.m
//  MDSDK
//
//  Created by Mateusz Dzwonek on 31/10/2013.
//  Copyright (c) 2013 Mateusz Dzwonek. All rights reserved.
//

#import "MDSideMenuViewController.h"
#import <QuartzCore/QuartzCore.h>

#define SCALE_TO_SHADOW_SCALE(scale) (1.0f + 10.0f * (1.0f - scale))


const CGFloat MD_SIDE_MENU_VC_DEFAULT_CORNER_RADIUS = 3.0f;

const CGFloat MD_SIDE_MENU_VC_DEFAULT_CONTENT_VIEW_SHADOW_RADIUS = 20.0f;
const CGFloat MD_SIDE_MENU_VC_DEFAULT_CONTENT_VIEW_SHADOW_OPACITY = 0.6f;

const NSTimeInterval MD_SIDE_MENU_VC_DEFAULT_MENU_ANIMATION_TIME = 0.3;

const CGFloat MD_SIDE_MENU_VC_DEFAULT_MAX_CONTENT_TRANSLATION = 270.0f;
const CGFloat MD_SIDE_MENU_VC_DEFAULT_MIN_MENU_SCALE = 0.9f;
const CGFloat MD_SIDE_MENU_VC_DEFAULT_MAX_MENU_SCALE = 1.0f;


@interface MDSideMenuViewController ()

@property (nonatomic) IBOutlet UIView *contentView;
@property (nonatomic) IBOutlet UIView *leftMenuView;
@property (nonatomic) IBOutlet UIView *rightMenuView;

@property (nonatomic) IBOutlet UIView *mainViewTapLayer;

- (BOOL)menuHidden:(UIView *)menu;

- (void)showMenu:(UIView *)menu animated:(BOOL)animated withCompletion:(void (^)(void))completion;
- (void)hideMenu:(UIView *)menu animated:(BOOL)animated withCompletion:(void (^)(void))completion;

- (void)didPanToShowMenu:(UIPanGestureRecognizer *)recogniser;
- (IBAction)didTapMainViewInvisibleLayer:(id)sender;

- (void)updateMenu:(UIView *)menu withRevealPercentage:(CGFloat)percentage andWillBeVisibleFlag:(BOOL)isShowing;
- (void)defaultMenuTransformations:(UIView *)menu withRevealPercentage:(CGFloat)percentage andWillBeVisibleFlag:(BOOL)isShowing;

@end


@implementation MDSideMenuViewController

- (id)initWithLeftMenuVC:(UIViewController *)leftMenuVC rightMenuVC:(UIViewController *)rightMenuVC andContentVC:(UIViewController *)contentVC {
    self = [super init];
    if (self) {
        NSAssert(leftMenuVC != nil || rightMenuVC != nil, @"At least one of the menu view controllers has to be non-nil");
        NSAssert(contentVC != nil, @"Content view controller can't be nil");
        _leftMenuViewController = leftMenuVC;
        _rightMenuViewController = rightMenuVC;
        _contentViewController = contentVC;
        self.cornerRadius = MD_SIDE_MENU_VC_DEFAULT_CORNER_RADIUS;
        self.contentViewShadowRadius = MD_SIDE_MENU_VC_DEFAULT_CONTENT_VIEW_SHADOW_RADIUS;
        self.contentViewShadowOpacity = MD_SIDE_MENU_VC_DEFAULT_CONTENT_VIEW_SHADOW_OPACITY;
        self.menuAnimationTime = MD_SIDE_MENU_VC_DEFAULT_MENU_ANIMATION_TIME;
        self.maxContentTranslation = MD_SIDE_MENU_VC_DEFAULT_MAX_CONTENT_TRANSLATION;
        self.minMenuScale = MD_SIDE_MENU_VC_DEFAULT_MIN_MENU_SCALE;
        self.maxMenuScale = MD_SIDE_MENU_VC_DEFAULT_MAX_MENU_SCALE;
        __weak MDSideMenuViewController *weakSelf = self;
        self.applyMenuTransformations = ^(MDSideMenuViewController *sideMenuVC, UIView *menu, CGFloat percentage, BOOL willBeVisible) {
            [weakSelf defaultMenuTransformations:menu withRevealPercentage:percentage andWillBeVisibleFlag:willBeVisible];
        };
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateCornerRadius];
    
    [self updateMenusFrames];
    
    if (self.leftMenuViewController != nil) {
        [self addChildViewController:self.leftMenuViewController];
        self.leftMenuViewController.view.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.leftMenuView.frame), CGRectGetHeight(self.leftMenuView.frame));
        self.leftMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.leftMenuView addSubview:self.leftMenuViewController.view];
        [self.leftMenuView removeFromSuperview];
    }
    
    if (self.rightMenuViewController != nil) {
        [self addChildViewController:self.rightMenuViewController];
        self.rightMenuViewController.view.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.rightMenuView.frame), CGRectGetHeight(self.rightMenuView.frame));
        self.rightMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.rightMenuView addSubview:self.rightMenuViewController.view];
        [self.rightMenuView removeFromSuperview];
    }
    
    
    [self addChildViewController:self.contentViewController];
    self.contentViewController.view.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame));
    self.contentViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView insertSubview:self.contentViewController.view belowSubview:self.mainViewTapLayer];
    
    CALayer *mainContentLayer = self.contentView.layer;
    [self updateContentViewShadowRadius];
    [self updateContentViewShadowOpacity];
    mainContentLayer.shadowOffset = CGSizeZero;
    mainContentLayer.shadowColor = [UIColor blackColor].CGColor;
    mainContentLayer.shouldRasterize = YES;
    mainContentLayer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    UIGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanToShowMenu:)];
    [self.view addGestureRecognizer:recognizer];
}


#pragma mark - Setters

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self updateCornerRadius];
}

- (void)setContentViewShadowRadius:(CGFloat)contentViewShadowRadius {
    _contentViewShadowRadius = contentViewShadowRadius;
    [self updateContentViewShadowRadius];
}

- (void)setContentViewShadowOpacity:(CGFloat)contentViewShadowOpacity {
    _contentViewShadowOpacity = contentViewShadowOpacity;
    [self updateContentViewShadowOpacity];
}

- (void)setMaxContentTranslation:(CGFloat)maxContentTranslation {
    _maxContentTranslation = maxContentTranslation;
    [self updateMenusFrames];
    if (!self.leftMenuHidden) {
        [self showLeftMenu];
    } else if (!self.rightMenuHidden) {
        [self showRightMenu];
    }
}

- (void)setMinMenuScale:(CGFloat)minMenuScale {
    _minMenuScale = minMenuScale;
    [self updateMenusScale];
}

- (void)setMaxMenuScale:(CGFloat)maxMenuScale {
    _maxMenuScale = maxMenuScale;
    [self updateMenusScale];
}


#pragma mark - Helper methods

- (void)updateCornerRadius {
    if (self.leftMenuView == nil || self.rightMenuView) {
        return;// views not initiated - do nothing
    }
    for (UIView *view in @[self.leftMenuView, self.rightMenuView]) {
        view.layer.cornerRadius = self.cornerRadius;
    }
}

- (void)updateContentViewShadowRadius {
    self.contentView.layer.shadowRadius = self.contentViewShadowRadius;
}

- (void)updateContentViewShadowOpacity {
    self.contentView.layer.shadowOpacity = self.contentViewShadowOpacity;
}

- (void)updateMenusFrames {
    CGAffineTransform leftMenuTransform = self.leftMenuView.transform;
    self.leftMenuView.transform = CGAffineTransformIdentity;
    CGRect frame = self.leftMenuView.frame;
    frame.size.width = self.maxContentTranslation;
    self.leftMenuView.frame = frame;
    self.leftMenuView.transform = leftMenuTransform;
    
    CGAffineTransform rightMenuTransform = self.rightMenuView.transform;
    self.rightMenuView.transform = CGAffineTransformIdentity;
    frame = self.rightMenuView.frame;
    frame.origin.x = CGRectGetWidth(self.contentView.frame) - self.maxContentTranslation;
    frame.size.width = self.maxContentTranslation;
    self.rightMenuView.frame = frame;
    self.rightMenuView.transform = rightMenuTransform;
}

- (void)updateMenusScale {
    UIView *leftMenu = self.leftMenuView;
    self.leftMenuHidden ? [self hideMenu:leftMenu animated:NO withCompletion:NULL] : [self showMenu:leftMenu animated:NO withCompletion:NULL];
    
    UIView *rightMenu = self.rightMenuView;
    self.rightMenuHidden ? [self hideMenu:rightMenu animated:NO withCompletion:NULL] : [self showMenu:rightMenu animated:NO withCompletion:NULL];
}


#pragma mark - Menus helpers

- (BOOL)leftMenuHidden {
    return [self menuHidden:self.leftMenuView];
}

- (BOOL)rightMenuHidden {
    return [self menuHidden:self.rightMenuView];
}

- (BOOL)menuHidden:(UIView *)menu {
    return menu.superview == nil;
}

- (void)toggleLeftMenu {
    if (self.leftMenuHidden) {
        if (self.rightMenuHidden) {
            [self showLeftMenu];
        } else {
            [self hideRightMenuWithCompletion:^{
                [self showLeftMenu];
            }];
        }
    } else {
        [self hideLeftMenu];
    }
}

- (void)toggleRightMenu {
    if (self.rightMenuHidden) {
        if (self.leftMenuHidden) {
            [self showRightMenu];
        } else {
            [self hideLeftMenuWithCompletion:^{
                [self showRightMenu];
            }];
        }
    } else {
        [self hideRightMenu];
    }
}


#pragma mark - Show menus

- (void)showLeftMenu {
    [self showLeftMenuWithCompletion:nil];
}

- (void)showLeftMenuWithCompletion:(void (^)(void))completion {
    [self showMenu:self.leftMenuView animated:YES withCompletion:^{
        if (self.didToggleLeftMenuBlock) self.didToggleLeftMenuBlock(self);
        if (completion) completion();
    }];
}

- (void)showRightMenu {
    [self showRightMenuWithCompletion:nil];
}

- (void)showRightMenuWithCompletion:(void (^)(void))completion {
    [self showMenu:self.rightMenuView animated:YES withCompletion:^{
        if (self.didToggleRightMenuBlock) self.didToggleRightMenuBlock(self);
        if (completion) completion();
    }];
}

- (void)showMenu:(UIView *)menu animated:(BOOL)animated withCompletion:(void (^)(void))completion {
    void (^animations)() = ^{
        [self updateMenu:menu withRevealPercentage:1.0f andWillBeVisibleFlag:YES];
    };
    void (^animationCompletion)(BOOL finished) = ^(BOOL finished) {
        self.mainViewTapLayer.hidden = NO;
        if (completion != NULL) completion();
    };
    
    if (animated) {
        [UIView animateWithDuration:self.menuAnimationTime animations:animations completion:animationCompletion];
    } else {
        animations();
        animationCompletion(YES);
    }
}


#pragma mark - Hide menus

- (void)hideLeftMenu {
    [self hideLeftMenuWithCompletion:nil];
}

- (void)hideLeftMenuWithCompletion:(void (^)(void))completion {
    [self hideMenu:self.leftMenuView animated:YES withCompletion:^{
        if (self.didToggleLeftMenuBlock) self.didToggleLeftMenuBlock(self);
        if (completion) completion();
    }];
}

- (void)hideRightMenu {
    [self hideRightMenuWithCompletion:nil];
}

- (void)hideRightMenuWithCompletion:(void (^)(void))completion {
    [self hideMenu:self.rightMenuView animated:YES withCompletion:^{
        if (self.didToggleRightMenuBlock) self.didToggleRightMenuBlock(self);
        if (completion) completion();
    }];
}

- (void)hideMenu:(UIView *)menu animated:(BOOL)animated withCompletion:(void (^)(void))completion {
    void (^animations)() = ^{
        [self updateMenu:menu withRevealPercentage:0.0f andWillBeVisibleFlag:NO];
    };
    void (^animationCompletion)(BOOL finished) = ^(BOOL finished) {
        [menu removeFromSuperview];
        self.mainViewTapLayer.hidden = YES;
        if (completion != NULL) completion();
    };
    
    if (animated) {
        [UIView animateWithDuration:self.menuAnimationTime animations:animations completion:animationCompletion];
    } else {
        animations();
        animationCompletion(YES);
    }
}


#pragma mark - Menu interactions

- (void)didPanToShowMenu:(UIPanGestureRecognizer *)recognizer {
    static UIView *menu;
    static BOOL menuWillBeVisible;
    CGPoint translation = [recognizer translationInView:recognizer.view];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (menu == nil) {
            if (self.leftMenuViewController != nil && (!self.leftMenuHidden || (self.rightMenuHidden && translation.x >= 0))) {
                menu = self.leftMenuView;
            } else if (self.rightMenuViewController != nil && (!self.rightMenuHidden || (self.leftMenuHidden && translation.x < 0))) {
                menu = self.rightMenuView;
            }
            menuWillBeVisible = [self menuHidden:menu];
            [self.view insertSubview:menu atIndex:0];
        }
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        if (menu != nil) {
            CGFloat translationRatio = (menu == self.leftMenuView ? 1.0f : -1.0f) * translation.x / self.maxContentTranslation;
            translationRatio = menuWillBeVisible ? translationRatio : translationRatio + 1.0f;
            CGFloat animationPercentage = fabs(MIN(MAX(translationRatio, 0.0f), 1.0f));
            [self updateMenu:menu withRevealPercentage:animationPercentage andWillBeVisibleFlag:menuWillBeVisible];
        }
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        CGFloat velocity = [recognizer velocityInView:recognizer.view].x;
        if (menu == self.leftMenuView) {
            if (velocity > 0.0f) {
                [self showLeftMenu];
            } else {
                [self hideLeftMenu];
            }
        } else if (menu == self.rightMenuView) {
            if (velocity < 0.0f) {
                [self showRightMenu];
            } else {
                [self hideRightMenu];
            }
        }
        menu = nil;
    }
}

- (IBAction)didTapMainViewInvisibleLayer:(id)sender {
    if (!self.leftMenuHidden) {
        [self hideLeftMenu];
    } else if (!self.rightMenuHidden) {
        [self hideRightMenu];
    }
}


#pragma mark - Menu animations

- (void)updateMenu:(UIView *)menu withRevealPercentage:(CGFloat)percentage andWillBeVisibleFlag:(BOOL)willBeVisible {
    if (self.applyMenuTransformations != NULL) {
        self.applyMenuTransformations(self, menu, percentage, willBeVisible);
    }
}

- (void)defaultMenuTransformations:(UIView *)menu withRevealPercentage:(CGFloat)percentage andWillBeVisibleFlag:(BOOL)willBeVisible {
    CGFloat menuScale = (self.maxMenuScale - self.minMenuScale) * percentage + self.minMenuScale;
    menu.transform = CGAffineTransformMakeScale(menuScale, menuScale);
    CGFloat revealedX = menu == self.leftMenuView ? self.maxContentTranslation : - self.maxContentTranslation;
    CGRect frame = self.contentView.frame;
    frame.origin.x = revealedX * percentage;
    self.contentView.frame = frame;
}

@end
