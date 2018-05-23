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
- (instancetype)initWithCellClass:(Class)cellClass {
    if (self = [super init]) {
        _identifier = NSStringFromClass(cellClass);
        _cellClass = cellClass;
    }
    return self;
}
@end

@interface CollectDataSource ()
@property (nonatomic, assign) CFRunLoopRef runloop;
@property (nonatomic, assign) CFRunLoopObserverRef observer;
@property (nonatomic, strong) NSMutableDictionary<NSIndexPath *, void (^)(NSIndexPath *indexPath)> *setupCellHandlers;
@end

@implementation CollectDataSource
- (instancetype)init {
    if (self = [super init]) {
        _rows = @[];
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
            CollectDataSource *dataSource = (__bridge CollectDataSource *)(info);
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
            [cell setValue:obj forKeyPath:key];
        }];
    }
    cell.layer.drawsAsynchronously = YES;
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    cell.layer.opaque = YES;
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
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(item.cellClass) bundle:nil] forCellWithReuseIdentifier:item.identifier];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:item.identifier forIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
    _setupCellHandlers[indexPath] = ^(NSIndexPath *indexPath){
        CollectItem *item = [weakSelf itemAtIndexPath:indexPath];
        [weakSelf _setItem:item toCell:cell];
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(collectDataSource:withCell:cellForRowAtIndexPath:)]) {
            [weakSelf.delegate collectDataSource:weakSelf withCell:cell cellForRowAtIndexPath:indexPath];
        }
    };
    if (_delegate && [_delegate respondsToSelector:@selector(collectDataSource:withCell:cellForRowAtIndexPath:)]) {
        [_delegate collectDataSource:self withCell:cell cellForRowAtIndexPath:indexPath];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (_delegate && [_delegate respondsToSelector:@selector(collectDataSource:viewForSupplementaryElementOfKind:atIndexPath:)]) {
        [_delegate collectDataSource:self viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    }
    return nil;
}


@end







