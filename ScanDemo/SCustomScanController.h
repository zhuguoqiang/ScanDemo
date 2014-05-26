//
//  SCustomScanController.h
//  ScanDemo
//
//  Created by 朱国强 on 14-5-23.
//  Copyright (c) 2014年 Apple002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "QRCodeReader.h"
#import "Decoder.h"
#import "TwoDDecoderResult.h"

@protocol CustomScanDelegate <NSObject>

- (void)customController:(UIViewController *)customController didDecodeImageWithResult:(NSString *)result;
- (void)customControllerDidCancleScan:(UIViewController *)viewController;

@end


@interface SCustomScanController : UIViewController <UINavigationControllerDelegate,
UIImagePickerControllerDelegate, DecoderDelegate,AVCaptureVideoDataOutputSampleBufferDelegate, UIAlertViewDelegate>

@property (assign, nonatomic) id<CustomScanDelegate> delegate;

@end
