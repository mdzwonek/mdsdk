//
//  MDRandom.m
//  MDSDK
//
//  Created by Mateusz Dzwonek on 13/10/2013.
//  Copyright (c) 2013 Mateusz Dzwonek. All rights reserved.
//

#import "MDRandom.h"

@implementation MDRandom

+ (int)randomInt:(int)number {
    return arc4random() % number;
}

+ (double)randomDouble {
    return ((double) [self randomInt:101]) / 100.0;
}

+ (double)randomDoubleBetween:(double)firstDouble and:(double)secondDouble {
    return firstDouble + [MDRandom randomDouble] * (secondDouble - firstDouble);
}

+ (UIColor *)randomColorBetween:(UIColor *)firstColor and:(UIColor *)secondColor {
    CGFloat firstColorComponents[4];
    if (![firstColor getRed:&firstColorComponents[0] green:&firstColorComponents[1] blue:&firstColorComponents[2] alpha:&firstColorComponents[3]]) {
        return firstColor;
    }
    
    CGFloat secondColorComponents[4];
    if (![secondColor getRed:&secondColorComponents[0] green:&secondColorComponents[1] blue:&secondColorComponents[2] alpha:&secondColorComponents[3]]) {
        return firstColor;
    }
    
    CGFloat resultColorComponents[4];
    for (int i = 0; i < 4; i++) {
        resultColorComponents[i] = [MDRandom randomDoubleBetween:firstColorComponents[i] and:secondColorComponents[i]];
    }

    return [UIColor colorWithRed:resultColorComponents[0] green:resultColorComponents[1] blue:resultColorComponents[2] alpha:resultColorComponents[3]];
}

@end
