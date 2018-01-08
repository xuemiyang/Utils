//
//  CollectDataSource.m
//  yzyx
//
//  Created by xuemiyang on 2017/12/20.
//  Copyright © 2017年 TCLios2. All rights reserved.
//

#import "CollectDataSource.h"
#import <objc/runtime.h>

@implementation CollectItem
- (instancetype)init {
    @throw [NSException exceptionWithName:@"CollectItem init error" reason:@"CollectItem must be initialized with a cellClass. Use 'initWithCellClass:' instead." userInfo:nil];
    return [self initWithCellClass:[UICollectionViewCell class]];
}

- (instancetype)initWithCellClass:(Class)cellClass {
    if (self = [super init]) {
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

@implementation CollectDataSource
- (instancetype)init {
    if (self = [super init]) {
        _rows = @[];
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

- (void)_setItem:(CollectItem *)item toCell:(UICollectionViewCell *)cell {
    if (item.extendDic && item.cellClass) {
        [item.extendDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([item.propertyNames containsObject:key]) {
                [cell setValue:obj forKey:key];
            }
        }];
    }
}

#pragma mark - public
- (CollectItem *)itemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = [self _indexAtIndexPath:indexPath];
    if (index == NSNotFound || index >= _items.count) {
        return nil;
    }
    return _items[index];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    _collectionView = collectionView;
    return _rows.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _rows[section].integerValue;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectItem *item = [self itemAtIndexPath:indexPath];
    [collectionView registerNib:[UINib nibWithNibName:item.identifier bundle:nil] forCellWithReuseIdentifier:item.identifier];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:item.identifier forIndexPath:indexPath];
    [self _setItem:item toCell:cell];
    if (_delegate && [_delegate respondsToSelector:@selector(collectDataSource:withCell:cellForRowAtIndexPath:)]) {
        [_delegate collectDataSource:self withCell:cell cellForRowAtIndexPath:indexPath];
    }
    return cell;
}


@end







