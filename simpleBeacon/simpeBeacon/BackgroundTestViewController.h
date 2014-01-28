//
//  BackgroundTestViewController.h
//  simpleBeacon
//
//  Created by uehara akihiro on 2014/01/27.
//  Copyright (c) 2014年 REINFORCE Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;
#import "baseViewController.h"

@interface BackgroundTestViewController : baseViewController<CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *advWindowLabel;
@property (weak, nonatomic) IBOutlet UITextField *advIntervalLabel;
@property (weak, nonatomic) IBOutlet UISwitch *beaconSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *monitoringSwitch;

@end
