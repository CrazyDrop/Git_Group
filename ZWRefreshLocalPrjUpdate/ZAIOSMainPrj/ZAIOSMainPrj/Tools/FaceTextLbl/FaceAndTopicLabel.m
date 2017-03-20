//
//  FaceAndTopicLabel.m
//  ViewControllerTest
//
//  Created by Apple on 14-8-28.
//  Copyright (c) 2014年 ___李言___. All rights reserved.
//

#import "FaceAndTopicLabel.h"
#import <CoreText/CoreText.h>
#import "LYTextAttachment.h"
#import "PoundTopicModel.h"
@interface FaceAndTopicLabel()
{
    CTFrameRef _frame;
    NSMutableAttributedString *atttext;
}

@property (nonatomic,strong) NSAttributedString * currentAttStr;
@property (nonatomic,strong) NSString * normalText;

@property (nonatomic,strong) NSAttributedString * frameStr;//此变量，为实现功能，废弃
@end
@implementation FaceAndTopicLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self attachTapHandler];
        
        _lineSpace  = 10.0f;
    }
    return self;
}
#pragma mark - privateMethods
//UILabel默认是不接收事件的，我们需要自己添加touch事件
-(void)attachTapHandler{
    self.userInteractionEnabled = YES;  //用户交互的总开关
    UITapGestureRecognizer *doubleTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTouch.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTouch];
    
    UITapGestureRecognizer *singleTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTouch.numberOfTapsRequired = 1;
    [singleTouch requireGestureRecognizerToFail:doubleTouch];
    [self addGestureRecognizer:singleTouch];
    
    UILongPressGestureRecognizer *longPress=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
    [self addGestureRecognizer:longPress];
    
}
//}
-(void)handleDoubleTap:(UIGestureRecognizer*) recognizer{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (menu.isMenuVisible) {
        //        [self hideMenuController];
    }else{
        [self becomeFirstResponder];
        [menu setTargetRect:self.frame inView:self.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}
-(void)handleSingleTap:(UIGestureRecognizer*) recognizer{
    //如果有菜单，就先把菜单关了
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (menu.isMenuVisible) {
        [self hideMenuController];
        return;
    }
    //    //获取UITouch对象
    //    UITouch *touch = [touches anyObject];
    //    //获取触摸点击当前view的坐标位置
    //    CGPoint location = [touch locationInView:self];
    CGPoint location=[recognizer locationInView:self];
    
    
    CFArrayRef lines = CTFrameGetLines(_frame);
    //调整响应高度范围
    
    CTLineRef line = [self lineRefForPosition:location];
    
//    location.x += 6;
    //获取点击位置所处的字符位置，就是相当于点击了第几个字符
    CFIndex index = CTLineGetStringIndexForPosition(line, location);
    CFArrayRef runs=CTLineGetGlyphRuns(line);
    
    if (!runs)
    {
        return;
    }
    
    //由于使用了attributiteText，导致分行数据异常(每行的最终位和实际位不一致)
    //通过循环的方式，修改数据
    //需要修改  index或者 校对方法  选择修改校对方法
    //图片实际占据一个中文字符大小，而系统认为，仅占一个字符大小，
    int faceCount = 0;//表情数量
    int charNumCount = 0;//字符数量
    int effectNumCount = 0;//表情数量导致的字符有效差异
    int numberCount = 0;//数字数量
    
    
    NSInteger * runTotalNum = 0;
    //循环行数
    for (int i= 0; i < CFArrayGetCount(lines); i++)
    {
        CTLineRef aLine = CFArrayGetValueAtIndex(lines, i);
        CFArrayRef aRuns=CTLineGetGlyphRuns(aLine);
        //循环每一个run
        for (int j=0; j<CFArrayGetCount(aRuns); j++)
        {
            CTRunRef run=CFArrayGetValueAtIndex(aRuns, j);
            CFRange runRange=CTRunGetStringRange(run);
            NSInteger orginLocation=runRange.location;
            
            NSDictionary* totalDic = (__bridge NSDictionary*)CTRunGetAttributes(run);
            NSString * eveText = [totalDic valueForKey:@"valueTextKey"];
            if ([totalDic valueForKey:@"NSAttachment"])
            {
                faceCount ++;
            }
            
            if (j==0)
            {
             //   NSLog(@"%d %d %@",i,j,eveText);

            }
            runTotalNum ++;
            effectNumCount = (int)(faceCount/2+1);
//            NSLog(@"index,orginLocation,faceCount %d %d %d %d",index,orginLocation,faceCount,runRange.length);

//            NSLog(@"%d %d %d %d %@",orginLocation,runRange.length,index,effectNumCount,eveText);

            //仅当前一个，不能包含此值，后一个，能够
            //此判定，在最后一行不准确，在最后一个字符处不准确，因为数据最大值为
            
            //最后一个字符时，在最后一个run生效
            if (runRange.location+runRange.length>=index)
            {
                [self tapedOnSelectedRun:run];
                return;
            }
        }
    }
}
-(CTLineRef)lineRefForPosition:(CGPoint)location
{
    //获取每一行
    CFArrayRef lines = CTFrameGetLines(_frame);
    CGPoint origins[CFArrayGetCount(lines)];
    
    //获取每行的原点坐标
    CTFrameGetLineOrigins(_frame, CFRangeMake(0, 0), origins);
    CTLineRef line = NULL;
    NSInteger lineCount = CFArrayGetCount(lines);
    
    if (lineCount==1)
    {
        line = CFArrayGetValueAtIndex(lines, 0);
        return line;
    }
    
    CGPoint origin1 = origins[0];
    CGPoint origin2 = origins[1];
    CGFloat sepHeight = origin1.y - origin2.y;
    
    for (int i= 0; i < lineCount; i++)
    {
        CGPoint origin = origins[i];
        CGPathRef path = CTFrameGetPath(_frame);
        //获取整个CTFrame的大小
        CGRect rect = CGPathGetBoundingBox(path);
        //坐标转换，把每行的原点坐标转换为uiview的坐标体系
        CGFloat y = rect.origin.y+ rect.size.height - origin.y+sepHeight/2.0;
        //判断点击的位置处于那一行范围内
        
       // NSLog(@"%@ %d %f %@",NSStringFromCGPoint(location),i,y,NSStringFromCGPoint(origin));
        if (location.y <= y)
        {
          //  NSLog(@"lineindex %d",i);
            line = CFArrayGetValueAtIndex(lines, i);
            
            break;
        }
        
        //由于使用了全文本attributedstring，不会再进如此判定
        //依然会进入此条件，点击范围比较偏
        //当最后一行时，
        if (i == (lineCount -1))
        {
            location.x = MAXFLOAT;
            line = CFArrayGetValueAtIndex(lines, i);
        }
    }
    return line;
}

- (BOOL)validateInputWithString:(NSString *)aString
{
    NSString * const regularExpression = @"^[\u4E00-\u9FA5]+$";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularExpression
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (error) {
        NSLog(@"error %@", error);
    }
    
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:aString
                                                        options:0
                                                          range:NSMakeRange(0, [aString length])];
    return numberOfMatches > 0;
}
-  (int)convertToInt:(NSString*)strtemp {
    
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            NSLog(@"lengthOfBytesUsingEncoding %c",*p);
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return (strlength+1)/2;
    
}
- (NSString*)unicodeLengthOfString:(NSString*)text
{
    NSMutableString* str = [text mutableCopy];
    
    float asciiLength = 0;
    
    //插入换行符个数，最多4个
    int insertCount = 0;
    
    //为了防止临近几个char经过NSUInteger unicodeLength = asciiLength/2;  if(asciiLength%2){unicodeLength++;} 计算后值一样，会进行相邻的2个插入换行符
    int lastCharIsInserted = 0;
    
    for (int i = 0, len = text.length; i < len; i++)
    {
        unichar uc = [text characterAtIndex: i];
        
        asciiLength += isascii(uc) ? 0.8 : 2;
        
        NSUInteger unicodeLength = asciiLength/2;
        
        //判断条件经过仔细考虑得出、改变时慎重
        if (unicodeLength%13 == 0 && i - lastCharIsInserted > 2)
        {
            //插入\n后，在\n被计算在字符内，但是它在ui上不显示，所以在第一个之后插入\n时，在计算位置上要加上\n的个数
            [str insertString:@"\n" atIndex:i+insertCount];
            lastCharIsInserted = i;
            insertCount++;
        }
        
        if (insertCount >= 4)
        {
            break;
        }
    }
    
    return str;
}


-(void)tapedOnSelectedRun:(CTRunRef)run
{
    NSDictionary* attributes = (__bridge NSDictionary*)CTRunGetAttributes(run);
    NSString *topicString=[attributes objectForKey:@"topicAtt"];
    
    NSString *valuStr=[attributes objectForKey:@"valueTextKey"];
    NSLog(@"valuStr %@",valuStr);
    if (topicString)
    {   
        NSLog(@"topicString %@",topicString);
        for (PoundTopicModel *poundTopicModel  in self.topicArray)
        {
            if ([poundTopicModel.content isEqualToString:topicString]) {
                if (self.tapTopicBlock) {
                    self.tapTopicBlock(poundTopicModel);
                }
                break;
            }
        }
    }

}



-(void)hideMenuController{
    [self resignFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuVisible:NO animated:YES];
}




-(void)createCurrentAttStr
{
    if (!self.normalText)
    {
        return;
    }
    
    NSMutableAttributedString * att = [[NSMutableAttributedString alloc] initWithString:self.normalText];
    UIFont *font = self.font;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    
    UIColor * color = [UIColor grayColor];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:(id)(color) forKey:NSForegroundColorAttributeName];
    [attributes setObject:(__bridge id)(fontRef) forKey:(NSString *)kCTFontAttributeName];
    
    
    NSInteger textLength = [self.normalText length];
    //添加话题
    for (PoundTopicModel * eveModel in self.topicArray)
    {
        NSString * topicStr = eveModel.content;
        NSString * eveText = self.normalText;
        NSRange range = [eveText rangeOfString:topicStr options:NSCaseInsensitiveSearch];
        while (range.length>0)
        {
            NSDictionary *attrDict1 = @{ NSUnderlineColorAttributeName: color,
                                         NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                                          };
            [attributes addEntriesFromDictionary:attrDict1];
            
            [attributes setValue:topicStr forKey:@"topicAtt"];
            [att addAttributes:attributes range:range];
            NSInteger startIndex = range.location+range.length;
            range = [eveText rangeOfString:topicStr options:NSCaseInsensitiveSearch range:NSMakeRange(startIndex,[eveText length]-startIndex)];
            
            
            //判定是否需要添加空格，以便处理最后字符串为话题情形
            if (range.location+range.length==textLength)
            {
                //当以话题结尾时，增加一个空格
                NSAttributedString * spaceAtt = [[NSAttributedString alloc] initWithString:@" "];
                [att appendAttributedString:spaceAtt];
            }
        }
    }
    
    [att addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)(fontRef)  range:NSMakeRange(0, [att length])];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle setLineSpacing:_lineSpace];//调整行间距
    [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
    
    [att addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [att length])];
    
    
    NSMutableAttributedString * noneImgStr  =[[NSMutableAttributedString alloc] initWithAttributedString:att];
    //匹配表情，
    NSMutableString *text = [NSMutableString stringWithString:self.normalText];
    NSString *regex_emoji = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    NSArray *array_emoji = nil;
