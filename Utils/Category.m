//
//  Category.m
//  yzyx
//
//  Created by xuemiyang on 2017/12/16.
//  Copyright © 2017年 TCLios2. All rights reserved.
//

#import "Category.h"

@implementation NSString (XM)
- (BOOL)xm_isNull {
    return !self || self.length == 0;
}

- (BOOL)xm_isPhone {
    if (self.length == 0) {
        return NO;
    }
    NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:self];
}

- (BOOL)xm_isNumberAndChar {
    if (self.length == 0) {
        return NO;
    }
    NSString *regex = @"(?!^[0-9]+$)(?!^[a-zA-Z]+$)[0-9a-zA-Z]{6}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:self];
}

- (NSString *)xm_urlEncodeString {
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"!*'\"();:@&=+$,/?%#[]% "];
    return [self stringByAddingPercentEncodingWithAllowedCharacters:characterSet] ?: self;
}

- (CGSize)xm_size:(UIFont *)font {
    return [self sizeWithAttributes:@{NSFontAttributeName:font}];
}

- (CGSize)xm_size:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)mode {
    return [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
}

- (CGFloat)xm_height:(UIFont *)font width:(CGFloat)width {
    return [self xm_size:font size:CGSizeMake(width, HUGE) mode:NSLineBreakByWordWrapping].height;
}

- (instancetype)xm_makeDotAppearOnce {
    NSRange range = [self rangeOfString:@"."];
    if (range.location != NSNotFound) {
        NSInteger startIndex = range.location + 1;
        range = [self rangeOfString:@"." options:NSCaseInsensitiveSearch range:NSMakeRange(startIndex, self.length - 1)];
        if (range.location != NSNotFound) {
            return [self substringWithRange:NSMakeRange(0, range.location)];
        }
    }
    return self;
}

+ (instancetype)xm_nullString:(UIFont *)font width:(CGFloat)width {
    CGFloat w = [@" " sizeWithAttributes:@{NSFontAttributeName:font}].width;
    NSInteger count = width / w + 1;
    NSString *str = @"";
    for (int i=0; i<count; i++) {
        str = [str stringByAppendingString:@" "];
    }
    return str;
}

@end

@implementation UIColor (XM)
+ (instancetype)xm_rgb:(CGFloat)r g:(CGFloat)g b:(CGFloat)b {
    return [self xm_rgba:r g:g b:b a:1];
}

+ (instancetype)xm_rgba:(CGFloat)r g:(CGFloat)g b:(CGFloat)b a:(CGFloat)a {
    return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a];
}

+ (instancetype)xm_hex:(NSString *)hex a:(CGFloat)a {
    hex = [hex stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].uppercaseString;
    UIColor *defaultColor = [UIColor clearColor];
    if (hex.length < 6) {
        return defaultColor;
    }
    if ([hex hasPrefix:@"#"]) {
        hex = [hex substringFromIndex:1];
    }
    if ([hex hasPrefix:@"0X"]) {
        hex = [hex substringFromIndex:2];
    }
    if (hex.length < 6) {
        return defaultColor;
    }
    NSScanner *scanner = [NSScanner scannerWithString:hex];
    uint32_t hexInt = 0;
    if (![scanner scanHexInt:&hexInt]) {
        return defaultColor;
    }
    if (hexInt > 0xffffff) {
        return defaultColor;
    }
    CGFloat r = (hexInt >> 16) & 0xff;
    CGFloat g = (hexInt >> 8) & 0xff;
    CGFloat b = hexInt & 0xff;
    return [self xm_rgba:r g:g b:b a:a];
}
@end


