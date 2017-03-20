//
//  ZACircularSlider.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/6/15.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZACircularSlider.h"
#import "Commons.h"

#pragma mark - Private -

@interface ZACircularSlider(){
    UITextField *_textField;
    int radius;
    BOOL hidePart;      //控制是否隐藏
    UIButton * selectBtn; //选中按钮部分
    UIBezierPath * selectPath;
    BOOL showCircle;
    BOOL  noneCheck;
}

@property (nonatomic,assign) CGFloat fingerAngle;             //手指最后的角度，用来标识当前响应位置
@property (nonatomic,assign) CGFloat latestEffectiveAngle;    //上一次的有效滑动位置
@end


#pragma mark - Implementation -

@implementation ZACircularSlider

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if(self){
        self.opaque = NO;
        
        //Define the circle radius taking into account the safe area
        noneCheck = NO;
        
//        self.extend = 15;
        hidePart = YES;
        showCircle = YES;
        //Initialize the Angle at 0
        self.angle = 0;
        self.maxAngle = 720;
        self.latestEffectiveAngle = NSNotFound;
        self.fingerAngle = -1;
        
        self.timeDegEx = 360.0 / 60 ;
        self.circleNum = 60 / 5;
        
        //Define the Font
//        UIFont *font = [UIFont fontWithName:TB_FONTFAMILY size:TB_FONTSIZE];
//        //Calculate font size needed to display 3 numbers
//        NSString *str = @"000000";
//        CGSize fontSize = [str sizeWithFont:font];
//        
//        _circleBGColor = [UIColor greenColor];
//        
//        //Using a TextField area we can easily modify the control to get user input from this field
//        _textField = [[UITextField alloc]initWithFrame:CGRectMake((frame.size.width  - fontSize.width) /2,
//                                                                  (frame.size.height - fontSize.height) /2,
//                                                                  fontSize.width,
//                                                                  fontSize.height)];
//        _textField.backgroundColor = [UIColor clearColor];
//        _textField.textColor = [UIColor colorWithWhite:1 alpha:0.8];
//        _textField.textAlignment = NSTextAlignmentCenter;
//        _textField.font = font;
//        _textField.text = [NSString stringWithFormat:@"%d",self.angle];
//        _textField.enabled = NO;
//        
//        [self addSubview:_textField];
        
        CGFloat width = radius * 0.5;;
        UIButton * bgView = [UIButton buttonWithType:UIButtonTypeCustom];
        bgView.frame = CGRectMake(0, 0, radius, radius);
        bgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:bgView];
        [bgView addTarget:self action:@selector(tapedOnContainCircleBtn:) forControlEvents:UIControlEventTouchUpInside];
        bgView.center = CGPointMake(self.bounds.size.width /2.0, self.bounds.size.height / 2.0 );
        bgView.clipsToBounds = YES;
        [bgView setImage:[UIImage imageNamed:@"time_confirm"] forState:UIControlStateNormal];
        [bgView setImage:[UIImage imageNamed:@"time_confirm_selected"] forState:UIControlStateSelected];
        [bgView setImage:[UIImage imageNamed:@"time_confirm_selected"] forState:UIControlStateHighlighted];
        [[bgView layer] setCornerRadius:width];
        selectBtn = bgView;
    }
    
    return self;
}



#pragma mark - UIControl Override -

/** Tracking is started **/
-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super beginTrackingWithTouch:touch withEvent:event];
    
    
    hidePart = NO;
    //Get touch location
    CGPoint lastPoint = [touch locationInView:self];
    
    BOOL effective = CGRectContainsPoint(self.bounds, lastPoint);
    if(!effective)
    {
        return NO;
    }
    
    //Use the location to design the Handle
    [self movehandle:lastPoint];
    
    //Control value has changed, let's notify that
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    //We need to track continuously
    return YES;
}

/** Track continuos touch event (like drag) **/
-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super continueTrackingWithTouch:touch withEvent:event];
    
    //Get touch location
    CGPoint lastPoint = [touch locationInView:self];
    
    BOOL effective = CGRectContainsPoint(self.bounds, lastPoint);
    if(!effective)
    {
        [self cancelTrackingWithEvent:event];
        return NO;
    }
    
    //判定点的位置，区间内，区间外，改变 hidePart
    //根据hidePart 设定状态
    BOOL contain =  [selectPath containsPoint:lastPoint];
    [self showBtnStyleWith:contain];
    hidePart = contain;
    
    //Use the location to design the Handle
    [self movehandle:lastPoint];
    
    //Control value has changed, let's notify that
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    return YES;
}
- (void)cancelTrackingWithEvent:(UIEvent *)event{
    [super cancelTrackingWithEvent:event];
    
    hidePart = YES;
    self.latestEffectiveAngle = NSNotFound;
//    self.fingerAngle = NSNotFound;
    [self showBtnStyleWith:NO];
    [self sendActionsForControlEvents:UIControlEventTouchCancel];
    
    [self setNeedsDisplay];
}
/** Track is finished **/
-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    CGPoint lastPoint = [touch locationInView:self];
    BOOL contain =  [selectPath containsPoint:lastPoint];
    if(contain)
    {
        self.fingerAngle = -1;
    }
    
    hidePart = YES;
    self.latestEffectiveAngle = NSNotFound;
