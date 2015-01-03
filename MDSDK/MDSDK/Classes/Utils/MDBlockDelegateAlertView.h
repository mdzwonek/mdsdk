//
//  MDBlockDelegateAlertView.h
//  MDSDK
//
//  Created by Mateusz Dzwonek on 24/07/2014.
//  Copyright (c) 2014 Mateusz Dzwonek. All rights reserved.
//

@interface MDBlockDelegateAlertView : UIAlertView

@property (nonatomic, copy) void (^willDismissWithButtonIndex)(MDBlockDelegateAlertView *alertView, NSInteger buttonIndex);
@property (nonatomic, copy) void (^didDismissWithButtonIndex)(MDBlockDelegateAlertView *alertView, NSInteger buttonIndex);

@end
