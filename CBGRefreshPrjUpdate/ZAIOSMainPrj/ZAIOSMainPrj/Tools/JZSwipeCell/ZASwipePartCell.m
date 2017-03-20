//
//  ZASwipePartCell.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/8/13.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZASwipePartCell.h"

#define  kSwipeCellIconHorizontalPadding  0
@interface ZASwipePartCell()
{
    CGFloat swipeWidth;
    UIButton * editDeleBtn;
    UITapGestureRecognizer * tapGes;
    UIButton * cellBtn;
}
@property (nonatomic,strong) UIButton * noticeBtn;
@property (nonatomic,strong) UIView * noticeRedCircle;
@property (nonatomic,strong) UIView * noUseRedCircle;
@end
@implementation ZASwipePartCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        
        [self createLocalSwipeCell];
        

    }
    return self;
}
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView * supView = [super hitTest:point withEvent:event];
    if(!editDeleBtn.hidden){
        if(CGRectContainsPoint(editDeleBtn.frame, point))
        {
            return editDeleBtn;
        }
    }
    
//    CGFloat centerX = self.contentView.center.x;
//    if(centerX != SCREEN_WIDTH/2.0)
//    {
//        if(CGRectContainsPoint(cellBtn.frame, point)){
//            return cellBtn;
//        }
//    }
    
    return supView;
}
-(void)createLocalSwipeCell
{
    //参数设置
    self.defaultBackgroundColor = [UIColor clearColor];
    
    SwipeCellColorSet * set = [[SwipeCellColorSet alloc] init];
    set.shortLeftSwipeColor = [UIColor clearColor];
    set.shortRightSwipeColor = [UIColor clearColor];
    set.longLeftSwipeColor = [UIColor clearColor];
    set.longRightSwipeColor = [UIColor clearColor];
    self.colorSet = set;
    
    self.shortSwipeLength = SCREEN_WIDTH;
    self.icon.hidden = YES;

    self.backgroundView.backgroundColor = self.defaultBackgroundColor;

    
//    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedOnCoverContentView:)];
////    tapGes = tap;
////    tap.enabled = NO;
//    [self.contentView addGestureRecognizer:tap];
    
    CGFloat btnWidth = FLoatChange(90*0.75);
    UIButton * deleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect rect = CGRectMake(0, 0, btnWidth, self.bounds.size.height);
    rect.origin.x = SCREEN_WIDTH - btnWidth;
    deleBtn.frame = rect;
    deleBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [deleBtn addTarget:self action:@selector(tapedOnDeleteBtn:) forControlEvents:UIControlEventTouchUpInside];
    [deleBtn.titleLabel setFont:[UIFont systemFontOfSize:FLoatChange(14)]];
    [deleBtn setTitle:@"删除" forState:UIControlStateNormal];
    [deleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [deleBtn setBackgroundColor:[UIColor redColor]];
    [self addSubview:deleBtn];
    [self sendSubviewToBack:deleBtn];
    deleBtn.hidden = YES;
    editDeleBtn = deleBtn;
    
    swipeWidth = btnWidth;
    
    
    UIView * bgView = self.contentView;
    CGFloat imgWidth = FLoatChange(21);
    CGSize imgSize = CGSizeMake(imgWidth, imgWidth / 21.0 * 38.0);
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(SCREEN_WIDTH - 20 - imgSize.width,(bgView.bounds.size.height - imgSize.height)/ 2.0 , imgSize.width, imgSize.height);
    [btn setImage:[UIImage imageNamed:@"detail_arrow"] forState:UIControlStateNormal];
    btn.userInteractionEnabled = NO;
    [bgView addSubview:btn];
    btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    btn.hidden = YES;
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"通知TA" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(tapedOnNoticeBtn:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:Custom_Blue_Button_BGColor forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:FLoatChange(14)]];
    [bgView addSubview:btn];
    self.noticeBtn = btn;
    
    
    CGFloat redWidth = FLoatChange(5);
    UIView * red = [[UIView alloc] initWithFrame:CGRectMake(0, 0, redWidth, redWidth)];
    red.backgroundColor = [UIColor redColor];
    [btn addSubview:red];
    [red.layer setCornerRadius:redWidth/2.0];
    red.hidden = YES;
    self.noticeRedCircle = red;
    
    
    //实际使用高度
    btn.backgroundColor = [UIColor clearColor];
    CGFloat btnHeight = FLoatChange(40);
    btnWidth = FLoatChange(80);
    btn.frame = CGRectMake(self.bounds.size.width - btnWidth, (self.bounds.size.height-btnHeight)/2.0, btnWidth, btnHeight);
    btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin;
    
    red.center = CGPointMake(btn.bounds.size.width - redWidth*3, redWidth*3);

    
    UIView * line = [DZUtils ToolCustomLineView];
    rect = line.frame;
    rect.size.width = rect.size.height;
    rect.size.height = btnHeight * 0.8;
    line.frame = rect;
    [btn addSubview:line];
    line.center = CGPointMake(FLoatChange(-5), btnHeight/2.0);
    
    
    red = [[UIView alloc] initWithFrame:CGRectMake(0, 0, redWidth, redWidth)];
    red.backgroundColor = [UIColor redColor];
    UILabel * lbl = self.textLabel;
    [lbl addSubview:red];
    [red.layer setCornerRadius:redWidth/2.0];
//    red.hidden = YES;
    self.noUseRedCircle = red;
    red.center = CGPointMake(redWidth/2.0, redWidth*3);
    
    
    UIButton * coverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    coverBtn.frame = self.contentView.bounds;
    [bgView addSubview:coverBtn];
    coverBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [coverBtn addTarget:self action:@selector(tapedOnCoverContentView:) forControlEvents:UIControlEventTouchUpInside];
    cellBtn = coverBtn;
    coverBtn.hidden = YES;
    
    UIView * topLine = [DZUtils ToolCustomLineView];
    [bgView addSubview:topLine];
    
    
    UIView * bottomLine = [DZUtils ToolCustomLineView];
    [bgView addSubview:bottomLine];
    bottomLine.center = CGPointMake(SCREEN_WIDTH/2.0, bgView.bounds.size.height - bottomLine.bounds.size.height/2.0);
    bottomLine.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;

}
-(void)tapedOnNoticeBtn:(id)sender
{
    if(self.TapedOnNotificationForUser)
    {
        self.TapedOnNotificationForUser(self);
    }
}

