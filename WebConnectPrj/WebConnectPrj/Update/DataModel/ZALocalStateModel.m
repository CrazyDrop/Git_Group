//
//  ZALocalStateModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/9.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZALocalStateModel.h"
#import "AutoCoding.h"
#import "Constant.h"
#import <objc/runtime.h>
@implementation ZALocalStateModel
//@synthesize warningId = _warningId;
//@synthesize password = _password;

-(id)init
{
    self = [super init];
    if(self)
    {
        safeLock = [[NSLock alloc] init];
    }
    return self;
}

static ZALocalStateModel *shareZALocalStateModelInstance = nil;
+(instancetype)currentLocalStateModel
{
    //不使用单例，原因，APP数据改变无法实时在watch上表现
    return [[self class] createInstanceModel];
    
//    static dispatch_once_t token;
//    dispatch_once(&token, ^{
//        shareZALocalStateModelInstance = [[self class] createInstanceModel];
//    });
//    
//    return shareZALocalStateModelInstance;
}

//本地统一存储的数据
+(instancetype)createInstanceModel
{
//    NSUserDefaults * stand = [[NSUserDefaults alloc] initWithSuiteName:USERDEFAULT_SUIT_NAME_PAPA];
    NSUserDefaults * stand = [NSUserDefaults standardUserDefaults];
    NSData * data  = [stand objectForKey:Local_File_ZALocalStateModel_Model];
    
    ZALocalStateModel * model = [ZALocalStateModel objectWithContentsOfData:data];
    if(!model)
    {
        model = [[ZALocalStateModel alloc] init];
        model.stateIdentifier = @"stateIdentifier";
    }
    return model;
}

//数据存储到本地文件，考虑
-(void)localSave
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
//    NSUserDefaults * stand = [[NSUserDefaults alloc] initWithSuiteName:USERDEFAULT_SUIT_NAME_PAPA];
    NSUserDefaults * stand = [NSUserDefaults standardUserDefaults];
    [stand setObject:data forKey:Local_File_ZALocalStateModel_Model];
    [stand synchronize];
}

-(void)refreshLocalSaveStateDataWithCurrentData
{
    [safeLock lock];
    ZALocalStateModel * model = [[self class] createInstanceModel];
    //使用
    id copyObject = self;
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([model class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *key = [NSString stringWithFormat:@"%s",property_getName(property)];
        id value = [model valueForKey:key];
        [copyObject setValue:value forKey:key];
    }
    free (properties);
    
    
    [safeLock unlock];
}

@end
