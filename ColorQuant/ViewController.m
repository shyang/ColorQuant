//
//  ViewController.m
//  ColorQuant
//
//  Created by shaohua yang on 4/25/21.
//

#import "ViewController.h"
#import <ColorQuant-Swift.h>

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
        NSDate *begin = [NSDate date];
        int quality = MAX(10, MAX(image.size.height, image.size.width) / 50);
        UIColor *color = [ColorThief getColorFrom:image quality:quality ignoreWhite:YES];
        NSLog(@"time %f, %@, %d", [begin timeIntervalSinceNow], NSStringFromCGSize(image.size), quality);
        self.originalView.backgroundColor = color; // 未经过手工调色
        self.view.backgroundColor = [self adjusted:color]; // 手工调色
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
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
