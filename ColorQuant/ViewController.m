//
//  ViewController.m
//  ColorQuant
//
//  Created by shaohua yang on 4/25/21.
//

#import "ViewController.h"
#import <leptonica/allheaders.h>

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic) UIImage *image;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIView *originalView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.view.backgroundColor = UIColor.whiteColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Open" style:UIBarButtonItemStylePlain target:self action:@selector(onRight)];

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 100, self.view.bounds.size.width - 100, self.view.bounds.size.height - 200)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView = imageView;
    [self.view addSubview:imageView];

    self.originalView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 30, 30)];
    self.originalView.layer.borderColor = [UIColor redColor].CGColor;
    self.originalView.layer.masksToBounds = YES;
    [self.view addSubview:self.originalView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.shadowImage = nil;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
}

- (void)onRight {
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    if (image) {
        self.image = image;
        self.imageView.image = image;
        UIColor *color = [self getColors:5].firstObject;
        self.originalView.backgroundColor = color; // 未经过手工调色
        self.view.backgroundColor = [self adjusted:color]; // 手工调色
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (NSArray<UIColor *> *)getColors:(int)MaxColors {
    struct CGImage *cgImage = [self.image CGImage];

    // 截图 PNG 每像素 16 bit，需特别处理
    if (CGImageGetBitsPerPixel(cgImage) != 32) {
        size_t w = CGImageGetWidth(cgImage);
        size_t h = CGImageGetHeight(cgImage);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(nil, w, h, 8, 0, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast); // kCGImageAlphaNoneSkipLast

        CGContextDrawImage(context, CGRectMake(0, 0, w, h), cgImage);
        cgImage = CGBitmapContextCreateImage(context);
        [UIImagePNGRepresentation([[UIImage alloc] initWithCGImage:cgImage]) writeToFile:@"/tmp/lept-orig.png" atomically:YES];
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
    }

    CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
    const UInt8 *imageData = CFDataGetBytePtr(data);

    struct Pix myPix = {};

    myPix.w = (l_uint32)CGImageGetWidth(cgImage);
    myPix.h = (l_uint32)CGImageGetHeight(cgImage);
    myPix.d = (l_uint32)CGImageGetBitsPerPixel(cgImage);
    myPix.wpl = (l_uint32)CGImageGetBytesPerRow(cgImage) / 4;
    myPix.data = (l_uint32 *)imageData;
    myPix.spp = myPix.d / 8;

    if (cgImage == [self.image CGImage]) {
        pixEndianByteSwap(&myPix);
    }

//  pixMedianCutQuantGeneral(<#PIX *pixs#>, <#l_int32 ditherflag#>, <#l_int32 outdepth#>, <#l_int32 maxcolors#>, <#l_int32 sigbits#>, <#l_int32 maxsub#>, <#l_int32 checkbw#>)
//  NSLog(@"pixWrite=%d", pixWrite("/tmp/lept-res.bmp", &myPix, IFF_BMP));
    struct Pix *newPix = pixMedianCutQuantGeneral(&myPix, 0, 0, MaxColors, 0, 10, 0);
//  NSLog(@"pixWrite=%d", pixWrite("/tmp/lept-new.bmp", newPix, IFF_BMP));

    if (!newPix) {
        return nil;
    }
    NSMutableArray *colors = [NSMutableArray array];
    for (int i = 0; i < newPix->colormap->n; i++) {
        struct RGBA_Quad c = ((struct RGBA_Quad *)newPix->colormap->array)[i];
        UIColor *uiColor = [UIColor colorWithRed:c.red / 255.0 green:c.green / 255.0 blue:c.blue / 255.0 alpha:c.alpha / 255.0];
        [colors addObject:uiColor];
    }
    return colors;
}

- (UIColor *)adjusted:(UIColor *)input {
    if (!input) {
        return nil;
    }
    CGFloat h, s, b, a;
    [input getHue:&h saturation:&s brightness:&b alpha:&a];

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