//    [text componentsMatchedByRegex:regex_emoji];
    
    
    [att beginEditing];
    //替换表情图片
    NSInteger startIndex = 0;
    for (int i = 0;i<[array_emoji count];i++ )
    {
        NSString *str= [array_emoji objectAtIndex:i];
        NSRange range = [text rangeOfString:str options:NSLiteralSearch range:NSMakeRange(startIndex, [text length]-startIndex)];
        {
            if (self.faceImageForFaceTextBlock)
            {
                UIImage * image = self.faceImageForFaceTextBlock(str);
                if (image)
                {
                    LYTextAttachment * txtAttach = [[LYTextAttachment alloc ] initWithData:nil ofType:nil ] ;
                    txtAttach.image = image ;
//                    txtAttach.bounds = CGRectMake(0, 0, 30, 30);
                    NSAttributedString * imgAttriStr = [NSAttributedString attributedStringWithAttachment:txtAttach] ;
                    [att replaceCharactersInRange:range withAttributedString:imgAttriStr];
                    [text replaceCharactersInRange:range withString:@"我"];
                    [noneImgStr replaceCharactersInRange:range withAttributedString:[[NSAttributedString alloc] initWithString:@"傻"]];
                    startIndex ++;
                    continue;
                }
            }
        //    NSLog(@"startIndex %@ %ld",str,(long)startIndex);
            startIndex =([str length]+range.location);
        }
    }
    [att endEditing];

    
    [self updateNormalTextAttDicWithAttributedString:att];
    [self updateNormalTextAttDicWithAttributedString:noneImgStr];
    
    self.frameStr = noneImgStr;
    self.currentAttStr = att;
    
    
}
-(void)updateNormalTextAttDicWithAttributedString:(NSMutableAttributedString *)att
{
    
    UIFont *font = self.font;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    
    [att beginEditing];
    for (int i=0;i<[att length];i++ )
    {
        NSRange range = NSMakeRange(i, 1);
        NSAttributedString * eve  = [att attributedSubstringFromRange:range];
        NSMutableAttributedString * newEve = [[NSMutableAttributedString alloc] initWithAttributedString:eve];
        
        NSDictionary * oldDic = [eve attributesAtIndex:0 effectiveRange:nil];
        if (![oldDic valueForKey:@"NSAttachment"])
        {
            [newEve addAttribute:@"valueTextKey" value:eve.string range:NSMakeRange(0, 1)];
            [newEve addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)(fontRef) range:NSMakeRange(0, 1)];
        }
        [att replaceCharactersInRange:range withAttributedString:newEve];
        
    }
    [att endEditing];
    
}


