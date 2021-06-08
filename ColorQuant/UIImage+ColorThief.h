//
//  ColorThief.h
//  ColorQuant
//
//  Created by shaohua on 2021/6/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Adjusted)

- (UIColor *)adjusted;

@end


@interface UIImage (ColorThief)

- (UIColor *)getDominantColor;
- (UIColor *)getDominantColorDownscaleTo:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
