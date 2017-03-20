//
//  ZAMMMaterialDesignSpinner.m
//  Pods
//
//  Created by Michael Maxwell on 12/28/14.
//
//

#import "ZAMMMaterialDesignSpinner.h"

static NSString *kMMRingStrokeAnimationKey = @"ZAMMMaterialDesignSpinner.stroke";
static NSString *kMMRingRotationAnimationKey = @"ZAMMMaterialDesignSpinner.rotation";

@interface ZAMMMaterialDesignSpinner ()
@property (nonatomic, readonly) CAShapeLayer *progressLayer;    //白色
@property (nonatomic, strong) CAShapeLayer *progressGrayLayer;  //灰色
@property (nonatomic, strong) CAShapeLayer *progressLightLayer; //浅色
@property (nonatomic, readwrite) BOOL isAnimating;
@end

@implementation ZAMMMaterialDesignSpinner

@synthesize progressLayer=_progressLayer;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initialize];
}

- (void)initialize {
    _timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.layer addSublayer:self.progressLightLayer];
    [self.layer addSublayer:self.progressGrayLayer];
    [self.layer addSublayer:self.progressLayer];
    // See comment in resetAnimations on why this notification is used.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetAnimations) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.progressLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    self.progressLightLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    self.progressGrayLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));

    [self updatePath];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    self.progressLayer.strokeColor = self.tintColor.CGColor;

}

- (void)resetAnimations {
    // If the app goes to the background, returning it to the foreground causes the animation to stop (even though it's not explicitly stopped by our code). Resetting the animation seems to kick it back into gear.
    if (self.isAnimating) {
        [self stopAnimating];
        [self startAnimating];
    }
}

- (void)setAnimating:(BOOL)animate {
    (animate ? [self startAnimating] : [self stopAnimating]);
}
-(CAAnimation *)circleAnimationWithNum:(NSInteger)number
{
//    return nil;
    CGFloat endAngle = M_PI_2*(1/3.0) + M_PI_2;
    CGFloat customSep = (M_PI*4/5.0)/3.0*number;
    CGFloat startAngle = endAngle - customSep;
    CGFloat firstStopAngle = 3*M_PI/2.0;
    CGFloat totalAngle = 2*M_PI - (startAngle - endAngle);

    //周期时间
    CGFloat totalTime = 1.1;
    
    //最小值
    CGFloat limitSpace =  0.1/4.0;
    
    //此值和圆弧角度有关
    CGFloat stopLength = totalTime/30.0;
    CGFloat eveTime = (totalTime-stopLength)/2.0;
    
    
    CGFloat circleTime = 2*M_PI*eveTime / (3/2.0*M_PI - endAngle);
    circleTime = 1;
    
    
    
    CGFloat startTime = 0;
    CABasicAnimation *rotationStart = [CABasicAnimation animation];
    rotationStart.beginTime = startTime;
    rotationStart.keyPath = @"transform.rotation.z";
    rotationStart.duration = eveTime;
    rotationStart.fromValue = @(0) ;
    rotationStart.toValue = @((M_PI*2 - M_PI/2.0 - startAngle));
    
    
    CABasicAnimation *tailAnimationStart = [CABasicAnimation animation];
    tailAnimationStart.beginTime = startTime;
    tailAnimationStart.keyPath = @"strokeEnd";
    tailAnimationStart.duration = eveTime;
    tailAnimationStart.fromValue = @(1.0);
    tailAnimationStart.toValue = @(limitSpace);
    tailAnimationStart.timingFunction = self.timingFunction;
    
    
    startTime = eveTime;
    CABasicAnimation *tailAnimationStop = [CABasicAnimation animation];
    tailAnimationStop.beginTime = startTime;
    tailAnimationStop.keyPath = @"strokeEnd";
    tailAnimationStop.duration = stopLength;
    tailAnimationStop.fromValue = @(limitSpace);
    tailAnimationStop.toValue = @(limitSpace);
    tailAnimationStop.timingFunction = self.timingFunction;
    
    
    CABasicAnimation *rotationStop = [CABasicAnimation animation];
    rotationStop.beginTime = startTime;
    rotationStop.keyPath = @"transform.rotation.z";
    rotationStop.duration = stopLength;
    rotationStop.fromValue = @((M_PI*2 - M_PI/2.0 - startAngle)) ;
    rotationStop.toValue = @((M_PI*2 - M_PI/2.0 - startAngle) + totalAngle * limitSpace);
    
    
    startTime = eveTime + stopLength;
    CABasicAnimation *headRotation = [CABasicAnimation animation];
    headRotation.beginTime = startTime;
    headRotation.keyPath = @"transform.rotation.z";
    headRotation.duration = eveTime;
    headRotation.fromValue =  @(M_PI*2 - M_PI/2.0 - endAngle);
    headRotation.toValue = @(M_PI/2.0 + endAngle + M_PI*2 - M_PI/2.0 - endAngle);
    
    
    CABasicAnimation *headAnimation = [CABasicAnimation animation];
    headAnimation.beginTime = startTime;
    headAnimation.keyPath = @"strokeStart";
    headAnimation.duration = eveTime;
    headAnimation.fromValue = @(1.0-limitSpace);
    headAnimation.toValue = @(0);
    headAnimation.timingFunction = self.timingFunction;
    
    
    CAAnimationGroup *animations = [CAAnimationGroup animation];
    [animations setDuration:totalTime];
//    [animations setDuration:eveTime];
    
    NSArray * arr = nil;
    //后半段  环到点
    arr = @[rotationStop,tailAnimationStart,tailAnimationStop];
    //点到环
    arr = @[headRotation,headAnimation];
    
    arr = @[rotationStart,tailAnimationStart,rotationStop,tailAnimationStop,headAnimation,headRotation];
    
    
    [animations setAnimations:arr];
    animations.repeatCount = INFINITY;
    animations.removedOnCompletion = NO;

    return animations;
}


