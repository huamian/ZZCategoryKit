//
//  UIImage+Kit.m
//  BXlive
//
//  Created by huangzhiwen on 2017/3/28.
//  Copyright © 2017年 cat. All rights reserved.
//

#import "UIImage+Kit.h"
#import "UIColor+Kit.h"
#import "UIDevice+Kit.h"
#import <objc/runtime.h>
/* 字符串转成尺寸大小 */
CGSize sizeForSizeString(NSString *sizeString)
{
    // 字符串成员分割
    NSArray *array = [sizeString componentsSeparatedByString:@"x"];
    if(array.count != 2)
        return CGSizeZero;
    return CGSizeMake([array[0] floatValue], [array[1] floatValue]);
}

/* 颜色字符串转成颜色 */
UIColor *colorForColorString(NSString *colorString)
{
    if(!colorString)
    {
        return [UIColor lightGrayColor];
    }
    // 从字符串获取方法选择器
    SEL colorSelector = NSSelectorFromString([colorString stringByAppendingString:@"Color"]);
    // 方法选择器是否响应
    if([UIColor respondsToSelector:colorSelector])
    {
        // 返回执行UIColor方法
        return [UIColor performSelector:colorSelector];
    }
    else
    {
        // 返回一个从HEX字符串得到UIColor对象
        return [UIColor colorWithHexString:colorString];
    }
}
@implementation UIImage (STKit)
+(UIImage*)compressedImageToLimitSizeOfKB:(CGFloat)kb image:(UIImage*)image
{
    //大于多少kb的图片需要压缩
    long imagePixel = CGImageGetWidth(image.CGImage)*CGImageGetHeight(image.CGImage);
    long imageKB = imagePixel * CGImageGetBitsPerPixel(image.CGImage) / (8*1024);
    if (imageKB > kb){
        float compressedParam = kb / imageKB;
        return [UIImage imageWithData:UIImageJPEGRepresentation(image, compressedParam)];
    }
    //返回原图
    else{
        return image;
    }
}

+(NSData*)returnDataCompressedImageToLimitSizeOfKB:(CGFloat)kb image:(UIImage*)image
{
    //大于多少kb的图片需要压缩
    long imagePixel = CGImageGetWidth(image.CGImage)*CGImageGetHeight(image.CGImage);
    long imageKB = imagePixel * CGImageGetBitsPerPixel(image.CGImage) / (8 * 1024);
    if (imageKB > kb){
        float compressedParam = kb / imageKB;
        return UIImageJPEGRepresentation(image, compressedParam);
    }
    //返回原图
    else{
        return UIImageJPEGRepresentation(image, 1);
    }
}


+(UIImage*) circleImage:(UIImage*) image withParam:(CGFloat) inset
{
    //UIGraphicsBeginImageContext(image.size);
    //解决失真 模糊的问题
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context =UIGraphicsGetCurrentContext();
    
    //圆的边框宽度为2，颜色为红色
    
    CGContextSetLineWidth(context,2);
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGRect rect = CGRectMake(inset, inset, image.size.width - inset *2.0f, image.size.height - inset *2.0f);
    
    CGContextAddEllipseInRect(context, rect);
    
    CGContextClip(context);
    
    //在圆区域内画出image原图
    
    [image drawInRect:rect];
    
    CGContextAddEllipseInRect(context, rect);
    
    CGContextStrokePath(context);
    
    //生成新的image
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newimg;
}

+(UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(size);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        
        NSAssert(!newImage,@"图片压缩失败");
    }
    
    UIGraphicsEndImageContext();
    return newImage;
}


+(UIImage *)compressImage:(UIImage *)sourceImage toTargetWidth:(CGFloat)targetWidth
{
    CGSize imageSize = sourceImage.size;
    
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetHeight = (targetWidth / width) * height;
    
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


+(UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size); //size 为CGSize类型，即你所需要的图片尺寸
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage; //返回的就是已经改变的图片
}
+ (void)load
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        [self exchangeClassMethod:@selector(imageNamed:)
                       withMethod:@selector(dummy_imageNamed:)];
    });
}

