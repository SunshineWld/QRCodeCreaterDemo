//
//  ScanQRViewController.m
//  QRCodeCreaterDemo
//
//  Created by wanglidan on 16/7/19.
//  Copyright © 2016年 wanglidan. All rights reserved.
//

#import "ScanQRViewController.h"
#import "QRHeader.h"
#import <AVFoundation/AVFoundation.h>

@interface ScanQRViewController ()<AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSString *QRCode;
}
//输入输出中间桥梁（会话）
@property (nonatomic, strong) AVCaptureSession *session;
//计时器
@property (nonatomic, strong) CADisplayLink *link;
//实际有效扫描区域的背景图（或者自己设置一个边框）
@property (nonatomic, strong) UIImageView *bgImg;
//有效扫描区域循环往返的一条线(这里用的是一个背景图)
@property (nonatomic, strong) UIImageView *scrollLine;
//扫码有效区域外自加的文字提示
@property (nonatomic, strong) UILabel *tip;
//用于控制照明灯的开启
@property (nonatomic, strong) UIButton *lamp;
//用于记录scrollLine的上下循环状态
@property (nonatomic, assign) BOOL up;

@end

@implementation ScanQRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setNavigationItem];
    _up = YES;
    [self session];
    
    //1，添加一个可见的扫描有效区域的框
    [self.view addSubview:self.bgImg];
    //2.添加一个上下循环运动的线条
    [self.view addSubview:self.scrollLine];
    //3。添加其他控件
    [self.view addSubview:self.tip];
    [self.view addSubview:self.lamp];
    
    
}
#pragma mark -NavigationItem
- (void)setNavigationItem
{
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationItem.title = @"二维码/条形码";
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(openPhoto)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.session startRunning];
    //计时器添加到循环中去‘
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.session stopRunning];
}
#pragma mark -lazy load
- (UIImageView *)bgImg
{
    if (!_bgImg) {
        _bgImg = [[UIImageView alloc] initWithFrame:CGRectMake(kBgImgX, kBgImgY, kBgImgWidth, kBgImgWidth)];
        _bgImg.image = [UIImage imageNamed:@"scanBackground"];
    }
    return _bgImg;
}
- (UIImageView *)scrollLine
{
    if (!_scrollLine) {
        _scrollLine = [[UIImageView alloc] initWithFrame:CGRectMake(kBgImgX, kBgImgY, kBgImgWidth, kScrollLineHeight)];
        _scrollLine.image = [UIImage imageNamed:@"scanLine"];
    }
    return _scrollLine;
}
- (UILabel *)tip
{
    if (!_tip) {
        _tip = [[UILabel alloc]initWithFrame:CGRectMake(kBgImgX, kTipY, kBgImgWidth, kTipHeight)];
        _tip.text = @"自动扫描框内二维码/条形码";
        _tip.numberOfLines = 0;
        _tip.textColor = [UIColor whiteColor];
        _tip.textAlignment = NSTextAlignmentCenter;
        _tip.font = [UIFont fontWithSize:14];
    }
    return _tip;
}
- (CADisplayLink *)link
{
    if (!_link) {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(LineAnimation)];
    }
    return _link;
}
- (UIButton *)lamp
{
    if (!_lamp) {
        _lamp = [[UIButton alloc]initWithFrame:CGRectMake(kLampX, kLampY, kLampWidth, kLampWidth)];
        _lamp.alpha = kBgAlpha;
        _lamp.selected = NO;
        [_lamp.layer setMasksToBounds:YES];
        [_lamp.layer setCornerRadius:kLampWidth/2];
        [_lamp.layer setBorderWidth:2.0];
        [_lamp.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        _lamp.backgroundColor = [UIColor whiteColor];
        [_lamp setImage:[UIImage imageNamed:@"turn_off"] forState:UIControlStateNormal];
        [_lamp addTarget:self action:@selector(touchLamp:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lamp;
}

- (AVCaptureSession *)session
{
    if (!_session) {
        //1.获取输入设备（摄像头）
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        //2.根据输入设备创建输入对象
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
        if (input == nil) {
            return nil;
        }
        //3.创建元数据的输出对象
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        //4.设置代理监听输出对象输出的数据，在主线程中刷新
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        //5.创建会话
        AVCaptureSession *session = [[AVCaptureSession alloc] init];
        //实现高质量的输出和摄像，默认值为AVCaptureSessionPresetHigh，可以不写
        [session setSessionPreset:AVCaptureSessionPresetHigh];
        //6.添加输入和输出到会话中（判断session是否已满）
        if ([session canAddInput:input]) {
            [session addInput:input];
        }
        if ([session canAddOutput:output]) {
            [session addOutput:output];
        }
        //7.告诉输出对象，需要输出什么样的数据（二维码还是条形码）,要先创建会话才能设置
        output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeUPCECode,AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeAztecCode];
        //8.创建预览图层
        AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
        [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        previewLayer.frame = self.view.bounds;
        [self.view.layer insertSublayer:previewLayer atIndex:0];
        //9.设置有效扫描区域，默认整个图层（很特别，1.要除以屏幕宽高比例 2.其中x和y， width和height分别互换位置）
        CGRect rect = CGRectMake(kBgImgY/SCREEN_HEIGHT, kBgImgX/SCREEN_WIDTH, kBgImgWidth/SCREEN_HEIGHT, kBgImgWidth/SCREEN_WIDTH);
        output.rectOfInterest = rect;
        //10.设置中空区域，即有效扫描区域（中间扫描区域透明度比周边要低的效果）
        UIView *maskView = [[UIView alloc] initWithFrame:self.view.bounds];
        maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:kBgAlpha];
        [self.view addSubview:maskView];
        UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
        [rectPath appendPath:[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(kBgImgX, kBgImgY, kBgImgWidth, kBgImgWidth) cornerRadius:1] bezierPathByReversingPath]];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = rectPath.CGPath;
        maskView.layer.mask = shapeLayer;
        
        _session = session;
        
    }
    
    return _session;
}
#pragma mark - 线条运动的动画
- (void)LineAnimation
{
    if (_up == YES) {
        CGFloat y = self.scrollLine.frame.origin.y;
        y += 2;
        [self.scrollLine setY:y];
        if (y >= (kBgImgY + kBgImgWidth - kScrollLineHeight)) {
            _up = NO;
        }
    }else{
        CGFloat y = self.scrollLine.frame.origin.y;
        y -= 2;
        [self.scrollLine setY:y];
        if (y <= kBgImgY) {
            _up = YES;
        }
    }
}
#pragma mark -开灯
- (void)touchLamp:(UIButton *)button
{
    if (button.selected == YES) {
        [button setImage:[UIImage imageNamed:@"turn_off"]  forState:UIControlStateNormal];
        button.backgroundColor = [UIColor whiteColor];
    }else{
        [button setImage:[UIImage imageNamed:@"turn_on"] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor clearColor];
    }
    button.selected = !button.selected;
    [SystemFunctions openLight:button.selected];
}

#pragma mark -调用相册
- (void)openPhoto
{
    //1.判断相册是否可以打开
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        return;
    }
    //2.创建图片选择控制器
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    //选中之后大图编辑模式
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}
#pragma mark -UIImagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //1.取出选中的图片
    UIImage *pickImage = info[UIImagePickerControllerOriginalImage];
    CIImage *ciImage = [CIImage imageWithCGImage:pickImage.CGImage];
    
    //2.从选中的图片中读取二维码数据
    //2.1 创建一个探测器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    //2.2利用探测器探测数据
    NSArray *feature = [detector featuresInImage:ciImage];
    //2.3 取出探测到得数据
    for (CIQRCodeFeature *result in feature) {
        NSString *urlStr = result.messageString;
        //二维码信息回传
        if (_showQRCodeInfo) {
            self.block(urlStr);
        }
        [SystemFunctions showInSafariWithURLMessage:urlStr Success:^(NSString *token) {
            
        } Failure:^(NSError *error) {
            [self showAlertWithTitle:@"该信息无法跳转，详细信息为：" Message:urlStr OptionalAction:@[@"确定"]];
        }];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (feature.count == 0) {
        [self showAlertWithTitle:@"扫描结果" Message:@"没有扫描到有效二维码" OptionalAction:@[@"确认"]];
    }
}
#pragma mark -AVCaptureMetadataOutputObjectsDelegate
//扫描到数据时会调用
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0) {
        [SystemFunctions openShake:YES Sound:YES];
//        //1.停止扫描
//        [self.session stopRunning];
//        //2.停止冲击波
//        [self.link removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        //3.取出扫描得到的数据
        AVMetadataMachineReadableCodeObject *obj = [metadataObjects lastObject];
        if (obj) {
            //二维码信息回传
            if (_showQRCodeInfo) {
                self.block([obj stringValue]);
            }
            [SystemFunctions showInSafariWithURLMessage:[obj stringValue] Success:^(NSString *token) {
                
            } Failure:^(NSError *error) {
                [self.session stopRunning];
                [self.link removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
                [self showAlertWithTitle:@"该信息无法跳转，详细信息为：" Message:[obj stringValue] OptionalAction:@[@"确定"]];
            }];
        }
    }
}
#pragma mark -提示框
- (void)showAlertWithTitle:(NSString *)title Message:(NSString *)message OptionalAction:(NSArray *)actions
{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:actions.firstObject style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.session startRunning];
        [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }]];
    [self presentViewController:alertCtrl animated:YES completion:nil];
}
#pragma mark -二维码传值
- (void)successfulGetQRCodeInfo:(successBlock)success
{
    self.block = success;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
