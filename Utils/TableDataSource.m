   //
//  TableDataSource.m
//  yzyx
//
//  Created by xuemiyang on 2017/12/17.
//  Copyright © 2017年 TCLios2. All rights reserved.
//

#import "TableDataSource.h"
#import <objc/runtime.h>


@implementation TableItem 

- (instancetype)init {
    @throw [NSException exceptionWithName:@"TableItem init error" reason:@"TableItem must be initialized with a cellClass. Use 'initWithCellClass:' instead." userInfo:nil];
    return [self initWithCellClass:[UITableViewCell class]];
}

- (instancetype)initWithCellClass:(Class)cellClass {
    if (self = [super init]) {
        _accessoryType = UITableViewCellAccessoryNone;
        _height = 44;
        _identifier = NSStringFromClass(cellClass);
        _cellClass = cellClass;
    }
    return self;
}
@end

@interface TableDataSource ()
@property (nonatomic, assign) CFRunLoopRef runloop;
@property (nonatomic, assign) CFRunLoopObserverRef observer;
@property (nonatomic, strong) NSMutableDictionary<NSIndexPath *, void (^)(NSIndexPath *indexPath)> *setupCellHandlers;
@end

@implementation TableDataSource
- (instancetype)init {
    if (self = [super init]) {
        _rows = @[@0];
        _headTitles = @[];
        _items = @[];
        _setupCellHandlers = [NSMutableDictionary dictionary];
        if ([NSThread isMainThread]) {
            [self _addRunLoopObserver];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _addRunLoopObserver];
            });
        }
    }
    return self;
}

- (NSUInteger)indexAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= _rows.count) {
        return NSNotFound;
    }
    NSUInteger index = 0;
    for (int i=0; i<indexPath.section; i++) {
        index += _rows[i].integerValue;
    }
    index += indexPath.row;
    return index;
}

- (void)dealloc {
    CFRunLoopRemoveObserver(_runloop, _observer, kCFRunLoopCommonModes);
    CFRelease(_observer);
    _runloop = NULL;
}

#pragma mark - private
- (void)_addRunLoopObserver {
    @autoreleasepool {
        CFRunLoopRef runloop = CFRunLoopGetCurrent();
        _runloop = runloop;
        CFRunLoopObserverContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
        CFRunLoopObserverRef observer = CFRunLoopObserverCreate(NULL, kCFRunLoopBeforeWaiting, true, 0, observeCallback, &context);
        _observer = observer;
        CFRunLoopAddObserver(runloop, observer, kCFRunLoopCommonModes);
    }
}

static void observeCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    switch (activity) {
        case kCFRunLoopBeforeWaiting: {
            if (info == NULL) {
                return;
            }
            TableDataSource *dataSource = (__bridge TableDataSource *)(info);
            if (dataSource.setupCellHandlers.count == 0) {
                return;
            }
            [dataSource.setupCellHandlers enumerateKeysAndObjectsUsingBlock:^(NSIndexPath * _Nonnull key, void (^ _Nonnull obj)(NSIndexPath *), BOOL * _Nonnull stop) {
                @autoreleasepool {
                    obj(key);
                }
            }];
            [dataSource.setupCellHandlers removeAllObjects];
        }
            break;
        default:
            break;
    }
}

- (void)_setItem:(TableItem *)item toCell:(UITableViewCell *)cell {
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = item.detail;
    if (item.titleColor) {
        cell.textLabel.textColor = item.titleColor;
    }
    if (item.detailColor) {
        cell.detailTextLabel.textColor = item.detailColor;
    }
    if (item.detailAttributedString) {
        cell.detailTextLabel.attributedText = item.detailAttributedString;
    }
    if (item.accessoryView) {
        cell.accessoryView = item.accessoryView();
    } else {
        cell.accessoryType = item.accessoryType;
    }
    cell.imageView.image = item.image;
    if (item.extendDic && item.cellClass) {
        [item.extendDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [cell setValue:obj forKeyPath:key];
        }];
    }
    cell.layer.drawsAsynchronously = YES;
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    cell.layer.opaque = YES;
}

#pragma mark - public
- (TableItem *)itemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = [self indexAtIndexPath:indexPath];
    if (index == NSNotFound || index >= _items.count) {
        return nil;
    }
    return _items[index];
}

- (NSArray<TableItem *> *)itemsAtSection:(NSUInteger)section {
    if (section >= _rows.count) {
        return @[];
    }
    NSUInteger index = 0;
    for (int i=0; i<section; i++) {
        index += _rows[i].integerValue;
    }
    NSRange range = NSMakeRange(index, _rows[section].integerValue);
    return [_items subarrayWithRange:range];
}

- (NSArray<TableItem *> *)itemsAtSection:(NSUInteger)section inRange:(NSRange)range {
    if (section >= _rows.count || range.length == 0 || range.location >= _rows[section].integerValue || range.location + range.length >= _rows[section].integerValue) {
        return @[];
    }
    NSUInteger index = 0;
    for (int i=0; i<section; i++) {
        index += _rows[i].integerValue;
    }
    range = NSMakeRange(range.location + index, range.length);
    return [_items subarrayWithRange:range];
}

- (void)setItem:(TableItem *)item atIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = [self indexAtIndexPath:indexPath];
    if (index == NSNotFound || index >= _items.count) {
        return;
    }
    NSMutableArray *items = [_items mutableCopy];
    items[index] = item;
    _items = [items copy];
}

