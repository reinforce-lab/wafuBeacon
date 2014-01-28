//
//  BackgroundTestViewController.h
//  simpleBeacon
//
//  Created by uehara akihiro on 2014/01/27.
//  Copyright (c) 2014年 REINFORCE Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreBluetooth;
@import CoreLocation;

// estimote default UUID
//#define kBeaconUUID  @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
// random UUID
#define kBeaconUUID  @"C7FC8659-DEE1-4B64-880A-83EAE89C59C3"
#define kIdentifier  @"com.reinforce-lab"
#define dataLogFile  @"datalog.txt"

@interface BackgroundTestViewController : UIViewController<CLLocationManagerDelegate,CBPeripheralManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *advWindowLabel;
@property (weak, nonatomic) IBOutlet UITextField *advIntervalLabel;
@property (weak, nonatomic) IBOutlet UISwitch *beaconSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *monitoringSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *rangingSwitch;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UIButton   *clearButton;
@end
