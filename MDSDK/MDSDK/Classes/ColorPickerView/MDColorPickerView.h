//
//  MDColorPickerView.h
//  MDSDK
//
//  Created by Mateusz Dzwonek on 06/03/2015.
//  Copyright (c) 2015 Mateusz Dzwonek. All rights reserved.
//


typedef UIColor *(^MDColorGenerator)(float progress);
typedef float (^MDReverseColorGenerator)(UIColor *color);


@protocol MDColorPickerViewDelegate;


@interface MDColorPickerView : UIView

@property (nonatomic) CGFloat startAngle;
@property (nonatomic) CGFloat endAngle;
@property (nonatomic) CGFloat innerRadiusMultiplier;
@property (nonatomic) CGFloat outerRadiusMultiplier;
@property (nonatomic) UIColor *indicatorViewBorderColor;
@property (nonatomic, copy) MDColorGenerator colorGenerator;

@property (nonatomic, readonly) UIView *indicatorView;

@property (nonatomic, weak) id<MDColorPickerViewDelegate> delegate;

- (void)setColor:(UIColor *)color withReverseColorGenerator:(MDReverseColorGenerator)reverseColorGenerator;

@end


@protocol MDColorPickerViewDelegate <NSObject>

- (void)colorPickerView:(MDColorPickerView *)pickerView didPickColor:(UIColor *)color;

@end
