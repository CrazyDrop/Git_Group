//
//  RegisterInfoViewController.m
//  Photography
//
//  Created by jialifei on 15/3/21.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import "RegisterInfoViewController.h"
#import "RoundImageView.h"
#import "CustomPickVIew.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface RegisterInfoViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate>
{
    int y;
    RoundImageView *userIcon;
    UITextField *nickName;
    UITextField *userName;
    UITextField *userSex;
    NSString *iconFile;
    NSString *userPassWord;
}
@property (nonatomic,retain) ALAssetsLibrary *specialLibrary;
@property (nonatomic,retain) UIImage *chosenImages;
@property (nonatomic ,retain) CustomPickVIew *pickview;
@end

@implementation RegisterInfoViewController


- (id)init{
    self = [super init];
    if (self) {
        self.viewTtle =@"注册";
        self.showRightBtn = YES;
        self.showLeftBtn = YES;
        self.rightTitle = @"完成";
        self.rightAction = @selector(submit);
    }
    return self;
}

-(void)submit
{
    if(!userIcon.image){
        [DZUtils noticeCustomerWithShowText:@"请选择照片"];
        return;
    }
    
    if(!nickName.text){
        
        [DZUtils noticeCustomerWithShowText:@"请填写昵称"];
        return;
    }
    if(!userName.text){
        [DZUtils noticeCustomerWithShowText:@"请填写姓名"];
        return;
    }
    
    //http://115.159.68.180:8080/sdbt/user_doregister
    NSString *req  = [NSString stringWithFormat:@"%@sdbt/user_doregister",URL_HEAD];
   
    NSData * data = UIImageJPEGRepresentation(userIcon.image, 1.0);
    
    if(!data){
        data = UIImagePNGRepresentation(userIcon.image);
    }

    NSMutableArray *img = [[NSMutableArray alloc] init];
    [img addObject:data];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue: _phoneNumber forKey:@"phone"];
    [dic setValue: [DZUtils encodedString:userName.text] forKey:@"true_name"];
    [dic setValue: [DZUtils encodedString:nickName.text] forKey:@"nickname"];
    [dic setValue:_userPassword forKey:@"password"];
    NSString * sex = [userSex.text isEqualToString:@"男"] ? @"0" : @"1";
    [dic setValue:sex forKey:@"user_getnter"];
    [dic setObject:@"head.png" forKey:@"fileName"];
    
    self.myClient.delegate =self;
    self.myClient.myNav = self.navigationController;
    [self.myClient postSingleImg:req params:dic file:img finish:@selector(refSucess:) fail:@selector(refFail:) andCancel:nil];
}

 -(void)refSucess:(NSDictionary *)info{
     
     NSDictionary *dic = info[@"data"];
     [DZUtils userLogout];
     [DZUtils saveUserInfnfo:dic];
     [DZUtils getUserInfo];
//     MianTabBarViewController *vc = [[MianTabBarViewController alloc] init];
//     [self.navigationController pushViewController:vc animated:YES];
 }
     
 -(void)refFail:(NSDictionary *)info
 {
     [DZUtils noticeCustomerWithShowText:info[@"info"]];
 }

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = VIEW_GAYCOLOR;
    
    [self.rightBtn setTitleColor:REDCOLOR forState:UIControlStateNormal];
    self.rightBtn.layer.borderWidth = 1.0;
    self.rightBtn.layer.borderColor = [REDCOLOR CGColor];

    [self creatCellImgViewWithFrame:CGRectMake(0, NAVBAR_HEIGHT+10, SCREEN_WIDTH, 72) title:@"头像" action:@selector(launchSpecialController)];
    nickName = [self creatCellViewWithFrame:CGRectMake(0, 82+NAVBAR_HEIGHT, SCREEN_WIDTH, YFLoatChange(44)) title:@"昵称"];
    userSex = [self creatSexCellViewWithFrame:CGRectMake(0, 82 +NAVBAR_HEIGHT+YFLoatChange(44), SCREEN_WIDTH, YFLoatChange(44)) title:@"性别"];
    userName = [self creatCellViewWithFrame:CGRectMake(0, 82 +NAVBAR_HEIGHT+YFLoatChange(44)*2, SCREEN_WIDTH, YFLoatChange(44)) title:@"真实姓名"];
}