+ (UIImage *)dummy_imageNamed:(NSString *)name
{
    if(!name) return nil;
    
    UIImage *result;
    
    NSArray *array = [name componentsSeparatedByString:@"."];
    if([[array[0] lowercaseString] isEqualToString:@"dummy"])
    {
        NSString *sizeString = array[1];
        if(!sizeString) return nil;
        
        NSString *colorString = nil;
        if(array.count >= 3)
        {
            colorString = array[2];
        }
        
        return [self dummyImageWithSize:sizeForSizeString(sizeString)
                                  color:colorForColorString(colorString)];
    }
    else
    {
        result = [self dummy_imageNamed:name];
    }
    
    return result;
}

/* 从尺寸和颜色中仿制图片 */
+ (UIImage *)dummyImageWithSize:(CGSize)size
                          color:(UIColor *)color
{
    // 开始UIImage上下文
    UIGraphicsBeginImageContext(size);
    // 获取绘图上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
    // 设置填充颜色
    [color setFill];
    // 当前在填写区域填充颜色
    CGContextFillRect(context, rect);
    
    [[UIColor blackColor] setFill];
    NSString *sizeString = [NSString stringWithFormat:@"%d x %d", (int)size.width, (int)size.height];
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        // 从NSParagraphStyle段落样式对象获取NSMutableParagraphStyle对象
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        // 设置文本对齐方式
        style.alignment = NSTextAlignmentCenter;
        // 获取属性字典
        NSDictionary *attributes = @{NSParagraphStyleAttributeName : style};
        // 绘制字符串
        [sizeString drawInRect:rect withAttributes:attributes];
    }
    else
    {
        //        [sizeString drawInRect:rect
        //                      withFont:[UIFont systemFontOfSize:12]
        //                 lineBreakMode:NSLineBreakByTruncatingTail
        //                     alignment:NSTextAlignmentCenter];
        
        NSDictionary *dicAttr = @{NSFontAttributeName:[UIFont systemFontOfSize:12]};
        [sizeString drawInRect:rect withAttributes:dicAttr];
    }
    
    // 从当前图像上下文获取图像
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    // 结束UIImage上下文
    UIGraphicsEndImageContext();
    
    return result;
}

/* 交换两种方法的实现 */
+ (void)exchangeClassMethod:(SEL)selector1
                 withMethod:(SEL)selector2
{
    // 获取一个指向给定类的方法
    Method fromMethod = class_getClassMethod(self, selector1);
    Method toMethod = class_getClassMethod(self, selector2);
    // 交换两种方法的实现
    method_exchangeImplementations(fromMethod, toMethod);
}

/* 获取混合模式图片 */
- (UIImage *)blendOverlay
{
    // 开启UIImage上下文
    UIGraphicsBeginImageContext(CGSizeMake(self.size.width, self.size.height));
    [self drawInRect:CGRectMake(0.0, 0.0, self.size.width, self.size.height)
           blendMode:kCGBlendModeOverlay
               alpha:1];
    // 从当前图像上下文获取图像
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    // 结束UIImage上下文
    UIGraphicsEndImageContext();
    
    return image;
}

/* 返回一个指定被遮住区域处理后的图片*/
- (UIImage *)maskWithImage:(UIImage *)image
                   andSize:(CGSize)size
{
    CGContextRef mainViewContentContext;
    CGColorSpaceRef colorSpace;
    colorSpace = CGColorSpaceCreateDeviceRGB();
    // 创建一个位图上下文
    mainViewContentContext = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    // 相当于`CFRelease', 释放空间
    CGColorSpaceRelease(colorSpace);
    
    if(mainViewContentContext == NULL) return NULL;
    // 添加'mask'转化为'rect'到背景下的剪裁区域
    CGContextClipToMask(mainViewContentContext, CGRectMake(0, 0, size.width, size.height), image.CGImage);
    // 通过'rect'的背景下，对图像进行缩放，如果需要的话，以适应'rect'
    CGContextDrawImage(mainViewContentContext, CGRectMake(0, 0, size.width, size.height), self.CGImage);
    // 获取一个包含位图上下文的快照图像
    CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(mainViewContentContext);
    // 相当于`CFRelease', 释放空间
    CGContextRelease(mainViewContentContext);
    UIImage *returnImage = [UIImage imageWithCGImage:mainViewContentBitmapContext];
    // 相当于`CFRelease', 释放空间
    CGImageRelease(mainViewContentBitmapContext);
    
    return returnImage;
}

