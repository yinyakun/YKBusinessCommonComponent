//
//  LNSendEmail.h
//  LNPSRefProject
//
//  Created by yakun yin on 2017/8/2.
//  Copyright © 2017年 yakun yin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LNSendEmail : NSObject
+ (instancetype)shareManager;

/**
 发送邮件

 @param title 邮件标题
 @param emialAddress 要给发送人的 邮箱地址 数组
 @param defaultBody 默认邮件内容
 */
- (void)sendEmailWithTitle:(NSString *)title emailed:(NSArray<NSString *>*)emialAddress body:(NSString *)defaultBody andCallBack:(void(^)(BOOL isSuccess))cb;

/**
 发送邮件 ,包含附件

 @param title 邮件标题
 @param emialAddress 要发送人的邮箱地址 数组
 @param defaultBody 默认邮件内容
 @param data 附件内容(Image)
 @param cb 是否成功回调
 */
- (void)sendEmailWithTitle:(NSString *)title emailed:(NSArray<NSString *>*)emialAddress body:(NSString *)defaultBody attachmentData:(NSData *)data andCallBack:(void(^)(BOOL isSuccess))cb;


/**
 分享到 whatsapp

 @param defaultBody  分享的内容
 */
    //- (void)shareToWhatsappWithBody:(NSString *)defaultBody;
@end

