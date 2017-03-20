//
//  RegisterViewController.h
//  Photography
//
//  Created by jialifei on 15/3/21.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPViewController.h"
@class JKCountDownButton;

@interface SelectedBtn:UIButton

@property (nonatomic,assign) BOOL isAgreed;

@end
@interface RegisterViewController : DPViewController
{
    UITextField * phoneNumTfd;
    UITextField * messageNumTfd;
    UITextField * passwordTfd;
    UITextField * password2Tfd;
    
    CheckNumModel * _checkNumModel;
    RegisterModel * _register;
    
    JKCountDownButton * _timerBtn;
    
    UIButton * finishBtn;
}
@end
