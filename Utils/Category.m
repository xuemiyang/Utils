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














