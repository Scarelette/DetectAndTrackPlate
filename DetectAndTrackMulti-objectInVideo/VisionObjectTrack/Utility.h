//
//  UIColor+UIColor_Hex.h
//  lpr
//
//  Created by 李澄 on 2021/7/18.
//  Copyright © 2021 lprSample. All rights reserved.
//
#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif
#ifdef __OBJC__
//#import <opencv2/opencv.hpp>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#endif

NS_ASSUME_NONNULL_BEGIN
//using namespace cv;

@interface Utility : NSObject

//+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;
//+ (UIImage *)UIImageFromCVMat:(cv::Mat)image;
+ (UIImage *)scaleAndRotateImageFrontCamera:(UIImage *)image;
+ (UIImage *)scaleAndRotateImageBackCamera:(UIImage *)image;
+ (NSDictionary *)detect:(UIImage *)image;
- (NSString *)getPath:(NSString*)fileName;
+ (UIImage*)getVideoImageWithTime:(Float64)currentTime video:(AVAsset *)asset;
//+ (UIImage *)imageWithMat:(const cv::Mat&) image andImageOrientation: (UIImageOrientation) orientation;
//+ (UIImage *)imageWithMat:(const cv::Mat&) image andDeviceOrientation: (UIDeviceOrientation) orientation;

@end

NS_ASSUME_NONNULL_END
