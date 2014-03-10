//
//  BackgroundTestViewController.m
//  simpleBeacon
//
//  Created by uehara akihiro on 2014/01/27.
//  Copyright (c) 2014年 REINFORCE Lab. All rights reserved.
//

#import "BackgroundTestViewController.h"

@interface BackgroundTestViewController () {
    CLBeaconRegion *_region;
    CLLocationManager *_locationManager;
}
@end

@implementation BackgroundTestViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // CLBeaconRegionを作成
    _region = [[CLBeaconRegion alloc]
               initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:kBeaconUUID]
               identifier:kIdentifier];

    if(_locationManager != nil) {
        [self stopMonitoring];
        _locationManager = nil;
    }
    
    // iBeaconを受信するlocationManagerを組み立てます
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    _monitoringSwitch.on = NO;
    _beaconSwitch.on     = NO;
}
-(void)viewWillDisappear:(BOOL)animated {
    [self stopMonitoring];
    _locationManager = nil;
}

#pragma mark Private methods
-(void)logging:(CLBeaconRegion *)region {
    int batteryLevel = (int)(100 * [[UIDevice currentDevice] batteryLevel]);
    NSDate *date = [NSDate date];
    [self writeLog:[NSString stringWithFormat:@"Enter: %@ %3d %@", date, batteryLevel, region]];
}
-(void)startMonitoring {
    _region.notifyOnEntry = YES;
    _region.notifyOnExit  = YES;
    _region.notifyEntryStateOnDisplay = YES;
    [_locationManager startMonitoringForRegion:_region];
}
-(void)stopMonitoring {
    [_locationManager stopMonitoringForRegion:_region];
}
#pragma mark Event handler
- (IBAction)beaconSwitchValueChanged:(id)sender {
}
- (IBAction)monitoringSwitchValueChanged:(id)sender {
    if([CLLocationManager isRangingAvailable]) {
        if(self.monitoringSwitch.on) {
            [self startMonitoring];
        } else {
            [self stopMonitoring];
        }
    } else {
        [self showAleart:@"iBeacon機能がありません。"];
        self.monitoringSwitch.on = NO;
    }
}
#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    [self writeLog:[NSString stringWithFormat:@"%s\n%@\n%@", __PRETTY_FUNCTION__, beacons, region]];
}
- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    [self writeLog:[NSString stringWithFormat:@"%s\n%@\n%@", __PRETTY_FUNCTION__, region, error]];
}
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    [self writeLog:[NSString stringWithFormat:@"%s\n%@\n%@", __PRETTY_FUNCTION__, region, error]];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self writeLog:[NSString stringWithFormat:@"%s\n%@", __PRETTY_FUNCTION__, error]];
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self writeLog:[NSString stringWithFormat:@"%s\n%d", __PRETTY_FUNCTION__, status]];
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        [self writeLog:@"ローケーションサービスを使う権限がありません。"];
        if(self.monitoringSwitch.on) {
            [_locationManager stopMonitoringForRegion:_region];
            self.monitoringSwitch.on = NO;
        }
        return;
    }
}
-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    [self writeLog:[NSString stringWithFormat:@"%s\nstate:%d %@", __PRETTY_FUNCTION__, (int)state, region]];
}
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self writeLog:[NSString stringWithFormat:@"%s\n%@", __PRETTY_FUNCTION__, region]];
    [self logging:(CLBeaconRegion *)region];
}
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self writeLog:[NSString stringWithFormat:@"%s\n%@", __PRETTY_FUNCTION__, region]];
}
- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    [self writeLog:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
}
- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    [self writeLog:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
}
- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error {
    [self writeLog:[NSString stringWithFormat:@"%s\n%@", __PRETTY_FUNCTION__, error]];
}
@end
