//
//  BeaconManager.h
//  iBeaconMonitor
//
//  Created by uehara akihiro on 2013/12/15.
//  Copyright (c) 2013年 REINFORCE Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;
#import "BeaconVO.h"

// UUID of the Estimote's beacon
#define kDefaultUUIDString @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"

typedef enum {
    init    = 0,
    region  = 1,
    ranging = 2
} BeaconManagerStat;

@class BeaconManager;

@protocol BeaconManagerDelegate <NSObject>
@optional
// 状態遷移
-(void)didChangeStat:(BeaconManager *)sender;
// ビーコンのVOが追加された
-(void)didBeaconAdded:(BeaconManager *)sender beacon:(BeaconVO *)beacon;

-(void)didEnterBeaconRegion:(BeaconManager *)sender beacon:(BeaconVO *)beacon;
-(void)didExitBeaconRegion:(BeaconManager *)sender  beacon:(BeaconVO *)beacon;
-(void)didUpdateRanging:(BeaconManager *)sender beacons:(NSArray *)beacons;
@end

@interface BeaconManager : NSObject<CLLocationManagerDelegate>
@property (nonatomic) NSObject<BeaconManagerDelegate> *delegate;
@property (nonatomic) BeaconManagerStat stat;

// 選択されたビーコン
@property (nonatomic, readonly) NSArray *selectedBeacons;

// レンジング計測した回数
@property (nonatomic, assign, readonly) NSInteger totalRangingCount;

// シングルトン
+(BeaconManager *)sharedInstance;

//ユニークなmajor番号の配列、番号で昇順ソート
-(NSArray *)majors;
//指定したmajor番号のBeaconVOの配列
-(NSArray *)beacons:(NSNumber *)major;

// レンジングカウントのクリア
-(void)clearTotalRangingCount;
@end
