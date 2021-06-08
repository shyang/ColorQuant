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

- (UIColor *)getDominantColorDownscaleTo:(CGFloat)width startY:(CGFloat)startY endY:(CGFloat)endY cropped:(UIImage **)cropped;
+ (UIImage *)gradientImageWithSize:(CGSize)size
                        startColor:(UIColor *)startColor
                          endColor:(UIColor *)endColor;
@end

NS_ASSUME_NONNULL_END
