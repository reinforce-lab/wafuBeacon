//
//  BeaconVO.m
//  iBeaconMonitor
//
//  Created by uehara akihiro on 2013/12/15.
//  Copyright (c) 2013年 REINFORCE Lab. All rights reserved.
//

#import "BeaconVO.h"
@interface BeaconVO () {
    
}
@property (nonatomic) NSNumber *major;
@property (nonatomic) NSNumber *minor;
@property (nonatomic) NSDate *lastRangingUpdatedAt;
@property (nonatomic) CLProximity proximity;
@property (nonatomic) CLLocationAccuracy accuracy;
@property (nonatomic) NSInteger rssi;

@end

@implementation BeaconVO
-(id)initWithNumbers:(NSNumber *)major minor:(NSNumber *)minor {
    self = [super init];
    if(self) {
        self.major = major;
        self.minor = minor;
        self.lastRangingUpdatedAt = [NSDate distantPast];
    }
    return self;
}

#pragma mark Public methods
-(void)updateByRanging:(CLBeacon *)beacon {
    
    NSAssert([beacon.major isEqualToNumber:self.major], @"major number must be the same.");
    NSAssert([beacon.minor isEqualToNumber:self.minor], @"minor number must be the same.");
    
    if(beacon.proximity != CLProximityUnknown) {
        self.inRangeCount += 1;
    }
    
    self.lastRangingUpdatedAt = [NSDate date];
    self.proximity = beacon.proximity;
    self.accuracy  = beacon.accuracy;
    self.rssi      = beacon.rssi;
}
-(NSComparisonResult)compare:(BeaconVO *)beacon {
    if(self.major > beacon.major) {
        return NSOrderedDescending;
    } else if(self.major < beacon.major) {
        return NSOrderedAscending;
    } else if(self.minor > beacon.minor) {
        return NSOrderedDescending;
    } else if(self.minor < beacon.minor) {
        return NSOrderedAscending;
    } else {
        return NSOrderedSame;
    }
}
@end