@implementation UIImage (XM)
+ (instancetype)xm_colorImage:(UIColor *)color size:(CGSize)size scale:(CGFloat)scale {
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (instancetype)xm_QRImageWithString:(NSString *)string size:(CGSize)size {
    /**
     "CIAttributeFilterAvailable_Mac" = "10.9";
     "CIAttributeFilterAvailable_iOS" = 7;
     CIAttributeFilterCategories =     (
        CICategoryGenerator,
        CICategoryStillImage,
        CICategoryBuiltIn
     );
     CIAttributeFilterDisplayName = "QRCode Generator";
     CIAttributeFilterName = CIQRCodeGenerator;
     CIAttributeReferenceDocumentation = "http://developer.apple.com/library/ios/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIQRCodeGenerator";
     inputCorrectionLevel =     {
        CIAttributeClass = NSString;
        CIAttributeDefault = M;
        CIAttributeDescription = "QRCode correction level L, M, Q, or H.";
        CIAttributeDisplayName = CorrectionLevel;
     };
     inputMessage =     {
        CIAttributeClass = NSData;
        CIAttributeDisplayName = Message;
     };
     */
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    [filter setDefaults];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    CIImage *image = [filter outputImage];
    return [self _hdImageWithCIImage:image size:size];
}

+ (instancetype)xm_QRImageWithString:(NSString *)string size:(CGSize)size QRColor:(UIColor *)QRColor backgroundColor:(UIColor *)backgroundColor {
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    [filter setDefaults];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    CIImage *image = [filter outputImage];
    return [self _hdImageWithCIImage:image size:size QRColor:QRColor backgroundColor:backgroundColor];
}

+ (instancetype)_hdImageWithCIImage:(CIImage *)ciImage size:(CGSize)size {
    CGRect extent = CGRectIntegral(ciImage.extent);
    CGFloat scale = MIN(size.width / extent.size.width, size.height / extent.size.height);
    size_t width = extent.size.width * scale;
    size_t height = extent.size.height * scale;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    CGImageRef cgImage = [[CIContext context] createCGImage:ciImage fromRect:extent];
    CGContextSetInterpolationQuality(bitmapContext, kCGInterpolationNone);
    CGContextScaleCTM(bitmapContext, scale, scale);
    CGContextDrawImage(bitmapContext, extent, cgImage);
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapContext);
    CGImageRelease(cgImage);
    CGContextRelease(bitmapContext);
    CGColorSpaceRelease(colorSpace);
    UIImage *image = [UIImage imageWithCGImage:scaledImage];
    return image;
}

+ (instancetype)_hdImageWithCIImage:(CIImage *)ciImage size:(CGSize)size QRColor:(UIColor *)QRColor backgroundColor:(UIColor *)backgroundColor {
    /**
     "CIAttributeFilterAvailable_Mac" = "10.4";
     "CIAttributeFilterAvailable_iOS" = 5;
     CIAttributeFilterCategories =     (
        CICategoryColorEffect,
        CICategoryVideo,
        CICategoryInterlaced,
        CICategoryNonSquarePixels,
        CICategoryStillImage,
        CICategoryBuiltIn
     );
     CIAttributeFilterDisplayName = "False Color";
     CIAttributeFilterName = CIFalseColor;
     CIAttributeReferenceDocumentation = "http://developer.apple.com/library/ios/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIFalseColor";
     inputColor0 =     {
        CIAttributeClass = CIColor;
        CIAttributeDefault = "(0.3 0 0 1) <CGColorSpace 0x1c00b6d40> (kCGColorSpaceDeviceRGB)";
        CIAttributeDescription = "The first color to use for the color ramp.";
        CIAttributeDisplayName = "Color 1";
        CIAttributeType = CIAttributeTypeColor;
     };
     inputColor1 =     {
        CIAttributeClass = CIColor;
        CIAttributeDefault = "(1 0.9 0.8 1) <CGColorSpace 0x1c00b6d40> (kCGColorSpaceDeviceRGB)";
        CIAttributeDescription = "The second color to use for the color ramp.";
        CIAttributeDisplayName = "Color 2";
        CIAttributeType = CIAttributeTypeColor;
     };
     inputImage =     {
        CIAttributeClass = CIImage;
        CIAttributeDescription = "The image to use as an input image. For filters that also use a background image, this is the foreground image.";
        CIAttributeDisplayName = Image;
        CIAttributeType = CIAttributeTypeImage;
     };
     */
    CIFilter *filter = [CIFilter filterWithName:@"CIFalseColor" keysAndValues:@"inputImage", ciImage, @"inputColor0", [CIColor colorWithCGColor:QRColor.CGColor], @"inputColor1", [CIColor colorWithCGColor:backgroundColor.CGColor], nil];
    CIImage *colorCIImage = [filter outputImage];
    CGImageRef cgImage = [[CIContext context] createCGImage:colorCIImage fromRect:CGRectIntegral(colorCIImage.extent)];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1, -1);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    return image;
}

