//
//  MDPopupButtonsController.h
//  MDSDK
//
//  Created by Mateusz Dzwonek on 02/12/2013.
//  Copyright (c) 2013 Mateusz Dzwonek. All rights reserved.
//

#import "MDLongPressPopupButtonsController.h"

typedef void (^MDPopupButtonTextBlock)(NSString *text);

@interface MDPopupButtonsController : MDLongPressPopupButtonsController

@property (nonatomic) UIColor *tintColor;

@property (nonatomic, copy) MDPopupButtonTextBlock didFinishWithPopupButtonWithText;

- (UIView *)addPopupButtonWithImage:(UIImage *)image andText:(NSString *)text;
- (UIView *)insertPopupButtonWithImage:(UIImage *)image andText:(NSString *)text atIndex:(NSInteger)index;

@end
