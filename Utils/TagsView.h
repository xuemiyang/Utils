//
//  TagsView.h
//  yzyx
//
//  Created by xuemiyang on 2017/12/20.
//  Copyright © 2017年 TCLios2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TagsView;
@protocol TagsViewDelegate <NSObject>
@optional
- (void)tagsView:(TagsView *)tagsView didSelectTextInIndex:(NSInteger)index atText:(NSString *)text withView:(UIView * _Nullable)view;
- (void)tagsViewWillBeginDragging:(TagsView *)tagsView;
- (void)tagsViewDidEndDeceleratingAndScrollingAnimationEnd:(TagsView *)tagsView;
@end

@protocol TagViewController <NSObject>
- (void)setup;
@end

@interface RoundCountView: UIView
/// default red color
@property (nonatomic, strong) UIColor *color;
/// default value
@property (nonatomic, strong) NSDictionary *attrbutes;
@property (nonatomic, assign) NSInteger count;
@end

@interface TagsView : UIScrollView 
@property (nonatomic, strong) NSArray<NSString *> *texts;
/// default value 1
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat lineLengthExtend;
@property (nonatomic, strong) UIColor *lineColor;
/// option
@property (nonatomic, strong, nullable) NSArray<UIColor *> *lineColors;
@property (nonatomic, strong) NSDictionary *textNormalFontAttribute;
@property (nonatomic, strong) NSDictionary *textSelectFontAttribute;
/// option
@property (nonatomic, strong, nullable) NSArray<NSDictionary *> *textSelectFontAttributes;
/// option, bottom scrollView
@property (nonatomic, weak, nullable) UIScrollView *scrollView;
/// option, bottom views at scrollView
@property (nonatomic, strong, nullable) NSArray<NSValue *> *views;
@property (nonatomic, weak, nullable) id<TagsViewDelegate> tagDelegate;
@property (nonatomic, assign, readonly) NSInteger currenIndex;
- (void)setup;
- (void)selectTagAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)setCount:(NSUInteger)count atIndex:(NSUInteger)index;
@end

NS_ASSUME_NONNULL_END