-(void)creatCellImgViewWithFrame:(CGRect)frame title:(NSString *)t action:(SEL)act
{
    UIView *cell = [[UIView alloc] initWithFrame:frame];
    [self.view addSubview:cell];
    cell.backgroundColor = [UIColor whiteColor];
    
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(10, cell.bounds.size.height-1 ,cell.bounds.size.width-20, 1)];
    [cell addSubview:view];
    view.backgroundColor = LINE_GAYCOLOR;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    [cell addSubview:title];
//    title.backgroundColor =  [UIColor greenColor];
    [title setTranslatesAutoresizingMaskIntoConstraints:NO];//将使用AutoLayout的方式来布局
    [title sizeToFit];
    title.font = [UIFont systemFontOfSize:FLoatChange(16.0)];
    title.text = t;
    
    NSLayoutConstraint *constraint = [
                                      NSLayoutConstraint
                                      constraintWithItem:title
                                      attribute:NSLayoutAttributeLeft
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:cell
                                      attribute:NSLayoutAttributeLeft
                                      multiplier:1.0f
                                      constant:10.0f
                                      ];
    
    [self.view addConstraint:constraint];//将约束添加到对应的父视图中
    constraint = [
                  NSLayoutConstraint
                  constraintWithItem:title
                  attribute:NSLayoutAttributeCenterY
                  relatedBy:NSLayoutRelationEqual
                  toItem:cell
                  attribute:NSLayoutAttributeCenterY
                  multiplier:1.0f
                  constant:00.0f
                  ];
    
    [self.view addConstraint:constraint];//将约束添加到对应的父视图中
    
    UIImageView *arrow= [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH -20, 30, 8, 12.5)];
    [cell addSubview:arrow];
    arrow.image = [UIImage imageNamed:@"tag"];
    
    userIcon= [[RoundImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH -70, 15, 45, 45)];
    [cell addSubview:userIcon];
    userIcon.image = [UIImage imageNamed:@"default_head"];

    UIButton *action  = [UIButton buttonWithType:UIButtonTypeCustom];
    action.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    [cell addSubview:action];
    [action addTarget:self action:act forControlEvents:UIControlEventTouchUpInside];
//    [action addTarget:self action:@selector(launchSpecialController) forControlEvents:UIControlEventTouchUpInside];
}

-(UITextField *)creatCellViewWithFrame:(CGRect)frame title:(NSString *)t
{
    UIView *cell = [[UIView alloc] initWithFrame:frame];
    [self.view addSubview:cell];
    cell.backgroundColor = [UIColor whiteColor];
    
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(10, YFLoatChange(43) , cell.bounds.size.width-20, 1)];
    [cell addSubview:view];
    view.backgroundColor = LINE_GAYCOLOR;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    [cell addSubview:title];
    title.backgroundColor =  [UIColor whiteColor];
    [title setTranslatesAutoresizingMaskIntoConstraints:NO];//将使用AutoLayout的方式来布局
    [title sizeToFit];
    title.font = [UIFont systemFontOfSize:FLoatChange(16.0)];
    title.text = t;
    
    NSLayoutConstraint *constraint = [
                                      NSLayoutConstraint
                                      constraintWithItem:title
                                      attribute:NSLayoutAttributeLeft
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:cell
                                      attribute:NSLayoutAttributeLeft
                                      multiplier:1.0f
                                      constant:10.0f
                                      ];
    
    [self.view addConstraint:constraint];//将约束添加到对应的父视图中
    constraint = [
                                      NSLayoutConstraint
                                      constraintWithItem:title
                                      attribute:NSLayoutAttributeCenterY
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:cell
                                      attribute:NSLayoutAttributeCenterY
                                      multiplier:1.0f
                                      constant:00.0f
                                      ];
    
    [self.view addConstraint:constraint];//将约束添加到对应的父视图中
    
    UITextField *content = [[UITextField alloc] initWithFrame:CGRectMake(90, 1, SCREEN_WIDTH -100, 44-2)];
    [cell addSubview:content];
    content.textAlignment = NSTextAlignmentRight;
    //content.backgroundColor = [UIColor redColor];
    
    return content;
}

