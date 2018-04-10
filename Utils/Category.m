//
//  Category.m
//  yzyx
//
//  Created by xuemiyang on 2017/12/16.
//  Copyright © 2017年 TCLios2. All rights reserved.
//

#import "Category.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (XM)
- (BOOL)xm_isNull {
    return !self || self.length == 0;
}

- (BOOL)xm_isPhone {
    if (self.length == 0) {
        return NO;
    }
    NSString *regex = @"^1[0-9]{10}$";
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

- (BOOL)xm_isEmail {
    if (self.length == 0) {
        return NO;
    }
    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [predicate evaluateWithObject:self];
}

- (NSString *)xm_urlEncodeString {
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"!*'\"();:@&=+$,/?%#[]% "];
    return [self stringByAddingPercentEncodingWithAllowedCharacters:characterSet] ?: self;
}

- (NSString *)xm_trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)_hashWithType:(NSInteger)type {
    const char *ptr = self.UTF8String;
    NSInteger bufferSize;
    switch (type) {
        case 0:
            // 16bytes
            bufferSize = CC_MD5_DIGEST_LENGTH;
            break;
        case 1:
            // 20bytes
            bufferSize = CC_SHA1_DIGEST_LENGTH;
            break;
        case 2:
            // 32bytes
            bufferSize = CC_SHA256_DIGEST_LENGTH;
            break;
        default:
            return nil;
            break;
    }
    
    Byte buffer[bufferSize];
    
    switch (type) {
        case 0:
            CC_MD5(ptr, (CC_LONG)strlen(ptr), buffer);
            break;
        case 1:
            CC_SHA1(ptr, (CC_LONG)strlen(ptr), buffer);
            break;
        case 2:
            CC_SHA256(ptr, (CC_LONG)strlen(ptr), buffer);
            break;
        default:
            return nil;
            break;
    }
    
    NSMutableString *hashString = [[NSMutableString alloc] initWithCapacity:2*bufferSize];
    for (int i=0; i<bufferSize; i++) {
        [hashString appendFormat:@"%02x", buffer[i]];
    }
    return hashString;
}

- (NSString *)xm_md5 {
    return [self _hashWithType:0];
}

- (NSString *)xm_sha1 {
    return [self _hashWithType:1];
}

- (NSString *)xm_sha256 {
    return [self _hashWithType:2];
}

- (NSString *)xm_hmacWithKey:(NSString *)key {
    const char *ptr = self.UTF8String;
    const char *keyPtr = key.UTF8String;
    
    Byte buffer[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, keyPtr, strlen(keyPtr), ptr, strlen(ptr), buffer);
    NSMutableString *hashString = [[NSMutableString alloc] initWithCapacity:2*CC_SHA256_DIGEST_LENGTH];
    for (int i=0; i<CC_SHA256_DIGEST_LENGTH; i++) {
        [hashString appendFormat:@"%02x", buffer[i]];
    }
    return hashString;
}

+ (NSString *)xm_encryptedKeyUsingMAC {
    return [self xm_encryptedKeyWithLength:kCCKeySizeAES128];
}

+ (NSString *)xm_encryptedKeyUsingAES {
    return [self xm_encryptedKeyWithLength:kCCKeySizeAES128];
}

+ (NSString *)xm_encryptedKeyUsing3DES {
    return [self xm_encryptedKeyWithLength:kCCKeySize3DES];
}

