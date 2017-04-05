//
//  OLEGONormalFooterView.m
//  WebConnectPrj
//
//  Created by Apple on 15/1/29.
//  Copyright (c) 2015年 zhangchaoqun. All rights reserved.
//

#import "OLEGONormalFooterView.h"
@interface OLEGONormalFooterView()
@property (nonatomic,strong)	UILabel *lastUpdatedLabel;
@property (nonatomic,strong)	UILabel *statusLabel;
@property (nonatomic,strong)	CALayer *arrowImage;
@property (nonatomic,strong)	UIActivityIndicatorView *activityView;
@end
@implementation OLEGONormalFooterView
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //视图创建
        [self initPreViews];
        
        self.egoViewHeight = REFRESH_REGION_HEIGHT;
    }
    return self;
}
-(void)initPreViews
{
    self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
    
    CGRect frame = self.frame;
    UIColor * textColor = [UIColor blackColor];
    NSString * arrow = @"blueArrow.png";
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 40.0f, self.frame.size.width, 20.0f)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.font = [UIFont systemFontOfSize:12.0f];
    label.textColor = textColor;
    label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    label.shadowOffset = CGSizeMake(0.0f, 1.0f);
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    [self addSubview:label];
    _lastUpdatedLabel=label;

    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 20.0f, self.frame.size.width, 20.0f)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.font = [UIFont boldSystemFontOfSize:13.0f];
    label.textColor = textColor;
    label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    label.shadowOffset = CGSizeMake(0.0f, 1.0f);
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    [self addSubview:label];
    _statusLabel=label;

    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(25.0f, 20.0f, 30.0f, 55.0f);
    layer.contentsGravity = kCAGravityResizeAspect;
    layer.contents = (id)[UIImage imageNamed:arrow].CGImage;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        layer.contentsScale = [[UIScreen mainScreen] scale];
    }
#endif
    
    [[self layer] addSublayer:layer];
    _arrowImage=layer;
    
    UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    view.frame = CGRectMake(25.0f, 20.0f, 20.0f, 20.0f);
    [self addSubview:view];
    _activityView = view;
    
    [self setState:EGOOPullRefreshNormal];
}
- (void)setState:(EGOPullRefreshState)aState{
    
    EGOPullRefreshState preState = self.state;
    switch (aState) {
        case EGOOPullRefreshPulling:
            
            _statusLabel.text = NSLocalizedString(@"Release to load more...", @"Release to load more");
            [CATransaction begin];
            [CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
            _arrowImage.transform =CATransform3DIdentity;
            [CATransaction commit];
            
            break;
        case EGOOPullRefreshNormal:
            
            if (preState == EGOOPullRefreshPulling) {
                [CATransaction begin];
                [CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
                _arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);;
                [CATransaction commit];
            }
            
            _statusLabel.text = NSLocalizedString(@"Pull up to load more...", @"Pull up to load more");
            [_activityView stopAnimating];
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            _arrowImage.hidden = NO;
            _arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);;
            [CATransaction commit];
            
            [self refreshLastUpdatedDate];
            
            break;
        case EGOOPullRefreshLoading:
            
            _statusLabel.text = NSLocalizedString(@"Loading...", @"Loading Status");
            [_activityView startAnimating];
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
            _arrowImage.hidden = YES;
            [CATransaction commit];
            
            break;
        default:
            break;
    }
        
    _state = aState;
}
- (void)refreshLastUpdatedDate
{
    id viewDelegate = self.delegate;
    if ([viewDelegate respondsToSelector:@selector(egoRefreshTableDataSourceLastUpdated:)])
    {
        
        NSDate *date = [viewDelegate egoRefreshTableDataSourceLastUpdated:self];
        
        [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        _lastUpdatedLabel.text = [NSString stringWithFormat:@"Last Updated: %@", [dateFormatter stringFromDate:date]];
        [[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } else {
        
        _lastUpdatedLabel.text = nil;
        
    }
    
}

@end
