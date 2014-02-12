//
//  BeaconTableViewController.m
//  iBeaconMonitor
//
//  Created by uehara akihiro on 2013/12/15.
//  Copyright (c) 2013年 REINFORCE Lab. All rights reserved.
//

#import "BeaconTableViewController.h"
#import "BeaconManager.h"
#import "BeaconCell.h"
#import "BeaconDetailViewController.h"

@interface BeaconTableViewController () {
    BeaconManager *_manager;
}
@end

@implementation BeaconTableViewController
- (void)viewDidLoad
{
    [super viewDidLoad];

    _manager = [BeaconManager sharedInstance];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_manager.selectedBeacons count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  100;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BeaconCell";
    BeaconCell *cell = (BeaconCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    NSUInteger row = [indexPath indexAtPosition:1];
    cell.beacon = [_manager.selectedBeacons objectAtIndex:row];
    
    return cell;
}
#pragma mark Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.destinationViewController isKindOfClass:[BeaconDetailViewController class]]) {
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        NSInteger row = [path indexAtPosition:1];
        BeaconVO *beacon = [_manager.selectedBeacons objectAtIndex:row];
        
        BeaconDetailViewController *dst = (BeaconDetailViewController *)segue.destinationViewController;
        dst.beacon = beacon;
    }
}
@end
