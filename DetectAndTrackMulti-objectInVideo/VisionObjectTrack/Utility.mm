//
//  UIColor+UIColor_Hex.h
//  lpr
//
//  Created by 李澄 on 2021/7/18.
//  Copyright © 2021 lprSample. All rights reserved.
//

#import "Utility.h"
#import "Pipeline.h"
using namespace cv;

@implementation Utility

+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

//缩放调整图片
+ (UIImage *)scaleAndRotateImageBackCamera:(UIImage *)image
{
    static int kMaxResolution = 480;
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        } else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
        case UIImageOrientationUp:
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationUpMirrored:
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        case UIImageOrientationDown:
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        case UIImageOrientationLeftMirrored:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationLeft:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationRightMirrored:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        case UIImageOrientationRight:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    } else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSLog(@"resize w%f,H%f",returnImage.size.width,returnImage.size.height);
    return returnImage;
}

+ (UIImage*)imageWithMat:(const cv::Mat&) image andDeviceOrientation: (UIDeviceOrientation)orientation
{
    UIImageOrientation imgOrientation = UIImageOrientationUp;
    
    switch (orientation)
    {
        case UIDeviceOrientationLandscapeLeft:
            imgOrientation =UIImageOrientationLeftMirrored; break;
            
        case UIDeviceOrientationLandscapeRight:
            imgOrientation = UIImageOrientationDown; break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            imgOrientation = UIImageOrientationRightMirrored; break;
        case UIDeviceOrientationFaceUp:
            imgOrientation = UIImageOrientationRightMirrored; break;
            
        default:
        case UIDeviceOrientationPortrait:
            imgOrientation = UIImageOrientationRight; break;
    };
    
    return [Utility imageWithMat:image andImageOrientation:imgOrientation];
}

+ (UIImage*)imageWithMat:(const cv::Mat&)image andImageOrientation:(UIImageOrientation)orientation;
{
    cv::Mat rgbaView;
    
    if (image.channels() == 3)
    {
        cv::cvtColor(image, rgbaView, COLOR_BGR2BGRA);
    }
    else if (image.channels() == 4)
    {
        cv::cvtColor(image, rgbaView, COLOR_BGR2BGRA);
    }
    else if (image.channels() == 1)
    {
        cv::cvtColor(image, rgbaView, COLOR_GRAY2RGBA);
    }
    
    NSData *data = [NSData dataWithBytes:rgbaView.data length:rgbaView.elemSize() * rgbaView.total()];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGBitmapInfo bmInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(rgbaView.cols,                                 //width
                                        rgbaView.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * rgbaView.elemSize(),                       //bits per pixel
                                        rgbaView.step.p[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        bmInfo,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef scale:1 orientation:orientation];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    cv::Mat cvMat3(rows, cols, CV_8UC3); // 8 bits per component, 4 channels
    cv::cvtColor(cvMat, cvMat3,COLOR_RGBA2RGB);
    
    return cvMat3;
}

+ (NSString *)getPath:(NSString*)fileName
{
    NSString *bundlePath = [NSBundle mainBundle].bundlePath;
    NSString *path = [bundlePath stringByAppendingPathComponent:fileName];
    return path;
}

+ (NSDictionary *)simpleRecognition:(cv::Mat&)src
{
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc]initWithCapacity:0];

    NSString *path_1 = [self getPath:@"cascade.xml"];
    NSString *path_2 = [self getPath:@"HorizonalFinemapping.prototxt"];
    NSString *path_3 = [self getPath:@"HorizonalFinemapping.caffemodel"];
    NSString *path_4 = [self getPath:@"Segmentation.prototxt"];
    NSString *path_5 = [self getPath:@"Segmentation.caffemodel"];
    NSString *path_6 = [self getPath:@"CharacterRecognization.prototxt"];
    NSString *path_7 = [self getPath:@"CharacterRecognization.caffemodel"];
    
    std::string *cpath_1 = new std::string([path_1 UTF8String]);
    std::string *cpath_2 = new std::string([path_2 UTF8String]);
    std::string *cpath_3 = new std::string([path_3 UTF8String]);
    std::string *cpath_4 = new std::string([path_4 UTF8String]);
    std::string *cpath_5 = new std::string([path_5 UTF8String]);
    std::string *cpath_6 = new std::string([path_6 UTF8String]);
    std::string *cpath_7 = new std::string([path_7 UTF8String]);
    
    
    pr::PipelinePR pr2 = pr::PipelinePR(*cpath_1, *cpath_2, *cpath_3, *cpath_4, *cpath_5, *cpath_6, *cpath_7);

    std::vector<pr::PlateInfo> list_res = pr2.RunPiplineAsImage(src);
    std::string concat_results = "";
    for(auto one:list_res) {
        if(one.confidence>0.7) {
            concat_results += one.getPlateName()+",";
            cv::Rect region = one.getPlateRect();
            NSMutableDictionary *oneDict = [[NSMutableDictionary alloc]initWithCapacity:0];
            NSString *plateName = [NSString stringWithCString:one.getPlateName().c_str() encoding:NSUTF8StringEncoding];
            NSString *tagX = [plateName stringByAppendingString:@"CX"];
            NSString *valX = [NSString stringWithFormat:@"%f", CGFloat(region.x + region.width / 2)];
            [oneDict setValue: valX forKey:tagX];
            NSString *tagY = [plateName stringByAppendingString:@"CY"];
            NSString *valY = [NSString stringWithFormat:@"%f", CGFloat(region.y + region.height / 2)];
            [oneDict setValue: valY forKey:tagY];
            NSString *tagR = @"Res";
            [oneDict setValue: plateName forKey:tagR];
            [resultDict setValue:oneDict forKey:plateName];
        }
    }
//
    NSString *str = [NSString stringWithCString:concat_results.c_str() encoding:NSUTF8StringEncoding];
    if (str.length > 0) {
        str = [str substringToIndex:str.length-1];
        str = [NSString stringWithFormat:@"%@",str];
    } else {
        str = [NSString stringWithFormat:@"未识别成功"];
    }
    NSLog(@"===> 识别结果 = %@", str);

    return resultDict;
}

+ (NSDictionary *)detect:(UIImage*)image
{
    cv::Mat source_image = [Utility cvMatFromUIImage:image];
    NSDictionary* dict = [self simpleRecognition: source_image];
    return dict;
}

+ (UIImage *)scaleAndRotateImageFrontCamera:(UIImage *)image
{
    static int kMaxResolution = 640;
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake( 0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        } else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
        case UIImageOrientationUp:
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationUpMirrored:
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        case UIImageOrientationDown:
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        case UIImageOrientationLeftMirrored:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationLeft:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    UIGraphicsBeginImageContext( bounds.size );
    CGContextRef context = UIGraphicsGetCurrentContext();
    if ( orient == UIImageOrientationRight || orient == UIImageOrientationLeft ) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    CGContextConcatCTM( context, transform );
    CGContextDrawImage( UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef );
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return returnImage;
}

+ (UIImage*)getVideoImageWithTime:(Float64)currentTime video:(AVAsset*)asset

{

//    AVAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];

    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];

    assetGen.appliesPreferredTrackTransform = YES;

    CMTime time = CMTimeMakeWithSeconds(currentTime, 10);

    NSError*error =nil;

    CMTime actualTime;

    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];

    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];

    CGImageRelease(image);

    return videoImage;

}


@end
