//
//  ServiceClassification.h
//  photographer
//
//  Created by jialifei on 15/4/27.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "PhotoGraphViewController.h"
@class  DPViewController;
@interface ClassInfoBtn : UIButton

@property (nonatomic) int index;

@end
@interface ClassInfoView : UIView


@end


@interface ServiceClassification : UIView
{
    ClassInfoView *serviceView ;
    UITextView *serviceInfoDes;
    UIImageView *serviceImgv;    //
    UILabel *titleLable;
    UILabel *desLable;
    UILabel *servicePrice;
    NSMutableArray *classBtnArray;
    
    NSMutableDictionary*selectedDic;
}
@property (nonatomic,retain) NSMutableArray *serviceInfoData;
@property (nonatomic,retain) DPViewController *delegate;

-(id)initWithFrame:(CGRect)frame data:(NSMutableArray *)data;
@end
