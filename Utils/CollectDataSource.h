//
//  CollectDataSource.h
//  yzyx
//
//  Created by xuemiyang on 2017/12/20.
//  Copyright © 2017年 TCLios2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CollectItem: NSObject
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign, readonly) Class cellClass;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong, nullable) NSMutableDictionary<NSString *, id> *extendDic;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithCellClass:(Class)cellClass;
@end

@protocol CollectionItemsFactoryProtocol <NSObject>
@property (nonatomic, strong, readonly) NSArray<CollectItem *> *items;
@property (nonatomic, strong, readonly) NSArray<NSNumber *> *rows;
@end

@class CollectDataSource;
@protocol CollectDataSourceDelegate <NSObject>
- (void)collectDataSource:(CollectDataSource *)dataSource withCell:(UICollectionViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (void)collectDataSource:(CollectDataSource *)dataSource viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;
@end

@interface CollectDataSource : NSObject <UICollectionViewDataSource>
@property (nonatomic, strong) NSArray<NSNumber *> *rows;
@property (nonatomic, strong) NSArray<CollectItem *> *items;
@property (nonatomic, weak, nullable) id<CollectDataSourceDelegate> delegate;
@property (nonatomic, weak, readonly) UICollectionView *collectionView;
- (CollectItem * _Nullable)itemAtIndexPath:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END