/* 返回一个遮罩后的图片 */
- (UIImage *)maskWithImage:(UIImage *)image
{
    CGContextRef mainViewContentContext;
    CGColorSpaceRef colorSpace;
    // 创建DeviceRGB色彩空间
    colorSpace = CGColorSpaceCreateDeviceRGB();
    // 创建位图上下文
    mainViewContentContext = CGBitmapContextCreate(NULL, self.size.width, self.size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    // 空间释放
    CGColorSpaceRelease(colorSpace);
    
    if(mainViewContentContext == NULL)
        return NULL;
    CGContextClipToMask(mainViewContentContext, CGRectMake(0, 0, self.size.width, self.size.height), image.CGImage);
    CGContextDrawImage(mainViewContentContext, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
    CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    UIImage *returnImage = [UIImage imageWithCGImage:mainViewContentBitmapContext];
    CGImageRelease(mainViewContentBitmapContext);
    
    return returnImage;
}

- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    if([UIDevice isRetina])
    {
        CGSize retinaTargetSize = CGSizeMake(targetSize.width*2, targetSize.height*2);
        if(!CGSizeEqualToSize(imageSize, retinaTargetSize))
            targetSize = retinaTargetSize;
    }
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if(CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor) thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        else if(widthFactor < heightFactor) thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
    }
    
    UIGraphicsBeginImageContext(targetSize);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"Could not scale image");
    
    return newImage ;
}

- (UIImage *)imageByScalingProportionallyToMaximumSize:(CGSize)targetSize
{
    if([UIDevice isRetina])
    {
        CGSize retinaMaxtSize = CGSizeMake(targetSize.width*2, targetSize.height*2);
        if(!CGSizeEqualToSize(targetSize, retinaMaxtSize)) targetSize = retinaMaxtSize;
    }
    
    if((self.size.width > targetSize.width || targetSize.width == targetSize.height) && self.size.width > self.size.height)
    {
        float factor = (targetSize.width*100)/self.size.width;
        float newWidth = (self.size.width*factor)/100;
        float newHeight = (self.size.height*factor)/100;
        
        CGSize newSize = CGSizeMake(newWidth, newHeight);
        UIGraphicsBeginImageContext(newSize);
        [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    }
    else if((self.size.height > targetSize.height || targetSize.width == targetSize.height) && self.size.width < self.size.height)
    {
        float factor = (targetSize.height*100)/self.size.height;
        float newWidth = (self.size.width*factor)/100;
        float newHeight = (self.size.height*factor)/100;
        
        CGSize newSize = CGSizeMake(newWidth, newHeight);
        UIGraphicsBeginImageContext(newSize);
        [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    }
    else if((self.size.height > targetSize.height || self.size.width > targetSize.width ) && self.size.width == self.size.height)
    {
        float factor = (targetSize.height*100)/self.size.height;
        float newDimension = (self.size.height*factor)/100;
        
        CGSize newSize = CGSizeMake(newDimension, newDimension);
        UIGraphicsBeginImageContext(newSize);
        [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    }
    else
    {
        CGSize newSize = CGSizeMake(self.size.width, self.size.height);
        UIGraphicsBeginImageContext(newSize);
        [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    }
    
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return returnImage;
}


- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    if([UIDevice isRetina])
    {
        CGSize retinaTargetSize = CGSizeMake(targetSize.width*2, targetSize.height*2);
        if(!CGSizeEqualToSize(imageSize, retinaTargetSize)) targetSize = retinaTargetSize;
    }
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if(CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor < heightFactor) scaleFactor = widthFactor;
        else scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if(widthFactor < heightFactor) thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        else if(widthFactor > heightFactor) thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
    }
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"Could not scale image");
    
    return newImage ;
}


- (UIImage *)imageByScalingToSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"Could not scale image");
    
    return newImage ;
}

