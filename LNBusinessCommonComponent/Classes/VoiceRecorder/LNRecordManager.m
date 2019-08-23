//
//  LNRecordManager.m
//  YKFuncation_Example
//
//  Created by 尹亚坤 on 2018/11/14.
//  Copyright © 2018 yinyakun. All rights reserved.
//

#import "LNRecordManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <objc/message.h>
#import <CommonCrypto/CommonDigest.h>
#import "LNTranslateRequest.h"

#define tenK 3 * 4096
#define kSandboxPathStr [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
#define kCafFileName @"myRecord.caf"
/**
 *存放所有的音乐播放器
 */
static NSMutableDictionary *_musices;
static long long voiceIndex = 0;
@interface LNRecordManager ()<AVAudioRecorderDelegate>
{
    AudioUnit recordUnit;
    AudioBufferList *bufferList;
    //临时缓存文件
    NSMutableData *tempPcmData;
    AudioComponentDescription recordDesc;

    NSString *filePath;
    NSString *fileName;
}

/**
 开始录音,录音过程中的回调
 */
@property (nonatomic,copy)LNRecordBlock toRecordCallback;

/**
 录音结束调用的回调
 */
@property (nonatomic,copy)LNRecordBlock stopRecordCallback;

/**
 录音失败调用的回调
 */
@property (nonatomic,copy) LNRecordFailedBlock failedRecordCallback;


/**
 分贝回调
 */
@property (nonatomic,copy)LNRecordBlock dbCallback;

/**
 声音文件的沙盒路径
 */
@property (nonatomic,copy)NSURL *voiceURL;

/**
 录音文件转文字请求
 */
@property (nonatomic,strong)LNTranslateRequest *request;

//@property (nonatomic,strong)NSString *filePath;
@end

@implementation LNRecordManager

+ (instancetype)shareInstance{
    static LNRecordManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self  new];
        [instance initData];
    });
    return instance;
}

- (void)initData{
    _request = [[LNTranslateRequest alloc] init];
}

- (void)initRecord{
    voiceIndex = 0;
    tempPcmData = [NSMutableData data];
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&error];
    [[AVAudioSession sharedInstance] setPreferredIOBufferDuration:0.022 error:&error];
    if (error) {
//        NSLog(@"audiosession error is %@",error.localizedDescription);
        return;
    }
    recordDesc.componentType = kAudioUnitType_Output;
    recordDesc.componentSubType = kAudioUnitSubType_RemoteIO;
    recordDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    recordDesc.componentFlags = 0;
    recordDesc.componentFlagsMask = 0;

    AudioComponent recordComponent = AudioComponentFindNext(NULL, &recordDesc);
    OSStatus status;
    status = AudioComponentInstanceNew(recordComponent, &recordUnit);
    if (status != noErr) {
        NSLog(@"AudioComponentInstanceNew status is %d",(int)status);
    }
    AudioStreamBasicDescription recordFormat;
    recordFormat.mSampleRate = 16000;   //采样率
    recordFormat.mFormatID = kAudioFormatLinearPCM; //格式
    recordFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked; //标签格式
    recordFormat.mFramesPerPacket = 1;  //每个packet 的帧数量
    recordFormat.mChannelsPerFrame = 1;            // 1. 单声道,2. 立体声
    recordFormat.mBitsPerChannel = 16;             // 语音每采样点占用位数[8,16,24,32]
    recordFormat.mBytesPerFrame = 2;                // 每帧的bytes 数
    recordFormat.mBytesPerPacket = 2;               // 每个packet 的bytes 数量
    status = AudioUnitSetProperty(recordUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &recordFormat, sizeof(recordFormat));
    if (status != noErr) {
        NSLog(@"AudioUnitSetProperty status is %d",(int)status);
    }
    // enable record
    UInt32 flag = 1;
    status = AudioUnitSetProperty(recordUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  1,
                                  &flag,
                                  sizeof(flag));
    if (status != noErr) {
//        NSLog(@"AudioUnitGetProperty error, ret: %d", status);
    }
    AURenderCallbackStruct recordCallback;
    recordCallback.inputProcRefCon = (__bridge void * _Nullable)(self);
    recordCallback.inputProc = RecordCallback;
    status = AudioUnitSetProperty(recordUnit, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Output, 1, &recordCallback, sizeof(recordCallback));
    if (status != noErr) {
//        NSLog(@"AURenderCallbackStruct error, ret: %d", status);
    }
    [self initBufferList];
    AudioUnitInitialize(recordUnit);
}

