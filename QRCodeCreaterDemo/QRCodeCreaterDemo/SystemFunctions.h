//
//  SystemFunctions.h
//  QRCodeCreaterDemo
//
//  Created by wanglidan on 16/7/18.
//  Copyright © 2016年 wanglidan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface SystemFunctions : NSObject

//是否开启系统照明灯
+ (void)openLight:(BOOL)opened;
//是否开启系统震动和声音
+ (void)openShake:(BOOL)shaked Sound:(BOOL)sounding;
//调用系统浏览器打开扫描信息
+ (void)showInSafariWithURLMessage:(NSString *)message Success:(void (^)(NSString *token))success Failure:(void (^)(NSError *error))failure;
@end
