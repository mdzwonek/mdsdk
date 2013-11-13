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

const CGFloat MD_SIDE_MENU_VC_DEFAULT_MIN_TRANSLATION_TO_SHOW_MENU = 100.0f;
const CGFloat MD_SIDE_MENU_VC_DEFAULT_MAX_CONTENT_TRANSLATION = 270.0f;
const CGFloat MD_SIDE_MENU_VC_DEFAULT_MIN_MENU_SCALE = 0.9f;
const CGFloat MD_SIDE_MENU_VC_DEFAULT_MAX_MENU_SCALE = 1.0f;


@interface MDSideMenuViewController ()

@property (nonatomic, weak) IBOutlet UIView *mainView;

@property (nonatomic, weak) IBOutlet UIView *contentView;

@property (nonatomic, strong) IBOutlet UIView *leftMenuView;
@property (nonatomic, strong) IBOutlet UIView *rightMenuView;

@property (nonatomic, weak) IBOutlet UIView *mainViewTapLayerLayer;

- (void)showMenu:(UIView *)menu toOffset:(CGFloat)offset withCompletion:(void (^)(void))completion;
- (void)hideMenu:(UIView *)menu andCompletion:(void (^)(void))completion;

- (void)didPanToShowMenu:(UIPanGestureRecognizer *)recogniser;
- (IBAction)didTapMainViewInvisibleLayer:(id)sender;

@end


@implementation MDSideMenuViewController

- (id)initWithLeftMenuVC:(UIViewController *)leftMenuVC rightMenuVC:(UIViewController *)rightMenuVC andContentVC:(UIViewController *)contentVC {
    self = [super init];
    if (self) {
        _leftMenuViewController = leftMenuVC;
        _rightMenuViewController = rightMenuVC;
        _contentViewController = contentVC;
        self.cornerRadius = MD_SIDE_MENU_VC_DEFAULT_CORNER_RADIUS;
        self.contentViewShadowRadius = MD_SIDE_MENU_VC_DEFAULT_CONTENT_VIEW_SHADOW_RADIUS;
        self.contentViewShadowOpacity = MD_SIDE_MENU_VC_DEFAULT_CONTENT_VIEW_SHADOW_OPACITY;
        self.menuAnimationTime = MD_SIDE_MENU_VC_DEFAULT_MENU_ANIMATION_TIME;
        self.minTranslationToShowMenu = MD_SIDE_MENU_VC_DEFAULT_MIN_TRANSLATION_TO_SHOW_MENU;
        self.maxContentTranslation = MD_SIDE_MENU_VC_DEFAULT_MAX_CONTENT_TRANSLATION;
        self.minMenuScale = MD_SIDE_MENU_VC_DEFAULT_MIN_MENU_SCALE;
        self.maxMenuScale = MD_SIDE_MENU_VC_DEFAULT_MAX_MENU_SCALE;
    }
    return self;
}

- (void)viewDidLoad {
    [self updateCornerRadius];

    [self updateMenusFrames];
    
    [self addChildViewController:self.leftMenuViewController];
    self.leftMenuViewController.view.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.leftMenuView.frame), CGRectGetHeight(self.leftMenuView.frame));
    self.leftMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.leftMenuView addSubview:self.leftMenuViewController.view];
    
    [self addChildViewController:self.rightMenuViewController];
    self.rightMenuViewController.view.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.rightMenuView.frame), CGRectGetHeight(self.rightMenuView.frame));
    self.rightMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.rightMenuView addSubview:self.rightMenuViewController.view];
    
    [self addChildViewController:self.contentViewController];
    self.contentViewController.view.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame));
    self.contentViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:self.contentViewController.view];

    CALayer *mainContentLayer = self.contentView.layer;
    [self updateContentViewShadowRadius];
    [self updateContentViewShadowOpacity];
    mainContentLayer.shadowOffset = CGSizeZero;
    mainContentLayer.shadowColor = [UIColor blackColor].CGColor;
    mainContentLayer.shouldRasterize = YES;
    mainContentLayer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    UIGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanToShowMenu:)];
    [self.mainView addGestureRecognizer:recognizer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.leftMenuView.transform = CGAffineTransformMakeScale(self.minMenuScale, self.minMenuScale);
    self.rightMenuView.transform = CGAffineTransformMakeScale(self.minMenuScale, self.minMenuScale);
    [self.leftMenuView removeFromSuperview];
    [self.rightMenuView removeFromSuperview];
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
    self.leftMenuHidden ? [self hideLeftMenu] : [self showLeftMenu];
    self.rightMenuHidden ? [self hideRightMenu] : [self showRightMenu];
}


#pragma mark - Menus helpers

- (BOOL)leftMenuHidden {
    return self.leftMenuView.superview == nil;
}

