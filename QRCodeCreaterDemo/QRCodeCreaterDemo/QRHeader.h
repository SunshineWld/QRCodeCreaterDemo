//
//  QRHeader.h
//  QRCodeCreaterDemo
//
//  Created by wanglidan on 16/7/18.
//  Copyright © 2016年 wanglidan. All rights reserved.
//

#ifndef QRHeader_h
#define QRHeader_h

#import "UIFont+MyFont.h"
#import "UIView+Frame.h"
#import "SystemFunctions.h"

//获取当前设备的尺寸
#define SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT  [UIScreen mainScreen].bounds.size.height
#define ScreenSize     [UIScreen mainScreen].bounds.size

//以iphone5为基础，坐标都以iphone5为基准，进行代码的适配
#define ratio  SCREEN_WIDTH / 320.0
//设置图片
#define ImgName(imageName) [UIImage imageNamed:imageName]

#define kBgImgX  45*ratio
#define kBgImgY  (64+60)*ratio
#define kBgImgWidth  230*ratio

#define kScrollLineHeight  20*ratio

#define kTipHeight  40*ratio
#define kTipY  (kBgImgY+kBgImgWidth+kTipHeight)

#define kLampWidth  64*ratio
#define kLampX  (SCREEN_WIDTH - kLampWidth) / 2
#define kLampY  (SCREEN_HEIGHT - kLampWidth - 30 * ratio)

#define kBgAlpha  0.6




#endif /* QRHeader_h */
