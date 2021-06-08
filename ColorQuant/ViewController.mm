//
//  ViewController.m
//  ColorQuant
//
//  Created by shaohua yang on 4/25/21.
//

#import "ViewController.h"
#import "UIImage+ColorThief.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic) UIImage *image;
@property (nonatomic) UIImageView *bgView;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIImageView *topView;
@property (nonatomic) UIImageView *bottomView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Open" style:UIBarButtonItemStylePlain target:self action:@selector(onRight)];

    UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.bgView = bgView;
    [self.view addSubview:bgView];

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 100, self.view.bounds.size.width - 100, self.view.bounds.size.height - 200)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView = imageView;
    [self.view addSubview:imageView];

    self.topView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 100, self.view.bounds.size.width - 20, 60)];
    self.topView.layer.borderWidth = 10;
    self.topView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.topView];

    self.bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(10, self.view.bounds.size.height - 70 - self.view.safeAreaInsets.bottom, self.view.bounds.size.width - 20, 60)];
    self.bottomView.layer.borderWidth = 10;
    self.bottomView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.bottomView];
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
        UIImage *output = nil;
        UIColor *color1 = [image getDominantColorDownscaleTo:400 startY:0 endY:0.1 cropped:&output];
        self.topView.image = output;
        self.topView.layer.borderColor = color1.CGColor;

        UIColor *color2 = [image getDominantColorDownscaleTo:400 startY:0.9 endY:1 cropped:&output];
        self.bottomView.image = output;
        self.bottomView.layer.borderColor = color2.CGColor;

        self.bgView.image = [UIImage gradientImageWithSize:self.view.bounds.size startColor:color1 endColor:color2];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
