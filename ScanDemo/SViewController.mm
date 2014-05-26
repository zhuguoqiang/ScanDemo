//
//  SViewController.m
//  ScanDemo
//
//  Created by 朱国强 on 14-5-22.
//  Copyright (c) 2014年 Apple002. All rights reserved.
//

#import "SViewController.h"



@interface SViewController ()

@end

@implementation SViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//zxing扫描
- (IBAction)btnScanAction:(id)sender {
    ZXingWidgetController *zxwController = [[ZXingWidgetController alloc]
                                            initWithDelegate:self
                                            showCancel:YES OneDMode:NO];
    
    NSMutableSet *readers = [[NSMutableSet alloc]init];
    
    QRCodeReader *reader = [[QRCodeReader alloc]init];
    
    [readers addObject:reader];
    
    zxwController.readers = readers;
    
    [self presentViewController:zxwController animated:YES completion:^{
        
    }];

}

//从相册选择
- (IBAction)btnSelectFromImagePickerAction:(id)sender {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    
    pickerController.allowsEditing = YES;
    
    pickerController.delegate = self;
    
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:pickerController animated:YES completion:^{
        
    }];
    
    
}

//自定义扫描

- (IBAction)btnCustomScanAction:(id)sender {
    UIStoryboard *storyboard = self.storyboard;
    
    SCustomScanController *customScanController = [storyboard instantiateViewControllerWithIdentifier:@"customScanVC"];
    
    customScanController.delegate = self;
    
    [self presentViewController:customScanController animated:YES completion:^{
        
    }];
}

//生成二维码

- (IBAction)btnBuildTwoDimesionCodeAction:(id)sender {
    int qrcodeImageDimension = 300;
    
    NSString *string = self.tvScanResult.text;
    
    DataMatrix *qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:string];
    
    UIImage *qrcodeImage = [QREncoder renderDataMatrix:qrMatrix imageDimension:qrcodeImageDimension];
    
    UIImageView *qrcodeImageView = [[UIImageView alloc] initWithImage:qrcodeImage];
    
    UIViewController *viewController = [[UIViewController alloc]init];
    
    viewController.view.backgroundColor = [UIColor whiteColor];
    
    [qrcodeImageView setCenter:viewController.view.center];
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone  target:self action:@selector(btnBackAction:)];
    
    [viewController.navigationItem setRightBarButtonItem:rightBarItem];
    
    [viewController.view addSubview:qrcodeImageView];
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:viewController];
    
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}


#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self.tvScanResult resignFirstResponder];
        return NO;
    }
    return YES;
}


#pragma mark - ZXingDelegate

- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result
{
    //扫描结果
//    [self.tvScanResult setText:result];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.tvScanResult setText:result];
    }];
    
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller
{
    //扫描取消
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self decodeImage:image];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - DecoderDelegate

- (void)decoder:(Decoder *)decoder didDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset withResult:(TwoDDecoderResult *)result
{
    [self outputResult:result.text];
}

- (void)decoder:(Decoder *)decoder failedToDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset reason:(NSString *)reason
{
    [self outputResult:@"解码失败！"];
}

#pragma mark - CustomScanDelegate

- (void)customController:(UIViewController *)customController didDecodeImageWithResult:(NSString *)result
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self outputResult:result];
    }];
    
}

- (void)customControllerDidCancleScan:(UIViewController *)viewController
{
    if (![self.presentedViewController isBeingDismissed]) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }

    
}

#pragma mark - Private

- (void)btnBackAction:sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)decodeImage:(UIImage *)image
{
    NSMutableSet *qrReader = [[NSMutableSet alloc]init];
    QRCodeReader *qrcoderReader = [[QRCodeReader alloc]init];
    [qrReader addObject:qrcoderReader];
    
    Decoder *decoder = [[Decoder alloc]init];
    decoder.delegate  = self;
    decoder.readers = qrReader;
    [decoder decodeImage:image];
}

- (void)outputResult:(NSString *)result
{
    NSLog(@"result : %@",result);
    [self.tvScanResult setText:result];
}

@end
