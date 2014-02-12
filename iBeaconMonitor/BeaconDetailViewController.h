//
//  BeaconDetailViewController.h
//  iBeaconMonitor
//
//  Created by uehara akihiro on 2013/12/15.
//  Copyright (c) 2013年 REINFORCE Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeaconVO.h"
@interface BeaconDetailViewController : UIViewController

@property (nonatomic) BeaconVO *beacon;

@property (weak, nonatomic) IBOutlet UILabel *majorLabel;
@property (weak, nonatomic) IBOutlet UILabel *minorLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;
@property (weak, nonatomic) IBOutlet UILabel *accuracyLabel;
@property (weak, nonatomic) IBOutlet UILabel *proximityLabel;
@property (weak, nonatomic) IBOutlet UISwitch *enterRegionSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *exitRegionSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *onDisplaySwitch;
@property (weak, nonatomic) IBOutlet UILabel *inRangeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalCountLabel;

- (IBAction)enterRegionSwitchValueChanged:(id)sender;
- (IBAction)exitRegionSwitchValueChanged:(id)sender;
- (IBAction)onDisplaySwitchValueChanged:(id)sender;

@end