- (instancetype)xm_addWaterImage:(UIImage *)waterImage {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, UIScreen.mainScreen.scale);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    
    [waterImage drawInRect:CGRectMake((self.size.width - waterImage.size.width) / 2, (self.size.height - waterImage.size.height) / 2, waterImage.size.width, waterImage.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (instancetype)xm_imageScaleMinBorderLength:(CGFloat)minBorderLength {
    CGSize size = CGSizeZero;
    if (self.size.width <= self.size.height) {
        size.width = minBorderLength;
        size.height = minBorderLength / self.size.width * self.size.height;
    } else {
        size.height = minBorderLength;
        size.width = minBorderLength / self.size.height * self.size.width;
    }
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (instancetype)xm_setColor:(UIColor *)color forBaseColor:(UIColor *)baseColor {
    size_t width = CGImageGetWidth(self.CGImage);
    size_t height = CGImageGetHeight(self.CGImage);
    size_t bytesPerRow = width * 4;
    uint32_t *rgbImageBuf = (uint32_t *)malloc(bytesPerRow * height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaNoneSkipFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), self.CGImage);
    size_t pixelNumber = width * height;
    uint32_t *p32 = rgbImageBuf;
    CGFloat r, g, b;
    [color getRed:&r green:&g blue:&b alpha:NULL];
    CGFloat br, bg, bb;
    [baseColor getRed:&br green:&bg blue:&bb alpha:NULL];
    uint32_t baseColorInt = (uint32_t)((((uint8_t)round(br * 255)) << 24) | (((uint8_t)round(bg * 255)) << 16) | (((uint8_t)round(bb * 255)) << 8));
    for (int i=0; i < pixelNumber; i++, p32++) {
        if ((*p32 & 0xffffff00) <= baseColorInt) {
            uint8_t *p8 = (uint8_t *)p32;
            p8[3] = b * 255;
            p8[2] = g * 255;
            p8[1] = r * 255;
        } else {
            uint8_t *p8 = (uint8_t *)p32;
            p8[0] = 0;
        }
    }
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow, dataProviderReleaseDataCallback);
    CGImageRef cgImage = CGImageCreate(width, height, 8, 32, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrderDefault, dataProvider, NULL, true, kCGRenderingIntentDefault);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CGImageRelease(cgImage);
    return image;
}

void dataProviderReleaseDataCallback(void * __nullable info,
                                     const void *  data, size_t size) {
    if (data) {
        free((void *)data);
    }
}

- (instancetype)xm_imageFixOrientation {
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp)
        return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


@end


@implementation UIScreen (XM)
+ (CGFloat)xm_width {
    return UIScreen.mainScreen.bounds.size.width;
}

+ (CGFloat)xm_height {
    return UIScreen.mainScreen.bounds.size.height;
}

+ (BOOL)xm_isIPhone320_480 {
    return [self xm_width] == 320 && [self xm_height] == 480;
}

+ (BOOL)xm_isIPhone320_568 {
    return [self xm_width] == 320 && [self xm_height] == 568;
}

+ (BOOL)xm_isIPhone375_667 {
    return [self xm_width] == 375 && [self xm_height] == 667;
}

+ (BOOL)xm_isIPhone414_736 {
    return [self xm_width] == 414 && [self xm_height] == 736;
}

+ (BOOL)xm_isIPhone375_812 {
    return [self xm_width] == 375 && [self xm_height] == 812;
}

@end

@implementation UIFont (XM)
+ (instancetype)xm_fontOfSize:(CGFloat)size {
    if ([UIScreen xm_isIPhone320_480]) {
        return [UIFont systemFontOfSize:size-1];
    }
    if ([UIScreen xm_isIPhone320_568]) {
        return [UIFont systemFontOfSize:size];
    }
    if ([UIScreen xm_isIPhone375_667]) {
        return [UIFont systemFontOfSize:size+1];
    }
    if ([UIScreen xm_isIPhone414_736]) {
        return [UIFont systemFontOfSize:size+2];
    }
    if ([UIScreen xm_isIPhone375_812]) {
        return [UIFont systemFontOfSize:size+1];
    }
    return [UIFont systemFontOfSize:size];
}

+ (instancetype)xm_font1 {
    return [self xm_fontOfSize:17];
}

+ (instancetype)xm_font2 {
    return [self xm_fontOfSize:16];
}

+ (instancetype)xm_font3 {
    return [self xm_fontOfSize:15];
}

+ (instancetype)xm_font4 {
    return [self xm_fontOfSize:14];
}

+ (instancetype)xm_font5 {
    return [self xm_fontOfSize:13];
}

+ (instancetype)xm_font6 {
    return [self xm_fontOfSize:12];
}

@end

@implementation UIView (XM)
- (CGFloat)xm_w {
    return self.frame.size.width;
}

- (void)setXm_w:(CGFloat)xm_w {
    CGRect frame = self.frame;
    frame.size.width = xm_w;
    self.frame = frame;
}

- (CGFloat)xm_h {
    return self.frame.size.height;
}

- (void)setXm_h:(CGFloat)xm_h {
    CGRect frame = self.frame;
    frame.size.height = xm_h;
    self.frame = frame;
}

- (CGFloat)xm_x {
    return self.frame.origin.x;
}

- (void)setXm_x:(CGFloat)xm_x {
    CGRect frame = self.frame;
    frame.origin.x = xm_x;
    self.frame = frame;
}

- (CGFloat)xm_y {
    return self.frame.origin.y;
}

- (void)setXm_y:(CGFloat)xm_y {
    CGRect frame = self.frame;
    frame.origin.y = xm_y;
    self.frame = frame;
}

- (CGFloat)xm_centerX {
    return self.center.x;
}

- (void)setXm_centerX:(CGFloat)xm_centerX {
    CGPoint center = self.center;
    center.x = xm_centerX;
    self.center = center;
}

- (CGFloat)xm_centerY {
    return self.center.y;
}

- (void)setXm_centerY:(CGFloat)xm_centerY {
    CGPoint center = self.center;
    center.y = xm_centerY;
    self.center = center;
}

- (CGPoint)xm_anchorPoint {
    return self.layer.anchorPoint;
}

- (void)setXm_anchorPoint:(CGPoint)xm_anchorPoint {
    CGPoint oldOrigin = self.frame.origin;
    self.layer.anchorPoint = xm_anchorPoint;
    CGPoint newOrigin = self.frame.origin;
    CGFloat transitionX = newOrigin.x - oldOrigin.x;
    CGFloat transitionY = newOrigin.y - oldOrigin.y;
    self.center = CGPointMake(self.center.x - transitionX, self.center.y - transitionY);
}

- (CGFloat)xm_cornerRadius {
    return self.layer.cornerRadius;
}

- (void)setXm_cornerRadius:(CGFloat)xm_cornerRadius {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = xm_cornerRadius;
}

+ (instancetype)xm_subview:(Class)cls view:(UIView *)view {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:cls]) {
            return subview;
        } else {
            UIView *v = [self xm_subview:cls view:subview];
            if (v) {
                return v;
            }
        }
    }
    return nil;
}

