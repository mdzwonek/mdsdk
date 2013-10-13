//
//  MDAnimatedDotsViewController.h
//  MDSDK
//
//  Created by Mateusz Dzwonek on 19/09/2013.
//  Copyright (c) 2013 Mateusz Dzwonek. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MDAnimatedDotsViewControllerDelegate;

@interface MDAnimatedDotsViewController : UIViewController

@property (nonatomic, weak) id<MDAnimatedDotsViewControllerDelegate> delegate;

- (id)initWithDelegate:(id<MDAnimatedDotsViewControllerDelegate>)delegate;

@end

@protocol MDAnimatedDotsViewControllerDelegate <NSObject>

@required
- (UIColor *)colorForDotViewForAnimatedDotsViewController:(MDAnimatedDotsViewController *)controller;

@end