-(NSAttributedString *)currentAttStr
{
    //创建话题文本
    if (!_currentAttStr)
    {
        //创建字符串
        [self createCurrentAttStr];
    }
    return _currentAttStr;
    return nil;
}
//设置话题数组时，需要重新生成currentAttStr
-(void)setTopicArray:(NSArray *)topicArray
{
    self.currentAttStr = nil;
    _topicArray = topicArray;
    
//    [self setAttributedText:self.currentAttStr];
}
#pragma mark - superMethods
//重新生成currentAttStr，由于不使用text展示，所以不调用父类方法
-(void)setText:(NSString *)text
{

    self.currentAttStr = nil;
    self.normalText = text;
    
    //此处创建
    [self setAttributedText:self.currentAttStr];
}
-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if(!self.frameStr){
    
        return;
    
    }
   
//    CGRect rect = self.bounds;
    CTFramesetterRef framesetter =  CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.frameStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, rect.size.width, rect.size.height));
    //创建CTFrame
    if (_frame) {
        CFRelease(_frame);
    }
   // NSLog(@"%@ %d",self.currentAttStr,self.currentAttStr.length);
    _frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, self.frameStr.length), path, NULL);
    CFRelease(framesetter);
    CFRelease(path);
}

#pragma mark -
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
