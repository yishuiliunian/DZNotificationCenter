//
//  DZViewController.m
//  NotificationCenter
//
//  Created by Stone Dong on 14-1-13.
//  Copyright (c) 2014年 Stone Dong. All rights reserved.
//

#import "DZViewController.h"
#import "DZNotificationCenter.h"
@interface DZViewController () <DZTestMessageInterface>

@end

@implementation DZViewController

- (void) dealloc
{
    [DZDefaultNotificationCenter removeObserver:self];
}

- (void) handleTestMessageWithKey:(NSString *)key
{
    self.showLabel.text = [NSString stringWithFormat:@"get message with %@", key];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [DZDefaultNotificationCenter addObserver:self forKey:kDZMessageTest];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)sendMessage:(id)sender
{
    [DZDefaultNotificationCenter postMessage:kDZMessageTest userInfo:@{@"key":[[NSDate date] description] }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