static OSStatus RecordCallback(void *inRefCon,
                               AudioUnitRenderActionFlags *ioActionFlags,
                               const AudioTimeStamp *inTimeStamp,
                               UInt32 inBusNumber,
                               UInt32 inNumberFrames,
                               AudioBufferList *ioData){
    LNRecordManager *self = (__bridge LNRecordManager*)inRefCon;
    if (inNumberFrames > 0) {
        self->bufferList->mNumberBuffers = 1;
        OSStatus stauts = AudioUnitRender(self->recordUnit, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, self->bufferList);
        if (stauts != noErr) {
//            NSLog(@"recordcallback error is %d",stauts);
        }
        [self->tempPcmData appendBytes:self->bufferList->mBuffers[0].mData length:self->bufferList->mBuffers[0].mDataByteSize];
        BOOL isquite = [self isQuite:self->tempPcmData andDBCB:^(NSDictionary *dict) {
            if (self.dbCallback) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.dbCallback(@{@"db":[NSString stringWithFormat:@"%@",dict[@"db"]]});
                });
            }
        }];
        if (!isquite) {
            if (self->tempPcmData.length > tenK) {
                voiceIndex ++;

//                [self asyncDo:@selector(writeFile:) host:self info:@(NO)];
                [self writeFile:NO];
            }
        }
        // 1. 先存本地
        // 2. 发送完整文件
    }
    return noErr;
}

-(BOOL)isQuite:(NSData *)pcmData andDBCB:(void(^)(NSDictionary *dict))cb
{
    if (pcmData == nil){
        return NO;
    }
    long long pcmAllLenght = 0;
    short butterByte[pcmData.length/2];
    memcpy(butterByte, pcmData.bytes, pcmData.length);//frame_size * sizeof(short)
    // 将 buffer 内容取出，进行平方和运算
    for (int i = 0; i < pcmData.length/2; i++){
        pcmAllLenght += butterByte[i] * butterByte[i];
    }
    // 平方和除以数据总长度，得到音量大小。
    double mean = pcmAllLenght / (double)pcmData.length;
    double volume =10*log10(mean);//volume为分贝数大小
    if (cb) {
        cb(@{@"db":[NSString stringWithFormat:@"%f",volume]});
    }
    //45分贝
    if (volume >= 45){
        //在说话
        return NO;
    }
    return YES;
}


//- (NSString *)filePath{
//    if (_filePath) {
//        return _filePath;
//    }
//    NSString *folderPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"wav"];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSError *error;
//    [fileManager createDirectoryAtPath:folderPath
//           withIntermediateDirectories:YES
//                            attributes:nil
//                                 error:&error];
//    NSString *filePath = [folderPath stringByAppendingPathComponent:@"record.pcm"];
//    [fileManager createFileAtPath:filePath contents:nil
//                       attributes:nil];
//    NSLog(@"filePath is %@",filePath);
//    return filePath;
//}
- (NSString *)creatFilePath{
    NSString *folderPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"wav"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager createDirectoryAtPath:folderPath
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:&error];
    NSString *filePath = [folderPath stringByAppendingPathComponent:@"record.pcm"];
    [fileManager createFileAtPath:filePath contents:nil
                       attributes:nil];
    NSLog(@"filePath is %@",filePath);
    return filePath;
}
- (void)writeFile:(BOOL)isover{
    NSString *path = [self creatFilePath];
    [tempPcmData writeToFile:path options:NSDataWritingAtomic error:nil];
    tempPcmData = nil;
    tempPcmData = [NSMutableData data];
    filePath = path;
    [self callbackToOut:isover];

}