-(UITextField *)creatSexCellViewWithFrame:(CGRect)frame title:(NSString *)t
{
    UIView *cell = [[UIView alloc] initWithFrame:frame];
    [self.view addSubview:cell];
    cell.backgroundColor = [UIColor whiteColor];
    
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(10, YFLoatChange(43) , cell.bounds.size.width-20, 1)];
    [cell addSubview:view];
    view.backgroundColor = LINE_GAYCOLOR;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    [cell addSubview:title];
    title.backgroundColor =  [UIColor whiteColor];
    [title setTranslatesAutoresizingMaskIntoConstraints:NO];//将使用AutoLayout的方式来布局
    [title sizeToFit];
    title.text = t;
    title.font = [UIFont systemFontOfSize:FLoatChange(16.0)];
    
    NSLayoutConstraint *constraint = [
                                      NSLayoutConstraint
                                      constraintWithItem:title
                                      attribute:NSLayoutAttributeLeft
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:cell
                                      attribute:NSLayoutAttributeLeft
                                      multiplier:1.0f
                                      constant:10.0f
                                      ];
    
    [self.view addConstraint:constraint];//将约束添加到对应的父视图中
    constraint = [
                  NSLayoutConstraint
                  constraintWithItem:title
                  attribute:NSLayoutAttributeCenterY
                  relatedBy:NSLayoutRelationEqual
                  toItem:cell
                  attribute:NSLayoutAttributeCenterY
                  multiplier:1.0f
                  constant:00.0f
                  ];
    
    [self.view addConstraint:constraint];//将约束添加到对应的父视图中
    
    UITextField *content = [[UITextField alloc] initWithFrame:CGRectMake(90, 1, SCREEN_WIDTH -100, 44-2)];
    [cell addSubview:content];
    content.textAlignment = NSTextAlignmentRight;
    //content.backgroundColor = [UIColor redColor];
    
    UIButton *action  = [UIButton buttonWithType:UIButtonTypeCustom];
    action.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    [cell addSubview:action];
    [action addTarget:self action:@selector(selectecSex) forControlEvents:UIControlEventTouchUpInside];

    return content;
}

-(void)returnResult:(NSString *)result withType:(NSString *)type
{
    NSLog(@"---++++++%@",result);
    userSex.text = result;
}

-(void)selectecSex
{
    [userName resignFirstResponder];
    [nickName resignFirstResponder];
    _pickview = [[CustomPickVIew alloc] initWithFrame:self.view.bounds type:@"sex"];
    _pickview.delegate =self;
    
    [self.view addSubview:_pickview];
}

- (void)launchSpecialController
{
    UIActionSheet *showSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相机",@"相册",nil];
    [showSheet showInView:self.view];
}

- (void) actionSheet: (UIActionSheet *) actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        
        if (buttonIndex == 0) {
            [self takePhoto];
        }else{
            [self LocalPhoto];
        }
    }
}

-(void)LocalPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;  //类型
    picker.delegate =self;  //协议
    picker.allowsEditing =YES;
    [self presentViewController:picker animated:YES completion:nil];
}
#pragma mark - 从相机获取
-(void)takePhoto
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate =self;
        picker.allowsEditing =YES;
        picker.sourceType =UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:@"无法拍照" message:@"此设备拍照功能不可用" delegate:self cancelButtonTitle:@"确定"otherButtonTitles:nil];
        [alerView show];
    }
}
/*当选择一张图片后进入*/
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];  //得到类型
    
    NSLog(@"%@ === %@",type,info);
    
    if ([type  isEqualToString:@"public.image"])
    {
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];  //得到相机图片
        if (!image)
        {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        self.chosenImages = image;
        userIcon.image = [DZUtils imageWithImageSimple:_chosenImages scaledToSize:CGSizeMake(120, 120)];
        [DZUtils saveImage:userIcon.image WithName:@"head.png"];
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSString *)documentFolderPath
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
