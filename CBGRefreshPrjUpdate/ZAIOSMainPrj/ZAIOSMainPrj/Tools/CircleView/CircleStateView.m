//
//  CircleStateView.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/12/11.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import "CircleStateView.h"

@interface CircleStateView()

@property (nonatomic,strong) UILabel * timeNumLbl;
@property (nonatomic,strong) UILabel * bottomLbl;

@property (nonatomic,strong) UIImageView * loadingImg;
@property (nonatomic,strong) UIImageView * successImg;

@property (nonatomic,strong) CAAnimation * circleAnimation;
@end


@implementation CircleStateView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self initSubViews];
        self.state = CircleStateViewStateType_NORMAL;
    }
    return self;
}

-(UILabel *)timeNumLbl
{
    if(!_timeNumLbl)
    {
        CGFloat fontSize = FLoatChange(45);
        UILabel * lbl = [[UILabel alloc] initWithFrame:self.bounds];
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont systemFontOfSize:fontSize];
        lbl.text = @"30";
        self.timeNumLbl = lbl;
    }
    return _timeNumLbl;
}
-(UILabel *)bottomLbl
{
    if(!_bottomLbl)
    {
        CGFloat fontSize = FLoatChange(12);
        CGRect rect = self.bounds;
        rect.size.height = FLoatChange(30);
        UILabel * lbl = [[UILabel alloc] initWithFrame:rect];
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont systemFontOfSize:fontSize];
        
        self.bottomLbl = lbl;
    }
    return _bottomLbl;
}
-(UIImageView *)successImg
{
    if(!_successImg)
    {
        UIImageView * img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_success"]];
        self.successImg = img;
    }
    return _successImg;
}
-(UIImageView *)loadingImg
{
    if(!_loadingImg)
    {
        UIImageView * img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"upload_loading"]];
        self.loadingImg = img;
    }
    return _loadingImg;
}

-(void)initSubViews
{
    CGSize size = self.bounds.size;
    
    [self addSubview:self.timeNumLbl];
    self.timeNumLbl.center = CGPointMake(size.width/2.0, 6.0/13.0*size.height);
    
    [self addSubview:self.bottomLbl];
    self.bottomLbl.center = CGPointMake(size.width/2.0, 95.0/(95.0+35)*size.height);
    
    [self addSubview:self.successImg];
    self.successImg.center = CGPointMake(size.width/2.0, 55.0/(55.0+75)*size.height);

    [self addSubview:self.loadingImg];
    self.loadingImg.center = CGPointMake(size.width/2.0, 6.0/13.0*size.height);

    UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(tapedOnRetryBtnForError)];
    [self addGestureRecognizer:tapGes];
    
}
-(void)tapedOnRetryBtnForError
{
    if(self.state != CircleStateViewStateType_UPLOAD_FAILED) return;
    
    if(self.RetryUploadForUploadErrorBlock)
    {
        self.RetryUploadForUploadErrorBlock();
    }
}

-(void)refreshLoadingImageViewAnimation
{
    
    NSString * animatedKey = @"circleAnimation";
    CALayer * loadingLayer = self.loadingImg.layer;
    CAAnimation * animation = [loadingLayer animationForKey:animatedKey];
    
    if(!animation)
    {
        animation = self.circleAnimation;
    }
    [loadingLayer removeAnimationForKey:animatedKey];
    [loadingLayer addAnimation:animation forKey:animatedKey];
}
-(void)stopLoadingImageViewAnimation
{
    NSString * animatedKey = @"circleAnimation";
    CALayer * loadingLayer = self.loadingImg.layer;

    [loadingLayer removeAnimationForKey:animatedKey];
}

-(CAAnimation *)circleAnimation
{
    if(!_circleAnimation)
    {
        CGFloat duration = 1.5;
        CGFloat eveDuration = duration/4.0;
        
        CABasicAnimation *animation = [CABasicAnimation
                                       animationWithKeyPath: @"transform" ];
        animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        
        //围绕Z轴旋转，垂直与屏幕
        animation.toValue = [NSValue valueWithCATransform3D:
                             CATransform3DMakeRotation(M_PI_2, 0.0, 0.0, 1.0) ];
        animation.duration = eveDuration;
        //旋转效果累计，先转180度，接着再旋转180度，从而实现360旋转
        animation.cumulative = YES;
        animation.repeatCount = CGFLOAT_MAX;
        self.circleAnimation = animation;
    }
    return _circleAnimation;
    
}

-(void)setState:(CircleStateViewStateType)state
{
//    CircleStateViewStateType_NORMAL = 1,//录音中
//    CircleStateViewStateType_RECORDER_FAIL, //录音失败
//    CircleStateViewStateType_UPLOAD_ING,    //上传中
//    CircleStateViewStateType_UPLOAD_SUCESS,//上传成功
//    CircleStateViewStateType_UPLOAD_FAILED,//上传失败
    
    //控制显示与隐藏
    self.timeNumLbl.hidden = (state != CircleStateViewStateType_NORMAL);
    self.bottomLbl.hidden = NO;
    self.successImg.hidden = (state != CircleStateViewStateType_UPLOAD_SUCESS);
    self.loadingImg.hidden = (state == CircleStateViewStateType_NORMAL || state == CircleStateViewStateType_UPLOAD_SUCESS);
    
    NSString * bottomTxt = @"录音中";
    
    switch (state)
    {
        case CircleStateViewStateType_NORMAL:
            bottomTxt = @"录音中";
            break;
        case CircleStateViewStateType_RECORDER_FAIL:
            bottomTxt = @"录音失败";
            break;
        case CircleStateViewStateType_UPLOAD_ING:
            bottomTxt = @"上传中";
            break;
        case CircleStateViewStateType_UPLOAD_SUCESS:
            bottomTxt = @"上传成功";
            break;
        case CircleStateViewStateType_UPLOAD_FAILED:
            bottomTxt = @"点击重新上传";
            break;
        default:
            break;
    }
    
    if(state == CircleStateViewStateType_UPLOAD_ING)
    {
        [self refreshLoadingImageViewAnimation];
    }else{
        [self stopLoadingImageViewAnimation];
    }
    
    self.bottomLbl.text = bottomTxt;
    _state = state;
}



-(void)refreshForLoadingAnimation
{
    if(self.state == CircleStateViewStateType_UPLOAD_ING)
    {
        [self refreshLoadingImageViewAnimation];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
