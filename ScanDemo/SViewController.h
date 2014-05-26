//
//  SViewController.h
//  ScanDemo
//
//  Created by 朱国强 on 14-5-22.
//  Copyright (c) 2014年 Apple002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXingWidgetController.h"
#import "QRCodeReader.h"
#import <Decoder.h>
#import "TwoDDecoderResult.h"

#import "QREncoder.h"

#import "SCustomScanController.h"

@interface SViewController : UIViewController <UITextViewDelegate, ZXingDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, DecoderDelegate, CustomScanDelegate>

@property (strong, nonatomic) IBOutlet UITextView *tvScanResult;

@end
