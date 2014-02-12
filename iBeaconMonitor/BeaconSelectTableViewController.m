//
//  BeaconSelectTableViewController.m
//  iBeaconMonitor
//
//  Created by uehara akihiro on 2013/12/15.
//  Copyright (c) 2013年 REINFORCE Lab. All rights reserved.
//

#import "BeaconSelectTableViewController.h"
#import "BeaconCell.h"

@interface BeaconSelectTableViewController () {
    BeaconManager *_manager;
}
@end

@implementation BeaconSelectTableViewController
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear   = NO;
    self.tableView.allowsMultipleSelection = YES;
    self.navigationController.navigationItem.rightBarButtonItem.enabled = NO;
    
    _manager = [BeaconManager sharedInstance];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _manager.delegate = self;
    _manager.stat     = ranging;
    
    [self updateNavigationRightButtonStat];
}

#pragma mark Private methods
// ナビゲーション右ボタンの表示状態更新
-(void)updateNavigationRightButtonStat {
    NSArray *indices    = [self.tableView indexPathsForSelectedRows];
    NSUInteger cnt = [indices count];
    self.navigationBarRightButton.enabled = (cnt != 0);
}
#pragma mark BeaconManagerDelegate
-(void)didBeaconAdded:(BeaconManager *)sender beacon:(BeaconVO *)beacon {
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BeaconCell *cell = (BeaconCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.beacon.selected = YES;

    [self updateNavigationRightButtonStat];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    BeaconCell *cell = (BeaconCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.beacon.selected = NO;
    
    [self updateNavigationRightButtonStat];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger cnt = [[_manager majors] count];
    return (cnt == 0) ? 1 : cnt;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *majors  = [_manager majors];
    NSInteger cnt = [majors count];
    if( cnt == 0 ) {
        return 1;
    } else {
        NSNumber *major  = [majors objectAtIndex:section];
        NSArray *beacons = [_manager beacons:major];
        return [beacons count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *detectingCellIdentifier = @"detectingLabelCell";
    static NSString *beaconCellIdentifier = @"BeaconCell";

    NSInteger cnt = [[_manager majors] count];
    if( cnt == 0 ) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:detectingCellIdentifier forIndexPath:indexPath];
        return cell;
    } else {
        BeaconCell *cell = (BeaconCell *)[tableView dequeueReusableCellWithIdentifier:beaconCellIdentifier forIndexPath:indexPath];
        
        NSUInteger section = [indexPath indexAtPosition:0];
        NSUInteger row     = [indexPath indexAtPosition:1];

        NSArray *majors  = [_manager majors];
        NSNumber *major  = [majors objectAtIndex:section];
        NSArray *beacons = [_manager beacons:major];
        cell.beacon      = [beacons objectAtIndex:row];
        
        return cell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger cnt = [[_manager majors] count];
    return  cnt == 0 ? 148 : 72;
}
@end
