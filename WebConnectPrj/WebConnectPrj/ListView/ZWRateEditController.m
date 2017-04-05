//
//  ZWRateEditController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/3/9.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWRateEditController.h"
#import "ZWDataDetailModel.h"
#import "ZWSystemListController.h"
@interface ZWRateEditController ()
{
    IBOutlet UITextField * buyRateTfd;
    IBOutlet UITextField * daysTfd;
    
    IBOutlet UITextField * sellRateTfd;
    
    
    IBOutlet UITextView * maxEarnResultLbl;
}
@end

@implementation ZWRateEditController

-(IBAction)tapedOnConfirmBtn:(id)sender
{
    
    [buyRateTfd resignFirstResponder];
    [sellRateTfd resignFirstResponder];
    [daysTfd resignFirstResponder];
    
    //启动运算
    NSString * buy = buyRateTfd.text;
    NSString * days = daysTfd.text;
    if(!buy || !days){
        return;
    }

    NSString * sellRate = sellRateTfd.text;
    
    ZWDataDetailModel * model = [[ZWDataDetailModel alloc] init];
    model.duration_str = [NSString stringWithFormat:@"%@",days];
    model.annual_rate_str = [NSString stringWithFormat:@"%f",[buy floatValue]/100.0];
    NSString * sell = sellRate;
    if(!sell || [sell length]==0)
    {
        sellRateTfd.text = model.sellRate;
        sell = model.sellRate;
    }else{
        model.sellRate = sellRate;
    }
    
    NSArray * array  = [model zwResultArrayForDifferentSellRate];
    
    NSMutableString * resultStr = [NSMutableString string];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [resultStr appendFormat:@"%@\n",obj];
    }];
    
    maxEarnResultLbl.text = resultStr;
    CGRect rect = maxEarnResultLbl.frame;
    
    CGPoint pt = [maxEarnResultLbl.superview convertPoint:rect.origin toView:self.view];
    rect.size.width = SCREEN_WIDTH * 0.9;
    rect.size.height = (SCREEN_HEIGHT - pt.y) * 0.8;
    maxEarnResultLbl.frame = rect;
    maxEarnResultLbl.center = CGPointMake(SCREEN_WIDTH/2.0, maxEarnResultLbl.center.y);
    
    
}
-(IBAction)tapedOnBackBtn:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)tapedOnSystemListBtn:(id)sender{
    ZWSystemListController * history = [[ZWSystemListController alloc] init];
    [self.navigationController pushViewController:history animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    buyRateTfd.keyboardType = UIKeyboardTypeNumberPad;
    daysTfd.keyboardType = UIKeyboardTypeNumberPad;
    sellRateTfd.keyboardType = UIKeyboardTypeNumberPad;
    
    maxEarnResultLbl.editable = NO;
    
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
