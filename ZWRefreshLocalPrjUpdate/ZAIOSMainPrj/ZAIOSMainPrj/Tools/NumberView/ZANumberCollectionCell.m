//
//  ZANumberCollectionCell.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/6/24.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZANumberCollectionCell.h"
@interface ZANumberCollectionCell()
{
    
}
@property (weak, nonatomic) IBOutlet UILabel *redStringLbl;
@property (weak, nonatomic) IBOutlet UILabel *subStringLbl;
@property (weak, nonatomic) IBOutlet UILabel *numberStringLbl;

@end

@implementation ZANumberCollectionCell

-(id)init
{
    self = [super init];
    if(self){
        [self customSetting];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self customSetting];
    }
    return self;
}
-(void)customSetting
{
//    self.backgroundColor = [UIColor whiteColor];
    self.circleColor = [UIColor grayColor];
    self.numberStr = @"1";
    self.subStr = @"ABC";
    
}

-(void)setCircleColor:(UIColor *)circleColor
{
    _circleColor = circleColor;
    //刷新大小和位置
    
    UIColor * color = self.circleColor?:[UIColor grayColor];
    CGFloat minLeng = MIN(self.bounds.size.width, self.bounds.size.height);
    CGRect rect = self.bounds;
    rect.size = CGSizeMake(minLeng, minLeng);
    self.circleView.frame = rect;
    self.circleView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    CALayer * viewLayer = [self.circleView layer];
    [viewLayer setCornerRadius:minLeng/2.0];
    [viewLayer setBorderColor:[color CGColor]];
    [viewLayer setBorderWidth:2];
    
    
}
-(UIImageView *)redIconImg
{
    if(!_redIconImg)
    {
        CGRect rect = self.circleView.frame;
        CGFloat imgWidth = rect.size.width * 0.55;
        CGFloat height = imgWidth /81.0 * 81.0;
        rect.size.width = imgWidth;
        rect.size.height = height;
        
        UIImageView * img = [[UIImageView alloc] initWithFrame:rect];
        [self.circleView addSubview:img];
        self.redIconImg = img;
    }
    return _redIconImg;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.redIconImg.center = CGPointMake(CGRectGetMidX(self.circleView.bounds), CGRectGetMidY(self.circleView.bounds));;
    
    self.redStringLbl.font = [UIFont systemFontOfSize:FLoatChange(32)];
    self.redStringLbl.textColor = [DZUtils colorWithHex:@"f9373d"];
    self.numberStringLbl.font = [UIFont systemFontOfSize:FLoatChange(30)];
    self.numberStringLbl.textColor = [DZUtils colorWithHex:@"969696"];
//    self.numberStringLbl.backgroundColor = [UIColor redColor];
    self.subStringLbl.font = [UIFont systemFontOfSize:FLoatChange(10)];
    self.subStringLbl.textColor = [UIColor lightGrayColor];
    BOOL blackCircle = !self.redString||[self.redString length]==0;

//    self.backgroundColor = [UIColor whiteColor];
//    self.circleColor = [UIColor grayColor];
    
    
    self.redStringLbl.text = self.redString;
    self.subStringLbl.text = self.subStr;
    self.numberStringLbl.text = self.numberStr;



    self.redStringLbl.hidden = blackCircle;
    self.subStringLbl.hidden = !blackCircle;
    self.numberStringLbl.hidden = !blackCircle;
    
    self.redIconImg.hidden = blackCircle;
    self.redStringLbl.hidden = YES;
}



@end
