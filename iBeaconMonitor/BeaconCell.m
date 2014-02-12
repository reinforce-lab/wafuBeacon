//
//  SelectBeaconCell.m
//  iBeaconMonitor
//
//  Created by uehara akihiro on 2013/12/15.
//  Copyright (c) 2013年 REINFORCE Lab. All rights reserved.
//

#import "BeaconCell.h"

@interface BeaconCell () {
    BeaconVO *_beacon;
}
@end

@implementation BeaconCell
#pragma mark Properties
@dynamic beacon;
-(void)setBeacon:(BeaconVO *)beacon {
    [self setSelected:_beacon.selected];
    
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

#pragma mark Cell Lifecycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

-(void)dealloc {
    self.beacon = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}
#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
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
    [self setSelected:_beacon.selected];
    
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
    [beacon removeObserver:self forKeyPath:@"state"];
}

@end
