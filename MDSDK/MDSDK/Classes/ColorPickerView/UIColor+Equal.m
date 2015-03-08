//
//  UIColor+Equal.m
//  MDSDK
//
//  Created by Mateusz Dzwonek on 07/03/2015.
//  Copyright (c) 2015 Mateusz Dzwonek. All rights reserved.
//

#import "UIColor+Equal.h"


@implementation UIColor (Equal)

- (BOOL)isEqualToColor:(UIColor *)other withTolerance:(CGFloat)tolerance {
    CGFloat r1, g1, b1, a1, r2, g2, b2, a2;
    [self getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [other getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    return fabsf(r1 - r2) <= tolerance && fabsf(g1 - g2) <= tolerance && fabsf(b1 - b2) <= tolerance && fabsf(a1 - a2) <= tolerance;
}

@end
