//
//  baseViewController.h
//  simpeBeacon
//
//  Created by uehara akihiro on 2013/10/20.
//  Copyright (c) 2013年 REINFORCE Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

// estimote default UUID
#define kBeaconUUID  @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
// random UUID
//#define kBeaconUUID  @"C7FC8659-DEE1-4B64-880A-83EAE89C59C3"

#define kIdentifier  @"com.reinforce-lab"
#define kPassBookURL @"https://pass.is/1B7fvaX1VrrZMqn"

@interface baseViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *uuidTextLabel;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;

- (IBAction)clearButtonTouchUpInside:(id)sender;

-(void)writeLog:(NSString *)log;
-(void)showAleart:(NSString *)message;
@end
