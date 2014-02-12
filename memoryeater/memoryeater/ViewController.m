//
//  ViewController.m
//  memoryeater
//
//  Created by uehara akihiro on 2014/02/11.
//  Copyright (c) 2014年 REINFORCE Lab. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    NSMutableString *_text;
    int *_buf[10000];
    int index;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _text = [[NSMutableString alloc] init];
    self.textView.text = @"";
}

- (void)didReceiveMemoryWarning
{
    [self printMessage:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startButtonTouchUpInside:(id)sender {
    [self printMessage:@"starting..."];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerFired:) userInfo:Nil repeats:YES];
}

-(void)timerFired:(NSTimer *)timer {
    [self printMessage:[NSString stringWithFormat:@"%d", index]];
    
    const int sizeOfBuf = sizeof(int) * 10000000; // allocate 10Mwords
    _buf[index] = malloc(sizeOfBuf);
    memset(_buf[index], 0, sizeOfBuf);
    index++;
}

-(void)printMessage:(NSString *)msg {
     [_text appendFormat:@"%@\n", msg];
    self.textView.text = _text;
}
@end
