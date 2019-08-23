//
//  LNViewController.m
//  LNBusinessCommonComponent
//
//  Created by yinyakun on 12/07/2018.
//  Copyright (c) 2018 yinyakun. All rights reserved.
//

#import "LNViewController.h"
//#import "LNSendEmail.h"
//#import <LNSendEmail.h>
#import <LNBusinessCommonComponent/LNWaterImageHelper.h>
#import "LNRecordManager.h"

@interface LNViewController ()

@end

@implementation LNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [LNWaterImageHelper hostView:self.view text:@"yinyk1" andMarkFont:[UIFont boldSystemFontOfSize:20] andMarkColor:[UIColor redColor]];
}
- (IBAction)sendEmail:(id)sender {
//    [[LNSendEmail shareManager] showWithTitle:@"发送邮件" emailed:@[@"yinyk1@lenovo.com"] body:@"hello ,send Email" andCallBack:^(BOOL isSuccess) {
//
//    }];
/*
 NSString *const PORTAL_MADP_APP_KEY = @"C725FFB7B8EE452EA03662948332FAE3";//企业
 NSString *const PORTAL_MADP_CLIENT_ID = @"577A2EF38A734E889963E8F7D4C4781F";
 NSString *const PORTAL_MADP_CLIENT_Secret = @"FB89B24CAAC54F0195F68EF64B10F485";
 */
//    [[LNRecordManager shareInstance] translateBeginWithClientID:@"577A2EF38A734E889963E8F7D4C4781F" clientSecret:@"FB89B24CAAC54F0195F68EF64B10F485" appKey:@"C725FFB7B8EE452EA03662948332FAE3" translateCB:^(NSDictionary *callback) {
//        NSLog(@"%@",callback);
//    } andDBCB:^(NSDictionary *callback) {
//        NSLog(@"%@",callback);
//    }];

    [[LNRecordManager shareInstance] translateBeginWithClientID:@"577A2EF38A734E889963E8F7D4C4781F" clientSecret:@"FB89B24CAAC54F0195F68EF64B10F485" appKey:@"C725FFB7B8EE452EA03662948332FAE3" translateCB:^(NSDictionary *callback) {
            NSLog(@"%@",callback);

    } andDBCB:^(NSDictionary *callback) {
        NSLog(@"%@",callback);

    } andFailedBlock:^(NSError *error) {
        NSLog(@"%@",error);

    }];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    translateEnd
    [[LNRecordManager shareInstance] translateEnd:^(NSDictionary *callback) {
        NSLog(@"endddddddddd");
        NSLog(@"%@",callback);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
