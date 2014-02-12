//
//  BeaconManager.m
//  iBeaconMonitor
//
//  Created by uehara akihiro on 2013/12/15.
//  Copyright (c) 2013年 REINFORCE Lab. All rights reserved.
//

#import "BeaconManager.h"

@interface BeaconManager () {
    NSMutableDictionary *_beacons; //majorをキー、valueは配列
    
    BeaconManagerStat _stat;
    CLBeaconRegion   *_region;
    CLLocationManager *_manager;
}
@property (nonatomic, assign) NSInteger totalRangingCount;
@end

@implementation BeaconManager
#pragma mark Properties
@dynamic stat;
-(void)setStat:(BeaconManagerStat)stat {
    if(stat != _stat) {
        // 一旦停止する
        switch (_stat) {
            case region:
                [_manager stopMonitoringForRegion:_region];
                break;
            case ranging:
                [_manager stopMonitoringForRegion:_region];
                [_manager stopRangingBeaconsInRegion:_region];
                break;
            default:
                break;
        }
        // 開始する
        switch (stat) {
            case region:
                //    if(!
                if([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
                    [_manager startMonitoringForRegion:_region];
                    _stat = stat;
                }
                break;
            case ranging:
                if([CLLocationManager isRangingAvailable]) {
                    [_manager startMonitoringForRegion:_region];
                    [_manager startRangingBeaconsInRegion:_region];
                    _stat = stat;
                }
            default:
                _stat = stat;
                break;
        }
        
        if([self.delegate respondsToSelector:@selector(didChangeStat:)]) {
            [self.delegate didChangeStat:self];
        }
    }
}
-(BeaconManagerStat)stat {
    return _stat;
}

@dynamic selectedBeacons;
-(NSArray *)selectedBeacons {
    NSMutableArray *beacons = [NSMutableArray array];
    for(NSDictionary *majorBeacons in [_beacons allValues] ) {
        for(BeaconVO *beacon in [majorBeacons allValues] ) {
            if(beacon.selected) {
                [beacons addObject:beacon];
            }
        }
    }
    // sorting
    [beacons sortUsingComparator:^NSComparisonResult(BeaconVO * obj1, BeaconVO * obj2) {
        return [obj1 compare:obj2];
    }];
    return beacons;
}

#pragma mark Constructor
static BeaconManager *_inst;
+(BeaconManager *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _inst = [[BeaconManager alloc] init];
    });
    return _inst;
}

-(id)init {
    self = [super init];
    if(self) {
        _beacons = [NSMutableDictionary dictionary];
        
        _region = [[CLBeaconRegion alloc]
                   initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:kDefaultUUIDString]
                   identifier:@"com.reinforce-lab.iBeaconMonitor"];
        _region.notifyEntryStateOnDisplay = YES;
        
        _manager = [[CLLocationManager alloc] init];
        _manager.delegate = self;
    }
    return self;
}
#pragma mark Private methods
-(BeaconVO *)acquireBeaconVO:(NSNumber *)major minor:(NSNumber *)minor {
    if(major == nil || minor == nil) return nil;
    
    NSMutableDictionary *beacons = [_beacons objectForKey:major];
    BeaconVO *vo = [beacons objectForKey:minor];
    if(vo == nil) {
        vo = [[BeaconVO alloc] initWithNumbers:major minor:minor];
        if(beacons == nil) {
            beacons = [NSMutableDictionary dictionary];
            [_beacons setObject:beacons forKey:major];
        }
        [beacons setObject:vo forKey:minor];
        
        if([self.delegate respondsToSelector:@selector(didBeaconAdded:beacon:)]) {
            [self.delegate didBeaconAdded:self beacon:vo];
        }
    }
    return vo;
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
}
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    CLBeaconRegion *b = (CLBeaconRegion *)region;
    
    BeaconVO *vo = [self acquireBeaconVO:b.major minor:b.minor];
    if(vo == nil) return;
    
    if(vo.notifyEntryStateOnDisplay) {
        UILocalNotification *notif = [[UILocalNotification alloc] init];
        notif.alertBody = [NSString stringWithFormat:@"beacon major:%@ minor:%@", vo.major, vo.minor];
        [[UIApplication sharedApplication] presentLocalNotificationNow:notif];
    }
    NSLog(@"ondisplay");
    
}
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [_manager requestStateForRegion:region];
}
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    self.totalRangingCount += 1;
    
    NSMutableArray *vos = [NSMutableArray array];
    
    for(CLBeacon *beacon in beacons) {
        BeaconVO *vo = [self acquireBeaconVO:beacon.major minor:beacon.minor];
        if(vo != nil) {
            [vo updateByRanging:beacon];
            [vos addObject:vo];
        }
    }
    
    if([self.delegate respondsToSelector:@selector(didUpdateRanging:beacons:)] ) {
        [self.delegate didUpdateRanging:self beacons:vos];
    }
}
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    CLBeaconRegion *b = (CLBeaconRegion *)region;
    BeaconVO *vo = [self acquireBeaconVO:b.major minor:b.minor];
    if(vo == nil) return;
    
    if([self.delegate respondsToSelector:@selector(didEnterBeaconRegion:beacon:)]) {
        [self.delegate didEnterBeaconRegion:self beacon:vo];
    }
    
    if(vo.notifyOnEntry) {
        UILocalNotification *notif = [[UILocalNotification alloc] init];
        notif.alertBody = [NSString stringWithFormat:@"enter major:%@ minor:%@", vo.major, vo.minor];
        [[UIApplication sharedApplication] presentLocalNotificationNow:notif];
        
        NSLog(@"enter notif");
    }
}
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    CLBeaconRegion *b = (CLBeaconRegion *)region;
    BeaconVO *vo = [self acquireBeaconVO:b.major minor:b.minor];
    if(vo == nil) return;
    
    if([self.delegate respondsToSelector:@selector(didExitBeaconRegion:beacon:)]) {
        [self.delegate didExitBeaconRegion:self beacon:vo];
    }
    
    if(vo.notifyOnExit) {
        UILocalNotification *notif = [[UILocalNotification alloc] init];
        notif.alertBody = [NSString stringWithFormat:@"exit major:%@ minor:%@", vo.major, vo.minor];
        [[UIApplication sharedApplication] presentLocalNotificationNow:notif];
    }
}
#pragma mark Public methods
-(NSArray *)majors {
    return [_beacons allKeys];
}
-(NSArray *)beacons:(NSNumber *)major {
    NSArray *beacons = [[_beacons objectForKey:major] allValues];
    return [beacons sortedArrayUsingComparator:^NSComparisonResult(BeaconVO *obj1, BeaconVO *obj2){
        return [obj1 compare:obj2];
    }];
}
-(void)clearTotalRangingCount {
    self.totalRangingCount = 0;
    for(NSDictionary *dic in [_beacons allValues]) {
        for(BeaconVO *beacon in [dic allValues]) {
            beacon.inRangeCount = 0;
        }
    }
}
@end
