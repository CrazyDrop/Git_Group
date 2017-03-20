//
//  ChangePasswordViewController.h
//  Photography
//
//  Created by jialifei on 15/4/10.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DPViewController.h"
@interface ChangePasswordViewController : DPViewController

@property (weak, nonatomic) IBOutlet UIView *firstBg;
@property (weak, nonatomic) IBOutlet UIView *secondBg;
@property (weak, nonatomic) IBOutlet UIView *mineBg;
@property (weak, nonatomic) IBOutlet UITextField *firstPassword;
@property (weak, nonatomic) IBOutlet UITextField *secondPassword;
@property (weak, nonatomic) IBOutlet UITextField *minePassWord;

@end
