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
        UIColor *color = [image getDominantColor];
        self.originalView.backgroundColor = color; // 未经过手工调色
        self.view.backgroundColor = [color adjusted]; // 手工调色
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
