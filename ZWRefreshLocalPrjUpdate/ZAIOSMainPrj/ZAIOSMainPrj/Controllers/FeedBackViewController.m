//
//  FeedBackViewController.m
//  Photography
//
//  Created by jialifei on 15/4/10.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import "FeedBackViewController.h"
#import "MKNetworkKit.h"
#import "UMFeedback.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "PGTextView.h"
#import "ZALocalStateTotalModel.h"
#define FeedBackTotalLength 140
@interface FeedBackViewController ()<UMFeedbackDataDelegate,UITextViewDelegate,UITextFieldDelegate>
{
    UITextField * _connectTfd;
    UIScrollView * bgScroll;
    BOOL isLoading;
    BOOL refreshed;
}
@property (strong, nonatomic) PGTextView *feedBack;
@end

@implementation FeedBackViewController


- (id)init{
    self = [super init];
    if (self) {
        self.viewTtle = ZAViewLocalizedStringForKey(@"ZAViewLocal_FeedBack_Title");
        self.viewTtle = @"意见反馈";
        self.showLeftBtn = YES;
        self.showRightBtn = NO;
        isLoading = NO;
//        self.rightTitle = @"提交";
    }
    return self;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}
-(void)submit
{
    //检查
    NSString * txt = _feedBack.text;
    txt = [txt stringByReplacingOccurrencesOfString:@" " withString:@""];
    txt = [txt stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if ([txt length] ==0 )
    {
        [DZUtils noticeCustomerWithShowText:@"反馈内容不能为空"];
        [_feedBack becomeFirstResponder];
        return;
    }
    if ([_feedBack.text length]>FeedBackTotalLength)
    {
        [DZUtils noticeCustomerWithShowText:[NSString stringWithFormat:@"反馈内容不能超过%d字",FeedBackTotalLength]];
        [_feedBack becomeFirstResponder];
        return;
    }
    
    //建议去掉此处判定，用户原本就很少提意见
    NSInteger tfdLength = 30;
    if (_connectTfd.text.length > tfdLength)
    {
        [DZUtils noticeCustomerWithShowText:[NSString stringWithFormat:@"联系方式不能超过%ld字",(long)tfdLength]];
        [_connectTfd becomeFirstResponder];
        return;
    }
    
    
    
    //http://115.159.68.180:8080/sdbt/leaveMessage
    NSString *url = [NSString stringWithFormat:@"%@sdbt/leaveMessage",URL_HEAD];
    [self loadData:url];
}
-(PGTextView *)feedBack
{
    if(!_feedBack){
        PGTextView * txt = [[PGTextView alloc] init];
        txt.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewValueChange:) name:UITextViewTextDidChangeNotification object:nil];
        
        self.feedBack = txt;
    }
    return _feedBack;
}
-(void)textViewValueChange:(id)sender
{
    //当数值超过限定值，直接剪切
    
    if ([_feedBack.text length]>FeedBackTotalLength)
    {
        _feedBack.text = [_feedBack.text substringToIndex:FeedBackTotalLength];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text length]==0)
    {
        return YES;
    }
    if([textView.text length]>=FeedBackTotalLength){
        return NO;
    }
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * nameStr = [[UITextInputMode currentInputMode] primaryLanguage];
    if ([nameStr isEqualToString:@"emoji"])
    {
        return NO;
    }
    
    //    //emoji无效
    //    if([NSString stringContainsEmoji:string])
    //    {
    //        return NO;
    //    }
    
//    string = [string inputStringExcept9Input];
    string = [string stringByReplacingOccurrencesOfString:@"@" withString:@""];
    if([string stringContainSpecialCharacters])
    {
        return NO;
    }
    
    return YES;

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UMFeedback sharedInstance] setDelegate:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UMFeedback sharedInstance] setDelegate:self];


    self.view.backgroundColor = Custom_View_Gray_BGColor;
    
    CGFloat whiteBGHeight = FLoatChange(300);
    CGFloat smallHeight = FLoatChange(47);
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    UIScrollView * scroll = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:rect];
    [self.view addSubview:scroll];
    bgScroll = scroll;
    [self.view sendSubviewToBack:scroll];
    
    CGFloat naBarHeight = CGRectGetMaxY(self.titleBar.frame);
    rect.size.height = whiteBGHeight + naBarHeight;
    

    UIView * bgView = [[UIView alloc] initWithFrame:rect];
    bgView.backgroundColor = [UIColor whiteColor];
    [scroll addSubview:bgView];
    
    CGFloat startX = FLoatChange(10);
    CGFloat startY = naBarHeight;
    rect.size.height = smallHeight;
    rect.origin.y = naBarHeight;
    UITextField * titLbl = [[UITextField alloc] initWithFrame:rect];
    [bgView addSubview:titLbl];
    titLbl.text = @"意见反馈:";
    titLbl.font = [UIFont systemFontOfSize:FLoatChange(16)];
    titLbl.center = CGPointMake(startX + titLbl.bounds.size.width/2.0, startY + smallHeight/2.0);
    titLbl.userInteractionEnabled = NO;
    
    UIView * line = [DZUtils ToolCustomLineView];
    [bgView addSubview:line];
    rect = line.frame;
    rect.origin.y = startY + smallHeight;
    line.frame = rect;
    
    
    startY += smallHeight;
    CGFloat sepY = FLoatChange(5);
    startY += sepY;
    
    PGTextView * txt = self.feedBack;
    txt.backgroundColor = [UIColor clearColor];
    [bgView addSubview:txt];
