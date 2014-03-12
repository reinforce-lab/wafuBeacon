//
//  AppDelegate.m
//  simpeBeacon
//
//  Created by uehara akihiro on 2013/10/19.
//  Copyright (c) 2013年 REINFORCE Lab. All rights reserved.
//
#import "baseViewController.h"
#import "AppDelegate.h"
@import CoreLocation;

@interface AppDelegate() {
    CLLocationManager *_mgr;
}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // --- NSLognの出力先をDocuments/log.txtに設定する ---
    // パス（Documents/log.txt）の文字列を作成する
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"log.txt"];
    
    // freopen関数で標準エラー出力をファイルに保存する
    freopen([path cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    
    NSLog(@"%s options:%@", __PRETTY_FUNCTION__, launchOptions);
    // Override point for customization after application launch.
    
    _mgr = [[CLLocationManager alloc] init];
    _mgr.delegate = self;
    
    [self pushNotification:[NSString stringWithFormat:@"launch:%@", launchOptions]];

     CLBeaconRegion *region = [[CLBeaconRegion alloc]
               initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:kBeaconUUID]
               identifier:kIdentifier];
    [_mgr startMonitoringForRegion:region];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    [self pushNotification:[NSString stringWithFormat:@"%@:%d %@",@"state", (int)state, region]];
}
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self pushNotification:[NSString stringWithFormat:@"%@:%@", @"enter", region]];
}
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self pushNotification:[NSString stringWithFormat:@"%@:%@", @"exit", region]];
}
-(void)pushNotification:(NSString *)msg {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody =msg;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}
@end
