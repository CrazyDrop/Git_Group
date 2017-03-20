//
//  DPViewController.h
//  Photography
//
//  Created by jialifei on 15/3/18.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPHttpClient.h"
#import "IIViewDeckController.h"
#import "BaseBlockController.h"

@interface DPViewController :BaseBlockController
{
    DPHttpClient *_myClient;
    UILabel * _topHeaderLbl;
    UILabel * _topHeaderSmallLbl;
    BaseRequestModel * _dpModel;
    UIView * topBgView;
    UIView * _topErrorView;
    UIImageView * imgBg;
}
@property (nonatomic,retain) UIImageView *titleBar;
@property (nonatomic,retain) UILabel *titleV;
@property (nonatomic,copy) NSString *viewTtle;
@property (nonatomic) int contentY;
@property (nonatomic) BOOL showLeftBtn;
@property (nonatomic) BOOL showRightBtn;
@property (nonatomic,copy) NSString *rightTitle;
@property (nonatomic,retain) UIButton *rightBtn;
@property (nonatomic,retain) UIButton *leftBtn;
@property (nonatomic ,assign) SEL rightAction;
@property (nonatomic,copy) NSString *currentPage;
@property (nonatomic,retain) UINavigationController *navgation;
@property (nonatomic ,assign,readonly) UIButton * coverBtn;
@property (nonatomic ,retain) DPHttpClient *myClient;



-(NSString *)classNameForKMRecord;

-(void)refreshDragBackEnable:(BOOL)enable;

-(void)showSpecialStyleTitle;

-(void)showLeftViewWithLeftSliderAnimated:(BOOL)animated;

-(UINavigationController *)rootNavigationController;



@end
