//
//  ViewController.m
//  QRCodeCreaterDemo
//
//  Created by wanglidan on 16/7/18.
//  Copyright © 2016年 wanglidan. All rights reserved.
//

#import "ViewController.h"
#import "ScanQRViewController.h"
#import "ShowQRCodeViewController.h"
#import "USAccountViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *data;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _data = @[@"扫二维码",@"生成二维码",@"账户"];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = _data[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        //扫二维码
        ScanQRViewController *scanVC = [[ScanQRViewController alloc] init];
        [self.navigationController pushViewController:scanVC animated:YES];
    }else if(indexPath.row == 1){
        //生成二维码
        ShowQRCodeViewController *showVC = [[ShowQRCodeViewController alloc] init];
        [self.navigationController pushViewController:showVC animated:YES];
    }else if (indexPath.row == 2){
        //账户
        USAccountViewController *account = [[USAccountViewController alloc] init];
        [self.navigationController pushViewController:account animated:YES];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
