//
//  ZAQuickCircle.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/6/18.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAQuickCircle.h"
@interface ZAQuickCircle()
{
    BOOL redStyle ;
    UIImageView * imgView;
    UILabel * hzLbl;
    UILabel * enLbl;
    
    UIBezierPath * selectPath;
}
@property (nonatomic,strong) UIImageView * iconImg;
@property (nonatomic,strong) UILabel * txtLbl;
@property (nonatomic,strong) UILabel * bigLbl;

@end
@implementation ZAQuickCircle
-(UILabel *)txtLbl
{
    if(!_txtLbl)
    {
        CGRect imgRect = CGRectZero;
        NSString * bigStr = @"求助";//解除防护
//        NSString * enStr = @"Emergency Protect";
        UIFont * bigFont = [UIFont systemFontOfSize:FLoatChange(35)];
//        UIFont * subFont = [UIFont systemFontOfSize:FLoatChange(15)];
        CGSize txtSize = [bigStr sizeWithFont:bigFont];
        imgRect.size = txtSize;
        UILabel * lbl = [[UILabel alloc] initWithFrame:imgRect];
        lbl.font = bigFont;
        lbl.text = bigStr;
        lbl.textColor = [UIColor whiteColor];
        lbl.backgroundColor = [UIColor clearColor];
        self.txtLbl = lbl;
    }
    return _txtLbl;
}
-(UILabel *)bigLbl
{
    if(!_bigLbl)
    {
        CGRect imgRect = CGRectZero;
        NSString * bigStr = @"一键";//松手
        //        NSString * enStr = @"Emergency Protect";
        UIFont * bigFont = [UIFont systemFontOfSize:FLoatChange(35)];
        //        UIFont * subFont = [UIFont systemFontOfSize:FLoatChange(15)];
        CGSize txtSize = [bigStr sizeWithFont:bigFont];
        imgRect.size = txtSize;
        UILabel * lbl = [[UILabel alloc] initWithFrame:imgRect];
        lbl.font = bigFont;
        lbl.text = bigStr;
        lbl.textColor = [UIColor whiteColor];
        lbl.backgroundColor = [UIColor clearColor];
        self.bigLbl = lbl;
    }
    return _bigLbl;
}

-(UIImageView * )iconImg
{
    if(!_iconImg)
    {
        CGRect imgRect = CGRectZero;
        CGFloat extenH = FLoatChange(0.75);
        imgRect.size = CGSizeMake(60 * extenH, 75 * extenH);
        
        UIImageView * img = [[UIImageView alloc] initWithFrame:imgRect];
        img.image = [UIImage imageNamed:@"quick_protected_inuse"];
        _iconImg = img;
    }
    return _iconImg;
}

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if(self){
        self.extend = FLoatChange(35);
        redStyle = NO;      //差距是外边线
        //Define the circle radius taking into account the safe area
        
        self.opaque = NO;
        //Initialize the Angle at 0
        
//        [self addSubview:self.iconImg];
        [self addSubview:self.txtLbl];
        [self addSubview:self.bigLbl];
    }
    return self;
}

