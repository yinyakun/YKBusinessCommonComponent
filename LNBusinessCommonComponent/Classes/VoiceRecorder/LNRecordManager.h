//
//  LNRecordManager.h
//  YKFuncation_Example
//
//  Created by 尹亚坤 on 2018/11/14.
//  Copyright © 2018 yinyakun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LNRecordBlock)(NSDictionary *callback);

typedef void(^LNRecordFailedBlock)(NSError *error);


@class LNRecordManager;
@protocol LNRecordDelegate <NSObject>

- (void)startRecord:(LNRecordManager *)recordmanager;

- (void)finishedRecord:(LNRecordManager *)recordmanager result:(NSDictionary *)result;
@end

NS_ASSUME_NONNULL_BEGIN

@interface LNRecordManager : NSObject
@property (nonatomic, copy)NSString * clientID;
@property (nonatomic, copy)NSString * clientSecret;
@property (nonatomic, copy)NSString * appKey;

+ (instancetype)shareInstance;
//语音文件播放测试
- (void)translateEnd:(LNRecordBlock)cb;
- (void)translateBeginWithClientID:(NSString *)clientID clientSecret:(NSString *)secret appKey:(NSString *)appKey translateCB:(LNRecordBlock)cb andDBCB:(LNRecordBlock)dbCB;

- (void)translateBeginWithClientID:(NSString *)clientID clientSecret:(NSString *)secret appKey:(NSString *)appKey translateCB:(LNRecordBlock)cb andDBCB:(LNRecordBlock)dbCB andFailedBlock:(LNRecordFailedBlock)failedBlock;

@end

NS_ASSUME_NONNULL_END
