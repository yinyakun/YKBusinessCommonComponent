//
//  LNTranslateRequest.h
//  YKFuncation_Example
//
//  Created by 尹亚坤 on 2018/11/15.
//  Copyright © 2018 yinyakun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^translateResult)(NSDictionary *dict);

typedef void(^translateErrorResult)(NSDictionary *dict);

NS_ASSUME_NONNULL_BEGIN

@interface LNTranslateRequest : NSObject
@property (nonatomic, copy)NSString * madpAuthkey;
@property (nonatomic, copy)NSString * appKey;


- (void)translateWithFileURL:(NSString *)fileURL
                currentIndex:(NSString *)currentIndex
                        over:(BOOL )over
                    fileName:(NSString *)fileName
                       andCB:(translateResult)result;

- (void)translateWithFileURL:(NSString *)fileURL
                currentIndex:(NSString *)currentIndex
                        over:(BOOL )over
                    fileName:(NSString *)fileName
                       andSuccessBlock:(translateResult)successResult andFailedBlock:(translateResult)failedBlock;


@end

NS_ASSUME_NONNULL_END