-(void)tapedOnCoverContentView:(UIButton *)btn
{
    CGFloat centerX = self.contentView.center.x;
    if(centerX != SCREEN_WIDTH/2.0)
    {
        [self runSwipeAnimationForType:JZSwipeTypeNone];
        cellBtn.hidden = YES;
    }
}
-(void)tapedOnDeleteBtn:(id)sender
{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(swipeCell:tipedOnDeleteBtnOnIndex:)])
    {
        [self.delegate swipeCell:self tipedOnDeleteBtnOnIndex:0];
    }
}

- (void)gestureHappened:(UIPanGestureRecognizer *)sender
{
    CGPoint translatedPoint = [sender translationInView:self];
    switch (sender.state)
    {
        case UIGestureRecognizerStatePossible:
            
            break;
        case UIGestureRecognizerStateBegan:
            dragStart = sender.view.center.x;
            break;
        case UIGestureRecognizerStateChanged:{
            
            CGFloat diff = translatedPoint.x;
            
//            NSLog(@"diffdiff %f",diff);
            JZSwipeType originalSwipe = currentSwipe;
            
            CGFloat iconWidth = self.icon.frame.size.width ;
            iconWidth = 10;
            
            if (diff > 0)
            {


                self.contentView.center = CGPointMake(dragStart + diff, self.contentView.center.y);

                // in short right swipe area
                if (diff <= iconWidth+ (kSwipeCellIconHorizontalPadding * 2))
                {
                    editDeleBtn.hidden = YES;
                    // fade range
                    self.icon.image = self.imageSet.shortRightSwipeImage;
                    self.backgroundView.backgroundColor = self.defaultBackgroundColor;
                    self.icon.center = CGPointMake((iconWidth/ 2) + kSwipeCellIconHorizontalPadding, self.contentView.frame.size.height / 2);
                    self.icon.alpha = diff / (iconWidth+ (kSwipeCellIconHorizontalPadding * 3));
                    currentSwipe = JZSwipeTypeNone;
                }
                else
                {
                    editDeleBtn.hidden = YES;
//                    editDeleBtn.hidden = NO;
                    // hang icon to side of content view
                    if (diff < self.shortSwipeLength)
                    {
                        self.icon.image = self.imageSet.shortRightSwipeImage;
                        self.backgroundView.backgroundColor = self.colorSet.shortRightSwipeColor;
                        currentSwipe = JZSwipeTypeShortRight;
                    }
                    else
                    {
                        self.icon.image = self.imageSet.longRightSwipeImage;
                        self.backgroundView.backgroundColor = self.colorSet.longRightSwipeColor;
                        currentSwipe = JZSwipeTypeLongRight;
                    }
                    
                    self.icon.center = CGPointMake(self.contentView.frame.origin.x - ((iconWidth/ 2) + kSwipeCellIconHorizontalPadding), self.contentView.frame.size.height / 2);
                    self.icon.alpha = 1;
                    currentSwipe = JZSwipeTypeNone;

                }
            }
            else if (diff < 0)
            {
//                CGFloat effectDiff = -1.0*diff;
//                
//                if(effectDiff>=swipeWidth)
//                {
//                    diff = -1.0* swipeWidth;
//                }
                
                self.contentView.center = CGPointMake(dragStart + diff, self.contentView.center.y);
                
                // in short left swipe area
                if (diff >= -(iconWidth+ (kSwipeCellIconHorizontalPadding * 2)))
                {
                    editDeleBtn.hidden = YES;
                    // fade range
                    self.icon.image = self.imageSet.shortLeftSwipeImage;
                    self.backgroundView.backgroundColor = self.defaultBackgroundColor;
                    self.icon.center = CGPointMake(self.frame.size.width - ((iconWidth/ 2) + kSwipeCellIconHorizontalPadding), self.contentView.frame.size.height / 2);
                    self.icon.alpha = fabs(diff / (iconWidth+ (kSwipeCellIconHorizontalPadding * 3)));
                    currentSwipe = JZSwipeTypeNone;
                }
                else
                {
                    editDeleBtn.hidden = NO;
                    // hang icon to side of content view
                    if (diff > -self.shortSwipeLength)
                    {
                        self.icon.image = self.imageSet.shortLeftSwipeImage;
                        self.backgroundView.backgroundColor = self.colorSet.shortLeftSwipeColor;
                        currentSwipe = JZSwipeTypeShortLeft;
                    }
                    else
                    {
                        self.icon.image = self.imageSet.longLeftSwipeImage;
                        self.backgroundView.backgroundColor = self.colorSet.longLeftSwipeColor;
                        currentSwipe = JZSwipeTypeLongLeft;
                    }
                    
                    self.icon.center = CGPointMake((self.contentView.frame.origin.x + self.contentView.frame.size.width) + ((iconWidth/ 2) + kSwipeCellIconHorizontalPadding), self.contentView.frame.size.height / 2);
                    self.icon.alpha = 1;
                }
            }
            
//            if (originalSwipe != currentSwipe)
//            {
//                if ([self.delegate respondsToSelector:@selector(swipeCell:swipeTypeChangedFrom:to:)])
//                    [self.delegate swipeCell:self swipeTypeChangedFrom:originalSwipe to:currentSwipe];
//            }
        }
            break;
        case UIGestureRecognizerStateEnded:
            if (currentSwipe != JZSwipeTypeNone)
                [self runSwipeAnimationForType:currentSwipe];
            else
                [self runSwipeAnimationForType:JZSwipeTypeNone];
            break;
        case UIGestureRecognizerStateCancelled:
            
            break;
        case UIGestureRecognizerStateFailed:
            
            break;
    }
}

