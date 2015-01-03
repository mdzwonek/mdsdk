//
//  MDBlockDelegateActionSheet.h
//  MDSDK
//
//  Created by Mateusz Dzwonek on 16/12/2014.
//  Copyright (c) 2014 Mateusz Dzwonek. All rights reserved.
//

@interface MDBlockDelegateActionSheet : UIActionSheet

@property (nonatomic, copy) void (^clickedButtonAtIndex)(MDBlockDelegateActionSheet *actionSheet, NSInteger buttonIndex);
@property (nonatomic, copy) void (^willDismissWithButtonIndex)(MDBlockDelegateActionSheet *actionSheet, NSInteger buttonIndex);
@property (nonatomic, copy) void (^didDismissWithButtonIndex)(MDBlockDelegateActionSheet *actionSheet, NSInteger buttonIndex);

@end
