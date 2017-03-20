//
//  ServiceClassification.m
//  photographer
//
//  Created by jialifei on 15/4/27.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import "ServiceClassification.h"
#import "DPViewController.h"
@implementation ClassInfoBtn


@end


@implementation ClassInfoView

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    return;
}
@end

@implementation ServiceClassification

-(id)initWithFrame:(CGRect)frame data:(NSMutableArray *)data{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        self.serviceInfoData = [[NSMutableArray alloc] init];
        _serviceInfoData =data;
        classBtnArray = [[NSMutableArray alloc] init];
        selectedDic= [[NSMutableDictionary alloc] init];

        self.serviceInfoData=data;
        [self creatServiceInfo];
        [self creatServiceClassInfo];
        [self creatServiceDes];
        [self botttomSure];
        [self setServiceData];
    }
    return self;
}

-(void)creatServiceInfo
{
    serviceView = [[ClassInfoView alloc] initWithFrame:CGRectMake(0, 110, SCREEN_WIDTH, SCREEN_HEIGHT - 110)];
    serviceView.backgroundColor = [UIColor whiteColor];
    [self addSubview:serviceView];
    
    UIView *serviceTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, YFLoatChange(170/2))];
    [serviceView addSubview:serviceTitle];
    serviceTitle.backgroundColor = [UIColor whiteColor];
//
    serviceImgv= [[UIImageView alloc] initWithFrame:CGRectMake(10, -(YFLoatChange(15)), FLoatChange(87) , FLoatChange(87))];
    [serviceTitle addSubview:serviceImgv];
     serviceImgv.backgroundColor = TITLE_LABLE_GAYCOLOR;
    
    float x = [DZUtils getLeftViewEndX:serviceImgv] + 10;
    titleLable = [[UILabel alloc] initWithFrame:CGRectMake(x, 10, SCREEN_WIDTH - 20-FLoatChange(87), YFLoatChange(20))];
    [serviceTitle addSubview:titleLable];
    titleLable.font = [UIFont systemFontOfSize:YFLoatChange(15.0)];
    titleLable.textColor = TITLE_LABLE_COLOR;
    
    float y= titleLable.frame.origin.y+titleLable.frame.size.height+10;
    desLable = [[UILabel alloc] initWithFrame:CGRectMake(x, y, SCREEN_WIDTH - 20-FLoatChange(87), YFLoatChange(20))];
    [serviceTitle addSubview:desLable];
    desLable.font = [UIFont systemFontOfSize:YFLoatChange(12.0)];
    desLable.text =@"不满意100%无条件退款";
    desLable.textColor = TITLE_LABLE_GAYCOLOR;
    
    y= desLable.frame.origin.y+desLable.frame.size.height ;
    servicePrice = [[UILabel alloc] initWithFrame:CGRectMake(x, y, SCREEN_WIDTH - 20-FLoatChange(87), YFLoatChange(20))];
    [serviceTitle addSubview:servicePrice];
    servicePrice.textColor = TITLE_LABLE_ORGANCE;
}

