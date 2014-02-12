//
//  BeaconSelectTableViewController.h
//  iBeaconMonitor
//
//  Created by uehara akihiro on 2013/12/15.
//  Copyright (c) 2013年 REINFORCE Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeaconManager.h"

@interface BeaconSelectTableViewController : UITableViewController<BeaconManagerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *navigationBarRightButton;
@end
