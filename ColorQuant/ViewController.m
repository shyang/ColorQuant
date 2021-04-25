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
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Open" style:UIBarButtonItemStylePlain target:self action:@selector(onRight)];
    self.tableView.rowHeight = 44;
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
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 400);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.tableView.tableHeaderView = imageView;
        [self.tableView reloadData];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (NSArray *)getColors:(int)MaxColors {
    struct CGImage *cgImage = [self.image CGImage];
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

//  pixMedianCutQuantGeneral(<#PIX *pixs#>, <#l_int32 ditherflag#>, <#l_int32 outdepth#>, <#l_int32 maxcolors#>, <#l_int32 sigbits#>, <#l_int32 maxsub#>, <#l_int32 checkbw#>)
//  NSLog(@"pixWrite=%d", pixWrite("/tmp/lept-res.bmp", &myPix, IFF_BMP));
    struct Pix *newPix = pixMedianCutQuantGeneral(&myPix, 0, 0, MaxColors, 0, 10, 0);
//  NSLog(@"pixWrite=%d", pixWrite("/tmp/lept-new.bmp", newPix, IFF_BMP));

    NSMutableArray *colors = [NSMutableArray array];
    for (int i = 0; i < MaxColors; i++) {
        struct RGBA_Quad c = ((struct RGBA_Quad *)newPix->colormap->array)[i];
        UIColor *uiColor = [UIColor colorWithRed:c.red / 255.0 green:c.green / 255.0 blue:c.blue / 255.0 alpha:c.alpha / 255.0];
        [colors addObject:uiColor];
    }
    return colors;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.image) {
        return 9;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    int ncolors = indexPath.row + 2;
    CGFloat w = self.view.bounds.size.width;
    NSArray *colors = [self getColors:ncolors];
    for (int i = 0; i < ncolors; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(w / ncolors * i, 0, w / ncolors, tableView.rowHeight)];
        label.text = [@(i + 1) description];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = colors[i];
        [cell.contentView addSubview:label];
    }
    return cell;
}

@end
