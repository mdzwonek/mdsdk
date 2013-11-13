//
//  RootViewController.m
//  MDSDK
//
//  Created by Mateusz Dzwonek on 12/11/2013.
//  Copyright (c) 2013 Mateusz Dzwonek. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

- (IBAction)didTapLeftMenuButton:(id)sender;
- (IBAction)didTapRightMenuButton:(id)sender;

@end

@implementation RootViewController

- (IBAction)didTapLeftMenuButton:(id)sender {
    if (self.didTapLeftMenuButtonBlock) {
        self.didTapLeftMenuButtonBlock();
    }
}

- (IBAction)didTapRightMenuButton:(id)sender {
    if (self.didTapRightMenuButtonBlock) {
        self.didTapRightMenuButtonBlock();
    }
}

@end