-(void)refreshCircleWithSelected:(BOOL)tapedOn
{
    redStyle = tapedOn;
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
    
    CGFloat halfExtend = self.extend /2.0;
    //外圈半径长度
    NSInteger bigRadius = rect.size.width/2.0 - 1 - halfExtend;
    
    //内圈半径长度
    NSInteger smallRadius = bigRadius - halfExtend;
    NSInteger shadowWidth = halfExtend * 1;
    
    //红色状态
    UIColor * lineColor = [UIColor clearColor];
    UIColor * smallLineColor = [UIColor clearColor];
    UIColor *  circleColor = [DZUtils colorWithHex:@"D33922"];
    circleColor = [DZUtils colorWithHex:@"EA5050"];
    
//    UIColor * shadowColor = [UIColor clearColor];
    UIColor * txtColor = [DZUtils colorWithHex:@"D39E9E"];
    UIColor * subTxtColor = [DZUtils colorWithHex:@"fcc4c4"];
    NSString* imgName = @"quick_protected_nouse";
    
    UIColor * subCircleColor = RGBA(160, 60, 60,0.3);
    UIColor * maxCircleColor = RGBA(160, 60, 60,0.2);
    subCircleColor = RGBA(234, 80, 80,0.3);
    maxCircleColor = RGBA(234, 80, 80,0.2);
    
    if(!redStyle)
    {
        txtColor = [UIColor whiteColor];
        circleColor = [DZUtils colorWithHex:@"FF6650"];
        lineColor = circleColor;
        smallLineColor = [DZUtils colorWithHex:@"f7494a"];
//        circleColor = [UIColor clearColor];
//        shadowColor = [DZUtils colorWithHex:@"f2a3a3"];
//        txtColor = [DZUtils colorWithHex:@"de221b"];
//        subTxtColor = [DZUtils colorWithHex:@"f2a3a3"];
        imgName = @"quick_protected_inuse";
    }
    
    self.txtLbl.text = redStyle?@"求助":@"求助";
    self.bigLbl.text = redStyle?@"松手":@"一键";

//    self.txtLbl.textColor = txtColor;
    self.iconImg.image = [UIImage imageNamed:imgName];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    /** Draw the Background **/
    CGFloat lineWidth = 1;
    
    //画外边线
//    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, bigRadius, 0, M_PI *2, 0);
//    [lineColor setStroke];
//    CGContextSetLineWidth(ctx, lineWidth);
//    CGContextSetLineCap(ctx, kCGLineCapButt);
//    CGContextDrawPath(ctx, kCGPathStroke);
    
    
    if(!redStyle)
    {
        lineWidth = 0;
        //画圆
        CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, bigRadius+halfExtend, 0, M_PI *2, 0);
        [maxCircleColor setFill];
        CGContextSetLineWidth(ctx, lineWidth);
        CGContextSetLineCap(ctx, kCGLineCapButt);
        CGContextDrawPath(ctx, kCGPathFillStroke);
        
//        CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, bigRadius+halfExtend, 0, M_PI *2, 0);
//        [maxCircleColor setStroke];
//        CGContextSetLineWidth(ctx, lineWidth);
//        CGContextSetLineCap(ctx, kCGLineCapButt);
//        CGContextDrawPath(ctx, kCGPathStroke);
        
        //画圆
        CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, bigRadius, 0, M_PI *2, 0);
        [subCircleColor setFill];
        CGContextSetLineWidth(ctx, lineWidth);
        CGContextSetLineCap(ctx, kCGLineCapButt);
        CGContextDrawPath(ctx, kCGPathFillStroke);
        
//        CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, bigRadius, 0, M_PI *2, 0);
//        [subCircleColor setStroke];
//        CGContextSetLineWidth(ctx, lineWidth);
//        CGContextSetLineCap(ctx, kCGLineCapButt);
//        CGContextDrawPath(ctx, kCGPathStroke);
    }
    
    lineWidth = 1;
    selectPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)) radius:bigRadius startAngle:0 endAngle:2 * M_PI clockwise:1];
    
    
    //画内边线
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, smallRadius, 0, M_PI *2, 0);
    [smallLineColor setStroke];
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    CGContextDrawPath(ctx, kCGPathStroke);

    //画内圆
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, smallRadius, 0, M_PI *2, 0);
    [circleColor setFill];
    CGContextSetLineCap(ctx, kCGLineCapButt);
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
    CGFloat halfWidth = self.bounds.size.width/2.0;
    //调整位置
//    self.iconImg.center = CGPointMake(halfWidth, 0.26 * rect.size.height + self.iconImg.bounds.size.height/2.0);
    self.txtLbl.center = CGPointMake(halfWidth, 0.50 * rect.size.height + self.txtLbl.bounds.size.height/2.0);
    self.bigLbl.center = CGPointMake(halfWidth, 0.33 * rect.size.height + self.bigLbl.bounds.size.height/2.0);
 
    
}


/** Tracking is started **/

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    BOOL result = [super beginTrackingWithTouch:touch withEvent:event];
    if(!result)
    {
        return result;
    }
    //Get touch location
    CGPoint lastPoint = [touch locationInView:self];
    BOOL contain =  [selectPath containsPoint:lastPoint];

//    BOOL effective = CGRectContainsPoint(self.bounds, lastPoint);
    if(!contain)
    {
        NSLog(@"%s contain",__FUNCTION__);
        return NO;
    }
    
    //We need to track continuously
    return YES;
}

/** Track continuos touch event (like drag) **/
-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    BOOL result = [super continueTrackingWithTouch:touch withEvent:event];
    if(!result)
    {
        return result;
    }
    
    //Get touch location
    CGPoint lastPoint = [touch locationInView:self];
    
//    BOOL effective = CGRectContainsPoint(self.bounds, lastPoint);
    //判定点的位置，区间内，区间外，改变 hidePart
    //根据hidePart 设定状态
    BOOL contain =  [selectPath containsPoint:lastPoint];

    if(!contain)
    {
        NSLog(@"%s contain",__FUNCTION__);
        [self cancelTrackingWithEvent:event];
        return NO;
    }
    
    
    //Control value has changed, let's notify that
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    return YES;
}
- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    [super cancelTrackingWithEvent:event];
    
    
    
}
/** Track is finished **/
-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    
    CGPoint lastPoint = [touch locationInView:self];
    BOOL contain =  [selectPath containsPoint:lastPoint];
    if(contain)
    {
        [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
    }
    
}

@end