- (BOOL)hasAlpha
{
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(self.CGImage);
    return (alpha == kCGImageAlphaFirst || alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst || alpha == kCGImageAlphaPremultipliedLast);
}

- (UIImage *)removeAlpha
{
    if(![self hasAlpha]) return self;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef mainViewContentContext = CGBitmapContextCreate(NULL, self.size.width, self.size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(mainViewContentContext, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
    CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    UIImage *returnImage = [UIImage imageWithCGImage:mainViewContentBitmapContext];
    CGImageRelease(mainViewContentBitmapContext);
    
    return returnImage;
}

- (UIImage *)fillAlpha
{
    CGRect im_r;
    im_r.origin = CGPointZero;
    im_r.size = self.size;
    
    UIGraphicsBeginImageContext(self.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context,im_r);
    [self drawInRect:im_r];
    
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return returnImage;
}

- (UIImage *)fillAlphaWithColor:(UIColor *)color
{
    CGRect im_r;
    im_r.origin = CGPointZero;
    im_r.size = self.size;
    
    CGColorRef cgColor = [color CGColor];
    
    UIGraphicsBeginImageContext(self.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, cgColor);
    CGContextFillRect(context,im_r);
    [self drawInRect:im_r];
    
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return returnImage;
}

- (BOOL)isGrayscale
{
    CGImageRef imgRef = [self CGImage];
    CGColorSpaceModel clrMod = CGColorSpaceGetModel(CGImageGetColorSpace(imgRef));
    
    switch(clrMod)
    {
        case kCGColorSpaceModelMonochrome :
            return YES;
        default:
            return NO;
    }
}

- (UIImage *)imageToGrayscale
{
    CGSize size = self.size;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil, size.width, size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, rect, [self CGImage]);
    CGImageRef grayscale = CGBitmapContextCreateImage(context);
    UIImage *returnImage = [UIImage imageWithCGImage:grayscale];
    CGContextRelease(context);
    CGImageRelease(grayscale);
    
    return returnImage;
}

- (UIImage *)imageToBlackAndWhite
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil, self.size.width, self.size.height, 8, self.size.width, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextSetShouldAntialias(context, NO);
    CGContextDrawImage(context, CGRectMake(0, 0, self.size.width, self.size.height), [self CGImage]);
    
    CGImageRef bwImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *returnImage = [UIImage imageWithCGImage:bwImage];
    CGImageRelease(bwImage);
    
    return returnImage;
}

- (UIImage *)invertColors
{
    UIGraphicsBeginImageContext(self.size);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeCopy);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeDifference);
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(),[UIColor whiteColor].CGColor);
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, self.size.width, self.size.height));
    
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return returnImage;
}

