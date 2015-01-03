//
//  MDBlockDelegateAlertView.m
//  MDSDK
//
//  Created by Mateusz Dzwonek on 24/07/2014.
//  Copyright (c) 2014 Mateusz Dzwonek. All rights reserved.
//

#import "MDBlockDelegateAlertView.h"


@interface MDBlockDelegateAlertView () <UIAlertViewDelegate>

@end


@implementation MDBlockDelegateAlertView

- (void)show {
    [super show];
    self.delegate = self;
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (self.willDismissWithButtonIndex != NULL) {
        self.willDismissWithButtonIndex(self, buttonIndex);
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (self.didDismissWithButtonIndex != NULL) {
        self.didDismissWithButtonIndex(self, buttonIndex);
    }
}

@end
