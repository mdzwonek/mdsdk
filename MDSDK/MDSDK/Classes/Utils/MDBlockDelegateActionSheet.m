//
//  MDBlockDelegateActionSheet.m
//  MDSDK
//
//  Created by Mateusz Dzwonek on 16/12/2014.
//  Copyright (c) 2014 Mateusz Dzwonek. All rights reserved.
//

#import "MDBlockDelegateActionSheet.h"


@interface MDBlockDelegateActionSheet () <UIActionSheetDelegate>

@end


@implementation MDBlockDelegateActionSheet

- (void)showInView:(UIView *)view {
    [super showInView:view];
    self.delegate = self;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.clickedButtonAtIndex != NULL) {
        self.clickedButtonAtIndex(self, buttonIndex);
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (self.willDismissWithButtonIndex != NULL) {
        self.willDismissWithButtonIndex(self, buttonIndex);
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (self.didDismissWithButtonIndex != NULL) {
        self.didDismissWithButtonIndex(self, buttonIndex);
    }
}

@end
