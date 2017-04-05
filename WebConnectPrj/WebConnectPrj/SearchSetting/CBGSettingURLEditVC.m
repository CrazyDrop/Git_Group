//
//  CBGSettingURLEditVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/3/28.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGSettingURLEditVC.h"

@interface CBGSettingURLEditVC ()
@property (nonatomic,strong) UITextView * textView;

@end

@implementation CBGSettingURLEditVC

-(void)submit
{
    NSString * txt = self.textView.text;
    if([txt length] == 0)
    {
        [DZUtils noticeCustomerWithShowText:@"重置"];
        txt = WebRefresh_ListRequest_Default_URLString;
    }else{
        [DZUtils noticeCustomerWithShowText:@"设置成功"];
    }
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    total.localURL1 = txt;
    [total localSave];
    
}
- (void)viewDidLoad {
    self.viewTtle = @"设置";
    
    self.showRightBtn = YES;
    self.rightTitle = @"保存";
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    CGRect rect = [[UIScreen mainScreen] bounds];
    
    CGFloat aHeight = CGRectGetMaxY(self.titleBar.frame);
//    rect.origin.y = aHeight;
//    rect.size.height -= aHeight;
    
    UIView * bgView = self.view;
    
    UITextView * txt = [[UITextView alloc] initWithFrame:CGRectMake(0, aHeight, SCREEN_WIDTH, 200)];
    [bgView addSubview:txt];
    self.textView = txt;
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, aHeight + txt.bounds.size.height, 100, 100);
    [btn addTarget:self action:@selector(tapedOnButtonForCopyIn) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundColor:[UIColor redColor]];
    [btn setTitle:@"粘贴" forState:UIControlStateNormal];
    [bgView addSubview:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(SCREEN_WIDTH - 100, aHeight + txt.bounds.size.height, 100, 100);
    [btn addTarget:self action:@selector(tapedOnButtonForCopyOut) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"复制" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor redColor]];
    [bgView addSubview:btn];
    
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    txt.text = total.localURL1;
}

-(void)tapedOnButtonForCopyIn
{
    UIPasteboard * board = [UIPasteboard generalPasteboard];
    NSString * detailCopy =  board.string;
    self.textView.text = detailCopy;

}
-(void)tapedOnButtonForCopyOut
{
    NSString * detail = self.textView.text;
    UIPasteboard * board = [UIPasteboard generalPasteboard];
    board.string = detail;
    
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
