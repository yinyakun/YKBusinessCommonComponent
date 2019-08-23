//
//  LNSendEmail.m
//  LNPSRefProject
//
//  Created by yakun yin on 2017/8/2.
//  Copyright © 2017年 yakun yin. All rights reserved.
//

#import "LNSendEmail.h"
#import <MessageUI/MessageUI.h>

typedef void(^sendCB)(BOOL sendSuccess);

@interface LNSendEmail ()<MFMailComposeViewControllerDelegate,UIDocumentInteractionControllerDelegate>
@property (nonatomic, strong) NSString                      *title;
@property (nonatomic, strong) NSString                      *defaultBody;
@property (nonatomic, strong) NSArray<NSString *>           *emailAddress;
@property (nonatomic, strong) UIDocumentInteractionController * documentInteractionController;
@property (nonatomic,copy)sendCB sendcb;
@end

@implementation LNSendEmail

+ (instancetype)shareManager{
    static LNSendEmail *emial = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (emial == nil) {
            emial = [[self alloc] init];
        }
    });
    return emial;
}
- (void)sendEmailWithTitle:(NSString *)title emailed:(NSArray<NSString *>*)emialAddress body:(NSString *)defaultBody andCallBack:(void(^)(BOOL isSuccess))cb{
    if (cb) {
        self.sendcb = cb;
    }
    self.title = title;
    self.emailAddress = emialAddress;
    self.defaultBody = defaultBody;
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    if (controller != nil) {
        controller.mailComposeDelegate = self;
        [controller setToRecipients:emialAddress];
        [controller setSubject:title];
        [controller setMessageBody:defaultBody isHTML:YES];
        [[self getCurrentVC] presentViewController:controller animated:YES completion:nil];
    }else{
        [self launchMailAppOnDevice];
    }

}
- (void)sendEmailWithTitle:(NSString *)title emailed:(NSArray<NSString *>*)emialAddress body:(NSString *)defaultBody attachmentData:(NSData *)data andCallBack:(void(^)(BOOL isSuccess))cb{
    if (cb) {
        self.sendcb = cb;
    }
    self.title = title;
    self.emailAddress = emialAddress;
    self.defaultBody = defaultBody;
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    if (controller != nil) {
        controller.mailComposeDelegate = self;
        [controller setToRecipients:emialAddress];
        [controller setSubject:title];
        [controller setMessageBody:defaultBody isHTML:YES];
        [controller addAttachmentData:data mimeType:@"" fileName:@"image.png"];
        [[self getCurrentVC] presentViewController:controller animated:YES completion:nil];
    }else{
        [self launchMailAppOnDevice];
    }

}
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        if(self.sendcb){self.sendcb(YES);};
    }else{
        if(self.sendcb){self.sendcb(NO);};
    }
    [[self getCurrentVC] dismissViewControllerAnimated:YES completion:^{

    }];
}

-(void)launchMailAppOnDevice {
    NSString *recipients;
    if (self.emailAddress.count) {
        recipients = [NSString stringWithFormat:@"mailto:%@&subject=%@",self.emailAddress[0],self.title];
    }else{
        recipients = [NSString stringWithFormat:@"mailto:subject=%@",self.title];
    }
    NSString *body =[NSString stringWithFormat:@"&body=%@",self.defaultBody];
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}


    //- (void)shareToWhatsappWithBody:(NSString *)defaultBody{
    //    NSString *str_url = [NSString stringWithFormat:@"whatsapp://send?text=%@",[defaultBody stringByURLEncode]];
    //    NSURL *whatsappURL = [NSURL URLWithString:str_url];
    //    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
    //        [[UIApplication sharedApplication] openURL: whatsappURL];
    //    }else{
    //        UIAlertView * alertV = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Can't find WhatsApp." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    //        [alertV show];
    //    }
    //}

- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
        {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
            {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
                {
                window = tmpWin;
                break;
                }
            }
        }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];

    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;

    return result;
}


@end
