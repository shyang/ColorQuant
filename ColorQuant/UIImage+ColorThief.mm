//
//  ColorThief.m
//  ColorQuant
//
//  Created by shaohua on 2021/6/7.
//

#import "UIImage+ColorThief.h"

#import <tuple>
#import <cstdint>
#import <vector>

using color_t = std::tuple<uint8_t, uint8_t, uint8_t>;
std::vector<color_t> quantize(std::vector<color_t>& pixels, int max_color);

@implementation UIImage (ColorThief)

- (UIColor *)getDominantColor {
    return [self getDominantColorDownscaleTo:400];
}

- (UIColor *)getDominantColorDownscaleTo:(CGFloat)width {
    CGSize sz = self.size;
    int w = MIN(sz.width, width);
    int h = w / sz.width * sz.height;
    int total = w * h * 4;
    UInt8 *rawData = (UInt8 *)malloc(total);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContext *context = CGBitmapContextCreate(rawData, w, h, 8, 4 * w, colorSpace, kCGImageAlphaNoneSkipLast | kCGImageByteOrder32Little);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), self.CGImage);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    std::vector<color_t> pixels;
    for (int i = 0; i < total; i += 4) {
        UInt8 b = rawData[i + 1];
        UInt8 g = rawData[i + 2];
        UInt8 r = rawData[i + 3];
        pixels.push_back({r, g, b});
    }
    free(rawData);
    auto output = quantize(pixels, 5);
    if (output.size() == 0) {
        return nil;
    }
    auto first = output[0];
    return [UIColor colorWithRed:std::get<0>(first) / 255.0 green:std::get<1>(first) / 255.0 blue:std::get<2>(first) / 255.0 alpha:1];
}

@end


@implementation UIColor (Adjusted)

- (UIColor *)adjusted {
    CGFloat h, s, b, a;
    [self getHue:&h saturation:&s brightness:&b alpha:&a];

    if (s <= 0.05 || s > 0.70) {
        // ignore
    } else if (s <= 0.10) {
        s += 0.10;
    } else if (s <= 0.30) {
        s += 0.30;
    } else if (s <= 0.40) {
        s += 0.20;
    } else if (s <= 0.50) {
        s += 0.10;
    } else if (s <= 0.70) {
        s += 0.5;
    }
    if (b > 0.50) {
        b = 0.45;
    } else if (b > 0.30) {
        b -= 0.10;
    }
    return [UIColor colorWithHue:h saturation:s brightness:b alpha:a];
}

@end
