//
//  MDSideMenuViewController.h
//  MDSDK
//
//  Created by Mateusz Dzwonek on 31/10/2013.
//  Copyright (c) 2013 Mateusz Dzwonek. All rights reserved.
//

extern const CGFloat MD_SIDE_MENU_VC_DEFAULT_CORNER_RADIUS;

extern const CGFloat MD_SIDE_MENU_VC_DEFAULT_CONTENT_VIEW_SHADOW_RADIUS;
extern const CGFloat MD_SIDE_MENU_VC_DEFAULT_CONTENT_VIEW_SHADOW_OPACITY;

extern const NSTimeInterval MD_SIDE_MENU_VC_DEFAULT_MENU_ANIMATION_TIME;

extern const CGFloat MD_SIDE_MENU_VC_DEFAULT_MIN_TRANSLATION_TO_SHOW_MENU;
extern const CGFloat MD_SIDE_MENU_VC_DEFAULT_MAX_CONTENT_TRANSLATION;
extern const CGFloat MD_SIDE_MENU_VC_DEFAULT_MIN_MENU_SCALE;
extern const CGFloat MD_SIDE_MENU_VC_DEFAULT_MAX_MENU_SCALE;

@interface MDSideMenuViewController : UIViewController

@property (nonatomic, readonly) UIViewController *leftMenuViewController;
@property (nonatomic, readonly) UIViewController *rightMenuViewController;
@property (nonatomic, readonly) UIViewController *contentViewController;

@property (nonatomic, readonly) BOOL leftMenuHidden;
@property (nonatomic, readonly) BOOL rightMenuHidden;

@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat contentViewShadowRadius;
@property (nonatomic, assign) CGFloat contentViewShadowOpacity;
@property (nonatomic, assign) NSTimeInterval menuAnimationTime;
@property (nonatomic, assign) CGFloat minTranslationToShowMenu;
@property (nonatomic, assign) CGFloat maxContentTranslation;
@property (nonatomic, assign) CGFloat minMenuScale;
@property (nonatomic, assign) CGFloat maxMenuScale;


@property (nonatomic, copy) void (^didToggleLeftMenuBlock)(MDSideMenuViewController *sideMenuVC);
@property (nonatomic, copy) void (^didToggleRightMenuBlock)(MDSideMenuViewController *sideMenuVC);
@property (nonatomic, copy) void (^isPanningMenuBlock)(MDSideMenuViewController *sideMenuVC, BOOL leftMenu, float revealedPercentage);

- (id)initWithLeftMenuVC:(UIViewController *)leftMenuVC rightMenuVC:(UIViewController *)rightMenuVC andContentVC:(UIViewController *)contentVC;

- (void)toggleLeftMenu;
- (void)showLeftMenu;
- (void)showLeftMenuWithCompletion:(void (^)(void))completion;
- (void)hideLeftMenu;
- (void)hideLeftMenuWithCompletion:(void (^)(void))completion;

- (void)toggleRightMenu;
- (void)showRightMenu;
- (void)showRightMenuWithCompletion:(void (^)(void))completion;
- (void)hideRightMenu;
- (void)hideRightMenuWithCompletion:(void (^)(void))completion;

@end
