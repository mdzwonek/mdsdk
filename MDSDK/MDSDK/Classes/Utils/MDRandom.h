//
//  MDRandom.h
//  MDSDK
//
//  Created by Mateusz Dzwonek on 13/10/2013.
//  Copyright (c) 2013 Mateusz Dzwonek. All rights reserved.
//

@interface MDRandom : NSObject

+ (int)randomInt:(int)number;

+ (double)randomDouble;
+ (double)randomDoubleBetween:(double)firstDouble and:(double)secondDouble;

+ (UIColor *)randomColorBetween:(UIColor *)firstColor and:(UIColor *)secondColor;

@end
