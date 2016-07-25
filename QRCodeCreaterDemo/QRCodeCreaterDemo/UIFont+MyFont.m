//
//  UIFont+MyFont.m
//  QRCodeCreaterDemo
//
//  Created by wanglidan on 16/7/19.
//  Copyright © 2016年 wanglidan. All rights reserved.
//

#import "UIFont+MyFont.h"
#import "QRHeader.h"

@implementation UIFont (MyFont)

+ (UIFont *)fontWithSize:(CGFloat)size
{
    CGFloat realSize = size * ratio;
    return [UIFont systemFontOfSize:realSize];
}
@end