//    self.fingerAngle = NSNotFound;
    [self showBtnStyleWith:NO];
    [self setNeedsDisplay];
    if(contain){
        [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
    }

}

-(void)tapedOnContainCircleBtn:(id)sender
{
    //结束编辑
    self.fingerAngle = -1;
    [self setNeedsDisplay];
    [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
}

-(void)showBtnStyleWith:(BOOL)tapedOn
{
    BOOL selected = YES;
    UIColor * nextColor = [UIColor greenColor];
    if(!tapedOn)
    {
        selected = NO;
        nextColor = [UIColor whiteColor];
    }
//    selectBtn.backgroundColor = nextColor;
    selectBtn.selected = selected;
}

#pragma mark - Drawing Functions -
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    radius = self.effectiveRadius;
    
    
    CGFloat width = radius * 85/240.0;
    selectBtn.frame = CGRectMake(0, 0, width, width);
    selectBtn.center = CGPointMake(self.bounds.size.width /2.0, self.bounds.size.height / 2.0 );
    [[selectBtn layer] setCornerRadius:width/2.0];
}


//Use the draw rect to draw the Background, the Circle and the Handle
-(void)drawRect:(CGRect)rect{
    
    [super drawRect:rect];
    radius = self.effectiveRadius;

    CGFloat lineWidth = _lineWidth;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    /** Draw the Background **/
    //Create the path，默认底图
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, 0 , M_PI * 2  , 0);
    
    //Set the stroke color to black
    [TB_SLIDER_UNSELECTED_COLOR setStroke];
    //Define line width and cap
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    
    //draw it!
    CGContextDrawPath(ctx, kCGPathStroke);
    
    
    //增加边线颜色
    //Create the path
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius + lineWidth /2.0, 0 , M_PI * 2  , 0);
    

    
    //Set the stroke color to black
    [TB_SLIDER_HEIGHT1_LINE_COLOR setStroke];
    
    //Define line width and cap
    CGContextSetLineWidth(ctx, 1);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    
    //** Draw the circle (using a clipped gradient) **/
    //根据
    selectPath = nil;
    CGFloat containRadius = radius * 85/240.0;
    selectPath = [UIBezierPath bezierPathWithArcCenter:selectBtn.center radius:containRadius startAngle:0 endAngle:2 * M_PI clockwise:1];
    
    CGContextAddPath(ctx, selectPath.CGPath);
    //增加边线颜色
    CGContextSetLineWidth(ctx, 1);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    CGContextDrawPath(ctx, kCGPathStroke);

    
    if(!showCircle&&hidePart) return;
    /** Create THE MASK Image **/
    CGFloat angleLength = M_PI_2;
    NSInteger latest = self.fingerAngle;
    if(latest<90)
    {
        latest = 90 - latest;
    }else
    {
        latest = 90 + 360 - latest;
    }
    CGFloat fingerAngle = ToRad(latest) ;
    
    CGFloat startAngle = fingerAngle - (angleLength / 2) ;
    CGFloat endAngle =  fingerAngle + (angleLength / 2) ;
    if(startAngle < 0)
    {
        startAngle = fingerAngle - (angleLength / 2) + 2 * M_PI;
    }
    
    CGContextAddArc(ctx, self.frame.size.width/2  , self.frame.size.height/2, radius,  - startAngle , - endAngle , 1);
    [TB_SLIDER_SELECTED_COLOR setStroke];
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextDrawPath(ctx, kCGPathStroke);
    
//
//    UIGraphicsBeginImageContext(CGSizeMake(TB_SLIDER_SIZE,TB_SLIDER_SIZE));
//    CGContextRef imageCtx = UIGraphicsGetCurrentContext();
//    CGContextAddArc(imageCtx, self.frame.size.width/2  , self.frame.size.height/2, radius , startAngle , endAngle , 0);
//    [[UIColor redColor]set];
//    
//    //Use shadow to create the Blur effect
//    CGContextSetShadowWithColor(imageCtx, CGSizeMake(0, 0), self.fingerAngle/20, [UIColor redColor].CGColor);
//    
//    //define the path
//    CGContextSetLineWidth(imageCtx, TB_LINE_WIDTH);
//    CGContextDrawPath(imageCtx, kCGPathStroke);
//    
//    //save the context content into the image mask
//    CGImageRef mask = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
//    UIGraphicsEndImageContext();
//    
//    
//    
//    /** Clip Context to the mask **/
//    CGContextSaveGState(ctx);
//    
//    CGContextClipToMask(ctx, self.bounds, mask);
//    CGImageRelease(mask);
//    
//    
//    /** THE GRADIENT **/
//    
//    //list of components
//    CGFloat components[8] = {
//        0.0, 0.0, 1.0, 1.0,     // Start color - Blue
//        1.0, 0.0, 1.0, 1.0,
//    };   // End color - Violet
//    
//    //增加颜色数组控制
//    
//    
//    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
//    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, components, NULL, 2);
//    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
//    
//    //Gradient direction
//    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
//    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
//    //Draw the gradient
//    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
//    CGGradientRelease(gradient), gradient = NULL;
//    
//    CGContextRestoreGState(ctx);
    
    
    /** Add some light reflection effects on the background circle**/
    
    
    CGContextSetLineWidth(ctx, 1);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    //Draw the outside light
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, self.frame.size.width/2  , self.frame.size.height/2, radius+lineWidth/2,  0, 2 * M_PI, 1);
    [[UIColor colorWithWhite:1.0 alpha:0.01]set];
    CGContextDrawPath(ctx, kCGPathStroke);
    
    //draw the inner light
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, self.frame.size.width/2  , self.frame.size.height/2, radius-lineWidth/2,  0, 2 * M_PI, 1);
    [[UIColor colorWithWhite:1.0 alpha:0.01]set];
    CGContextDrawPath(ctx, kCGPathStroke);
    
    
    /** Draw the handle **/
    //    [self drawTheHandlex:ctx];
    
}

