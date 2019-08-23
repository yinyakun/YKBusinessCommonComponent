//
//  LNWaterImageHelper.m
//  LNBusinessComponent_Example
//
//  Created by 尹亚坤 on 2019/1/8.
//  Copyright © 2019 yinyakun. All rights reserved.
//

#import "LNWaterImageHelper.h"

@implementation LNWaterImageHelper
#define HORIZONTAL_SPACE 30//水平间距
#define VERTICAL_SPACE 50//竖直间距
#define CG_TRANSFORM_ROTATION (M_PI_2 / 3)//旋转角度(正旋45度 || 反旋45度)


/**
 根据目标图片制作一个盖水印的图片

 @param originalImage 源图片
 @param title 水印文字
 @param markFont 水印文字font(如果不传默认为23)
 @param markColor 水印文字颜色(如果不传递默认为源图片的对比色)
 @return 返回盖水印的图片
 */
+ (UIImage *)getWaterMarkImage: (UIImage *)originalImage andTitle: (NSString *)title andMarkFont: (UIFont *)markFont andMarkColor: (UIColor *)markColor{
    return [self viewWithSize:originalImage.size WaterImageWithImage:originalImage text:title andMarkFont:markFont andMarkColor:markColor];
}

+(BOOL)hostView:(UIView *)view text:(NSString *)text andMarkFont: (UIFont *)markFont andMarkColor: (UIColor *)markColor{
    UIImageView *imgV = [[UIImageView alloc ] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)] ;
    imgV.alpha = 0.1;
    UIImage *image = [self view:imgV WaterImageWithImage:[UIImage new] text:text andMarkFont:[UIFont systemFontOfSize:18] andMarkColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
    imgV.image = image;
    [view addSubview:imgV];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [view bringSubviewToFront:imgV];
    });
    return YES;
}

    //根据图片获取图片的主色调
+(UIColor*)mostColor:(UIImage*)image{

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    int bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
#else
    int bitmapInfo = kCGImageAlphaPremultipliedLast;
#endif
        //第一步 先把图片缩小 加快计算速度. 但越小结果误差可能越大
    CGSize thumbSize=CGSizeMake(image.size.width/2, image.size.height/2);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 thumbSize.width,
                                                 thumbSize.height,
                                                 8,//bits per component
                                                 thumbSize.width*4,
                                                 colorSpace,
                                                 bitmapInfo);

    CGRect drawRect = CGRectMake(0, 0, thumbSize.width, thumbSize.height);
    CGContextDrawImage(context, drawRect, image.CGImage);
    CGColorSpaceRelease(colorSpace);

        //第二步 取每个点的像素值
    unsigned char* data = CGBitmapContextGetData (context);
    if (data == NULL) return nil;
    NSCountedSet *cls=[NSCountedSet setWithCapacity:thumbSize.width*thumbSize.height];

    for (int x=0; x<thumbSize.width; x++) {
        for (int y=0; y<thumbSize.height; y++) {
            int offset = 4*(x*y);
            int red = data[offset];
            int green = data[offset+1];
            int blue = data[offset+2];
            int alpha =  data[offset+3];
            if (alpha>0) {//去除透明
                if (red==255&&green==255&&blue==255) {//去除白色
                }else{
                    NSArray *clr=@[@(red),@(green),@(blue),@(alpha)];
                    [cls addObject:clr];
                }

            }
        }
    }
    CGContextRelease(context);
        //第三步 找到出现次数最多的那个颜色
    NSEnumerator *enumerator = [cls objectEnumerator];
    NSArray *curColor = nil;
    NSArray *MaxColor=nil;
    NSUInteger MaxCount=0;
    while ( (curColor = [enumerator nextObject]) != nil )
        {
        NSUInteger tmpCount = [cls countForObject:curColor];
        if ( tmpCount < MaxCount ) continue;
        MaxCount=tmpCount;
        MaxColor=curColor;

        }
    return [UIColor colorWithRed:([MaxColor[0] intValue]/255.0f) green:([MaxColor[1] intValue]/255.0f) blue:([MaxColor[2] intValue]/255.0f) alpha:([MaxColor[3] intValue]/255.0f)];
}




    // * 这三个属性 主要是让水印文字和水印文字之间间隔的效果，以及水印的文字的倾斜角度 ，不设置默认为平行角度*/
