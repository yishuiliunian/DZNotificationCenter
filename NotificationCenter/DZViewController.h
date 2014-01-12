//
//  DZViewController.h
//  NotificationCenter
//
//  Created by Stone Dong on 14-1-13.
//  Copyright (c) 2014年 Stone Dong. All rights reserved.
//

#import <UIKit/UIKit.h>
static NSString* const kDZMessageTest = @"kDZMessageTest";

@protocol DZTestMessageInterface <NSObject>

- (void) handleTestMessageWithKey:(NSString*)key;

@end

@interface DZViewController : UIViewController
@property (nonatomic, weak) IBOutlet UIButton* sendMessageButton;
@property (nonatomic, weak) IBOutlet UILabel* showLabel;

- (IBAction)sendMessage:(id)sender;

@end
