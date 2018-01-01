# Utils
iOS项目工具类集合。

* TableDataSource  一个TableView的数据源封装类。
* CollectDataSource  一个CollectionView的数据源封装类。
* TagsView  一个Android风格的顶部标签切换视图封装类。
* Category  iOS项目中常用的分类集合。
* ViewHelper  视图帮助类的抽象集合。

## TableDataSource
### 1. 使用实现协议<TableItemsFactoryProtocol>的TableItem工厂类创建TableItem。
```objc
@interface MyTableItemsFactory : NSObject <TableItemsFactoryProtocol>

@end

@implementation MyTableItemsFactory
- (NSArray<NSString *> *)headTitle {
    return @[@"headTitle1",@"headTitle2",@"headTitle3"];
}

- (NSArray<NSNumber *> *)rows {
    /// 每个数字代表section的row的数量。array的个数代表section的数量
    return @[@1,@1,@1];
}

- (NSArray<TableItem *> *)items {
    NSMutableArray<TableItem *> *items = [NSMutableArray arrayWithCapacity:3];
    TableItem *item = [[TableItem alloc] initWithCellClass:[SomeTableViewCell class]];
    // 设置TableViewCell的左边图片视图的图片。
    item.image = [UIImage imageNamed:@"imageName"];
    // 设置TableViewCell的标题。
    item.title = @"someTitle";
    // 设置TableViewCell的标题颜色。
    item.titleColor = someColor;
    // 设置TableViewCell的详情文本。
    item.detail = @"someDetail";
    // 设置TableViewCell的详情文本颜色。
    item.detailColor = someColor;
    // 设置TableViewCell的accessoryType
    item.accessoryType = UITableViewCellAccessoryType;
    // 设置TableViewCell的accessoryView
    item.accessoryView = ^{
        return someView;
    };
    // 设置TableViewCell的高度。
    item.height = 44;
    // 设置TableViewCell的扩展字典，该字典会通过KVC来设置属性。
    item.extendDic = @{@"somePropertyName1":theValue1,
                       @"somePropertyName2":theValue2};
    [items addObject:item];
    return [items copy];
}
@end
```
### 2. 实现<TableDataSourceDelegate>协议对TableViewCell进一步设置。
```objc
- (void)tableDataSource:(TableDataSource *)dataSource withCell:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 设置TableViewCell
}
- (BOOL)tableDataSource:(TableDataSource *)dataSource canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // 设置哪个Cell可以编辑。
    return YES;
}
- (void)tableDataSource:(TableDataSource *)dataSource commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 回调提交TableViewCell的editingStyle，可对TabelView进行设置。
}
```
### 3. TableDataSource的常用方法。
```objc
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
```

## CollectDataSource
### 1. 使用实现协议<CollectionItemsFactoryProtocol>的CollectItem工程类创建CollectItem
```objc
@interface MyCollectItemsFactory : NSObject <CollectionItemsFactoryProtocol>

@end

@implementation MyCollectItemsFactory

- (NSArray<NSNumber *> *)rows {
    /// 每个数字代表section的row的数量。array的个数代表section的数量
    return @[@1,@1,@1];
}

- (NSArray<TableItem *> *)items {
    NSMutableArray<CollectItem *> *items = [NSMutableArray arrayWithCapacity:3];
    CollectItem *item = [[CollectItem alloc] initWithCellClass:[SomeCollectionViewCell class]];
    // 设置cell的size
    item.size = cellSize;
    item.extendDic = @{@"somePropertyName1":theValue1,
                       @"somePropertyName2":theValue2};
    [items addObject:item];
    return [items copy];
}
@end
```
### 2. 实现<CollectDataSourceDelegate>协议对CollectionViewCell进一步设置。
```objc
- (void)collectDataSource:(CollectDataSource *)dataSource withCell:(UICollectionViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 设置CollectionViewCell
}
```
### 3. CollectDataSource的常用方法。
```objc
- (CollectItem * _Nullable)itemAtIndexPath:(NSIndexPath *)indexPath;
```
## TagsView
### 1. 设置TagsView
```objc
TagsView *tagsView = [[TagView alloc] initWithFrame:someFrame];
// 设置底部指示线的线宽
tagsView.lineWidth = 1;
// 设置底部指示线的颜色
tagView.lineColor = someColor;
// 设置tag的normal文字属性字典。
tagsView.textNormalFontAttribute = @{};
// 设置tag的select文字属性字典。
tagsView.textSelectFontAttribute = @{};
// 设置tagsView的标签数组。
tagsView.texts = @[];
// 设置tag对应的scrollView
tagsView.scrollView = scrollView;
// 设置标签对应的view的NSValue数组。
tagsView.view = @[];
// 建立
[tagsView setup];
```
### 2. TagsView的使用方法。
```objc
/// 选择对应的tag，是否带动画。
- (void)selectTagAtIndex:(NSUInteger)index animated:(BOOL)animated;
/// 设置tag对应的数量。
- (void)setCount:(NSUInteger)count atIndex:(NSUInteger)index;
```