#define HORIZONTAL_SPACEING 30//水平间距
#define VERTICAL_SPACEING 50//竖直间距
#define CG_TRANSFORM_ROTATING (M_PI_2 / 3)//旋转角度(正旋45度 || 反旋45度)

+(UIImage*)view:(UIImageView *)view WaterImageWithImage:(UIImage *)image text:(NSString *)text andMarkFont: (UIFont *)markFont andMarkColor: (UIColor *)markColor{
    return [self viewWithSize:view.bounds.size WaterImageWithImage:image text:text andMarkFont:markFont andMarkColor:markColor];
}


+(UIImage*)viewWithSize:(CGSize)size WaterImageWithImage:(UIImage *)image text:(NSString *)text andMarkFont: (UIFont *)markFont andMarkColor: (UIColor *)markColor{

    UIFont *font = markFont;
    if (font == nil) {
        font = [UIFont systemFontOfSize:23];
    }
    UIColor *color = markColor;
    if (color == nil) {
        color = [UIColor blackColor];
    }
        //设置水印大小，可以根据图片大小或者view大小
    CGFloat  img_w = size.width;
    CGFloat  img_h = size.height;
    CGFloat  w = size.width;//[UIScreen mainScreen].bounds.size.width;//view.bounds.size.height;
    CGFloat  h = size.height;
        //1.开启上下文
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h), NO, 0.0);
        //2.绘制图片 水印图片
    [image drawInRect:CGRectMake(0, 0, img_w, img_h)];

    /* --添加水印文字样式--*/
    NSDictionary * attr = @{NSFontAttributeName:font,NSForegroundColorAttributeName:color};
    NSMutableAttributedString * attr_str =[[NSMutableAttributedString alloc]initWithString:text attributes:attr];

        //文字：字符串的宽、高
    CGFloat str_w = attr_str.size.width;
    CGFloat str_h = attr_str.size.height;

        //根据中心开启旋转上下文矩阵，绘制水印文字
    CGContextRef context = UIGraphicsGetCurrentContext();

        //将绘制原点（0，0）调整到源image的中心
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(img_w/2, img_h/2));
        //以绘制原点为中心旋转
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(CG_TRANSFORM_ROTATING));

        //将绘制原点恢复初始值，保证context中心点和image中心点处在一个点(当前context已经发生旋转，绘制出的任何layer都是倾斜的)
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(-w/2, -h/2));

        //sqrtLength：原始image对角线length。在水印旋转矩阵中只要矩阵的宽高是原始image的对角线长度，无论旋转多少度都不会有空白。
    CGFloat sqrtLength = sqrt(img_w*img_w + img_h*img_h);


        //计算需要绘制的列数和行数
    int count_Hor = sqrtLength / (str_w + HORIZONTAL_SPACEING) + 1;
    int count_Ver = sqrtLength / (str_h + VERTICAL_SPACEING) + 1;

        //此处计算出需要绘制水印文字的起始点，由于水印区域要大于图片区域所以起点在原有基础上移
    CGFloat orignX = -(sqrtLength-w)/2;
    CGFloat orignY = -(sqrtLength-h)/2;

        //在每列绘制时X坐标叠加
    CGFloat overlayOrignX = orignX;
        //在每行绘制时Y坐标叠加
    CGFloat overlayOrignY = orignY;


    for (int i = 0; i < count_Hor * count_Ver; i++) {
            //绘制图片
        [text drawInRect:CGRectMake(overlayOrignX, overlayOrignY, str_w, str_h) withAttributes:attr];
        if (i % count_Hor == 0 && i != 0) {
            overlayOrignX = orignX;
            overlayOrignY += (str_h + VERTICAL_SPACEING);
        }else{
            overlayOrignX += (str_w + HORIZONTAL_SPACEING);
        }
    }
        //根据上下文制作成图片
    UIImage *finalImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGContextRestoreGState(context);
        //3.从上下文中获取新图片
        //    [view.layer renderInContext:UIGraphicsGetCurrentContext()];

        //4.关闭图形上下文
    UIGraphicsEndImageContext();
    CGContextRestoreGState(context);
    return finalImg;
}
@end