+ (NSString *)xm_encryptedKeyWithLength:(size_t)length {
    if (length == 0) {
        length = kCCKeySizeAES128;
    }
    Byte buffer[length];
    int result = SecRandomCopyBytes(kSecRandomDefault, length, buffer);
    if (result == noErr) {
        NSMutableString *key = [[NSMutableString alloc] initWithCapacity:2*length];
        for (int i=0; i<length; i++) {
            [key appendFormat:@"%02x", buffer[i]];
        }
        return key;
    }
    return nil;
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

- (NSString *)xm_makeDotAppearOnce {
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

+ (NSString *)xm_nullString:(UIFont *)font width:(CGFloat)width {
    CGFloat w = [@" " sizeWithAttributes:@{NSFontAttributeName:font}].width;
    NSInteger count = width / w + 1;
    NSString *str = @"";
    for (int i=0; i<count; i++) {
        str = [str stringByAppendingString:@" "];
    }
    return str;
}

size_t const kKeySize = kCCKeySizeAES128;

- (NSString * _Nullable)xm_decryptAESWithKey:(NSString *)key initVector:(NSString *)initVector {
    // 把 base64 String 转换成 Data
    NSData *contentData = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSUInteger dataLength = contentData.length;
    char keyPtr[kKeySize + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    size_t decryptSize = dataLength + kCCBlockSizeAES128;
    void *decryptedBytes = malloc(decryptSize);
    size_t actualOutSize = 0;
    NSData *initVectorData = [initVector dataUsingEncoding:NSUTF8StringEncoding];
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kKeySize,
                                          initVectorData.bytes,
                                          contentData.bytes,
                                          dataLength,
                                          decryptedBytes,
                                          decryptSize,
                                          &actualOutSize);
    if (cryptStatus == kCCSuccess) {
        return [[NSString alloc] initWithData:[NSData dataWithBytesNoCopy:decryptedBytes length:actualOutSize] encoding:NSUTF8StringEncoding];
    }
    free(decryptedBytes);
    return nil;
}

- (NSString * _Nullable)xm_encryptAESWithKey:(NSString *)key initVector:(NSString *)initVector {
    NSData *contentData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = contentData.length;
    // 为结束符'\\0' +1
    char keyPtr[kKeySize + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    // 密文长度 <= 明文长度 + BlockSize
    size_t encryptSize = dataLength + kCCBlockSizeAES128;
    void *encryptedBytes = malloc(encryptSize);
    size_t actualOutSize = 0;
    NSData *initVectorData = [initVector dataUsingEncoding:NSUTF8StringEncoding];
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding,  // 系统默认使用 CBC，然后指明使用 PKCS7Padding
                                          keyPtr,
                                          kKeySize,
                                          initVectorData.bytes,
                                          contentData.bytes,
                                          dataLength,
                                          encryptedBytes,
                                          encryptSize,
                                          &actualOutSize);
    if (cryptStatus == kCCSuccess) {
        // 对加密后的数据进行 base64 编码
        return [[NSData dataWithBytesNoCopy:encryptedBytes length:actualOutSize] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    free(encryptedBytes);
    return nil;
}

@end

@implementation UIColor (XM)
+ (UIColor *)xm_rgb:(CGFloat)r g:(CGFloat)g b:(CGFloat)b {
    return [self xm_rgba:r g:g b:b a:1];
}

+ (UIColor *)xm_rgba:(CGFloat)r g:(CGFloat)g b:(CGFloat)b a:(CGFloat)a {
    return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a];
}

+ (UIColor *)xm_hex:(NSString *)hex a:(CGFloat)a {
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
+ (UIImage *)xm_colorImage:(UIColor *)color size:(CGSize)size scale:(CGFloat)scale {
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)xm_QRImageWithString:(NSString *)string size:(CGSize)size {
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

+ (UIImage *)xm_QRImageWithString:(NSString *)string size:(CGSize)size QRColor:(UIColor *)QRColor backgroundColor:(UIColor *)backgroundColor {
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    [filter setDefaults];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    CIImage *image = [filter outputImage];
    return [self _hdImageWithCIImage:image size:size QRColor:QRColor backgroundColor:backgroundColor];
}

+ (UIImage *)_hdImageWithCIImage:(CIImage *)ciImage size:(CGSize)size {
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

+ (UIImage *)_hdImageWithCIImage:(CIImage *)ciImage size:(CGSize)size QRColor:(UIColor *)QRColor backgroundColor:(UIColor *)backgroundColor {
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

- (UIImage *)xm_addWaterImage:(UIImage *)waterImage {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, UIScreen.mainScreen.scale);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    
    [waterImage drawInRect:CGRectMake((self.size.width - waterImage.size.width) / 2, (self.size.height - waterImage.size.height) / 2, waterImage.size.width, waterImage.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)xm_imageScaleMinBorderLength:(CGFloat)minBorderLength {
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

- (UIImage *)xm_setColor:(UIColor *)color forBaseColor:(UIColor *)baseColor {
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

- (UIImage *)xm_imageFixOrientation {
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

- (UIImage *)xm_decodeImage {
    CGImageRef imageRef = self.CGImage;
    if (imageRef == NULL) {
        return nil;
    }
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst);
    CFRelease(colorSpace);
    if (context) {
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        CGImageRef imageRefExtended = CGBitmapContextCreateImage(context);
        CFRelease(context);
        if (imageRefExtended) {
            UIImage *image = [UIImage imageWithCGImage:imageRefExtended];
            CFRelease(imageRefExtended);
            return image;
        }
    }
    return nil;
}

- (UIImage *)xm_imageRotatedByDegrees:(CGFloat)degrees {
    
    CGFloat width = CGImageGetWidth(self.CGImage);
    CGFloat height = CGImageGetHeight(self.CGImage);
    
    CGSize rotatedSize;
    
    rotatedSize.width = width;
    rotatedSize.height = height;
    
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    CGContextRotateCTM(bitmap, degrees * M_PI / 180);
    CGContextRotateCTM(bitmap, M_PI);
    CGContextScaleCTM(bitmap, -1.0, 1.0);
    CGContextDrawImage(bitmap, CGRectMake(-rotatedSize.width/2, -rotatedSize.height/2, rotatedSize.width, rotatedSize.height), self.CGImage);
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)xm_gradientImageWithSize:(CGSize)size colors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    if (colors.count > 0 && locations.count > 0) {
        UIGraphicsBeginImageContext(size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGColorRef CGColors[colors.count];
        for (int i=0; i<colors.count; i++) {
            CGColors[i] = colors[i].CGColor;
        }
        CFArrayRef colorsRef = CFArrayCreate(CFAllocatorGetDefault(), (const void **)CGColors, colors.count, NULL);
        CGFloat locationsRef[locations.count];
        for (int i=0; i<locations.count; i++) {
            locationsRef[i] = locations[i].doubleValue;
        }
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpaceRef, colorsRef, locationsRef);
        CGPoint _startPoint_ = CGPointMake(startPoint.x * size.width, startPoint.y * size.height);
        CGPoint _endPoint_ = CGPointMake(endPoint.x * size.width, endPoint.y * size.height);
        CGContextDrawLinearGradient(context, gradient, _startPoint_, _endPoint_, kCGGradientDrawsBeforeStartLocation);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        CGGradientRelease(gradient);
        CFRelease(colorsRef);
        CGColorSpaceRelease(colorSpaceRef);
        UIGraphicsEndImageContext();
        return image;
    }
    return nil;
}

+ (UIImage *)xm_stretchedWithImageName:(NSString *)name {
    UIImage *image = [UIImage imageNamed:name];
    NSInteger leftCap = image.size.width * 0.5;
    NSInteger topCap = image.size.height * 0.5;
    return [image stretchableImageWithLeftCapWidth:leftCap topCapHeight:topCap];
}

- (UIImage *)xm_stretched {
    NSInteger leftCap = self.size.width * 0.5;
    NSInteger topCap = self.size.height * 0.5;
    return [self stretchableImageWithLeftCapWidth:leftCap topCapHeight:topCap];
}

- (UIImage *)xm_imageByRoundCornerRadius:(CGFloat)radius {
    return [self xm_imageByRoundCornerRadius:radius borderWidth:0 borderColor:nil];
}

- (UIImage *)xm_imageByRoundCornerRadius:(CGFloat)radius
                                borderWidth:(CGFloat)borderWidth
                                borderColor:(UIColor *)borderColor {
    return [self xm_imageByRoundCornerRadius:radius
                                     corners:UIRectCornerAllCorners
                                 borderWidth:borderWidth
                                 borderColor:borderColor
                              borderLineJoin:kCGLineJoinMiter];
}

- (UIImage *)xm_imageByRoundCornerRadius:(CGFloat)radius
                                    corners:(UIRectCorner)corners
                                borderWidth:(CGFloat)borderWidth
                                borderColor:(UIColor *)borderColor
                             borderLineJoin:(CGLineJoin)borderLineJoin {
    
    if (corners != UIRectCornerAllCorners) {
        UIRectCorner tmp = 0;
        if (corners & UIRectCornerTopLeft) tmp |= UIRectCornerBottomLeft;
        if (corners & UIRectCornerTopRight) tmp |= UIRectCornerBottomRight;
        if (corners & UIRectCornerBottomLeft) tmp |= UIRectCornerTopLeft;
        if (corners & UIRectCornerBottomRight) tmp |= UIRectCornerTopRight;
        corners = tmp;
    }
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -rect.size.height);
    
    CGFloat minSize = MIN(self.size.width, self.size.height);
    if (borderWidth < minSize / 2) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, borderWidth, borderWidth) byRoundingCorners:corners cornerRadii:CGSizeMake(radius, borderWidth)];
        [path closePath];
        
        CGContextSaveGState(context);
        [path addClip];
        CGContextDrawImage(context, rect, self.CGImage);
        CGContextRestoreGState(context);
    }
    
    if (borderColor && borderWidth < minSize / 2 && borderWidth > 0) {
        CGFloat strokeInset = (floor(borderWidth * self.scale) + 0.5) / self.scale;
        CGRect strokeRect = CGRectInset(rect, strokeInset, strokeInset);
        CGFloat strokeRadius = radius > self.scale / 2 ? radius - self.scale / 2 : 0;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:strokeRect byRoundingCorners:corners cornerRadii:CGSizeMake(strokeRadius, borderWidth)];
        [path closePath];
        
        path.lineWidth = borderWidth;
        path.lineJoinStyle = borderLineJoin;
        [borderColor setStroke];
        [path stroke];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

@implementation NSData (XM)
- (UIImage *)xm_decodeImage {
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)self, NULL);
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, 0, nil);
    CFRelease(source);
    if (imageRef == NULL) {
        return nil;
    }
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst);
    CFRelease(colorSpace);
    if (context) {
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        CFRelease(imageRef);
        CGImageRef imageRefExtended = CGBitmapContextCreateImage(context);
        CFRelease(context);
        if (imageRefExtended) {
            UIImage *image = [UIImage imageWithCGImage:imageRefExtended];
            CFRelease(imageRefExtended);
            return image;
        }
    }
    return nil;
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
+ (UIFont *)xm_fontOfSize:(CGFloat)size {
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

+ (UIFont *)xm_font1 {
    return [self xm_fontOfSize:17];
}

+ (UIFont *)xm_font2 {
    return [self xm_fontOfSize:16];
}

+ (UIFont *)xm_font3 {
    return [self xm_fontOfSize:15];
}

+ (UIFont *)xm_font4 {
    return [self xm_fontOfSize:14];
}

+ (UIFont *)xm_font5 {
    return [self xm_fontOfSize:13];
}

+ (UIFont *)xm_font6 {
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

+ (UIView *)xm_subview:(Class)cls view:(UIView *)view {
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

- (UIView *)xm_subview:(Class)cls {
    return [UIView xm_subview:cls view:self];
}

+ (UIView *)xm_superview:(Class)cls view:(UIView *)view {
    if ([view isKindOfClass:cls]) {
        return view;
    }
    UIView *superView = view.superview;
    if (superView) {
        return [self xm_superview:cls view:superView];
    }
    return nil;
}

- (UIView *)xm_superview:(Class)cls {
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














