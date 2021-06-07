//
//  ColorThief.m
//  ColorQuant
//
//  Created by shaohua on 2021/6/7.
//

#import "ColorThief.h"

#import <tuple>
#import <cstdint>
#import <vector>

using color_t = std::tuple<uint8_t, uint8_t, uint8_t>;
std::vector<color_t> quantize(std::vector<color_t>& pixels, int max_color);

@implementation ColorThief

+ (UIColor *)getColor:(UIImage *)image {
    CGSize sz = image.size;
    int w = MIN(sz.width, 400);
    int h = w / sz.width * sz.height;
    int total = w * h * 4;
    UInt8 *rawData = (UInt8 *)malloc(total);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContext *context = CGBitmapContextCreate(rawData, w, h, 8, 4 * w, colorSpace, kCGImageAlphaNoneSkipLast | kCGImageByteOrder32Little);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), image.CGImage);
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
    auto first = output[0];
    return [UIColor colorWithRed:std::get<0>(first) / 255.0 green:std::get<1>(first) / 255.0 blue:std::get<2>(first) / 255.0 alpha:1];
}

@end
