//
//  LNShareManager.m
//  AFNetworking
//
//  Created by 尹亚坤 on 2019/3/28.
//

#import "LNShareManager.h"

@implementation LNShareManager

+ (instancetype)shareInstance{
    static LNShareManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [LNShareManager new];
    });
    return instance;
}

- (void)list{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ShareList.plist" ofType:nil];
    if (!path) {
        NSLog(@"请创建plist 文件,配置APP 再使用");
        return;
    }
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSLog(@"%@",dict);
    NSDictionary *UAPPConfigDict = [dict objectForKey:@"UAPPConfig"];
    NSString *color = [UAPPConfigDict objectForKey:@"color"];
}
@end