//    txt.translatesAutoresizingMaskIntoConstraints = YES;
    CGFloat length = SCREEN_WIDTH - startX * 2;
    txt.frame = CGRectMake(startX,startY,length, whiteBGHeight - smallHeight*2 - sepY * 2);
    txt.placeHolder = ZAViewLocalizedStringForKey(@"ZAViewLocal_FeedBack_Notice_Title");
    txt.font = [UIFont systemFontOfSize:FLoatChange(16.0)];
    
    
    
    startY = whiteBGHeight + naBarHeight - smallHeight;
    line = [DZUtils ToolCustomLineView];
    [bgView addSubview:line];
    rect = line.frame;
    rect.origin.y = startY ;
    line.frame = rect;
    
    
    titLbl = [[UITextField alloc] initWithFrame:rect];
    [bgView addSubview:titLbl];
    titLbl.text = @"联系方式:";
    titLbl.font = [UIFont systemFontOfSize:FLoatChange(16)];
    [titLbl sizeToFit];
    titLbl.center = CGPointMake(startX + titLbl.bounds.size.width/2.0, startY + smallHeight/2.0);
    titLbl.userInteractionEnabled = NO;
    
    line = [DZUtils ToolCustomLineView];
    [bgView addSubview:line];
    rect = line.frame;
    rect.origin.y = startY + smallHeight ;
    line.frame = rect;
    

    rect.size.width = SCREEN_WIDTH - startX * 2 - titLbl.bounds.size.width;
    rect.size.height = smallHeight;
    UITextField * field = [[UITextField alloc] initWithFrame:rect];
    field.placeholder = @"QQ/邮箱/电话";
    [bgView addSubview:field];
    field.font = [UIFont systemFontOfSize:FLoatChange(16)];
    field.center = CGPointMake(rect.size.width/2.0 + (startX + titLbl.bounds.size.width) , startY + smallHeight/2.0);
    _connectTfd = field;
    field.delegate = self;

    
    rect.size.width = FLoatChange(275);
    rect.size.height = FLoatChange(43);
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = rect;
    btn.backgroundColor = Custom_Blue_Button_BGColor;
    [btn refreshButtonSelectedBGColor];

    [[btn layer]setCornerRadius:5.0];//圆角
    
    [btn setTitle:@"提交" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    
    [scroll addSubview:btn];
    btn.center = CGPointMake(SCREEN_WIDTH/2.0, bgView.bounds.size.height + FLoatChange(60) + rect.size.height/2.0);
    
    // Do any additional setup after loading the view from its nib.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self firstTfdBecomeResponsder];
}
-(void)firstTfdBecomeResponsder
{
    if(refreshed) return;
    [self.feedBack becomeFirstResponder];
    refreshed = YES;
}

- (UIButton *)createButton:(CGRect)frame text:(NSString *)text color:(UIColor *)cl action:(SEL)action{
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    btn.backgroundColor = cl;
    [[btn layer]setCornerRadius:5.0];//圆角
    
    [btn setTitle:text forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

-(UITextField *)logViewWithFrame:(CGRect)frame  image:(UIImage *)img text:(NSString *)text
{
    UIImageView *userName = [[UIImageView alloc] initWithFrame:frame];
    userName.userInteractionEnabled = YES;
    userName.alpha = 1;
    userName.backgroundColor = [UIColor whiteColor];//[DZUtils colorWithHex:@"ffffff"];
    [bgScroll addSubview:userName];
    
//    UIImageView  *head = [[UIImageView alloc] initWithFrame:CGRectMake(10, (frame.size.height-30)/2, 30,30)];
//    head.image = img;
//    [userName addSubview:head];
    
    UITextField  *name = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
    [userName addSubview:name];
    name.alpha = 0.7;
    name.placeholder=text;//默认显示的
    name.backgroundColor = [UIColor whiteColor] ;
    
    return name;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)loadData:(NSString *)url
{
    if(isLoading) return;
    [self showLoading];
    //将两个请求，拆分成两部分
    isLoading = YES;

//    NSMutableDictionary * userDic = [NSMutableDictionary dictionary];
    NSString * txt = _connectTfd.text;

//    Account * account = [[AccountManager sharedInstance] account];
//    NSString * uid = account.userId?:@"";
//    NSString * uName = account.name?:@"";
//    
//    [userDic setValue:uid forKey:@"userId"];
//    [userDic setValue:uName forKey:@"userName"];

    

    NSMutableDictionary *postContent = [NSMutableDictionary dictionary];
    NSMutableDictionary * userDic = [NSMutableDictionary dictionary];
    NSString * message = _feedBack.text;

    
    //version 以及 设备型号  都有收集
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    
    [userDic setValue:total.userInfo.mobile forKey:@"login"];
    if(txt && [txt length]>0)   [userDic setValue:txt forKey:@"others"];
    [[UMFeedback sharedInstance] setRemarkInfo:@{@"contact": userDic}];
    

    [postContent setValue:message forKey:@"content"];
    [postContent setValue:@"user_reply" forKey:@"type"];
    [postContent setValue:[[UIDevice currentDevice] systemVersion] forKey:@"deviceVersion"];

    [[UMFeedback sharedInstance] post:postContent];
    
    

    
   
}

- (void)postFinishedWithError:(NSError *)error
{
    [self hideLoading];
    
    if(!isLoading) return;
    isLoading = NO;
    
    if(error)
    {
        NSString * message = kAppNone_Service_Error;
        NSDictionary * dic = error.userInfo;
        NSString * str = [dic valueForKeyPath:@"data.error_msg"];
        if(str && [str length]>0)
        {
            message = str;
        }
        [DZUtils noticeCustomerWithShowText:message];
    }else{
        
        [DZUtils noticeCustomerWithShowText:@"反馈已经成功提交"];
        [self.navigationController popViewControllerAnimated:YES];
    }

}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
