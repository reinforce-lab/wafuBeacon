//
//  BackgroundTestViewController.m
//  simpleBeacon
//
//  Created by uehara akihiro on 2014/01/27.
//  Copyright (c) 2014年 REINFORCE Lab. All rights reserved.
//

#import "BackgroundTestViewController.h"

@interface BackgroundTestViewController () {
    NSFileHandle *_logFile;
    NSMutableString   *_logText;

    CLBeaconRegion *_region;
    CLLocationManager *_locationManager;
    CBPeripheralManager *_peripheralManager;
    NSTimer *_onTimer, *_offTimer;
    int _intervalSec, _windowSec;
}
@end

@implementation BackgroundTestViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // パス（Documents/log.txt）の文字列を作成する
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:dataLogFile];
    _logFile = [NSFileHandle fileHandleForWritingAtPath:path];
    
    _logText = [[NSMutableString alloc] init];
    _logTextView.text = @"";

    // PeripheralManagerオブジェクトを作ります。
    // Bluetoothの電源がOFFの場合はダイアログを表示します。
    _peripheralManager = [[CBPeripheralManager alloc]
                          initWithDelegate:self queue:nil
                          options:@{CBPeripheralManagerOptionShowPowerAlertKey : @YES}];
    
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    
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

/*
 // iOS5.1以降、アプリケーションから設定アプリに遷移する方法はない。
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"prefs:root=LOCATION_SERVICES"]];
}
 */

#pragma mark Private methods
-(void)writeLog:(NSString *)log {
    NSLog(@"%@", log);
    [_logText appendFormat:@"%@\n", log];
    self.logTextView.text = _logText;
}
-(void)showAleart:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}
-(void)logging:(NSString *)prefix region:(CLBeaconRegion *)region {
    int batteryLevel = (int)(100 * [[UIDevice currentDevice] batteryLevel]);
    NSDate *date = [NSDate date];
    
    NSString *msg = [NSString stringWithFormat:@"%@ %@ %3d %@", prefix, date, batteryLevel, region];
    [self writeLog:msg];

    msg = [NSString stringWithFormat:@"%@\n", msg]; // appending a new line
    [_logFile writeData:[NSData dataWithBytes:msg.UTF8String length:[msg lengthOfBytesUsingEncoding:NSUTF8StringEncoding]]];
}

-(void)startMonitoring {
    [self writeLog:@"startMonitoring"];
    _region.notifyOnEntry = YES;
    _region.notifyOnExit  = YES;
    _region.notifyEntryStateOnDisplay = YES;
    [_locationManager startMonitoringForRegion:_region];
}
-(void)stopMonitoring {
    [self writeLog:@"stopMonitoring"];
    [_locationManager stopMonitoringForRegion:_region];
}
-(void)startRanging {
    [self writeLog:@"startRanging"];
    
    // CLBeaconRegionを作成
    [_locationManager startRangingBeaconsInRegion:_region];
    [self writeLog:[NSString stringWithFormat:@"rangedRegions: %@", _locationManager.rangedRegions]];
}
-(void)stopRanging {
    [self writeLog:@"stopRanging"];
    [_locationManager stopRangingBeaconsInRegion:_region];
}
-(void)startBeacon {
    // check paremters
    _intervalSec = [self.advIntervalLabel.text intValue] * 60; // 単位は分
    _windowSec   = [self.advWindowLabel.text intValue]; // 単位は秒
    if(_intervalSec <= 0) {
        [self showAleart:@"アドバタイズメントの周期が負です。"];
        return;
    }
    if(_windowSec <= 0) {
        [self showAleart:@"アドバタイズメントの時間が負です。"];
        return;
    }
    if(_intervalSec < _windowSec) {
        [self showAleart:@"周期がアドバタイジング時間より短いです。"];
        return;
    }
    
    self.advIntervalLabel.enabled = NO;
    self.advWindowLabel.enabled   = NO;
    self.rangingSwitch.enabled    = NO;
    
    // タイマーを設定
    NSTimeInterval currentInterval = [[NSDate date] timeIntervalSinceReferenceDate];
    NSTimeInterval startTimeInHour = floor( currentInterval / 3600 ) * 3600; // スタート時間の時間(hour)
    NSTimeInterval fireAt = (trunc((currentInterval - startTimeInHour) / _intervalSec)  + 1) * _intervalSec + startTimeInHour;
    NSDate *fireAtDate = [NSDate dateWithTimeIntervalSinceReferenceDate:fireAt];
    
    _onTimer = [[NSTimer alloc]
                         initWithFireDate:fireAtDate interval:_intervalSec
                         target:self selector:@selector(onTimerFired:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_onTimer forMode:NSDefaultRunLoopMode];
}
-(void)stopBeacon {
    if(_onTimer != nil) {
        [_onTimer invalidate];
        _onTimer = nil;
        [_offTimer invalidate];
        _offTimer = nil;
        
        if(_peripheralManager.isAdvertising) {
            [_peripheralManager stopAdvertising];
        }
        self.advIntervalLabel.enabled = YES;
        self.advWindowLabel.enabled   = YES;
        self.rangingSwitch.enabled    = YES;
    }
}
- (IBAction)textFieldsDidEndExit:(id)sender {
    UITextField *field = (UITextField *)sender;
    [field resignFirstResponder];
}
#pragma mark Event handler
-(void)onTimerFired:(NSTimer *)timer {
    [self writeLog:[NSString stringWithFormat:@"%s %@", __PRETTY_FUNCTION__, [NSDate date]]];
    
    // 時間にあわせた、Regionを作成
    NSDate *date = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *cmp = [gregorian components:( NSCalendarUnitHour | NSCalendarUnitMinute)
                                         fromDate:date];
    uint16_t minor = cmp.hour << 8 + cmp.minute;
    CLBeaconRegion *region = [[CLBeaconRegion alloc]
                              initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:kBeaconUUID]
                              major:1 minor:minor identifier:kIdentifier];
    NSDictionary *advertisementData = [region peripheralDataWithMeasuredPower:nil];
    [_peripheralManager startAdvertising:advertisementData];
    
    // 停止タイマーを開始
    _offTimer = [NSTimer
                 scheduledTimerWithTimeInterval:_windowSec
                 target:self selector:@selector(offTimerFired:) userInfo:nil repeats:NO];
}
-(void)offTimerFired:(NSTimer *)timer {
    [self writeLog:[NSString stringWithFormat:@"%s %@", __PRETTY_FUNCTION__, [NSDate date]]];
    
    [_peripheralManager stopAdvertising];
}
- (IBAction)clearButtonTouchUpInside:(id)sender {
    _logText = [[NSMutableString alloc] init];
    _logTextView.text = @"";
}
- (IBAction)beaconSwitchValueChanged:(id)sender {
    if(self.beaconSwitch.on) {
        // BTの電源がONになっているかを、確認します。
        if (_peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
            //        [self showAleart:@"Bleutoothの電源が入っていません"];
            self.beaconSwitch.on = NO;
            return;
        }
        [self startBeacon];
    } else {
        [self stopBeacon];
    }
}