- (void)callbackToOut:(BOOL)isOver{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isOver) {
            if (self.stopRecordCallback) {
                self.stopRecordCallback(@{
                                          @"fileURL":self->filePath,
                                          @"isOver":[NSString stringWithFormat:@"%d",isOver],
                                          @"currentIndex":[NSString stringWithFormat:@"%lld",voiceIndex]
                                          });
            }
        }else{
            if(self.toRecordCallback)
                self.toRecordCallback(
                                      @{@"fileURL":self->filePath,
                                        @"isOver":[NSString stringWithFormat:@"%d",isOver],
                                        @"currentIndex":[NSString stringWithFormat:@"%lld",voiceIndex]
                                        });
        }
    });
}

- (void)recordAction{
    [self initRecord];
    AudioOutputUnitStart(recordUnit);
}

- (void)stopRecord{
    AudioOutputUnitStop(recordUnit);
    AudioUnitUninitialize(recordUnit);
    [self releaseBufferList];
    [self performSelectorOnMainThread:@selector(disposeCoreAudio) withObject:nil waitUntilDone:NO];
    voiceIndex = 0;
    [self writeFile:YES];
}
- (void)releaseBufferList{
    if (bufferList != NULL) {
        if (bufferList->mBuffers[0].mData) {
            free(bufferList->mBuffers[0].mData);
            bufferList->mBuffers[0].mData = NULL;
        }
        free(bufferList);
        bufferList = NULL;
    }
}

- (void)initBufferList{
    uint32_t numberBuffers = 1;
    UInt32 bufferSize = 4096;

    bufferList = (AudioBufferList*)malloc(sizeof(AudioBufferList));
    bufferList->mNumberBuffers = numberBuffers;
    bufferList->mBuffers[0].mData = malloc(bufferSize);
    bufferList->mBuffers[0].mDataByteSize = bufferSize;
    bufferList->mBuffers[0].mNumberChannels = 1;
}
-(void) disposeCoreAudio
{
    AudioComponentInstanceDispose(recordUnit);
    recordUnit = nil;
}


- (void)beginTranslateWithClientID:(NSString *)clientID clientSecret:(NSString *)secret andCB:(LNRecordBlock)callback{
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    if (callback) {
        self.toRecordCallback = callback;
    }
    [self recordAction];
}

- (void)stopWithCallBack:(LNRecordBlock)callback{
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    if (callback) {
        self.stopRecordCallback = callback;
    }
    [self stopRecord];
}

#pragma mark ===========外部调用================
- (void)translateBeginWithClientID:(NSString *)clientID clientSecret:(NSString *)secret appKey:(NSString *)appKey translateCB:(LNRecordBlock)cb andDBCB:(LNRecordBlock)dbCB{
    if (!clientID) {
        NSLog(@"clientID 不存在");
        return;
    }
    if (!secret) {
        NSLog(@"secret 不存在");
        return;
    }
    if (!appKey) {
        NSLog(@"appkey 不存在");
        return;
    }
    if (dbCB) {
        self.dbCallback = dbCB;
    }
    if (cb) {
        self.toRecordCallback  = cb;
    }

    self.clientID = clientID;
    self.clientSecret = secret;
    self.appKey = appKey;
    fileName = [LNRecordManager  getNowTimeTimestamp3];
    [[LNRecordManager shareInstance] beginTranslateWithClientID:clientID clientSecret:secret andCB:^(NSDictionary *callback) {
        NSString *filePath = callback[@"fileURL"];
        NSString *currentIndex = callback[@"currentIndex"];
        self.request.madpAuthkey = [[LNRecordManager shareInstance] calculateAuthKey];
        self.request.appKey = self.appKey;
//        [self.request translateWithFileURL:filePath currentIndex:currentIndex over:NO fileName:self->fileName andCB:^(NSDictionary *dict) {
//            NSDictionary *resultDict = dict[@"content"];
//            if ([resultDict[@"code"] integerValue] == 0) {
//                NSString *content = resultDict[@"result"][@"rawText"] ? resultDict[@"result"][@"rawText"] : @"";
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    cb(@{@"content":content});
//                });;
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    cb(@{@"content":content});
//                });
//            }
//
//        }];
        [self.request translateWithFileURL:filePath currentIndex:currentIndex over:NO fileName:fileName andSuccessBlock:^(NSDictionary *dict) {
            NSDictionary *resultDict = dict[@"content"];
            if ([resultDict[@"code"] integerValue] == 0) {
                NSString *content = resultDict[@"result"][@"rawText"] ? resultDict[@"result"][@"rawText"] : @"";
                dispatch_async(dispatch_get_main_queue(), ^{
                    cb(@{@"content":content});
                });;
                dispatch_async(dispatch_get_main_queue(), ^{
                    cb(@{@"content":content});
                });
            }
        } andFailedBlock:^(NSDictionary *dict) {
            if (self.failedRecordCallback) {
                NSError *error = [callback valueForKey:@"content"];
                self.failedRecordCallback(error);
            }
        }];
    }];
}

