//
//  ShareViewController.h
//  Photography
//
//  Created by jialifei on 15/4/10.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPViewController.h"
@interface ShareViewController : DPViewController
@property (weak, nonatomic) IBOutlet UIImageView *appCode;
@property (nonatomic,copy)NSString *url;
@end