- (instancetype)xm_subview:(Class)cls {
    return [UIView xm_subview:cls view:self];
}

+ (instancetype)xm_superview:(Class)cls view:(UIView *)view {
    if ([view isKindOfClass:cls]) {
        return view;
    }
    UIView *superView = view.superview;
    if (superView) {
        return [self xm_superview:cls view:superView];
    }
    return nil;
}

- (instancetype)xm_superview:(Class)cls {
    return [UIView xm_superview:cls view:self];
}

- (UITableViewCell *)xm_tableViewCell {
    return (UITableViewCell *)[self xm_superview:[UITableViewCell class]];
}

- (UIImage *)xm_cutImage {
    UIImage *image;
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context) {
        [self.layer renderInContext:context];
        image = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    return image;
}

@end

@implementation UIApplication (XM)
+ (UIViewController *)xm_activityViewController {
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    if (window == nil || window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = UIApplication.sharedApplication.windows;
        for (UIWindow *w in windows) {
            if (w.windowLevel == UIWindowLevelNormal) {
                window = w;
                break;
            }
        }
    }
    if (!window) {
        return nil;
    }
    UIViewController *vc = window.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    if ([vc isKindOfClass:[UINavigationController class]]) {
        vc = ((UINavigationController *)vc).topViewController;
    }
    return vc;
}
@end

@implementation UINavigationController (XM)
- (void)xm_setBackIndicatorImage:(UIImage *)image {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width + 8, image.size.height), NO, 0);
    [image drawInRect:CGRectMake(8, 0, image.size.width, image.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.navigationBar.backIndicatorImage = newImage;
    self.navigationBar.backIndicatorTransitionMaskImage = newImage;
}
@end

@implementation NSBundle (XM)
- (NSString *)xm_bundleVersion {
    return self.infoDictionary[@"CFBundleShortVersionString"];
}

- (NSString *)xm_boundleBuildVersion {
    return self.infoDictionary[@"CFBundleVersion"];
}

@end