- (void)runSwipeAnimationForType:(JZSwipeType)type
{
    CGFloat newIconCenterX = 0;
    CGFloat newViewCenterX = 0;
    CGFloat iconAlpha = 1;
    
    CGFloat iconWidth = self.icon.frame.size.width ;
    iconWidth = 10;
    
    if ([self isRightSwipeType:type])
    {
        self.icon.center = CGPointMake(self.contentView.center.x - ((self.contentView.frame.size.width / 2) + (iconWidth/ 2) + kSwipeCellIconHorizontalPadding), self.contentView.frame.size.height / 2);
        newIconCenterX = self.frame.size.width + (iconWidth/ 2) + kSwipeCellIconHorizontalPadding;
        newViewCenterX = newIconCenterX + (self.contentView.frame.size.width / 2) + (iconWidth/ 2) + kSwipeCellIconHorizontalPadding;
    }
    else if ([self isLeftSwipeType:type])
    {
        self.icon.center = CGPointMake(self.contentView.center.x + (self.contentView.frame.size.width / 2) + (iconWidth/ 2) + kSwipeCellIconHorizontalPadding, self.contentView.frame.size.height / 2);
        newIconCenterX = -((iconWidth/ 2) + kSwipeCellIconHorizontalPadding);
        newViewCenterX = newIconCenterX - ((self.contentView.frame.size.width / 2) + (iconWidth/ 2) + kSwipeCellIconHorizontalPadding);
        
        newViewCenterX = SCREEN_WIDTH /2.0 - swipeWidth;
        
    }
    else
    {
//        self.contentView.userInteractionEnabled = NO;
        //归原位
        // non-bouncing swipe type none (unused)
        newIconCenterX = self.icon.center.x;
        newViewCenterX = SCREEN_WIDTH/2.0;
        iconAlpha = 0;
    }
    
    editDeleBtn.hidden = type==JZSwipeTypeNone;
//    tapGes.enabled = type != JZSwipeTypeNone;
    cellBtn.hidden = type==JZSwipeTypeNone;
    
    [UIView animateWithDuration:0.2 delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.icon.center = CGPointMake(newIconCenterX, self.contentView.frame.size.height / 2);
                         self.contentView.center = CGPointMake(newViewCenterX, self.contentView.center.y);
                         self.icon.alpha = iconAlpha;
                         
                     } completion:^(BOOL finished) {
                         if ([self.delegate respondsToSelector:@selector(swipeCell:triggeredSwipeWithType:)])
                             [self.delegate swipeCell:self triggeredSwipeWithType:type];
//                         dragStart = CGFLOAT_MIN;
                     }];

}
-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
//    [self tapedOnCoverContentView:nil];
    [self tapedOnCoverContentView:nil];
    [super setHighlighted:highlighted animated:animated];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
#pragma mark - Helper methods
- (BOOL)isRightSwipeType:(JZSwipeType)type
{
    return type == JZSwipeTypeShortRight || type == JZSwipeTypeLongRight;
}

- (BOOL)isLeftSwipeType:(JZSwipeType)type
{
    return type == JZSwipeTypeShortLeft || type == JZSwipeTypeLongLeft;
}


@end
