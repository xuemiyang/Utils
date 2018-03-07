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
- (instancetype)xm_md5;
- (instancetype)xm_sha1;
- (instancetype)xm_sha256;
- (instancetype)xm_hmacWithKey:(NSString *)key;
+ (instancetype)xm_encryptedKeyUsingAES;
+ (instancetype)xm_encryptedKeyUsing3DES;/// 3DES
+ (instancetype)xm_encryptedKeyUsingMAC;
+ (instancetype)xm_encryptedKeyWithLength:(size_t)length;

- (CGSize)xm_size:(UIFont *)font;
- (CGSize)xm_size:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)mode;
- (CGFloat)xm_height:(UIFont *)font width:(CGFloat)width;
- (instancetype)xm_makeDotAppearOnce;
- (instancetype)xm_trim;
+ (instancetype)xm_nullString:(UIFont *)font width:(CGFloat)width;
@end

@interface UIColor (XM)
+ (instancetype)xm_rgb:(CGFloat)r g:(CGFloat)g b:(CGFloat)b;
+ (instancetype)xm_rgba:(CGFloat)r g:(CGFloat)g b:(CGFloat)b a:(CGFloat)a;
+ (instancetype)xm_hex:(NSString *)hex a:(CGFloat)a;
@end

@interface UIImage (XM)
+ (instancetype)xm_colorImage:(UIColor *)color size:(CGSize)size scale:(CGFloat)scale;
+ (instancetype)xm_QRImageWithString:(NSString *)string size:(CGSize)size;
+ (instancetype)xm_QRImageWithString:(NSString *)string size:(CGSize)size QRColor:(UIColor *)QRColor backgroundColor:(UIColor *)backgroundColor;
+ (instancetype)xm_gradientImageWithSize:(CGSize)size colors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;
+ (instancetype)xm_stretchedWithImageName:(NSString *)name;
- (instancetype)xm_stretched;
- (instancetype)xm_setColor:(UIColor *)color forBaseColor:(UIColor *)baseColor;
- (instancetype)xm_addWaterImage:(UIImage *)waterImage;
- (instancetype)xm_imageScaleMinBorderLength:(CGFloat)minBorderLength;
- (instancetype)xm_imageFixOrientation;
- (instancetype)xm_decodeImage;
- (instancetype)xm_imageRotatedByDegrees:(CGFloat)degrees;
- (instancetype)xm_imageByRoundCornerRadius:(CGFloat)radius;
- (instancetype)xm_imageByRoundCornerRadius:(CGFloat)radius
                                borderWidth:(CGFloat)borderWidth
                                borderColor:(UIColor * _Nullable)borderColor;
- (instancetype)xm_imageByRoundCornerRadius:(CGFloat)radius
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
+ (instancetype)xm_fontOfSize:(CGFloat)size;
+ (instancetype)xm_font1;
+ (instancetype)xm_font2;
+ (instancetype)xm_font3;
+ (instancetype)xm_font4;
+ (instancetype)xm_font5;
+ (instancetype)xm_font6;
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
+ (_Nullable instancetype)xm_subview:(Class)cls view:(UIView *)view;
- (_Nullable instancetype)xm_subview:(Class)cls;
+ (_Nullable instancetype)xm_superview:(Class)cls view:(UIView *)view;
- (_Nullable instancetype)xm_superview:(Class)cls;
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





