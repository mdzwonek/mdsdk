//
//  RootViewController.h
//  MDSDK
//
//  Created by Mateusz Dzwonek on 14/09/2013.
//  Copyright (c) 2013 Mateusz Dzwonek. All rights reserved.
//

@interface RootViewController : UIViewController

@property (nonatomic, copy) void (^didTapLeftMenuButtonBlock)();
@property (nonatomic, copy) void (^didTapRightMenuButtonBlock)();

@end
