//
//  CustomPickVIew.m
//  Try
//
//  Created by jialifei on 15/4/8.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import "CustomPickVIew.h"
//#import "OrderMakeViewController.h"
@implementation CustomPickVIew

-(id)initWithFrame:(CGRect)frame  type:(NSString *)t
{
    self= [super initWithFrame:frame];
    if (self) {
        self.type= t;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];;
        
        if ([t isEqualToString:@"data"]) {
            NSDate *date=[NSDate dateWithTimeIntervalSinceNow:90];
            _pickview=[[ZHPickView alloc] initDatePickWithDate:date datePickerMode:UIDatePickerModeDate isHaveNavControler:NO title:@"日期"];
            
        }
        if ([t isEqualToString:@"sex"]) {
            _pickview=[[ZHPickView alloc] initPickviewWithPlistName:@"sex" isHaveNavControler:NO title:@"性别"];
        }
        _pickview.delegate=self;
        [_pickview show];
        [self addTarget:self action:@selector(cancelSelectedView) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)cancelSelectedView
{
    [_pickview remove];
    [self removeFromSuperview];
}

#pragma mark ZhpickVIewDelegate
-(void)toobarDonBtnHaveClick:(ZHPickView *)pickView resultString:(NSString *)resultString{
    
    NSLog(@"--->%@",resultString);
    
    self.requestString = resultString;
//    [(OrderMakeViewController *)_delegate  returnResult:resultString withType:self.type];
}
@end
