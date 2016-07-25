//
//  ShowQRCodeViewController.m
//  QRCodeCreaterDemo
//
//  Created by wanglidan on 16/7/19.
//  Copyright © 2016年 wanglidan. All rights reserved.
//

#import "ShowQRCodeViewController.h"
#import "CreateQRCode.h"

@interface ShowQRCodeViewController ()

@end

@implementation ShowQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    _input = [[UITextField alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, 64+30, 200, 35)];
    _input.backgroundColor = [UIColor whiteColor];
    _input.placeholder = @"请输入...";
    _input.layer.borderColor = [UIColor grayColor].CGColor;
    _input.layer.borderWidth = 1.f;
    _input.layer.cornerRadius = 5;
    _input.layer.masksToBounds = YES;
    
    [self.view addSubview:_input];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake((SCREEN_WIDTH-120)/2, 94+35+50, 120, 40);
    [btn setTitle:@"生成二维码" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor cyanColor]];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    _QRImgView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-300)/2, 94+35+50+40+50, 300, 300)];
    _QRImgView.backgroundColor = [UIColor redColor];
    _QRImgView.layer.borderColor = [UIColor yellowColor].CGColor;
    _QRImgView.layer.borderWidth = 1.0;
    [self.view addSubview:_QRImgView];
    
    
    
}
- (void)btnClick:(UIButton *)btn
{
    [_input resignFirstResponder];
    _QRImgView.image = [CreateQRCode createQRCodeWithString:_input.text ViewController:self];
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
