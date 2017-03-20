//
//  ChangeViewController.h
//  Photography
//
//  Created by jialifei on 15/4/10.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPViewController.h"

@interface ChangeViewController : DPViewController
@property (weak, nonatomic) IBOutlet UIView *textBg;
@property (weak, nonatomic) IBOutlet UITextField *userTextfile;
@property (weak, nonatomic) IBOutlet NSString *type;
@property  (nonatomic,copy) NSString *userShowName;
- (id)initWithType :(NSString *)t;
@end