/** Draw a white knob over the circle **/
-(void) drawTheHandle:(CGContextRef)ctx{
    
    CGContextSaveGState(ctx);
    
    //I Love shadows
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 3, [UIColor blackColor].CGColor);
    
    //Get the handle position
    CGPoint handleCenter =  [self pointFromAngle: self.fingerAngle];
    
    //Draw It!
    [[UIColor colorWithWhite:1.0 alpha:0.7]set];
    CGContextFillEllipseInRect(ctx, CGRectMake(handleCenter.x, handleCenter.y, _lineWidth, _lineWidth));
    
    CGContextRestoreGState(ctx);
}


#pragma mark - Math -

/** Move the Handle **/
-(void)movehandle:(CGPoint)lastPoint{
    
    //Get the center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    //Calculate the direction from a center point and a arbitrary position.
    float currentAngle = AngleFromNorth(centerPoint, lastPoint, NO);
    CGFloat latest = 360.0 - currentAngle;
    
    if(latest<90)
    {
        latest = 90 - latest;
    }else
    {
        latest = 90 + 360 - latest;
    }
    
    self.fingerAngle = latest;
    //Update the textfield
    
    
    latest = [self effectiveAngleForCurrentAngle:latest];
    
    //之前无数据，刚开始触碰
    if(self.latestEffectiveAngle == NSNotFound)
    {
        self.latestEffectiveAngle = latest;
    }
    
    //处理轮圈情况
    if(fabsf(latest - self.latestEffectiveAngle) >= 300.0 )
    {
        CGFloat effective = latest - self.latestEffectiveAngle;
        NSInteger num = 0;
        //当从 350 到达 0 时
        if(effective < 0 )
        {
            num ++;
        }else
        {//当从 0 到达 350 时
            num --;
        }
        //数值变为带着圈数的刻度
        latest = num * 360 + latest;
    }
    
    
    if(fabsf(latest - self.latestEffectiveAngle) >= self.timeDegEx )
    {
        CGFloat effective = latest - self.latestEffectiveAngle;
//        effective -= ((int)effective % (int)self.timeDegEx);
//        effective = effective / self.timeDegEx;
        //1、度数，转为时间参数
        //2、时间最小基数为5分钟
        NSInteger timeNum =  effective / (self.timeDegEx + 0.0);
        CGFloat degNum = effective - timeNum * self.timeDegEx;
        latest -= degNum;
        
        self.angle += timeNum;
        if(latest<0) latest+= 360.0;
        if(latest>=360) latest -= 360;
        self.latestEffectiveAngle =  latest;
        

        if(self.angle > self.maxAngle || self.angle < 0)
        {
            self.angle = self.angle < 0 ? 0 : self.maxAngle;
        }
        
        noneCheck = NO;
        if(self.angle == 0 || self.angle == self.maxAngle){
            noneCheck = YES;
        }
        _textField.text =  [NSString stringWithFormat:@"%d", self.angle];
    }

    //不成功
    if(noneCheck)
    {
//        self.latestEffectiveAngle =  latest;
    }
    
    //Redraw
    [self setNeedsDisplay];
}
-(CGFloat)effectiveAngleForCurrentAngle:(CGFloat)angle
{
    CGFloat eveAngle = 360 / self.circleNum;
    NSInteger number = angle / eveAngle;
    CGFloat last = number * eveAngle;
    return last;
}

/** Given the angle, get the point position on circumference **/
-(CGPoint)pointFromAngle:(int)angleInt{
    
    //Circle center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2 - TB_LINE_WIDTH/2, self.frame.size.height/2 - TB_LINE_WIDTH/2);
    
    //The point position on the circumference
    CGPoint result;
    result.y = round(centerPoint.y - radius * cos(ToRad(angleInt))) ;
    result.x = round(centerPoint.x + radius * sin(ToRad(angleInt)));
    
    return result;
}

//Sourcecode from Apple example clockControl
//Calculate the direction in degrees from a center point to an arbitrary position.
static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y,v.x);
    result = ToDeg(radians);
    return (result >=0  ? result : result + 360.0);
}

@end
