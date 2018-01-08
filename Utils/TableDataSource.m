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
        _propertyNames = [NSMutableArray array];
        Class cls = cellClass;
        while (cls) {
            unsigned int outCount = 0;
            objc_property_t *propertys = class_copyPropertyList(cls, &outCount);
            for (int i=0; i<outCount; i++) {
                objc_property_t property = propertys[i];
                const char *name = property_getName(property);
                if (!name) {
                    continue;
                }
                NSString *key = [NSString stringWithUTF8String:name];
                if (!key) {
                    continue;
                }
                if (![_propertyNames containsObject:key]) {
                    [_propertyNames addObject:key];
                }
            }
            free(propertys);
            cls = class_getSuperclass(cls);
        }
    }
    return self;
}
@end

@implementation TableDataSource
- (instancetype)init {
    if (self = [super init]) {
        _rows = @[@0];
        _headTitles = @[];
        _items = @[];
    }
    return self;
}

#pragma mark - private
- (NSUInteger)_indexAtIndexPath:(NSIndexPath *)indexPath {
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
            if ([item.propertyNames containsObject:key]) {
                [cell setValue:obj forKey:key];
            }
        }];
    }
}

#pragma mark - public
- (TableItem *)itemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = [self _indexAtIndexPath:indexPath];
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
    NSUInteger index = [self _indexAtIndexPath:indexPath];
    if (index == NSNotFound || index >= _items.count) {
        return;
    }
    NSMutableArray *items = [_items mutableCopy];
    items[index] = item;
    _items = [items copy];
}

- (void)deleteCellAtIndexPath:(NSIndexPath *)indexPath withAnimation:(UITableViewRowAnimation)animation {
    NSUInteger index = [self _indexAtIndexPath:indexPath];
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
    NSUInteger index = [self _indexAtIndexPath:indexPath];
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
    UITableViewCell *cell;
    if (item.identifier) {
        cell = [tableView dequeueReusableCellWithIdentifier:item.identifier];
        if (!cell) {
            [tableView registerNib:[UINib nibWithNibName:item.identifier bundle:nil] forCellReuseIdentifier:item.identifier];
            cell = [tableView dequeueReusableCellWithIdentifier:item.identifier];
        }
        [self _setItem:item toCell:cell];
    }
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












