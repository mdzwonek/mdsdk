//
//  MDDotView.h
//  MDSDK
//
//  Created by Mateusz Dzwonek on 14/09/2013.
//  Copyright (c) 2013 Mateusz Dzwonek. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat DEFAULT_DOT_VIEW_SIZE;

@interface MDDotView : UIView

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGFloat depth;

- (void)updatePositionWithDeltaVelocity:(UIOffset)deltaVelocity andDeltaTime:(NSTimeInterval)deltaTime;

@end
