//
//  ZAConfigModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/21.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZAConfigModel.h"
#import "AutoCoding.h"

#define Local_File_ZAConfigModel_Model         @"Model.ZAConfigModel"

@implementation ZAConfigModel

+(instancetype)sharedInstanceManager
{
    static ZAConfigModel *_sharedZAConfigModelManagerClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedZAConfigModelManagerClient = [[self class] createInstanceModel];
    });
    return _sharedZAConfigModelManagerClient;
}
//本地统一存储的数据
+(instancetype)createInstanceModel
{
    NSUserDefaults * stand = [[NSUserDefaults alloc] initWithSuiteName:USERDEFAULT_SUIT_NAME_PAPA];
    stand = [NSUserDefaults standardUserDefaults];
    NSData * data  = [stand objectForKey:Local_File_ZAConfigModel_Model];
    
    ZAConfigModel * model = [ZAConfigModel objectWithContentsOfData:data];
    if(!model)
    {
        model = [[ZAConfigModel alloc] init];
        model.quick_recorder_length = @"30";
        model.timing_recorder_length = @"60";
        model.quick_waiting_length = @"30";
        model.timing_waiting_length = @"60";
        
        [model localSave];
    }
    return model;
}

//数据存储到本地文件，考虑
-(void)localSave
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSUserDefaults * stand = [[NSUserDefaults alloc] initWithSuiteName:USERDEFAULT_SUIT_NAME_PAPA];
    stand = [NSUserDefaults standardUserDefaults];
    [stand setObject:data forKey:Local_File_ZAConfigModel_Model];
    [stand synchronize];
}

-(void)refreshConfigDataWithList:(NSDictionary *)dic
{
    if(!dic) return;
    if(![[dic allKeys] containsObject:@"quick_recorder_length"]) return;
    
    self.quick_recorder_length = [dic valueForKey:@"quick_recorder_length"];
    self.timing_recorder_length = [dic valueForKey:@"timing_recorder_length"];
    self.quick_waiting_length = [dic valueForKey:@"quick_waiting_length"];
    self.timing_waiting_length = [dic valueForKey:@"timing_waiting_length"];
    
    [self localSave];
    
}






@end
