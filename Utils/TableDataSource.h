//
//  TableDataSource.h
//  yzyx
//
//  Created by xuemiyang on 2017/12/17.
//  Copyright © 2017年 TCLios2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TableItem: NSObject
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign, readonly) Class cellClass;
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, strong, nullable) UIColor *titleColor;
@property (nonatomic, copy, nullable) NSString *detail;
@property (nonatomic, strong, nullable) UIColor *detailColor;
@property (nonatomic, strong, nullable) NSAttributedString *detailAttributedString;
@property (nonatomic, assign) UITableViewCellAccessoryType accessoryType;
@property (nonatomic, copy, nullable) UIView *(^accessoryView)(void);
/// default value 44
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong, nullable) NSMutableDictionary<NSString *, id> *extendDic;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithCellClass:(Class)cellClass;
@end

@protocol TableItemsFactoryProtocol <NSObject>
@property (nonatomic, strong, readonly) NSArray<TableItem *> *items;
@property (nonatomic, strong, readonly) NSArray<NSNumber *> *rows;
@property (nonatomic, strong, readonly) NSArray<NSString *> *headTitle;
@end

@class TableDataSource;
@protocol TableDataSourceDelegate <NSObject>
@required
- (void)tableDataSource:(TableDataSource *)dataSource withCell:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (BOOL)tableDataSource:(TableDataSource *)dataSource canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableDataSource:(TableDataSource *)dataSource commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface TableDataSource : NSObject <UITableViewDataSource>
@property (nonatomic, strong) NSArray<NSNumber *> *rows;
@property (nonatomic, strong) NSArray<NSString *> *headTitles;
@property (nonatomic, strong) NSArray<TableItem *> *items;
@property (nonatomic, weak, nullable) id<TableDataSourceDelegate> delegate;
@property (nonatomic, weak, readonly) UITableView *tableView;
- (NSUInteger)indexAtIndexPath:(NSIndexPath *)indexPath;
- (TableItem * _Nullable)itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray<TableItem *> *)itemsAtSection:(NSUInteger)section;
- (NSArray<TableItem *> *)itemsAtSection:(NSUInteger)section inRange:(NSRange)range;
- (void)setItem:(TableItem *)item atIndexPath:(NSIndexPath *)indexPath;
- (void)deleteCellAtIndexPath:(NSIndexPath *)indexPath withAnimation:(UITableViewRowAnimation)animation;
- (void)deleteCellAtSection:(NSUInteger)section withAnimation:(UITableViewRowAnimation)animation;
- (void)deleteCellAtSection:(NSUInteger)section inRange:(NSRange)range withAnimation:(UITableViewRowAnimation)animation;
- (void)appendCellAtSection:(NSUInteger)section withItems:(NSArray<TableItem *> *)items withAnimation:(UITableViewRowAnimation)animation;
- (void)insertCellAtIndexPath:(NSIndexPath *)indexPath withItem:(TableItem *)item withAnimation:(UITableViewRowAnimation)animation;
- (void)insertCellAtSection:(NSUInteger)section withItems:(NSArray<TableItem *> *)items withAnimation:(UITableViewRowAnimation)animation;
@end

NS_ASSUME_NONNULL_END







