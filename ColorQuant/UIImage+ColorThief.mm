//
//  ColorThief.m
//  ColorQuant
//
//  Created by shaohua on 2021/6/7.
//

#import "UIImage+ColorThief.h"
#import "colorquant.h"

@implementation UIImage (ColorThief)


+ (UIImage *)gradientImageWithSize:(CGSize)size
                        startColor:(UIColor *)startColor
                          endColor:(UIColor *)endColor
{
    if (!startColor || !endColor || CGSizeEqualToSize(CGSizeZero, size)) {
        return nil;
    }
    CGFloat width = size.width;
    CGFloat height = size.height;
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();

    size_t num_locations = 2;
    CGFloat locations[2] = {0.0, 1.0};
    const CGFloat *startComponents = CGColorGetComponents(startColor.CGColor);
    const CGFloat *endComponents = CGColorGetComponents(endColor.CGColor);
    CGFloat components[8] = {startComponents[0], startComponents[1], startComponents[2], startComponents[3],  // Start color
        endComponents[0], endComponents[1], endComponents[2], endComponents[3]}; // End color
    CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    CGPoint topCenter = CGPointZero;
    CGPoint bottomCenter = CGPointMake(0, height);
    CGContextDrawLinearGradient(context, glossGradient, topCenter, bottomCenter, 0);
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIColor *)getDominantColorDownscaleTo:(CGFloat)width startY:(CGFloat)startY endY:(CGFloat)endY cropped:(UIImage **)cropped {
    CGSize sz = self.size;
    int w = MIN(sz.width, width);
    int h = w / sz.width * sz.height;
    int cropY = h * startY;
    int cropH = h * (endY - startY);
    int total = w * cropH * 4;
    UInt8 *rawData = (UInt8 *)malloc(total);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    struct CGContext *context = CGBitmapContextCreate(rawData, w, cropH, 8, 4 * w, colorSpace, kCGImageAlphaNoneSkipLast | kCGImageByteOrder32Big);
    UIGraphicsPushContext(context);
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -cropH);
    [self drawInRect:CGRectMake(0, -cropY, w, h)];

    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *tmp = [[UIImage alloc] initWithCGImage:cgImage];
    if (cropped) {
        *cropped = tmp;
    }
    UIGraphicsPopContext();
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    auto myPix = std::make_shared<Pix>();
    myPix->depth = 4;
    myPix->n = total / 4;
    myPix->pixs = rawData;

    // 5 colors, default sigbits, no subsampling
    auto cmap = pix_median_cut_quant(myPix, 5, DEFAULT_SIG_BITS, 1);
    if (!cmap || cmap->n < 1) {
        return nil;
    }
    auto first = *cmap->array->begin();

    return [UIColor colorWithRed:first->red / 255.0 green:first->green / 255.0 blue:first->blue / 255.0 alpha:1];
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