- (void)startAnimating
{
    if (self.isAnimating)
        return;
    
    CAAnimation * animations = [self circleAnimationWithNum:3];
    [self.progressLayer addAnimation:animations forKey:kMMRingStrokeAnimationKey];
    
    animations = [self circleAnimationWithNum:2];
    [self.progressGrayLayer addAnimation:animations forKey:kMMRingStrokeAnimationKey];
    
    animations = [self circleAnimationWithNum:1];
    [self.progressLightLayer addAnimation:animations forKey:kMMRingStrokeAnimationKey];
    
    self.isAnimating = true;
    
    if (self.hidesWhenStopped)
    {
        self.hidden = NO;
    }
}

- (void)stopAnimating {
    if (!self.isAnimating)
        return;
    
    [self.progressLayer removeAnimationForKey:kMMRingRotationAnimationKey];
    [self.progressLayer removeAnimationForKey:kMMRingStrokeAnimationKey];
    
    [self.progressGrayLayer removeAnimationForKey:kMMRingRotationAnimationKey];
    [self.progressGrayLayer removeAnimationForKey:kMMRingStrokeAnimationKey];
    
    [self.progressLightLayer removeAnimationForKey:kMMRingRotationAnimationKey];
    [self.progressLightLayer removeAnimationForKey:kMMRingStrokeAnimationKey];
    
    self.isAnimating = false;
    
    if (self.hidesWhenStopped) {
        self.hidden = YES;
    }
}

#pragma mark - Private

- (void)updatePath
{
    [self refreshEffectiveLayer:self.progressLightLayer andSepNum:1];
    [self refreshEffectiveLayer:self.progressGrayLayer andSepNum:2];
    [self refreshEffectiveLayer:self.progressLayer andSepNum:3];
    
//    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
//    CGFloat radius = MIN(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2) - self.progressLayer.lineWidth / 2;
//    
//    CGFloat hideAngle = M_PI*3/2.0 + M_PI/4.0;
//    CGFloat sepAngle = M_PI/4.0;
//    CGFloat startAngle = (CGFloat)(hideAngle + sepAngle);
//    CGFloat endAngle = (CGFloat)(hideAngle);
//    
//    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
//    
//    self.progressLayer.path = path.CGPath;
//    self.progressLayer.lineCap = kCALineCapRound;
//    self.progressLayer.strokeStart = 0.1/4.0;
//    self.progressLayer.strokeEnd = 1.0;
//
////    self.progressLayer.strokeStart = 0.0f;
////    self.progressLayer.strokeEnd = 0.1/4.0;
}
-(void)refreshEffectiveLayer:(CAShapeLayer *)layer andSepNum:(NSInteger)number
{
    
    CGFloat startAngle = M_PI_2*(1/3.0) + M_PI_2;
    CGFloat customSep = (M_PI*4/5.0)/3.0*number;
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = MIN(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2) - self.progressLayer.lineWidth / 2;
    
    CGFloat hideAngle = M_PI*3/2.0 + M_PI/4.0;
    CGFloat endAngle = (CGFloat)(hideAngle);
    endAngle = startAngle - customSep;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:endAngle  endAngle:startAngle clockwise:NO];

    layer.path = path.CGPath;
    layer.lineCap = kCALineCapRound;
    
    layer.strokeStart = 0.0f;
    layer.strokeEnd = 1.0;
  
//        layer.strokeStart = 0.0f;
//        layer.strokeEnd = 0.1/4.0;
    
//    layer.strokeStart = 1.0f-0.1/4.0;
//    layer.strokeEnd = 1.0f;
}


#pragma mark - Properties

- (CAShapeLayer *)progressLightLayer
{
    if (!_progressLightLayer) {
        _progressLightLayer = [CAShapeLayer layer];
        _progressLightLayer.strokeColor = [UIColor colorWithWhite:0.99 alpha:0.8].CGColor;
        _progressLightLayer.fillColor = nil;
        _progressLightLayer.lineWidth = 1.5f;
    }
    return _progressLightLayer;
}
- (CAShapeLayer *)progressGrayLayer
{
    if (!_progressGrayLayer)
    {
        _progressGrayLayer = [CAShapeLayer layer];
        _progressGrayLayer.strokeColor = [UIColor colorWithWhite:0.99 alpha:0.9].CGColor;
        _progressGrayLayer.fillColor = nil;
        _progressGrayLayer.lineWidth = 1.5f;
    }
    return _progressGrayLayer;
}
- (CAShapeLayer *)progressLayer
{
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.strokeColor = self.tintColor.CGColor;
        _progressLayer.fillColor = nil;
        _progressLayer.lineWidth = 1.5f;
    }
    return _progressLayer;
}

- (BOOL)isAnimating {
    return _isAnimating;
}

- (CGFloat)lineWidth {
    return self.progressLayer.lineWidth;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    self.progressLayer.lineWidth = lineWidth;
    self.progressGrayLayer.lineWidth = lineWidth;
    self.progressLightLayer.lineWidth = lineWidth;
    [self updatePath];
}

- (void)setHidesWhenStopped:(BOOL)hidesWhenStopped {
    _hidesWhenStopped = hidesWhenStopped;
    self.hidden = !self.isAnimating && hidesWhenStopped;
}

@end