- (BOOL)rightMenuHidden {
    return self.rightMenuView.superview == nil;
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
        if (self.leftMenuView) {
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
    [self showMenu:self.leftMenuView toOffset:self.maxContentTranslation withCompletion:^{
        if (self.didToggleLeftMenuBlock) self.didToggleLeftMenuBlock(self);
        if (completion) completion();
    }];
}

- (void)showRightMenu {
    [self showRightMenuWithCompletion:nil];
}

- (void)showRightMenuWithCompletion:(void (^)(void))completion {
    [self showMenu:self.rightMenuView toOffset:-self.maxContentTranslation withCompletion:^{
        if (self.didToggleRightMenuBlock) self.didToggleLeftMenuBlock(self);
        if (completion) completion();
    }];
}

- (void)showMenu:(UIView *)menu toOffset:(CGFloat)offset withCompletion:(void (^)(void))completion {
    [self.view insertSubview:menu atIndex:0];
    [UIView animateWithDuration:self.menuAnimationTime animations:^{
        menu.layer.transform = CATransform3DScale(CATransform3DIdentity, self.maxMenuScale, self.maxMenuScale, 1.0f);
        CGRect frame = self.mainView.frame;
        frame.origin.x = offset;
        self.mainView.frame = frame;
    } completion:^(BOOL finished) {
        self.mainViewTapLayerLayer.hidden = NO;
        if (completion != NULL) completion();
    }];
}


#pragma mark - Hide menus

- (void)hideLeftMenu {
    [self hideLeftMenuWithCompletion:nil];
}

- (void)hideLeftMenuWithCompletion:(void (^)(void))completion {
    [self hideMenu:self.leftMenuView andCompletion:^{
        if (self.didToggleLeftMenuBlock) self.didToggleLeftMenuBlock(self);
        if (completion) completion();
    }];
}

- (void)hideRightMenu {
    [self hideRightMenuWithCompletion:nil];
}

- (void)hideRightMenuWithCompletion:(void (^)(void))completion {
    [self hideMenu:self.rightMenuView andCompletion:^{
        if (self.didToggleLeftMenuBlock) self.didToggleRightMenuBlock(self);
        if (completion) completion();
    }];
}

- (void)hideMenu:(UIView *)menu andCompletion:(void (^)(void))completion {
    [UIView animateWithDuration:self.menuAnimationTime animations:^{
        menu.layer.transform = CATransform3DScale(CATransform3DIdentity, self.minMenuScale, self.minMenuScale, 1.0f);
        CGRect frame = self.mainView.frame;
        frame.origin.x = 0;
        self.mainView.frame = frame;
    } completion:^(BOOL finished) {
        [menu removeFromSuperview];
        self.mainViewTapLayerLayer.hidden = YES;
        if (completion != NULL) completion();
    }];
}


#pragma mark - Menu interactions

- (void)didPanToShowMenu:(UIPanGestureRecognizer *)recognizer {
    static UIView *menu;
    static CGFloat minOffset;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint translation = [recognizer translationInView:recognizer.view];
        if (menu == nil) {
            if (self.leftMenuViewController != nil && (!self.leftMenuHidden || (self.rightMenuHidden && translation.x >= 0))) {
                menu = self.leftMenuView;
                minOffset = 0.0f;
            } else if (self.rightMenuViewController != nil && (!self.rightMenuHidden || (self.leftMenuHidden && translation.x < 0))) {
                menu = self.rightMenuView;
                minOffset = -self.maxContentTranslation;
            }
            [self.view insertSubview:menu atIndex:0];
        }
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:recognizer.view];
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
        CGFloat percentageOfAnimation = fabsf(CGRectGetMinX(self.mainView.frame) / self.maxContentTranslation);
        CGFloat menuScale = (self.maxMenuScale - self.minMenuScale) * percentageOfAnimation + self.minMenuScale;
        menu.transform = CGAffineTransformMakeScale(menuScale, menuScale);
        CGFloat maxOffset = minOffset + self.maxContentTranslation;
        CGRect frame = self.mainView.frame;
        frame.origin.x = MAX(minOffset, MIN(maxOffset, frame.origin.x + translation.x));
        self.mainView.frame = frame;
        if (self.isPanningMenuBlock) self.isPanningMenuBlock(self, menu == self.leftMenuView, percentageOfAnimation);
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        CGFloat velocity = [recognizer velocityInView:recognizer.view].x;
        CGFloat offset = self.mainView.frame.origin.x;
        if (menu == self.leftMenuView) {
            if (velocity > 0.0f || (velocity == 0.0f && offset >= self.minTranslationToShowMenu)) {
                [self showLeftMenu];
            } else {
                [self hideLeftMenu];
            }
        } else {// if (menu == self.rightMenuView)
            if (velocity < 0.0f || (velocity == 0.0f && offset <= -self.minTranslationToShowMenu)) {
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


@end
