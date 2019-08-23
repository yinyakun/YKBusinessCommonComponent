//
//  LNTranslateRequest.m
//  YKFuncation_Example
//
//  Created by 尹亚坤 on 2018/11/15.
//  Copyright © 2018 yinyakun. All rights reserved.
//

#import "LNTranslateRequest.h"
#import "AFNetworking.h"
#import <sys/utsname.h>
@interface LNTranslateRequest()
{
    NSString *currentIndex;
    BOOL over;
    NSString *fileNameUUID;
    AFHTTPSessionManager *manager;
}

@property (nonatomic, copy) translateResult failedResultBlock;

@end

@implementation LNTranslateRequest

- (instancetype)init{
    self = [super init];
    if (self) {
        manager = [AFHTTPSessionManager manager];
    }
    return self;
}

- (void)translateWithFileURL:(NSString *)fileURL  currentIndex:(NSString *)current over:(BOOL )isOver fileName:(NSString *)fileName  andCB:(translateResult)result{
    currentIndex = current;
    over         = isOver;
    fileNameUUID = fileName;

    NSString *requestStr = [NSString stringWithFormat:@"%@%@/voice/transform",@"https://wngfp.unifiedcloud.lenovo.com/madp-voice-service/v1/tenants/lenovo/apps/",self.appKey];//09E2C806795846B0A29B98C469C333DF/voice/transform";
        //创建会话管理者

    /* 设置请求和接收的数据编码格式 */
    manager.requestSerializer = [AFJSONRequestSerializer serializer]; // 设置请求数据为 JSON 数据
    manager.responseSerializer = [AFJSONResponseSerializer serializer]; // 设置接收数据为 JSON 数据

    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    [manager.requestSerializer setValue:self.madpAuthkey forHTTPHeaderField:@"madp-authkey"];
    [manager.requestSerializer setValue:self.appKey forHTTPHeaderField:@"appKey"];
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];

    NSDictionary *sendDict = [self requestParams];

    [manager POST:requestStr parameters:sendDict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:fileURL] name:@"voice-data" error:nil];
    }progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (result) {
            if ([[responseObject objectForKey:@"code"] integerValue] == 0) {
                result(@{@"content":responseObject});
            }else{
            }}
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"上传失败.%@",error);
        if (self.failedResultBlock) {
            self.failedResultBlock(@{@"content":error});
        }
    }];
}

- (void)translateWithFileURL:(NSString *)fileURL currentIndex:(NSString *)currentIndex over:(BOOL)over fileName:(NSString *)fileName andSuccessBlock:(translateResult)successResult andFailedBlock:(translateResult)failedBlock {
    self.failedResultBlock = failedBlock;
    [self translateWithFileURL:fileURL currentIndex:currentIndex over:over fileName:fileName andCB:successResult];
}


- (NSDictionary *)requestParams{
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//    NSString* phoneModel = [[UIDevice currentDevice] model];
    NSString* phoneModel = [self iphoneName];
    return @{
             @"platform":   @"ios",
             @"name"    :   @"test",
             @"version" :   @"1.0.0",
             @"vdm"     :   @"all",
             @"did"     :   uuid,
             @"dtp"     :   phoneModel,
             @"ixid"    :   fileNameUUID,//[LNTranslateRequest getNowTimeTimestamp3],
             @"pidx"    :   currentIndex,
             @"uid"     :   @"101",
             @"over"    :   [NSString stringWithFormat:@"%d",over]
             };
}

+(NSString *)getNowTimeTimestamp3{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SSS"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
                                                          //设置时区,这个对于时间的处理有时很重要
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]*1000];
    return timeSp;
}
/**
 获取设备名称
 */
