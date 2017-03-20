//
//  ZADoMenuController.m
//  ZAIOSMainPrj
//
//  Created by 赵宪云 on 16/1/4.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZADoMenuController.h"
#import "TPKeyboardAvoidingScrollView.h"
#define DoMenu_Add_Tag  100
@interface ZADoMenuController ()
{
    UIButton * bottomBtn;
    UITextField * editTfd;
}
@property (nonatomic,strong) NSArray * tagArray;
@property (nonatomic,strong) NSArray * imgNameArr;
@property (nonatomic,strong) UIView * containView;
@end

@implementation ZADoMenuController

+(NSArray *)ZATagMenuArray
{
    return [NSArray arrayWithObjects:@"回家",@"夜跑",@"搭夜车",nil];
}

-(void)loadView
{
    NSMutableArray * array = [NSMutableArray arrayWithArray:[[self class] ZATagMenuArray]];
    [array addObject:@"自定义"];
    
    self.tagArray = array;
    self.imgNameArr = [NSArray arrayWithObjects:@"menu_icon_home",@"menu_icon_run",@"menu_icon_car",@"menu_icon_edit",nil];
//    _selected

    CGRect rect = [[UIScreen mainScreen] bounds];
    TPKeyboardAvoidingScrollView * view = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:rect];
    view.scrollsToTop = NO;
    view.backgroundColor = [UIColor clearColor];
    self.view = view;
    [view addSubview:self.containView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(tapedOnBgView)];
    [view addGestureRecognizer:tap];
    
}
-(void)tapedOnBgView
{
    [editTfd resignFirstResponder];
    if(self.DoneDoMenuBlock)
    {
        self.DoneDoMenuBlock(nil);
    }
}

-(UIView *)containView
{
    if(!_containView)
    {
        CGRect rect = CGRectMake(0, 0, FLoatChange(265), FLoatChange(140));
//        rect = CGRectMake(0, 0, FLoatChange(265), FLoatChange(245));
        UIView * centerView = [[UIView alloc] initWithFrame:rect];
        centerView.layer.cornerRadius = 5;
        centerView.layer.masksToBounds = YES;
        centerView.autoresizesSubviews = NO;
        centerView.backgroundColor = [DZUtils colorWithHex:@"E1EDF3"];
        centerView.center = CGPointMake(SCREEN_WIDTH/2.f, SCREEN_HEIGHT/2.f);
        self.containView = centerView;
        
        [self createSubViews];
    }
    return _containView;
}

-(void)createSubViews
{
    UIView * bgView = self.containView;
    CGRect rect = CGRectMake(0, 0, bgView.bounds.size.width, FLoatChange(40));
    UILabel *titleLbl = [[UILabel alloc]initWithFrame:rect];
    titleLbl.text = @"您要做什么？";
    titleLbl.textColor = [DZUtils colorWithHex:@"002952"];
    titleLbl.font = [UIFont systemFontOfSize:FLoatChange(17)];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    titleLbl.backgroundColor = [DZUtils colorWithHex:@"C1D2D9"];
    [bgView addSubview:titleLbl];
    
    NSArray *iconArray = self.imgNameArr;
    NSArray *nameArr = self.tagArray;
    CGFloat totalWidth = bgView.bounds.size.width;
    CGFloat btnW = FLoatChange(55);
    CGFloat btnH = btnW;
    CGFloat lblH = FLoatChange(10);
    CGFloat startX = FLoatChange(15);
    CGFloat startY = startX + CGRectGetMaxY(titleLbl.frame);
    CGFloat space = (totalWidth - startX * 2 - btnW*[nameArr count])/2.0;
    
    for (NSInteger i = 0;i<[nameArr count];i++)
    {
        NSString *name  = [nameArr objectAtIndex:i];
        NSString *icon  = [iconArray objectAtIndex:i];
        NSString * selected = [icon stringByAppendingString:@"_selected"];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:selected] forState:UIControlStateHighlighted];
        [btn setImage:[UIImage imageNamed:selected] forState:UIControlStateSelected];
        CGFloat x = startX + i * (space + btnW);
        [btn setFrame:CGRectMake(x, startY, btnW, btnH)];
        [bgView addSubview:btn];
        btn.tag = DoMenu_Add_Tag + i;
        [btn addTarget:self action:@selector(tapedOnTopCoverBtn:) forControlEvents:UIControlEventTouchUpInside];

        
        UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btnW, lblH)];
        lbl.font = [UIFont systemFontOfSize:FLoatChange(10)];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.text = name;
        [btn addSubview:lbl];
        [lbl sizeToFit];
        lbl.center = CGPointMake(btnW/2.0, btnH + FLoatChange(8));
    }
    
    CGFloat tfdHeight = FLoatChange(47);
    CGFloat tfdWidth = 0.9 * totalWidth;
    UITextField * tfd = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, tfdWidth, tfdHeight)];
    [bgView addSubview:tfd];
    tfd.backgroundColor = [UIColor whiteColor];
    tfd.placeholder = @"去约会，走夜路等等......";
    tfd.center = CGPointMake(totalWidth/2.0, FLoatChange(95) + tfdHeight/2.0 +  CGRectGetMaxY(titleLbl.frame));
    tfd.hidden = YES;
    editTfd = tfd;
    
    CGFloat btnHeight = FLoatChange(44);
    CGFloat maxHeight = FLoatChange(60) + CGRectGetMaxY(tfd.frame);
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, totalWidth, btnHeight);
    [bgView addSubview:btn];
    [btn addTarget:self action:@selector(tapedOnBottomBtn:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"提交" forState:UIControlStateNormal];
    [btn setTitleColor:Custom_Blue_Button_BGColor forState:UIControlStateNormal];
    btn.center = CGPointMake(totalWidth/2.0, maxHeight - btnHeight/2.0);
    btn.hidden = YES;
    bottomBtn = btn;
    
    UIView * line = [DZUtils ToolCustomLineView];
    line.backgroundColor = [DZUtils colorWithHex:@"C1D2D9"];
    rect = line.bounds;
    rect.size.width = totalWidth;
    rect.origin.y = (-1.0 * rect.size.height);
    line.frame = rect;
    [btn addSubview:line];
}