- (UIImage *)bloom:(float)radius
         intensity:(float)intensity
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *image = [CIImage imageWithCGImage:[self CGImage]];
    CIFilter *filter = [CIFilter filterWithName:@"CIBloom"];
    [filter setValue:image forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
    [filter setValue:[NSNumber numberWithFloat:intensity] forKey:@"inputIntensity"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[result extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    CFRelease(cgImage);
    
    return returnImage;
}

- (UIImage *)bumpDistortion:(CIVector *)center
                     radius:(float)radius
                      scale:(float)scale
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *image = [CIImage imageWithCGImage:[self CGImage]];
    CIFilter *filter = [CIFilter filterWithName:@"CIBumpDistortion"];
    [filter setValue:image forKey:kCIInputImageKey];
    [filter setValue:center forKey:@"inputCenter"];
    [filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
    [filter setValue:[NSNumber numberWithFloat:scale] forKey:@"inputScale"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[result extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    CFRelease(cgImage);
    
    return returnImage;
}

- (UIImage *)bumpDistortionLinear:(CIVector *)center
                           radius:(float)radius
                            angle:(float)angle
                            scale:(float)scale
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *image = [CIImage imageWithCGImage:[self CGImage]];
    CIFilter *filter = [CIFilter filterWithName:@"CIBumpDistortionLinear"];
    [filter setValue:image forKey:kCIInputImageKey];
    [filter setValue:center forKey:@"inputCenter"];
    [filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
    [filter setValue:[NSNumber numberWithFloat:angle] forKey:@"inputAngle"];
    [filter setValue:[NSNumber numberWithFloat:scale] forKey:@"inputScale"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[result extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    CFRelease(cgImage);
    
    return returnImage;
}

- (UIImage *)circleSplashDistortion:(CIVector *)center
                             radius:(float)radius
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *image = [CIImage imageWithCGImage:[self CGImage]];
    CIFilter *filter = [CIFilter filterWithName:@"CICircleSplashDistortion"];
    [filter setValue:image forKey:kCIInputImageKey];
    [filter setValue:center forKey:@"inputCenter"];
    [filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[result extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    CFRelease(cgImage);
    
    return returnImage;
}

- (UIImage *)circularWrap:(CIVector *)center
                   radius:(float)radius
                    angle:(float)angle
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *image = [CIImage imageWithCGImage:[self CGImage]];
    CIFilter *filter = [CIFilter filterWithName:@"CICircularWrap"];
    [filter setValue:image forKey:kCIInputImageKey];
    [filter setValue:center forKey:@"inputCenter"];
    [filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
    [filter setValue:[NSNumber numberWithFloat:angle] forKey:@"inputAngle"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[result extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    CFRelease(cgImage);
    
    return returnImage;
}

- (UIImage *)cmykHalftone:(CIVector *)center
                    width:(float)width
                    angle:(float)angle
                sharpness:(float)sharpness
                      gcr:(float)gcr
                      ucr:(float)ucr
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *image = [CIImage imageWithCGImage:[self CGImage]];
    CIFilter *filter = [CIFilter filterWithName:@"CICMYKHalftone"];
    [filter setValue:image forKey:kCIInputImageKey];
    [filter setValue:center forKey:@"inputCenter"];
    [filter setValue:[NSNumber numberWithFloat:width] forKey:@"inputWidth"];
    [filter setValue:[NSNumber numberWithFloat:angle] forKey:@"inputAngle"];
    [filter setValue:[NSNumber numberWithFloat:sharpness] forKey:@"inputSharpness"];
    [filter setValue:[NSNumber numberWithFloat:gcr] forKey:@"inputGCR"];
    [filter setValue:[NSNumber numberWithFloat:ucr] forKey:@"inputUCR"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[result extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    CFRelease(cgImage);
    
    return returnImage;
}

- (UIImage *)sepiaToneWithIntensity:(float)intensity
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *image = [CIImage imageWithCGImage:[self CGImage]];
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"];
    [filter setValue:image forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:intensity] forKey:@"inputIntensity"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[result extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    CFRelease(cgImage);
    
    return returnImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/*!
 *  图片背景颜色
 *
 *  @param color Color value
 *  @param size size
 *
 *  @return Return an UIImage instance
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height); UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext(); CGContextSetFillColorWithColor(context, [color CGColor]); CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext(); UIGraphicsEndImageContext();
    
    return image;
}

+ (instancetype)imageWithStretchableName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}

/*! 获得的就是一个圆形的图片 */
- (UIImage *)circleImage
{
    // 开始图形上下文
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    
    // 获得图形上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 设置一个范围
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    // 根据一个rect创建一个椭圆
    CGContextAddEllipseInRect(ctx, rect);
    
    // 裁剪
    CGContextClip(ctx);
    
    // 将原照片画到图形上下文
    [self drawInRect:rect];
    
    // 从上下文上获取剪裁后的照片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (instancetype)circleImageWithName:(NSString *)name borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor
{
    // 1.加载原图
    UIImage *oldImage = [UIImage imageNamed:name];
    
    // 2.开启上下文
    CGFloat imageW = oldImage.size.width + 2 * borderWidth;
    CGFloat imageH = oldImage.size.height + 2 * borderWidth;
    CGSize imageSize = CGSizeMake(imageW, imageH);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    
    // 3.取得当前的上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 4.画边框(大圆)
    [borderColor set];
    CGFloat bigRadius = imageW * 0.5; // 大圆半径
    CGFloat centerX = bigRadius; // 圆心
    CGFloat centerY = bigRadius;
    CGContextAddArc(ctx, centerX, centerY, bigRadius, 0, M_PI * 2, 0);
    CGContextFillPath(ctx); // 画圆
    
    // 5.小圆
    CGFloat smallRadius = bigRadius - borderWidth;
    CGContextAddArc(ctx, centerX, centerY, smallRadius, 0, M_PI * 2, 0);
    // 裁剪(后面画的东西才会受裁剪的影响)
    CGContextClip(ctx);
    
    // 6.画图
    [oldImage drawInRect:CGRectMake(borderWidth, borderWidth, oldImage.size.width, oldImage.size.height)];
    
    // 7.取图
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 8.结束上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}

/*! 加载最原始的图片，没有渲染 */
+ (instancetype)imageWithOriginalName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

/**
 *  图片的压缩方法
 *
 *  @param sourceImage   要被压缩的图片
 *  @param defineWidth 要被压缩的尺寸(宽)
 *
 *  @return 被压缩的图片
 */
+ (UIImage *)imgCompressed:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth
{
    
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(size);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        
        NSAssert(!newImage,@"图片压缩失败");
    }
    
    UIGraphicsEndImageContext();
    return newImage;
}

/**
 *  图片等比例压缩
 *
 *  @param sourceImage 要压缩的图片
 *  @param maxWidth    最大宽度
 *  @param maxHeight   最大高度
 *
 *  @return 压缩后的图片
 */
+ (UIImage *)imageCompressWithSourceImage:(UIImage *)sourceImage MaxWidth:(CGFloat)maxWidth MaxHeight:(CGFloat)maxHeight
{
    if (sourceImage.size.height>=maxHeight || sourceImage.size.width>=maxWidth) {
        
        double scaleH = 1.0;//高度压缩倍数
        if (sourceImage.size.height>maxHeight) {
            scaleH = maxHeight / sourceImage.size.height;
        }
        
        double scaleW = 1.0;//宽度压缩倍数
        if (sourceImage.size.width>maxWidth) {
            scaleW = maxWidth / sourceImage.size.width;
        }
        
        if (scaleH<scaleW) {//谁的倍数小用谁的
            maxHeight = scaleH * sourceImage.size.height;
            maxWidth = scaleH * sourceImage.size.width;
        }else{
            maxWidth = scaleW * sourceImage.size.width;
            maxHeight = scaleW * sourceImage.size.height;

        }
        
        return [self OriginImage:sourceImage scaleToSize:CGSizeMake(maxWidth, maxHeight)];
    }else{
        return sourceImage;
    }
}

+ (UIImage *)tg_blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
    if (image == nil) {
        return nil;
    }
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:ciImage forKey:kCIInputImageKey];
    //设置模糊程度
    [filter setValue:@(blur) forKey: @"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef outImage = [context createCGImage: result fromRect:ciImage.extent];
    UIImage * blurImage = [UIImage imageWithCGImage:outImage];
    CGImageRelease(outImage);
    return blurImage;
}


@end
