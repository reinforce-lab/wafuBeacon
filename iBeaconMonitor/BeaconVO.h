//
//  BeaconVO.h
//  iBeaconMonitor
//
//  Created by uehara akihiro on 2013/12/15.
//  Copyright (c) 2013年 REINFORCE Lab. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface BeaconVO : NSObject
@property (nonatomic, assign) BOOL selected;

@property (readonly, nonatomic) NSNumber *major;
@property (readonly, nonatomic) NSNumber *minor;

@property (nonatomic, assign) BOOL notifyOnEntry;
@property (nonatomic, assign) BOOL notifyOnExit;
@property (nonatomic, assign) BOOL notifyEntryStateOnDisplay;

// レンジングカウント用
@property (nonatomic, assign) NSInteger inRangeCount;

@property (readonly, nonatomic) NSDate *lastRangingUpdatedAt;
@property (readonly, nonatomic) CLProximity proximity;
@property (readonly, nonatomic) CLLocationAccuracy accuracy;
@property (readonly, nonatomic) NSInteger rssi;

-(id)initWithNumbers:(NSNumber *)major minor:(NSNumber *)minor;
-(void)updateByRanging:(CLBeacon *)beacon;

-(NSComparisonResult)compare:(BeaconVO *)beacon;
@end
