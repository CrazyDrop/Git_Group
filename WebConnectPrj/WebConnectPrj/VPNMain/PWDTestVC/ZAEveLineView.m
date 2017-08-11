//
//  ZAEveLineView.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/23.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAEveLineView.h"
@interface ZAEveLineView()
{
    NSLock * lock;
}
@property (nonatomic,assign) BOOL lineSelected;
@property (nonatomic,copy) NSString *tempTxt;
@property (nonatomic,strong) UITextField * inputTfd;

@property (nonatomic,strong) UIView * bottomLine;
@property (nonatomic,strong) UIView * centerPoint;
@property (nonatomic, strong) UIColor * lineColor;
@property (nonatomic, strong) UIColor * txtColor;
@end

@implementation ZAEveLineView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        
        self.lineColor = [UIColor colorWithRed:221/255.0 green:241.0/255.0 blue:254/255.0 alpha:1];
        self.txtColor = [UIColor colorWithRed:70/255.0 green:156/255.0 blue:210/255.0 alpha:1];
        [self addSubview:self.inputTfd];
        [self addSubview:self.bottomLine];
        [self addSubview:self.centerPoint];
        
    }
    return self;
}
-(UIView *)centerPoint
{
    if(!_centerPoint)
    {
        CGFloat width = FLoatChange(8);
        UIView * aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,width, width)];
        aView.backgroundColor = [UIColor whiteColor];
        [[aView layer] setCornerRadius:width/2.0];
        aView.hidden = YES;
        self.centerPoint = aView;
    }
    return _centerPoint;
}

-(UIView *)bottomLine
{
    if(!_bottomLine)
    {
        CGFloat width = self.bounds.size.width;
        UIView * aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,width, FLoatChange(1))];
        aView.backgroundColor = self.lineColor;
        self.bottomLine = aView;
    }
    return _bottomLine;
}

-(UITextField *)inputTfd
{
    if (!_inputTfd)
    {
        UITextField * field = [[UITextField alloc] initWithFrame:self.bounds];
        field.textColor = self.txtColor;
        field.font = [UIFont systemFontOfSize:FLoatChange(40)];
        field.textAlignment = NSTextAlignmentCenter;
        field.userInteractionEnabled = NO;
        self.inputTfd = field;
    }
    return _inputTfd;
}


//当txt为nil时，相当于不选中
-(void)refreshLineVewSelectedWithCurrentTxt:(NSString *)txt animated:(BOOL)animated
{
    self.tempTxt = txt;
    
    if(self.ingorePt)
    {
        [self refreshTfdSubStateWithTxt:txt];
        return;
    }
    
    //取消之前操作
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideInputTxtAndShowPoint) object:nil];
    
    if(!txt)
    {
        self.centerPoint.hidden = YES;
        self.inputTfd.hidden = YES;
        
    }else if(!animated)
    {
        //直接展示
        self.inputTfd.hidden = YES;
        self.centerPoint.hidden = NO;

        
    }else
    {
        //有动画
        self.inputTfd.hidden = NO;
        self.inputTfd.text = txt;
        self.centerPoint.hidden = YES;
        [self performSelector:@selector(hideInputTxtAndShowPoint) withObject:nil afterDelay:0.2];
    }
}
-(void)refreshTfdSubStateWithTxt:(NSString *)txt
{
    self.centerPoint.hidden = YES;
    self.inputTfd.hidden = !txt?YES:NO;
    self.inputTfd.text = txt;
}

-(void)hideInputTxtAndShowPoint
{
    self.inputTfd.hidden = YES;
    self.centerPoint.hidden = NO;
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat height = self.bounds.size.height;
    CGFloat width = self.bounds.size.width;
    self.bottomLine.center = CGPointMake(width/2.0, height - self.bottomLine.bounds.size.height/2.0);
    self.centerPoint.center = CGPointMake(width/2.0, height/2.0);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
