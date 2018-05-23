//
//  Category.h
//  yzyx
//
//  Created by xuemiyang on 2017/12/16.
//  Copyright © 2017年 TCLios2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (XM)
@property (nonatomic, assign, readonly) BOOL xm_isNull;
@property (nonatomic, assign, readonly) BOOL xm_isPhone;
@property (nonatomic, assign, readonly) BOOL xm_isNumberAndChar;
@property (nonatomic, assign, readonly) BOOL xm_isEmail;
@property (nonatomic, copy, readonly) NSString *xm_urlEncodeString;
- (NSString *)xm_md5;
- (NSString *)xm_sha1;
- (NSString *)xm_sha256;
- (NSString *)xm_hmacWithKey:(NSString *)key;
+ (NSString *)xm_encryptedKeyUsingAES;
+ (NSString *)xm_encryptedKeyUsing3DES;/// 3DES
+ (NSString *)xm_encryptedKeyUsingMAC;
+ (NSString *)xm_encryptedKeyWithLength:(size_t)length;
- (NSString * _Nullable)xm_decryptAESWithKey:(NSString *)key initVector:(NSString *)initVector;
- (NSString * _Nullable)xm_encryptAESWithKey:(NSString *)key initVector:(NSString *)initVector;

- (CGSize)xm_size:(UIFont *)font;
- (CGSize)xm_size:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)mode;
- (CGFloat)xm_height:(UIFont *)font width:(CGFloat)width;
- (NSString *)xm_makeDotAppearOnce;
- (NSString *)xm_trim;
+ (NSString *)xm_nullString:(UIFont *)font width:(CGFloat)width;
@end

@interface UIColor (XM)
+ (UIColor *)xm_rgb:(CGFloat)r g:(CGFloat)g b:(CGFloat)b;
+ (UIColor *)xm_rgba:(CGFloat)r g:(CGFloat)g b:(CGFloat)b a:(CGFloat)a;
+ (UIColor *)xm_hex:(NSString *)hex a:(CGFloat)a;
@end

@interface UIImage (XM)
+ (UIImage *)xm_colorImage:(UIColor *)color size:(CGSize)size scale:(CGFloat)scale;
+ (UIImage *)xm_QRImageWithString:(NSString *)string size:(CGSize)size;
+ (UIImage *)xm_QRImageWithString:(NSString *)string size:(CGSize)size QRColor:(UIColor *)QRColor backgroundColor:(UIColor *)backgroundColor;
+ (UIImage *)xm_gradientImageWithSize:(CGSize)size colors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;
+ (UIImage *)xm_stretchedWithImageName:(NSString *)name;
- (UIImage *)xm_stretched;
- (UIImage *)xm_setColor:(UIColor *)color forBaseColor:(UIColor *)baseColor;
- (UIImage *)xm_addWaterImage:(UIImage *)waterImage;
- (UIImage *)xm_imageScaleMinBorderLength:(CGFloat)minBorderLength;
- (UIImage *)xm_imageFixOrientation;
- (UIImage *)xm_decodeImage;
- (UIImage *)xm_imageRotatedByDegrees:(CGFloat)degrees;
- (UIImage *)xm_imageByRoundCornerRadius:(CGFloat)radius;
- (UIImage *)xm_imageByRoundCornerRadius:(CGFloat)radius
                                borderWidth:(CGFloat)borderWidth
                                borderColor:(UIColor * _Nullable)borderColor;
- (UIImage *)xm_imageByRoundCornerRadius:(CGFloat)radius
                                    corners:(UIRectCorner)corners
                                borderWidth:(CGFloat)borderWidth
                                borderColor:(UIColor * _Nullable)borderColor
                             borderLineJoin:(CGLineJoin)borderLineJoin;
@end

@interface NSData (XM)
- (UIImage *)xm_decodeImage;
@end

@interface UIScreen (XM)
+ (CGFloat)xm_width;
+ (CGFloat)xm_height;
+ (BOOL)xm_isIPhone320_480;
+ (BOOL)xm_isIPhone320_568;
+ (BOOL)xm_isIPhone375_667;
+ (BOOL)xm_isIPhone414_736;
+ (BOOL)xm_isIPhone375_812;
@end

CG_INLINE CGFloat width(CGFloat w) {
    if ([UIScreen xm_isIPhone320_480]) {
        return floor(w);
    }
    if ([UIScreen xm_isIPhone320_568]) {
        return floor(w);
    }
    if ([UIScreen xm_isIPhone375_667]) {
        return floor(w / 320.0 * 375.0);
    }
    if ([UIScreen xm_isIPhone414_736]) {
        return floor(w / 320.0 * 414.0);
    }
    if ([UIScreen xm_isIPhone375_812]) {
        return floor(w / 320.0 * 375.0);
    }
    return floor(w);
}

CG_INLINE CGFloat height(CGFloat h) {
    if ([UIScreen xm_isIPhone320_480]) {
        return floor(h / 568.0 * 480.0);
    }
    if ([UIScreen xm_isIPhone320_568]) {
        return floor(h);
    }
    if ([UIScreen xm_isIPhone375_667]) {
        return floor(h / 568.0 * 667.0);
    }
    if ([UIScreen xm_isIPhone414_736]) {
        return floor(h / 568.0 * 736.0);
    }
    if ([UIScreen xm_isIPhone375_812]) {
        return floor(h / 568.0 * 734.0);
    }
    return floor(h);
}

@interface UIFont (XM)
+ (UIFont *)xm_fontOfSize:(CGFloat)size;
+ (UIFont *)xm_font1;
+ (UIFont *)xm_font2;
+ (UIFont *)xm_font3;
+ (UIFont *)xm_font4;
+ (UIFont *)xm_font5;
+ (UIFont *)xm_font6;
@end


@interface UIView (XM)
@property (nonatomic, assign) CGFloat xm_w;
@property (nonatomic, assign) CGFloat xm_h;
@property (nonatomic, assign) CGFloat xm_x;
@property (nonatomic, assign) CGFloat xm_y;
@property (nonatomic, assign) CGFloat xm_centerX;
@property (nonatomic, assign) CGFloat xm_centerY;
@property (nonatomic, assign) CGPoint xm_anchorPoint;
@property (nonatomic, assign) CGFloat xm_cornerRadius;
+ (UIView * _Nullable)xm_subview:(Class)cls view:(UIView *)view;
- (UIView * _Nullable)xm_subview:(Class)cls;
+ (UIView * _Nullable)xm_superview:(Class)cls view:(UIView *)view;
- (UIView * _Nullable)xm_superview:(Class)cls;
@property (nonatomic, weak, nullable, readonly) UITableViewCell *xm_tableViewCell;
@property (nonatomic, strong, nullable, readonly) UIImage * xm_cutImage;
@end

@interface UIApplication (XM)
+ (UIViewController * _Nullable)xm_activityViewController;
@end

@interface UINavigationController (XM)
- (void)xm_setBackIndicatorImage:(UIImage *)image;
@end

@interface NSBundle (XM)
@property (nonatomic, copy, readonly, nullable) NSString *xm_bundleVersion;
@property (nonatomic, copy, readonly, nullable) NSString *xm_boundleBuildVersion;
@end


NS_ASSUME_NONNULL_END