-(void)creatServiceClassInfo
{
    
    UIView *classInfoBg = [[UIView alloc] initWithFrame:CGRectMake(0, YFLoatChange(170/2)+1, SCREEN_WIDTH, FLoatChange(80))];
    [serviceView addSubview:classInfoBg];
    classInfoBg.backgroundColor = [UIColor whiteColor];
    
    
    UIView *topLine =[[UIView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-20,1 )];
    [classInfoBg addSubview:topLine];
    topLine.backgroundColor = LINE_GAYCOLOR;
    
    UILabel *des = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, FLoatChange(100) ,YFLoatChange(20))];
    [classInfoBg addSubview:des];
    des.textColor = [UIColor blackColor];
    des.backgroundColor = [UIColor whiteColor];
    des.font = [UIFont systemFontOfSize:FLoatChange(15.0)];
    des.text = @"选择套系";
    
    float y = des.frame.size.height +des.frame.origin.y+ 10;
    int i = 0;
    for (NSDictionary *title in _serviceInfoData) {
       
        ClassInfoBtn *btn = [ClassInfoBtn buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(10+(i*FLoatChange(50+5)), y, FLoatChange(50),25 );
        btn.backgroundColor = [UIColor whiteColor];
        btn.titleLabel.font = [UIFont systemFontOfSize:YFLoatChange(12.0)];
        [classInfoBg addSubview:btn];
        [btn.layer setCornerRadius:3.0];
        btn.layer.borderWidth = 1.0;
        btn.layer.borderColor = [TITLE_LABLE_GAYCOLOR CGColor];
        [classBtnArray addObject:btn];
        [btn setTitleColor:TITLE_LABLE_GAYCOLOR forState:UIControlStateNormal];
        btn.index = i;
        [btn setTitle:title[@"meal_name"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(showClassInfo:) forControlEvents:UIControlEventTouchUpInside];
        i++;
    }
    
    UIView *bottomLine =[[UIView alloc] initWithFrame:CGRectMake(10, YFLoatChange(80)-1, SCREEN_WIDTH-20,1 )];
    [classInfoBg addSubview:bottomLine];
    bottomLine.backgroundColor = LINE_GAYCOLOR;
}

-(void)creatServiceDes
{
    UILabel *des = [[UILabel alloc] initWithFrame:CGRectMake(10, FLoatChange(180), FLoatChange(100) ,YFLoatChange(20))];
    [serviceView addSubview:des];
    des.text = @"套系介绍";
    des.font = [UIFont systemFontOfSize:FLoatChange(15.0)];
    serviceInfoDes =[[UITextView alloc] initWithFrame:CGRectMake(10, FLoatChange(210), SCREEN_WIDTH - 20, YFLoatChange(200) )];
    [serviceView addSubview:serviceInfoDes];serviceInfoDes.userInteractionEnabled =NO;
    serviceInfoDes.backgroundColor = [UIColor whiteColor];
    serviceInfoDes.font = [UIFont systemFontOfSize:FLoatChange(12.0)];
}

-(void)botttomSure
{
    UIButton *sureSelected = [UIButton  buttonWithType:UIButtonTypeCustom];
    [sureSelected setTitle:@"确 认" forState:UIControlStateNormal];
    sureSelected.frame = CGRectMake(0, self.frame.size.height-160, SCREEN_WIDTH, 50);
    [serviceView addSubview:sureSelected];
    sureSelected.backgroundColor = REDCOLOR;
    [sureSelected addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
}

-(void)sureAction
{
//    [_delegate datePhotographer:selectedDic];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    [_delegate cancelSelected];
}
//UITextView *serviceInfoDes;
//UIImageView *serviceImgv;
//
////
//UILabel *titleLable;
//UILabel *desLable;
//UILabel *servicePrice;
//
//"meal_id": "7",
//"meal_name": "百天",
//"meal_price": "512",
//"meal_introduce": "456"

-(void)showClassInfo:(ClassInfoBtn *)btn
{
    int i = btn.index;
    
    for (ClassInfoBtn *btn in classBtnArray) {
        btn.backgroundColor = [UIColor whiteColor];
        [btn setTitleColor:TITLE_LABLE_GAYCOLOR forState:UIControlStateNormal];
        btn.layer.borderWidth = 1.0;
        btn.layer.borderColor = [TITLE_LABLE_GAYCOLOR CGColor];
    }
    
    [btn setBackgroundColor:REDCOLOR];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.layer.borderWidth = 0.0;
    btn.layer.borderColor = [[UIColor clearColor] CGColor];
    
    NSDictionary *dic;
    if ([DZUtils isValidateArray:_serviceInfoData]) {
         dic = _serviceInfoData[i];
        selectedDic = dic;
    }
    if ([DZUtils isValidateDictionary:dic]) {
        titleLable.text = dic[@"meal_name"];
        servicePrice.text = dic[@"meal_price"];
        serviceInfoDes.text = dic[@"meal_introduce"];
        NSString *img = [NSString stringWithFormat:@"%@",dic[@"meal_name"]];
        serviceImgv.image= [UIImage imageNamed:img];
    }
  }

-(void)setServiceData
{
    if ([DZUtils isValidateArray:classBtnArray]) {
        [self showClassInfo:classBtnArray[0]];
    }
}


@end
