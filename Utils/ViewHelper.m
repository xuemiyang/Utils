//
//  ViewHelper.m
//  yzyx
//
//  Created by xuemiyang on 2017/12/17.
//  Copyright © 2017年 TCLios2. All rights reserved.
//

#import "ViewHelper.h"
#import "Category.h"
//#import <MJRefresh.h>

@implementation TableViewHelper
@synthesize context = _context;

- (instancetype)init {
    if (self = [super init]) {
        _dataSource = [[TableDataSource alloc] init];
    }
    return self;
}

- (void)setupView {
    if (_tableView.delegate == self) {
        return;
    }
    _tableView.dataSource = _dataSource;
    _tableView.delegate = self;
    _dataSource.rows = _itemsFactory.rows;
    _dataSource.items = _itemsFactory.items;
}

- (void)updateTableView {
    _dataSource.rows = _itemsFactory.rows;
    _dataSource.items = _itemsFactory.items;
    [_tableView reloadData];
}

- (void)updateDataSource {
    _dataSource.rows = _itemsFactory.rows;
    _dataSource.items = _itemsFactory.items;
}

- (void)setupTableUIHelper:(id<ViewHelper,TableUIHelper>)helper {
    helper.context = _context;
    helper.tableViewHelper = self;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableItem *item = [_dataSource itemAtIndexPath:indexPath];
    return item ? item.height : height(40);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_heightForHeaders && section < _heightForHeaders.count) {
        NSNumber *height = _heightForHeaders[section];
        if ([height isKindOfClass:[NSNumber class]]) {
            return height.doubleValue;
        }
    }
    if (_tableViewHeightForHeader) {
        return _tableViewHeightForHeader(tableView, section);
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (_heightForFooters && section < _heightForFooters.count) {
        NSNumber *height = _heightForFooters[section];
        if ([height isKindOfClass:[NSNumber class]]) {
            return height.doubleValue;
        }
    }
    if (_tableViewHeightForFooter) {
        return _tableViewHeightForFooter(tableView, section);
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (_viewForHeaderHandlers && section < _viewForHeaderHandlers.count) {
        UIView *(^handler)(UITableView *, NSInteger) = _viewForHeaderHandlers[section];
        if (![(id)handler isKindOfClass:[NSNull class]]) {
            return handler(tableView, section);
        }
    }
    if (_tableViewViewForHeader) {
        return _tableViewViewForHeader(tableView, section);
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (_viewForFooterHandlers && section < _viewForFooterHandlers.count) {
        UIView *(^handler)(UITableView *, NSInteger) = _viewForFooterHandlers[section];
        if (![(id)handler isKindOfClass:[NSNull class]]) {
            return handler(tableView, section);
        }
    }
    if (_tableViewViewForFooter) {
        return _tableViewViewForFooter(tableView, section);
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TableItem *item = [_dataSource itemAtIndexPath:indexPath];
    if (item) {
        if (_selectRowHandlers) {
            if (indexPath.section < _selectRowHandlers.count) {
                NSArray *sectionHandlers = _selectRowHandlers[indexPath.section];
                if (indexPath.row < sectionHandlers.count) {
                    void (^handler)(UITableView *, NSIndexPath *, TableItem *) = sectionHandlers[indexPath.row];
                    if (![(id)handler isKindOfClass:[NSNull class]]) {
                        handler(tableView, indexPath, item);
                    }
                }
            }
        } else if (_tableViewDidSelectRow) {
            _tableViewDidSelectRow(tableView, indexPath, item);
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_tableViewDidScroll) {
        _tableViewDidScroll((UITableView *)scrollView);
    }
}

@end

@interface ListTableViewHelper ()
@property (nonatomic, assign) NSInteger pageNum;
@end

@implementation ListTableViewHelper
- (instancetype)init {
    if (self = [super init]) {
        _pageNum = 1;
    }
    return self;
}

- (void)setupView {
    [super setupView];
//    __weak typeof(self) weakSelf = self;
//    MJRefreshHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        [weakSelf.tableView.mj_header endRefreshing];
//        weakSelf.pageNum = 1;
//        [weakSelf updateTableView];
//    }];
//    self.tableView.mj_header = header;
//    MJRefreshFooter *footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
//        [weakSelf.tableView.mj_footer endRefreshing];
//        [weakSelf updateTableView];
//    }];
//    self.tableView.mj_footer = footer;
}

- (void)reloadTableView {
    _pageNum = 1;
    [self updateTableView];
}

- (void)updateTableView {
    if (_updateTableViewForPageNumber) {
        __weak typeof(self) weakSelf = self;
        _updateTableViewForPageNumber(_pageNum, ^(NSUInteger count) {
            NSArray *rows = weakSelf.itemsFactory.rows;
            NSArray *items = weakSelf.itemsFactory.items;
            if (count <= 0) {
                if (items.count == 0) {
                    weakSelf.pageNum = 1;
                } else {
                    return ;
                }
            }
            weakSelf.dataSource.rows = rows;
            weakSelf.dataSource.items = items;
            weakSelf.pageNum += 1;
            [weakSelf.tableView reloadData];
        });
    }
}

@end


@implementation CollectionViewHelper
@synthesize context = _context;

- (instancetype)init {
    if (self = [super init]) {
        _dataSource = [[CollectDataSource alloc] init];
    }
    return self;
}

- (void)setupView {
    if (_collectionView.delegate == self) {
        return;
    }
    _collectionView.delegate = self;
    _collectionView.dataSource = _dataSource;
    _dataSource.rows = _itemsFactory.rows;
    _dataSource.items = _itemsFactory.items;
}

- (void)updateCollectionView {
    _dataSource.rows = _itemsFactory.rows;
    _dataSource.items = _itemsFactory.items;
    [_collectionView reloadData];
}

- (void)updateDataSource {
    _dataSource.rows = _itemsFactory.rows;
    _dataSource.items = _itemsFactory.items;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectItem *item = [_dataSource itemAtIndexPath:indexPath];
    if (item && _collectionViewDidSelectItem) {
        _collectionViewDidSelectItem(collectionView, indexPath, item);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectItem *item = [_dataSource itemAtIndexPath:indexPath];
    return  item ? item.size : CGSizeZero;
}


@end

@interface ListCollectionViewHelper ()
@property (nonatomic, assign) NSInteger pageNum;
@end

@implementation ListCollectionViewHelper
- (instancetype)init {
    if (self = [super init]) {
        _pageNum = 1;
    }
    return self;
}

- (void)setupView {
    [super setupView];
//    __weak typeof(self) weakSelf = self;
//    MJRefreshHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        [weakSelf.collectionView.mj_header endRefreshing];
//        weakSelf.pageNum = 1;
//        [weakSelf updateCollectionView];
//    }];
//    self.collectionView.mj_header = header;
//    MJRefreshFooter *footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
//        [weakSelf.collectionView.mj_footer endRefreshing];
//        [weakSelf updateCollectionView];
//    }];
//    self.collectionView.mj_footer = footer;
}

- (void)updateCollectionView {
    if (_updateCollectionViewForPageNumber) {
        __weak typeof(self) weakSelf = self;
        _updateCollectionViewForPageNumber(_pageNum, ^(NSUInteger count) {
            NSArray *rows = weakSelf.itemsFactory.rows;
            NSArray *items = weakSelf.itemsFactory.items;
            if (count <= 0) {
                if (items.count == 0) {
                    weakSelf.pageNum = 1;
                } else {
                    return ;
                }
            }
            weakSelf.dataSource.rows = rows;
            weakSelf.dataSource.items = items;
            weakSelf.pageNum += 1;
            [weakSelf.collectionView reloadData];
        });
    }
}

@end