- (NSString *)iphoneName
{
    struct utsname systemInfo;
    uname(&systemInfo); // 获取系统设备信息
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];

    NSDictionary *dict = @{
                           // iPhone
                           @"iPhone5,3" : @"iPhone 5c",
                           @"iPhone5,4" : @"iPhone 5c",
                           @"iPhone6,1" : @"iPhone 5s",
                           @"iPhone6,2" : @"iPhone 5s",
                           @"iPhone7,1" : @"iPhone 6 Plus",
                           @"iPhone7,2" : @"iPhone 6",
                           @"iPhone8,1" : @"iPhone 6s",
                           @"iPhone8,2" : @"iPhone 6s Plus",
                           @"iPhone8,4" : @"iPhone SE",
                           @"iPhone9,1" : @"iPhone 7",
                           @"iPhone9,2" : @"iPhone 7 Plus",
                           @"iPhone10,1" : @"iPhone 8",
                           @"iPhone10,4" : @"iPhone 8",
                           @"iPhone10,2" : @"iPhone 8 Plus",
                           @"iPhone10,5" : @"iPhone 8 Plus",
                           @"iPhone10,3" : @"iPhone X",
                           @"iPhone10,6" : @"iPhone X",
                           @"iPhone11,2" : @"iPhone XS",
                           @"iPhone11,4" : @"iPhone XS Max",
                           @"iPhone11,6" : @"iPhone XS Max",
                           @"iPhone11,8" : @"iPhone XR",
                           @"i386" : @"iPhone Simulator",
                           @"x86_64" : @"iPhone Simulator",
                           // iPad
                           @"iPad4,1" : @"iPad Air",
                           @"iPad4,2" : @"iPad Air",
                           @"iPad4,3" : @"iPad Air",
                           @"iPad5,3" : @"iPad Air 2",
                           @"iPad5,4" : @"iPad Air 2",
                           @"iPad6,7" : @"iPad Pro 12.9",
                           @"iPad6,8" : @"iPad Pro 12.9",
                           @"iPad6,3" : @"iPad Pro 9.7",
                           @"iPad6,4" : @"iPad Pro 9.7",
                           @"iPad6,11" : @"iPad 5",
                           @"iPad6,12" : @"iPad 5",
                           @"iPad7,1" : @"iPad Pro 12.9 inch 2nd gen",
                           @"iPad7,2" : @"iPad Pro 12.9 inch 2nd gen",
                           @"iPad7,3" : @"iPad Pro 10.5",
                           @"iPad7,4" : @"iPad Pro 10.5",
                           @"iPad7,5" : @"iPad 6",
                           @"iPad7,6" : @"iPad 6",
                           // iPad mini
                           @"iPad2,5" : @"iPad mini",
                           @"iPad2,6" : @"iPad mini",
                           @"iPad2,7" : @"iPad mini",
                           @"iPad4,4" : @"iPad mini 2",
                           @"iPad4,5" : @"iPad mini 2",
                           @"iPad4,6" : @"iPad mini 2",
                           @"iPad4,7" : @"iPad mini 3",
                           @"iPad4,8" : @"iPad mini 3",
                           @"iPad4,9" : @"iPad mini 3",
                           @"iPad5,1" : @"iPad mini 4",
                           @"iPad5,2" : @"iPad mini 4",
                           // Apple Watch
                           @"Watch1,1" : @"Apple Watch",
                           @"Watch1,2" : @"Apple Watch",
                           @"Watch2,6" : @"Apple Watch Series 1",
                           @"Watch2,7" : @"Apple Watch Series 1",
                           @"Watch2,3" : @"Apple Watch Series 2",
                           @"Watch2,4" : @"Apple Watch Series 2",
                           @"Watch3,1" : @"Apple Watch Series 3",
                           @"Watch3,2" : @"Apple Watch Series 3",
                           @"Watch3,3" : @"Apple Watch Series 3",
                           @"Watch3,4" : @"Apple Watch Series 3",
                           @"Watch4,1" : @"Apple Watch Series 4",
                           @"Watch4,2" : @"Apple Watch Series 4",
                           @"Watch4,3" : @"Apple Watch Series 4",
                           @"Watch4,4" : @"Apple Watch Series 4"
                           };
    NSString *name = dict[platform];

    return name ? name : platform;
}


@end