- (void)deleteCellAtIndexPath:(NSIndexPath *)indexPath withAnimation:(UITableViewRowAnimation)animation {
    NSUInteger index = [self indexAtIndexPath:indexPath];
    if (index == NSNotFound || index >= _items.count) {
        return;
    }
    NSMutableArray *items = [_items mutableCopy];
    [items removeObjectAtIndex: index];
    _items = [items copy];
    NSMutableArray<NSNumber *> *rows = [_rows mutableCopy];
    rows[indexPath.section] = @(rows[indexPath.section].integerValue - 1);
    _rows = [rows copy];
    [_tableView beginUpdates];
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
    [_tableView endUpdates];
}

- (void)deleteCellAtSection:(NSUInteger)section withAnimation:(UITableViewRowAnimation)animation {
    if (section >= _rows.count) {
        return;
    }
    NSUInteger index = 0;
    for (int i=0; i<section; i++) {
        index += _rows[i].integerValue;
    }
    NSMutableArray *items = [_items mutableCopy];
    [items removeObjectsInRange:NSMakeRange(index, _rows[section].integerValue)];
    _items = [items copy];
    NSMutableArray *rows = [_rows mutableCopy];
    [rows removeObjectAtIndex:section];
    _rows = [rows copy];
    [_tableView beginUpdates];
    [_tableView deleteSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:animation];
    [_tableView endUpdates];
}

- (void)deleteCellAtSection:(NSUInteger)section inRange:(NSRange)range withAnimation:(UITableViewRowAnimation)animation {
    if (section >= _rows.count || range.length + range.location > _rows[section].integerValue) {
        return;
    }
    NSUInteger index = 0;
    for (int i=0; i<section; i++) {
        index += _rows[i].integerValue;
    }
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:range.length];
    for (int i=0; i<range.length; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i + range.location inSection:section]];
    }
    NSMutableArray *items = [_items mutableCopy];
    [items removeObjectsInRange:NSMakeRange(index + range.location, range.length)];
    _items = [items copy];
    NSMutableArray<NSNumber *> *rows = [_rows mutableCopy];
    rows[section] =  @(rows[section].integerValue - range.length);
    _rows = [rows copy];
    [_tableView beginUpdates];
    [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [_tableView endUpdates];
}

- (void)appendCellAtSection:(NSUInteger)section withItems:(NSArray<TableItem *> *)items withAnimation:(UITableViewRowAnimation)animation {
    if (section >= _rows.count) {
        return;
    }
    NSUInteger index = 0;
    for (int i=0; i<section; i++) {
        index += _rows[i].integerValue;
    }
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:items.count];
    for (int i=0; i<items.count; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    NSMutableArray *__items = [_items mutableCopy];
    [__items insertObjects:items atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, items.count)]];
    _items = [__items copy];
    NSMutableArray<NSNumber *> *rows = [_rows mutableCopy];
    rows[section] = @(rows[section].integerValue + items.count);
    _rows = [rows copy];
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [_tableView endUpdates];
}

- (void)insertCellAtIndexPath:(NSIndexPath *)indexPath withItem:(TableItem *)item withAnimation:(UITableViewRowAnimation)animation {
    NSUInteger index = [self indexAtIndexPath:indexPath];
    if (index == NSNotFound || index >= _items.count) {
        return;
    }
    NSMutableArray *items = [_items mutableCopy];
    [items insertObject:item atIndex:index];
    _items = [items copy];
    NSMutableArray<NSNumber *> *rows = [_rows mutableCopy];
    rows[indexPath.section] = @(rows[indexPath.section].integerValue + 1);
    _rows = [rows copy];
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
    [_tableView endUpdates];
}

- (void)insertCellAtSection:(NSUInteger)section withItems:(NSArray<TableItem *> *)items withAnimation:(UITableViewRowAnimation)animation {
    if (section >= _rows.count) {
        return;
    }
    NSUInteger index = 0;
    for (int i=0; i<section; i++) {
        index += _rows[i].integerValue;
    }
    NSMutableArray *__items = [_items mutableCopy];
    [__items insertObjects:items atIndexes:[NSIndexSet indexSetWithIndex:index]];
    _items = [__items copy];
    NSMutableArray<NSNumber *> *rows = [_rows mutableCopy];
    [rows insertObject:@(items.count) atIndex:section];
    _rows = [rows copy];
    [_tableView beginUpdates];
    [_tableView insertSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:animation];
    [_tableView endUpdates];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    _tableView = tableView;
    return _rows.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _rows[section].integerValue;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableItem *item = [self itemAtIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item.identifier];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:NSStringFromClass(item.cellClass) bundle:nil] forCellReuseIdentifier:item.identifier];
        cell = [tableView dequeueReusableCellWithIdentifier:item.identifier];
    }
    __weak typeof(self) weakSelf = self;
    _setupCellHandlers[indexPath] = ^(NSIndexPath *indexPath){
        TableItem *item = [weakSelf itemAtIndexPath:indexPath];
        [weakSelf _setItem:item toCell:cell];
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(tableDataSource:withCell:cellForRowAtIndexPath:)]) {
            [weakSelf.delegate tableDataSource:weakSelf withCell:cell cellForRowAtIndexPath:indexPath];
        }
    };
    cell.imageView.image = item.image;
    if (_delegate && [_delegate respondsToSelector:@selector(tableDataSource:withCell:cellForRowAtIndexPath:)]) {
        [_delegate tableDataSource:self withCell:cell cellForRowAtIndexPath:indexPath];
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section >= _headTitles.count) {
        return nil;
    }
    return _headTitles[section];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_delegate && [_delegate respondsToSelector:@selector(tableDataSource:canEditRowAtIndexPath:)]) {
        return [_delegate tableDataSource:self canEditRowAtIndexPath:indexPath];
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_delegate && [_delegate respondsToSelector:@selector(tableDataSource:commitEditingStyle:forRowAtIndexPath:)]) {
        [_delegate tableDataSource:self commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

@end












