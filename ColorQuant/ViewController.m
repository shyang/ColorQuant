//
//  ViewController.m
//  ColorQuant
//
//  Created by shaohua yang on 4/25/21.
//

#import "ViewController.h"
#import <leptonica/allheaders.h>

static const int MaxColors = 2;

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) UIImageView *imageView;
@property (nonatomic) NSMutableArray<UIView *> *palette;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = UIColor.whiteColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Open" style:UIBarButtonItemStylePlain target:self action:@selector(onRight)];

    CGFloat h = self.view.bounds.size.height;
    CGFloat w = self.view.bounds.size.width;
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, h / 2)];

    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];

    self.palette = [NSMutableArray array];
    CGFloat y = h / 2;
    for (int i = 0; i < MaxColors; i++) {
        UILabel *colorView = [[UILabel alloc] initWithFrame:CGRectMake(0, y, w, h / 2 / MaxColors)];
        colorView.text = [@(i) description];
        colorView.textAlignment = NSTextAlignmentCenter;
        y += h / 2 / MaxColors;
        [self.view addSubview:colorView];
        [self.palette addObject:colorView];
    }
}

- (void)onRight {
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    if (!image) {
        return;
    }

    struct CGImage *cgImage = [image CGImage];
    CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
    const UInt8 *imageData = CFDataGetBytePtr(data);

    struct Pix myPix = {};

    myPix.w = (l_uint32)CGImageGetWidth(cgImage);
    myPix.h = (l_uint32)CGImageGetHeight(cgImage);
    myPix.d = (l_uint32)CGImageGetBitsPerPixel(cgImage);
    myPix.wpl = (l_uint32)CGImageGetBytesPerRow(cgImage) / 4;
    myPix.data = (l_uint32 *)imageData;
    myPix.spp = myPix.d / 8;

    pixEndianByteSwap(&myPix);

    // pixMedianCutQuantGeneral(<#PIX *pixs#>, <#l_int32 ditherflag#>, <#l_int32 outdepth#>, <#l_int32 maxcolors#>, <#l_int32 sigbits#>, <#l_int32 maxsub#>, <#l_int32 checkbw#>)
//    NSLog(@"pixWrite=%d", pixWrite("/tmp/lept-res.bmp", &myPix, IFF_BMP));
    struct Pix *newPix = pixMedianCutQuantGeneral(&myPix, 0, 0, MaxColors, 0, 10, 0);
//    NSLog(@"pixWrite=%d", pixWrite("/tmp/lept-new.bmp", newPix, IFF_BMP));

    for (int i = 0; i < MaxColors; i++) {
        struct RGBA_Quad c = ((struct RGBA_Quad *)newPix->colormap->array)[i];
        UIColor *uiColor = [UIColor colorWithRed:c.red / 255.0 green:c.green / 255.0 blue:c.blue / 255.0 alpha:c.alpha / 255.0];
        self.palette[i].backgroundColor = uiColor;
    }
    self.imageView.image = image;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