-(void)refreshContainViewWithCurrentString:(NSString *)str
{
    if(!str) return;
    
    NSMutableArray * names = [NSMutableArray arrayWithArray:self.tagArray];
    NSInteger index = [names count] - 1;
    [names removeLastObject];

    BOOL  editEnable = ![names containsObject:str];
    
    CGRect rect = CGRectMake(0, 0, FLoatChange(265), FLoatChange(140));;
    if(editEnable)
    {
        rect = CGRectMake(0, 0, FLoatChange(265), FLoatChange(245));;
    }else{
        index = [names indexOfObject:str];
    }
    
    self.containView.frame = rect;
    self.containView.center = CGPointMake(SCREEN_WIDTH/2.f, SCREEN_HEIGHT/2.f);
    
    editTfd.hidden = !editEnable;
    bottomBtn.hidden = !editEnable;
    
    if(editEnable)
    {
        editTfd.text = str;
        [editTfd becomeFirstResponder];
    }else
    {
        [editTfd resignFirstResponder];
    }
    
    
    //进行按钮状态刷新
    for(NSInteger i = 0;i<[self.tagArray count];i++)
    {
        NSInteger tag = DoMenu_Add_Tag + i;
        UIButton *btn = (UIButton *) [self.containView viewWithTag:tag];
        btn.selected = index == i;
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString * str = self.currentStr;
    [self refreshContainViewWithCurrentString:str];
}

-(void)tapedOnTopCoverBtn:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    NSInteger index = btn.tag - DoMenu_Add_Tag;
    
    NSArray * arr = self.tagArray;
    if(index == [arr count]-1)
    {
        [self refreshContainViewWithCurrentString:@""];
        return;
    }
    
    NSString * tagValue = nil;
    if([arr count]>index)
    {
        tagValue = [arr objectAtIndex:index];
    }
    
    [self refreshContainViewWithCurrentString:tagValue];
    
    if(self.DoneDoMenuBlock)
    {
        self.DoneDoMenuBlock(tagValue);
    }
}

-(void)tapedOnBottomBtn:(id)sender
{
    NSString * str = editTfd.text;
    
    NSString * errorStr = [ZATfdLocalCheck localCheckInputWhatToDoWithText:str];
    if(errorStr)
    {
        [DZUtils noticeCustomerWithShowText:errorStr];
        return;
    }
    
    
    [editTfd resignFirstResponder];
    if(self.DoneDoMenuBlock)
    {
        self.DoneDoMenuBlock(str);
    }
}
//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    [editTfd resignFirstResponder];
//    if(self.DoneDoMenuBlock)
//    {
//        self.DoneDoMenuBlock(nil);
//    }
//}


@end
