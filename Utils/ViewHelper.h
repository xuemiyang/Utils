//
//  ViewHelper.h
//  yzyx
//
//  Created by xuemiyang on 2017/12/17.
//  Copyright © 2017年 TCLios2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TableDataSource.h"
#import "CollectDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ViewHelper <NSObject>
- (void)setupView;
@property (nonatomic, weak) UIViewController *context;
@end

@protocol ButtonHelper <ViewHelper>
@property (nonatomic, weak) UIButton *button;
@end

@protocol TableUIHelper <NSObject>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) TableDataSource *dataSource;
@end

@protocol TextFieldHelper <ViewHelper>
@property (nonatomic, weak) UITextField *textField;
@end

@interface TableViewHelper: NSObject <ViewHelper, UITableViewDelegate>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) id<TableItemsFactoryProtocol> itemsFactory;
@property (nonatomic, strong, readonly) TableDataSource *dataSource;
@property (nonatomic, copy) void (^tableViewDidSelect)(UITableView *tableView, NSIndexPath *indexPath, TableItem *item);
- (void)updateTableView;
- (void)updateDataSource;
- (void)setupTableUIHelper:(id<ViewHelper, TableUIHelper>)helper;
@end

@interface ListTableViewHelper: TableViewHelper
@property (nonatomic, assign, readonly) NSInteger pageNum;
/// handler(count) count load data count
@property (nonatomic, copy) void (^updateTableViewForPageNumber)(NSUInteger pageNo, void (^handler)(NSUInteger count));
- (void)reloadTableView;
@end

@interface CollectionViewHelper: NSObject <ViewHelper, UICollectionViewDelegateFlowLayout>
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) id<CollectionItemsFactoryProtocol> itemsFactory;
@property (nonatomic, strong, readonly) CollectDataSource *dataSource;
@property (nonatomic, copy) void (^collectionViewDidSelect)(UICollectionView *collectionView, NSIndexPath *indexPath, CollectItem *item);
- (void)updateCollectionView;
- (void)updateDataSource;
@end

@interface ListCollectionViewHelper: CollectionViewHelper
@property (nonatomic, assign, readonly) NSInteger pageNum;
/// handler(count) count load data count
@property (nonatomic, copy) void (^updateCollectionViewForPageNumber)(NSInteger pageNo, void (^handler)(NSUInteger count));
@end

NS_ASSUME_NONNULL_END









