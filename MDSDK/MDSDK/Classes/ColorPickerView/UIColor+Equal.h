//
//  UIColor+Equal.h
//  MDSDK
//
//  Created by Mateusz Dzwonek on 07/03/2015.
//  Copyright (c) 2015 Mateusz Dzwonek. All rights reserved.
//

@interface UIColor (Equal)

- (BOOL)isEqualToColor:(UIColor *)other withTolerance:(CGFloat)tolerance;

@end
