//
//  ScanQRViewController.h
//  QRCodeCreaterDemo
//
//  Created by wanglidan on 16/7/19.
//  Copyright © 2016年 wanglidan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^successBlock)(NSString *QRCodeInfo);

@interface ScanQRViewController : UIViewController

@property (nonatomic, copy) successBlock block;

//是否需要将扫码的到的信息进行回传并展示
@property (nonatomic, assign) BOOL showQRCodeInfo;

//扫码成功后获得的二维码信息进行回传
- (void)successfulGetQRCodeInfo:(successBlock)success;

@end