//- (void)translateBeginWithClientID:(NSString *)clientID clientSecret:(NSString *)secret appKey:(NSString *)appKey translateCB:(LNRecordBlock)cb andDBCB:(LNRecordBlock)dbCB andFailedBlock:(LNRecordBlock)failedBlock {
//    self.failedRecordCallback = failedBlock;
//    [self translateBeginWithClientID:clientID clientSecret:secret appKey:appKey translateCB:cb andDBCB:dbCB];
//}
- (void)translateBeginWithClientID:(NSString *)clientID clientSecret:(NSString *)secret appKey:(NSString *)appKey translateCB:(LNRecordBlock)cb andDBCB:(LNRecordBlock)dbCB andFailedBlock:(LNRecordFailedBlock)failedBlock {
    
    self.failedRecordCallback = failedBlock;
    [self translateBeginWithClientID:clientID clientSecret:secret appKey:appKey translateCB:cb andDBCB:dbCB];
}

- (void)translateEnd:(LNRecordBlock)cb{
    [[LNRecordManager shareInstance] stopWithCallBack:^(NSDictionary *callback) {
        NSString *filePath = callback[@"fileURL"];
        NSString *currentIndex = callback[@"currentIndex"];
        self.request.madpAuthkey = [[LNRecordManager shareInstance] calculateAuthKey];
        [self.request translateWithFileURL:filePath currentIndex:currentIndex over:YES fileName:self->fileName andCB:^(NSDictionary *dict) {
            NSDictionary *resultDict = dict[@"content"];
            if ([resultDict[@"code"] integerValue] == 0) {
                NSString *content = resultDict[@"result"][@"rawText"] ? resultDict[@"result"][@"rawText"] : @"";
                dispatch_async(dispatch_get_main_queue(), ^{
                    cb(@{@"content":content});
                });;
                dispatch_async(dispatch_get_main_queue(), ^{
                    cb(@{@"content":content});
                });
            }
        }];
    }];
}

- (void)asyncDo:(SEL)doSomething host:(id)host info:(id)info{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ((void(*)(id,SEL, id,id))objc_msgSend)(host,doSomething,info,nil);
    });
}
- (NSString *)calculateAuthKey{
    NSString *timeTemp = [LNRecordManager getNowTimeTimestamp3];
    NSString *beforeStr = [NSString stringWithFormat:@"%@%@AT%@",self.clientID,self.clientSecret,timeTemp];
    NSString *afterStr = [LNRecordManager md5:beforeStr];
    NSString *subAfterStr = [afterStr substringWithRange:NSMakeRange(8, 16)];
    NSString *resultStr = [NSString stringWithFormat:@"%@.%@",subAfterStr,timeTemp];
    return resultStr;
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

+ (NSString *) md5:(NSString *) str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