- (IBAction)monitoringSwitchValueChanged:(id)sender {
    if([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
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

- (IBAction)rangingSwitchValueChanged:(id)sender {
    if([CLLocationManager isRangingAvailable]) {
        if(self.rangingSwitch.on) {
            [self startRanging];
        } else {
            [self stopRanging];
        }
    } else {
        [self showAleart:@"Ranging機能がありません。"];
        self.rangingSwitch.on = NO;
    }
}
#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
//    [self writeLog:[NSString stringWithFormat:@"%s\n%@\n%@", __PRETTY_FUNCTION__, beacons, region]];
    
    // 先頭要素がunknownなCLBeaconがあるので、それは除外する
    CLBeacon *firstBeacon = [beacons firstObject];
    if(firstBeacon.proximity == CLProximityUnknown) {
        [self writeLog:@"\t先頭要素のビーコンの近接状態がunknown."];
    }
    /*
    for(CLBeacon *beacon in beacons) {
        if(beacon.proximity != CLProximityUnknown) {
            [self writeLog:[NSString stringWithFormat:@"\t先頭要素:%@",beacon]];
            break;
        }
    }
     */
    
    if(!self.rangingSwitch.on) {
        [_locationManager stopRangingBeaconsInRegion:_region];
    }
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
//    [self writeLog:[NSString stringWithFormat:@"%s\nstate:%d %@", __PRETTY_FUNCTION__, (int)state, region]];
}
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
//    [self writeLog:[NSString stringWithFormat:@"%s\n%@", __PRETTY_FUNCTION__, region]];

    // 登録したリージョンはmajor/minorがワイルドカードなので、major/minorはnil
    [self logging:@"Enter" region:(CLBeaconRegion *)region];

    // 周囲にあるビーコン情報を取得したいならば、Rangingを呼び出すほかない。バックグラウンドの10秒間の実行時間を使う。
    if(self.rangingSwitch.on) {
        [_locationManager startRangingBeaconsInRegion:_region];
    }
}
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
//    [self writeLog:[NSString stringWithFormat:@"%s\n%@", __PRETTY_FUNCTION__, region]];
//    [self logging:@"Exit" region:(CLBeaconRegion *)region];
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

#pragma mark CBPeripheralManagerDelegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    [self writeLog:[NSString stringWithFormat:@"%s\n", __PRETTY_FUNCTION__]];
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            break;
        case CBPeripheralManagerStatePoweredOff:
        case CBPeripheralManagerStateResetting:
        case CBPeripheralManagerStateUnauthorized:
        case CBPeripheralManagerStateUnknown:
        case CBPeripheralManagerStateUnsupported:
            _beaconSwitch.on = NO;
        default:
            break;
    }
}
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    if(error != nil) {
        [self writeLog:[NSString stringWithFormat:@"%s\n%@", __PRETTY_FUNCTION__, error]];
    }
}

@end
