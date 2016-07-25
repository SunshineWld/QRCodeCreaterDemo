//
//  UIFont+MyFont.h
//  QRCodeCreaterDemo
//
//  Created by wanglidan on 16/7/19.
//  Copyright © 2016年 wanglidan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (MyFont)

//根据不同手机型号，改变字体大小   size 当前机型下的字体大小  return 适配的字体大小
+ (UIFont *)fontWithSize:(CGFloat)size;

@end
