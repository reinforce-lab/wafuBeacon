//
//  BeaconDetailViewController.m
//  iBeaconMonitor
//
//  Created by uehara akihiro on 2013/12/15.
//  Copyright (c) 2013年 REINFORCE Lab. All rights reserved.
//

#import "BeaconDetailViewController.h"
#import "BeaconVO.h"
#import "BeaconManager.h"

@interface BeaconDetailViewController () {
    BeaconManager *_manager;
    BeaconVO *_beacon;
}
@end

@implementation BeaconDetailViewController
#pragma mark Properties
@dynamic beacon;
-(void)setBeacon:(BeaconVO *)beacon {
    if(_beacon != nil) {
        [self unregisterBeacon:_beacon];
    }
    _beacon = beacon;
    if(_beacon != nil) {
        [self registerBeacon:_beacon];
    }
}
-(BeaconVO *)beacon {
    return _beacon;
}
#pragma mark Constructor
-(void)dealloc {
    self.beacon = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    _manager = [BeaconManager sharedInstance];
    [_manager clearTotalRangingCount];
}
#pragma mark Event handler
- (IBAction)enterRegionSwitchValueChanged:(id)sender {
    _beacon.notifyOnEntry = self.enterRegionSwitch.on;
}
- (IBAction)exitRegionSwitchValueChanged:(id)sender {
    _beacon.notifyOnExit = self.exitRegionSwitch.on;
}
- (IBAction)onDisplaySwitchValueChanged:(id)sender {
    _beacon.notifyEntryStateOnDisplay = self.onDisplaySwitch.on;
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSObject *obj = (__bridge NSObject *)(context);
    if ([obj isKindOfClass:[NSString class]]) {
//        [self updateUI:(NSString *)obj];
        [self updateUI];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark  Private methods
-(void)updateUI {
    self.totalCountLabel.text   = [NSString stringWithFormat:@"%d", _manager.totalRangingCount];
    self.inRangeCountLabel.text = [NSString stringWithFormat:@"%d", _beacon.inRangeCount];
    
    self.enterRegionSwitch.on = _beacon.notifyOnEntry;
    self.exitRegionSwitch.on  = _beacon.notifyOnExit;
    self.onDisplaySwitch.on   = _beacon.notifyEntryStateOnDisplay;
    
    self.majorLabel.text = [_beacon.major stringValue];
    self.minorLabel.text = [_beacon.minor stringValue];
    
    switch (_beacon.proximity) {
        case CLProximityFar:
            self.proximityLabel.text = @"Far";
            break;
        case CLProximityNear:
            self.proximityLabel.text = @"Near";
            break;
        case CLProximityImmediate:
            self.proximityLabel.text = @"Immediate";
            break;
        case CLProximityUnknown:
        default:
            self.proximityLabel.text = @"Unknown";
            break;
    }
    self.accuracyLabel.text = [NSString stringWithFormat:@"%.1lf", _beacon.accuracy];
    self.rssiLabel.text = [NSString stringWithFormat:@"%d", (int)_beacon.rssi];
}
/*
-(void)updateUI:(NSString *)path {
    if([path isEqualToString:@"major"]) {
        self.majorLabel.text = [_beacon.major stringValue];
    } else if([path isEqualToString:@"minor"]) {
        self.minorLabel.text = [_beacon.minor stringValue];
    } else if([path isEqualToString:@"proximity"]) {
        switch (_beacon.proximity) {
            case CLProximityFar:
                self.proximityLabel.text = @"Far";
                break;
            case CLProximityNear:
                self.proximityLabel.text = @"Near";
                break;
            case CLProximityImmediate:
                self.proximityLabel.text = @"Immediate";
                break;
            case CLProximityUnknown:
            default:
                self.proximityLabel.text = @"Unknown";
                break;
        }
    } else if([path isEqualToString:@"accuracy"]) {
        self.accuracyLabel.text = [NSString stringWithFormat:@"%.1lf", _beacon.accuracy];
    } else if([path isEqualToString:@"rssi"]) {
        self.rssiLabel.text = [NSString stringWithFormat:@"%d", (int)_beacon.rssi];
    } else if([path isEqualToString:@"state"]) {
        switch (_beacon.state) {
            case CLRegionStateInside:
                self.stateLabel.text = @"Inside";
                break;
            case CLRegionStateOutside:
                self.stateLabel.text = @"Outside";
                break;
            case CLRegionStateUnknown:
                self.stateLabel.text = @"Unknown";
            default:
                break;
        }
    }
}*/
-(void)registerBeacon:(BeaconVO *)beacon {
    [beacon addObserver:self forKeyPath:@"major" options:NSKeyValueObservingOptionNew context:@"major"];
    [beacon addObserver:self forKeyPath:@"minor" options:NSKeyValueObservingOptionNew context:@"minor"];
    [beacon addObserver:self forKeyPath:@"proximity" options:NSKeyValueObservingOptionNew context:@"proximity"];
    [beacon addObserver:self forKeyPath:@"accuracy" options:NSKeyValueObservingOptionNew context:@"accuracy"];
    [beacon addObserver:self forKeyPath:@"rssi" options:NSKeyValueObservingOptionNew context:@"rssi"];
    [beacon addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:@"state"];
    
    [self updateUI];
}
-(void)unregisterBeacon:(BeaconVO *)beacon {
    [beacon removeObserver:self forKeyPath:@"major"];
    [beacon removeObserver:self forKeyPath:@"minor"];
    [beacon removeObserver:self forKeyPath:@"proximity"];
    [beacon removeObserver:self forKeyPath:@"accuracy"];
    [beacon removeObserver:self forKeyPath:@"rssi"];
}

@end
