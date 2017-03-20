//
//  IdentifyViewController.h
//  Photography
//
//  Created by jialifei on 15/3/21.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPViewController.h"
@interface IdentifyViewController : DPViewController

@property (nonatomic,copy) NSString *phoneNumber;
@property (nonatomic,copy) NSString *type;

-(id)initWithType:(NSString *)type ;

@end
