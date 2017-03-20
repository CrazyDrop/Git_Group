//
//  OLEGOCustomHeaderView.m
//  WebConnectPrj
//
//  Created by Apple on 15/1/29.
//  Copyright (c) 2015年 zhangchaoqun. All rights reserved.
//

#import "OLEGOCustomHeaderView.h"
#import "OLEGOHeaderNormalControl.h"
@interface OLEGOCustomHeaderView()
@property (nonatomic,strong) UIImageView * arrowImageView;
@property (nonatomic,strong) UIImageView * loadingImg;
@end
@implementation OLEGOCustomHeaderView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        //视图创建
        [self initPreViews];
        
        self.egoViewHeight = REFRESH_REGION_HEIGHT;
        OLEGOHeaderNormalControl * control = [[OLEGOHeaderNormalControl alloc] init];
        self.viewControl = control;
    }
    return self;
}
-(void)initPreViews
{
    CGFloat imageHeight  = 23;
    UIImageView *arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"下拉（松开刷新）.png"]];
    arrowImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:arrowImage];
    _arrowImageView= arrowImage;
    arrowImage.frame = CGRectMake(0, 0, imageHeight, imageHeight);
    
    UIImageView * images = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageHeight, imageHeight)];
    NSMutableArray * imgArr = [NSMutableArray array];
    for (int i=1;i<5 ; i++)
    {
        UIImage * img = [UIImage imageNamed:[NSString stringWithFormat:@"刷新%d.png",i]];
        if (!img) {
            continue;
        }
        [imgArr addObject:img];
    }
    images.animationImages = imgArr;
    images.animationDuration = 0.5;
    
    
    [self addSubview:images];
    _loadingImg = images;
    images.hidden = YES;
    
    CGRect rect = self.bounds;
    CGFloat bottomExtend = 30;//距离底部高度
    CGPoint pt = CGPointMake(rect.size.width/2.0, rect.size.height - bottomExtend - imageHeight/2.0);
    images.center = pt;
    arrowImage.center = pt;
}


-(void)setState:(EGOPullRefreshState)aState
{
    EGOPullRefreshState preState = self.state;
    switch (aState) {
        case EGOOPullRefreshPulling:
        {
            //重置朝向
            [UIView animateWithDuration:FLIP_ANIMATION_DURATION animations:^{
                _arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
            }];
        }
            break;
        case EGOOPullRefreshNormal:
        {
            if (preState == EGOOPullRefreshPulling)
            {
                [UIView animateWithDuration:FLIP_ANIMATION_DURATION animations:^{
                    _arrowImageView.transform = CGAffineTransformIdentity;
                }];
            }
            
            [_loadingImg stopAnimating];
            _loadingImg.hidden = YES;
        }
            break;
        case EGOOPullRefreshLoading:
        {
            [_loadingImg startAnimating];
            _loadingImg.hidden = NO;
            _arrowImageView.transform = CGAffineTransformIdentity;
        }
            break;
        default:
            break;
    }
    
    _state = aState;
    
}

@end
