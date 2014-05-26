//
//  SCustomScanController.m
//  ScanDemo
//
//  Created by 朱国强 on 14-5-23.
//  Copyright (c) 2014年 Apple002. All rights reserved.
//

#import "SCustomScanController.h"

@interface SCustomScanController ()

@property (assign, nonatomic) BOOL isScan;

@property (nonatomic, strong) AVCaptureSession * session;


@end

@implementation SCustomScanController

@synthesize delegate, isScan;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        isScan = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
     [self configCapture];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
   
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ACTION

//从相册选择
- (IBAction)btnSelectFromImageLibraryAction:(id)sender {
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    imagePickerController.delegate = self;
    
    imagePickerController.allowsEditing = YES;

    [self presentViewController:imagePickerController animated:YES completion:^{
        isScan = NO;
        
        [self.session stopRunning];
    }];
    
}

//取消扫描

- (IBAction)btnCancleScanAction:(id)sender {
    isScan = NO;
    [self.session stopRunning];
    if (nil != delegate && [delegate respondsToSelector:@selector(customControllerDidCancleScan:)]) {
        [delegate customControllerDidCancleScan:self];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self decodeImage:[info objectForKey:@"UIImagePickerControllerEditedImage"]];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [self dismissViewControllerAnimated:YES completion:^{
        isScan = YES;
        [self.session startRunning];
    }];
}

#pragma mark - DecoderDelegate

- (void)decoder:(Decoder *)decoder didDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset withResult:(TwoDDecoderResult *)result
{

    isScan = NO;
    [self.session stopRunning];
    if (nil != delegate && [delegate respondsToSelector:@selector(customController:didDecodeImageWithResult:)])
    {
        [delegate customController:self didDecodeImageWithResult:result.text];
    }
    
}

- (void)decoder:(Decoder *)decoder failedToDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset reason:(NSString *)reason
{
    
    if (!isScan)
    {//从相册选择，解码失败，给出提示，继续扫码，
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"没有发现二维码！！" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alertView show];

    }
    else
    {
        //扫码解析失败，什么也不做，继续扫码，
    }
    
//下面的代码会产生 zmobie (僵尸对象)
    
//    if (nil != delegate && [delegate respondsToSelector:@selector(customController:failToDecodeImageWithReason:)])
//    {
//        [delegate customController:self failToDecodeImageWithReason:reason];
//    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    [self decodeImage:image];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    isScan = YES;
    [self.session startRunning];
}

#pragma mark - Private

- (void)decodeImage:(UIImage *)image
{
    NSMutableSet *readers = [[NSMutableSet alloc]init];
    
    QRCodeReader *codeReader = [[QRCodeReader alloc] init];
    
    [readers addObject:codeReader];
  
    Decoder *decoder = [[Decoder alloc]init];
    
    decoder.delegate = self;
    
    decoder.readers = readers;
    
    [decoder decodeImage:image];
    
}

- (void)configCapture
{
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error ];
    
    if (!input) {
        
    }
    
    if ([captureSession canAddInput:input]) {
        [captureSession addInput:input];
    }
    else
    {
        
    }
    
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc]init];
    
    output.alwaysDiscardsLateVideoFrames = YES;

    [output setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    NSDictionary *viedoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    [output setVideoSettings:viedoSettings];
    
    
    if ([captureSession canAddOutput:output]) {
        
        [captureSession addOutput:output];
    }
    else
    {
        
    }
    
    NSString *preset = 0;
    
    if (NSClassFromString(@"NSOrderedSet")&&
        [UIScreen mainScreen].scale > 1 &&
        [device supportsAVCaptureSessionPreset:AVCaptureSessionPresetiFrame960x540]) {
        preset = AVCaptureSessionPresetiFrame960x540;
    }
    else
    {
        preset = AVCaptureSessionPresetMedium;
    }

    captureSession.sessionPreset = preset;
    
    self.session = captureSession;
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    
    
    CGRect frame = self.view.bounds;
    
    frame.origin.y = frame.origin.y + 44;
    
    frame.size.height = frame.size.height - 88;
    
    captureVideoPreviewLayer.frame = frame;
    
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.view.layer addSublayer:captureVideoPreviewLayer];
    
    isScan = YES;
    
    [self.session startRunning];
    
}

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (!colorSpace) {
        NSLog(@"CGColorSpaceCreateDeviceRGB failed");
        return nil;
    }
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
    
    CGImageRef cgImage = CGImageCreate(width,
                                       height,
                                       8,
                                       32,
                                       bytesPerRow,
                                       colorSpace,
                                       kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,
                                       provider,
                                       NULL,
                                       true,
                                       kCGRenderingIntentDefault);
    
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return image;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
