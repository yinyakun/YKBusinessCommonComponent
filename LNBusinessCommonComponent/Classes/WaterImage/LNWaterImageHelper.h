//
//  LNWaterImageHelper.h
//  LNBusinessComponent_Example
//
//  Created by 尹亚坤 on 2019/1/8.
//  Copyright © 2019 yinyakun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LNWaterImageHelper : NSObject

+ (UIImage *)getWaterMarkImage: (UIImage *)originalImage andTitle: (NSString *)title andMarkFont: (UIFont *)markFont andMarkColor: (UIColor *)markColor;

+(UIImage*)view:(UIImageView *)view WaterImageWithImage:(UIImage *)image text:(NSString *)text andMarkFont: (UIFont *)markFont andMarkColor: (UIColor *)markColor;

+(BOOL)hostView:(UIView *)view text:(NSString *)text andMarkFont: (UIFont *)markFont andMarkColor: (UIColor *)markColor;

@end

NS_ASSUME_NONNULL_END
