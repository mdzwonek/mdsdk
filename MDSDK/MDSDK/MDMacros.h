//
//  MDMacros.h
//  MDSDK
//
//  Created by Mateusz Dzwonek on 01/03/2014.
//  Copyright (c) 2014 Mateusz Dzwonek. All rights reserved.
//

#ifndef MDSDK_MDMacros_h
#define MDSDK_MDMacros_h

#define UIOffsetAdd(firstOffset, secondOffset) UIOffsetMake(firstOffset.horizontal + secondOffset.horizontal, firstOffset.vertical + secondOffset.vertical)
#define UIOffsetMultiply(offset, multiplier) UIOffsetMake(multiplier * offset.horizontal, multiplier * offset.vertical)
#define UIOffsetSubstract(firstOffset, secondOffset) UIOffsetAdd(firstOffset, UIOffsetMultiply(secondOffset, -1.0f))

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#endif
