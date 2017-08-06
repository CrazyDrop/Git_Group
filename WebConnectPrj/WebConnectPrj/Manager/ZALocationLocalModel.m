//
//  ZALocationLocalModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/29.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZALocationLocalModel.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMDatabaseAdditions.h"
#import "AutoCoding.h"
#import "NSObject+AutoCoding.h"
#import "ZWDataDetailModel.h"
#import "ZWSysSellModel.h"
#import "Equip_listModel.h"
#import "JSONKit.h"
#import "MJExtension.h"
#import "CBGListModel.h"
#import "ZWServerEquipModel.h"
#define ZADATABASE_NAME @"zadatabase_update_total.db" //缓存的数据库名称
#define ZADATABASE_NAME_READ @"zadatabase_update_read.db" //缓存的数据库名称

#define ZADATABASE_TABLE_LOCATIONS @"ZADATABASE_TABLE_LOCATIONS" //缓存的数据库名称
#define ZADATABASE_TABLE_LOCATIONS_SOLDOUT @"ZADATABASE_TABLE_LOCATIONS_SOLDOUT" //已售出数据库

#define ZADATABASE_TABLE_LOCATIONS_HISTORY @"ZADATABASE_TABLE_LOCATIONS_HISTORY" //缓存的数据库名称
#define ZADATABASE_TABLE_LOCATIONS_SYSTEM_SELL @"ZADATABASE_TABLE_LOCATIONS_SYSTEM_SELL" //系统销售数据


#define ZADATABASE_TABLE_LOCATIONS_KEY_TIME @"ZADATABASE_TABLE_LOCATIONS_KEY_TIME"  //时间
#define ZADATABASE_TABLE_LOCATIONS_KEY_DIC  @"ZADATABASE_TABLE_LOCATIONS_KEY_DIC"   //字典数据
#define ZADATABASE_TABLE_LOCATIONS_KEY_DETAIL @"ZADATABASE_TABLE_LOCATIONS_KEY_DETAIL"  //详情数据
#define ZADATABASE_TABLE_LOCATIONS_KEY_START @"ZADATABASE_TABLE_LOCATIONS_KEY_START"    //创建时间
#define ZADATABASE_TABLE_LOCATIONS_KEY_FAV @"ZADATABASE_TABLE_LOCATIONS_KEY_FAV"        //是否加关注


#define ZADATABASE_TABLE_EQUIP_TOTAL @"ZADATABASE_TABLE_EQUIP_TOTAL" //主表
#define ZADATABASE_TABLE_EQUIP_ORDER @"ZADATABASE_TABLE_EQUIP_ORDER"    //下单表
#define ZADATABASE_TABLE_EQUIP_CHANGE @"ZADATABASE_TABLE_EQUIP_CHANGE"  //变动表
#define ZADATABASE_TABLE_EQUIP_SERVER @"ZADATABASE_TABLE_EQUIP_SERVER"  //服务名称表

#define ZADATABASE_TABLE_SERVER_KEY_TIME    @"SERVER_TIME"  //服务器时间
#define ZADATABASE_TABLE_SERVER_KEY_NAME    @"SERVER_NAME"  //服务名称
#define ZADATABASE_TABLE_SERVER_KEY_ID      @"SERVER_ID"     //服务器id
#define ZADATABASE_TABLE_SERVER_KEY_TEST    @"SERVER_TEST"   //测试标识

#define ZADATABASE_TABLE_EQUIP_KEY_ORDER_SN_SELL_TIME     @"ORDER_SN_SELL_TIME"
#define ZADATABASE_TABLE_EQUIP_KEY_ORDER_SN_ORDER_TIME    @"ORDER_SN_ORDER_TIME"

#define ZADATABASE_TABLE_EQUIP_KEY_ORDER_SN     @"ORDER_SN"
#define ZADATABASE_TABLE_EQUIP_KEY_ROLE_ID      @"ROLE_ID"
#define ZADATABASE_TABLE_EQUIP_KEY_SERVER_ID     @"SERVER_ID"
#define ZADATABASE_TABLE_EQUIP_KEY_EQUIP_ID       @"EQUIP_ID"

#define ZADATABASE_TABLE_EQUIP_KEY_EQUIP_SCHOOL     @"EQUIP_SCHOOL"
#define ZADATABASE_TABLE_EQUIP_KEY_EQUIP_LEVEL      @"EQUIP_LEVEL"
#define ZADATABASE_TABLE_EQUIP_KEY_EQUIP_NAME       @"EQUIP_NAME"
#define ZADATABASE_TABLE_EQUIP_KEY_EQUIP_TYPE       @"EQUIP_TYPE"
#define ZADATABASE_TABLE_EQUIP_KEY_EQUIP_KINDID     @"EQUIP_KINDID"
#define ZADATABASE_TABLE_EQUIP_KEY_EQUIP_SERVERCHECK    @"SERVER_CHECK"

#define ZADATABASE_TABLE_EQUIP_KEY_EQUIP_STATUS         @"EQUIP_STATUS"
#define ZADATABASE_TABLE_EQUIP_KEY_COMMON_PRICE         @"COMMON_PRICE"
#define ZADATABASE_TABLE_EQUIP_KEY_EQUIP_APPOINTED      @"APPOINTED"
#define ZADATABASE_TABLE_EQUIP_KEY_EQUIP_INGORE         @"INGORE"
#define ZADATABASE_TABLE_EQUIP_KEY_EQUIP_OWNERBUY       @"OWNERBUY"
#define ZADATABASE_TABLE_EQUIP_KEY_EQUIP_BARGAINBUY     @"BARGAINBUY"
#define ZADATABASE_TABLE_EQUIP_KEY_EQUIP_ERRORED        @"ERRORED"

#define ZADATABASE_TABLE_EQUIP_KEY_EQUIP_DES        @"EQUIP_DES"
#define ZADATABASE_TABLE_EQUIP_KEY_EQUIP_PRICE      @"EQUIP_PRICE"
#define ZADATABASE_TABLE_EQUIP_KEY_EQUIP_ACCEPT     @"EQUIP_ACCEPT"
#define ZADATABASE_TABLE_EQUIP_KEY_EQUIP_START_PRICE      @"EQUIP_START_PRICE"
#define ZADATABASE_TABLE_EQUIP_KEY_EQUIP_EVAL_PRICE     @"EVAL_PRICE"
#define ZADATABASE_TABLE_EQUIP_KEY_EQUIP_MORE_DETAIL    @"MORE_DETAIL"//存放追加数据json

#define ZADATABASE_TABLE_EQUIP_KEY_FAV_OR_INGORE       @"FAV_OR_INGORE"

#define ZADATABASE_TABLE_EQUIP_KEY_PLAN_TOTAL       @"PLAN_TOTAL"
#define ZADATABASE_TABLE_EQUIP_KEY_PLAN_XIULIAN     @"PLAN_XIULIAN"
#define ZADATABASE_TABLE_EQUIP_KEY_PLAN_CHONGXIU    @"PLAN_CHONGXIU"
#define ZADATABASE_TABLE_EQUIP_KEY_PLAN_JINENG      @"PLAN_JINENG"
#define ZADATABASE_TABLE_EQUIP_KEY_PLAN_JINGYAN     @"PLAN_JINGYAN"
#define ZADATABASE_TABLE_EQUIP_KEY_PLAN_QIANNENGGUO @"PLAN_QIANNENGGUO"
#define ZADATABASE_TABLE_EQUIP_KEY_PLAN_QIANYUANDAN @"PLAN_QIANYUANDAN"
#define ZADATABASE_TABLE_EQUIP_KEY_PLAN_DENGJI      @"PLAN_DENGJI"
#define ZADATABASE_TABLE_EQUIP_KEY_PLAN_JIYUAN      @"PLAN_JIYUAN"
#define ZADATABASE_TABLE_EQUIP_KEY_PLAN_MENPAI      @"PLAN_MENPAI"
#define ZADATABASE_TABLE_EQUIP_KEY_PLAN_FANGWU      @"PLAN_FANGWU"
#define ZADATABASE_TABLE_EQUIP_KEY_PLAN_XIANJIN     @"PLAN_XIANJIN"
#define ZADATABASE_TABLE_EQUIP_KEY_PLAN_HAIZI       @"PLAN_HAIZI"
#define ZADATABASE_TABLE_EQUIP_KEY_PLAN_XIANGRUI    @"PLAN_XIANGRUI"
#define ZADATABASE_TABLE_EQUIP_KEY_PLAN_ZUOJI       @"PLAN_ZUOJI"
#define ZADATABASE_TABLE_EQUIP_KEY_PLAN_FABAO       @"PLAN_FABAO"
#define ZADATABASE_TABLE_EQUIP_KEY_PLAN_ZHAOHUAN    @"PLAN_ZHAOHUAN"
#define ZADATABASE_TABLE_EQUIP_KEY_PLAN_ZHUANGBEI   @"PLAN_ZHUANGBEI"
#define ZADATABASE_TABLE_EQUIP_KEY_PLAN_DES         @"PLAN_DES"
#define ZADATABASE_TABLE_EQUIP_KEY_PLAN_RATE        @"PLAN_RATE"


#define ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE      @"SELL_CREATE"
#define ZADATABASE_TABLE_EQUIP_KEY_SELL_START       @"SELL_START"
#define ZADATABASE_TABLE_EQUIP_KEY_SELL_SOLD        @"SELL_SOLD"
#define ZADATABASE_TABLE_EQUIP_KEY_SELL_BACK        @"SELL_BACK"
#define ZADATABASE_TABLE_EQUIP_KEY_SELL_ORDER       @"SELL_ORDER"
#define ZADATABASE_TABLE_EQUIP_KEY_SELL_CANCEL      @"SELL_CANCEL"
#define ZADATABASE_TABLE_EQUIP_KEY_SELL_SPACE       @"SELL_SPACE"


inline __attribute__((always_inline)) void fcm_onMainThread(void (^block)())
{
    if (block) {
        if (NSThread.isMainThread) block(); else dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@implementation ZALocationLocalModel


@end

@interface ZALocationLocalModelManager()
{
    FMDatabaseQueue * databaseQueue;
    FMDatabaseQueue * databaseQueue_read;
    
//    FMDatabase * dataBase;
}
@property (nonatomic,copy) ZALocationLocalModel * latestLocation;
@end
@implementation ZALocationLocalModelManager

+(instancetype)sharedInstance
{
    static ZALocationLocalModelManager *shareZALocationLocalModelManagerInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareZALocationLocalModelManagerInstance = [[[self class] alloc] init];
    });
    return shareZALocationLocalModelManagerInstance;
}

+(NSString *)localSaveReadDBPath
{
    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *databasePath=[path stringByAppendingPathComponent:ZADATABASE_NAME_READ];
    return databasePath;
}
+(NSString *)localSaveTotalDBPath
{
    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *databasePath=[path stringByAppendingPathComponent:ZADATABASE_NAME];
    return databasePath;
}

//库表替换
-(void)exchangeLocalDBWithCurrentDBPath:(NSString *)inputPath
{
    NSFileManager * fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:inputPath])
    {
        return;
    }
    
    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *databasePath=[path stringByAppendingPathComponent:ZADATABASE_NAME];
    NSError* error;
    if ([fm fileExistsAtPath:databasePath])
    {
        BOOL result =[fm isDeletableFileAtPath:databasePath];
        if(result)
        {
            [fm removeItemAtPath:databasePath error:&error];
            if(error)
            {
                NSLog(@"%@",error);
            }
        }
    }
    
    if([fm fileExistsAtPath:inputPath])
    {
        [fm copyItemAtPath:inputPath toPath:databasePath error:&error];
        if(error)
        {
            NSLog(@"%@",error);
        }
    }
}
-(void)refreshLocalDBNameForLatestDBDetail
{
    
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         
         //******************************
         //*-begin-- 创建相关的表
         //******************************
         NSString *deleteSql = [NSString stringWithFormat:@"alter table %@ rename column %@ to %@",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_SELL_START,ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE];
         
         deleteSql = [NSString stringWithFormat:@"alter table %@ rename column %@ to %@",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_SELL_START,ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE];
         
         BOOL isSuccessed = [fmdatabase executeUpdate:deleteSql];
         if (isSuccessed == NO) {
             //更新语句执行失败
             NSLog(@"alter table --删除语句执行失败:%@",fmdatabase.lastErrorMessage);
         }
         
         [fmdatabase close];
     }];
}
-(void)testDetailSQLForTime
{
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         
         //******************************
         //*-begin-- 创建相关的表
         //******************************
         NSString *deleteSql = [NSString stringWithFormat:@"alter table %@ rename column %@ to %@",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_SELL_START,ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE];
         
         deleteSql = [NSString stringWithFormat:@"SELECT DATEADD(yy, DATEDIFF(yy,0,getdate()), 0)"];
         
         BOOL isSuccessed = [fmdatabase executeUpdate:deleteSql];
         if (isSuccessed == NO) {
             //更新语句执行失败
             NSLog(@"alter table --删除语句执行失败:%@",fmdatabase.lastErrorMessage);
         }
         
         [fmdatabase close];
     }];
}

-(void)localCopySoldOutDataToPartDataBase
{
    
    NSArray *   soldout = [self localSaveEquipArrayForSoldOut_database];
    NSMutableDictionary * remoteDic = [NSMutableDictionary dictionary];
    for (NSInteger index = 0;index < [soldout count] ;index ++ )
    {
        CBGListModel * eve = [soldout objectAtIndex:index];
        [remoteDic setObject:eve forKey:eve.game_ordersn];
    }
    
    
    //不能使用外部方法，那会填充数据
    NSArray * objArray = [NSArray arrayWithArray:[remoteDic allValues]];
    [databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback)
     {
         if (!db.open)
         {
             [db open];
         }
         //NSLog(@"%s %ld",__FUNCTION__,[objArray count]);
         BOOL result = YES;
         for (int i = 0; i < [objArray count]; i++)
         {
             CBGListModel * dataObj = [objArray objectAtIndex:i];
             if(!dataObj.sell_create_time){
                 dataObj.sell_create_time = @"";
             }
             if(!dataObj.equip_type){
                 dataObj.equip_type = @"";
             }
             if(!dataObj.equip_more_append){
                 dataObj.equip_more_append = @"";
             }

             dataObj.dbStyle = CBGLocalDataBaseListUpdateStyle_RefreshTotal;//矫正serverid或者新增
             result = [self privateLocalSaveEquipHistoryDetailCBGModel:dataObj withDataBase:db];
             if (!result)
             {
                 NSLog(@"%s break",__FUNCTION__);
                 *rollback = YES;
                 break;
             }
         }
         
         [db close];
     }];
    
}

//最近的一个model
-(ZWDataDetailModel *)latestLocationModel
{
    //两种可能1、位置信息库表有数据
    //2、库表里数据刚好全部上传清空了
    
    //取当前最近的一个进行保存  有则返回
//    没有最近的保存记录，由数据库获取，数据库为空，返回空
//    @property (nonatomic, copy) NSString *longtitude;
//    @property (nonatomic, copy) NSString *latitude;
    
    ZWDataDetailModel * model = (ZWDataDetailModel *)self.latestLocation;
    DetailModelSaveType type = [model currentModelState];
    if(model && (type == DetailModelSaveType_Notice || type == DetailModelSaveType_Buy)){
        return model;
    }
    
    
    NSArray * array = [self localLocationsArrayForCurrent];
    if(array && [array count]>0)
    {
        model = [array lastObject];
        return model;
    }
    
    return nil;
}

-(id)init
{
    self = [super init];
    if(self)
    {
    
        NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        if(TARGET_IPHONE_SIMULATOR)
        {
            path = @"/Users/apple/desktop/Database";
        }else{
            [self checkReadSorceCopyOrIngore];
        }
        
        NSString *databasePath=[path stringByAppendingPathComponent:ZADATABASE_NAME];
        databaseQueue= [[FMDatabaseQueue alloc]initWithPath:databasePath];
        
//        path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        
        if(TARGET_IPHONE_SIMULATOR)
        {
            databasePath=[path stringByAppendingPathComponent:ZADATABASE_NAME_READ];
        }else{
            databasePath=[[self class] localSaveReadDBPath];
        }
        databaseQueue_read= [[FMDatabaseQueue alloc]initWithPath:databasePath];

        
        [self checkLocalTables];
    }
    return self;
}
-(id)initWithDBExtendString:(NSString *)extend
{
    self = [super init];
    if(self)
    {
        
        NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        path = [path stringByAppendingPathComponent:@"details"];
        path = [path stringByAppendingPathComponent:extend];
        NSFileManager * fm = [NSFileManager defaultManager];
        if(![fm fileExistsAtPath:path])
        {
            NSError * error;
            if([fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error])
            {
                
            }
            else
            {
                NSLog(@"Failed to create directory %@,error:%@",path,error);
            }
        }

        NSString *databasePath=[path stringByAppendingPathComponent:ZADATABASE_NAME];
        databaseQueue= [[FMDatabaseQueue alloc]initWithPath:databasePath];
        
        
//        databasePath=[path stringByAppendingPathComponent:ZADATABASE_NAME_READ];
//        databaseQueue_read= [[FMDatabaseQueue alloc]initWithPath:databasePath];
        
        [self checkLocalTables];
    }
    return self;
}

-(void)checkReadSorceCopyOrIngore
{
    BOOL needCopy = NO;
    
    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *databasePath=[path stringByAppendingPathComponent:ZADATABASE_NAME];

    NSFileManager * fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:databasePath])
    {
        needCopy = YES;
    }
    
    if(needCopy)
    {
        NSString * sorcePath = [[NSBundle mainBundle] pathForResource:ZADATABASE_NAME_READ ofType:nil];
        [self exchangeLocalDBWithCurrentDBPath:sorcePath];
    }
}

-(void)checkLocalTables
{
    fcm_onMainThread(^{

    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
        if (!fmdatabase.open) {
            [fmdatabase open];
        }
        
        //******************************
        //*-begin-- 创建相关的表
        //******************************
         
         //缓存列表 22个
        if(![fmdatabase tableExists:ZADATABASE_TABLE_EQUIP_TOTAL])
        {//主表  sell_time 应该改为 create_time
            NSString *createSql=[NSString stringWithFormat:@"create table %@(%@ text primary key,%@ text,%@ int,%@ int,%@ text,%@ int,%@ int,%@ int,%@ int,%@ int,%@ text,%@ text,%@ text,%@ text,%@ text,%@ int,%@ int,%@ int,%@ int,%@ int,%@ int,%@ int,%@ int,%@ int,%@ int,%@ int,%@ int,%@ int,%@ int,%@ int,%@ int,%@ int,%@ int,%@ int,%@ int,%@ text,%@ int,%@ int,%@ int,%@ int,%@ int,%@ int,%@ int,%@ int,%@ int,%@ int,%@  int);",ZADATABASE_TABLE_EQUIP_TOTAL,
                                 ZADATABASE_TABLE_EQUIP_KEY_ORDER_SN,
                                 ZADATABASE_TABLE_EQUIP_KEY_ROLE_ID,
                                 ZADATABASE_TABLE_EQUIP_KEY_SERVER_ID,
                                 ZADATABASE_TABLE_EQUIP_KEY_EQUIP_ID,
                                 ZADATABASE_TABLE_EQUIP_KEY_EQUIP_TYPE,
                                 ZADATABASE_TABLE_EQUIP_KEY_EQUIP_LEVEL,
                                 ZADATABASE_TABLE_EQUIP_KEY_EQUIP_SCHOOL,
                                 ZADATABASE_TABLE_EQUIP_KEY_EQUIP_START_PRICE,
                                 ZADATABASE_TABLE_EQUIP_KEY_EQUIP_PRICE,
                                 ZADATABASE_TABLE_EQUIP_KEY_COMMON_PRICE,
                                 ZADATABASE_TABLE_EQUIP_KEY_EQUIP_NAME,
                                 ZADATABASE_TABLE_EQUIP_KEY_PLAN_DES,
                                 ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE,
                                 ZADATABASE_TABLE_EQUIP_KEY_SELL_SOLD,
                                 ZADATABASE_TABLE_EQUIP_KEY_SELL_BACK,
                                 ZADATABASE_TABLE_EQUIP_KEY_PLAN_TOTAL,
                                 ZADATABASE_TABLE_EQUIP_KEY_PLAN_XIULIAN,
                                 ZADATABASE_TABLE_EQUIP_KEY_PLAN_CHONGXIU,
                                 ZADATABASE_TABLE_EQUIP_KEY_PLAN_JINENG,
                                 ZADATABASE_TABLE_EQUIP_KEY_PLAN_JINGYAN,
                                 ZADATABASE_TABLE_EQUIP_KEY_PLAN_QIANNENGGUO,
                                 ZADATABASE_TABLE_EQUIP_KEY_PLAN_QIANYUANDAN,
                                 ZADATABASE_TABLE_EQUIP_KEY_PLAN_DENGJI,
                                 ZADATABASE_TABLE_EQUIP_KEY_PLAN_JIYUAN,
                                 ZADATABASE_TABLE_EQUIP_KEY_PLAN_MENPAI,
                                 ZADATABASE_TABLE_EQUIP_KEY_PLAN_FANGWU,
                                 ZADATABASE_TABLE_EQUIP_KEY_PLAN_XIANJIN,
                                 ZADATABASE_TABLE_EQUIP_KEY_PLAN_HAIZI,
                                 ZADATABASE_TABLE_EQUIP_KEY_PLAN_XIANGRUI,
                                 ZADATABASE_TABLE_EQUIP_KEY_PLAN_ZUOJI,
                                 ZADATABASE_TABLE_EQUIP_KEY_PLAN_FABAO,
                                 ZADATABASE_TABLE_EQUIP_KEY_PLAN_ZHAOHUAN,
                                 ZADATABASE_TABLE_EQUIP_KEY_PLAN_ZHUANGBEI,
                                 ZADATABASE_TABLE_EQUIP_KEY_EQUIP_ACCEPT,
                                 ZADATABASE_TABLE_EQUIP_KEY_EQUIP_EVAL_PRICE,
                                 ZADATABASE_TABLE_EQUIP_KEY_EQUIP_MORE_DETAIL,
                                 ZADATABASE_TABLE_EQUIP_KEY_PLAN_RATE,
                                 ZADATABASE_TABLE_EQUIP_KEY_SELL_SPACE,
                                 ZADATABASE_TABLE_EQUIP_KEY_FAV_OR_INGORE,
                                 ZADATABASE_TABLE_EQUIP_KEY_EQUIP_KINDID,
                                 ZADATABASE_TABLE_EQUIP_KEY_EQUIP_SERVERCHECK,
                                 ZADATABASE_TABLE_EQUIP_KEY_EQUIP_STATUS,
                                 ZADATABASE_TABLE_EQUIP_KEY_EQUIP_APPOINTED,
                                 ZADATABASE_TABLE_EQUIP_KEY_EQUIP_INGORE,
                                 ZADATABASE_TABLE_EQUIP_KEY_EQUIP_OWNERBUY,
                                 ZADATABASE_TABLE_EQUIP_KEY_EQUIP_BARGAINBUY,
                                 ZADATABASE_TABLE_EQUIP_KEY_EQUIP_ERRORED,
                                 nil];
            [fmdatabase executeUpdate:createSql];
            NSString *databasePath=[fmdatabase databasePath];
            NSFileManager *defaultFileManager=[NSFileManager defaultManager];
            BOOL isExit=[defaultFileManager fileExistsAtPath:databasePath];
            
            if (!isExit)
            {
                [defaultFileManager createFileAtPath:databasePath contents:nil attributes:nil];
            }
            
        }
         //下单状态列表 9个
         if(![fmdatabase tableExists:ZADATABASE_TABLE_EQUIP_ORDER])
         {
             NSString *createSql=[NSString stringWithFormat:@"create table %@(%@ text primary key,%@ text,%@ text,%@ int,%@ text,%@ int,%@ text,%@ text,%@ int);",ZADATABASE_TABLE_EQUIP_ORDER,
                                  ZADATABASE_TABLE_EQUIP_KEY_ORDER_SN_ORDER_TIME,//order表用ordertime
                                  ZADATABASE_TABLE_EQUIP_KEY_ORDER_SN,
                                  ZADATABASE_TABLE_EQUIP_KEY_SELL_START,
                                  ZADATABASE_TABLE_EQUIP_KEY_EQUIP_PRICE,
                                  ZADATABASE_TABLE_EQUIP_KEY_ROLE_ID,
                                  ZADATABASE_TABLE_EQUIP_KEY_SERVER_ID,
                                  ZADATABASE_TABLE_EQUIP_KEY_SELL_ORDER,
                                  ZADATABASE_TABLE_EQUIP_KEY_SELL_CANCEL,
                                  ZADATABASE_TABLE_EQUIP_KEY_EQUIP_ACCEPT];
             [fmdatabase executeUpdate:createSql];
             //建完文章表，顺便处理下文件不备份到icloud
             NSString *databasePath=[fmdatabase databasePath];
             NSFileManager *defaultFileManager=[NSFileManager defaultManager];
             BOOL isExit=[defaultFileManager fileExistsAtPath:databasePath];
             
             if (!isExit)
             {
                 [defaultFileManager createFileAtPath:databasePath contents:nil attributes:nil];
             }
             
         }
         //卖方修改列表 7个
         if(![fmdatabase tableExists:ZADATABASE_TABLE_EQUIP_CHANGE])
         {
             NSString *createSql=[NSString stringWithFormat:@"create table %@(%@ text primary key,%@ text,%@ text,%@ int,%@ text,%@ int,%@ int);",ZADATABASE_TABLE_EQUIP_CHANGE,
                                  ZADATABASE_TABLE_EQUIP_KEY_ORDER_SN_SELL_TIME,//change表用selltime
                                  ZADATABASE_TABLE_EQUIP_KEY_ORDER_SN,
                                  ZADATABASE_TABLE_EQUIP_KEY_SELL_START,
                                  ZADATABASE_TABLE_EQUIP_KEY_EQUIP_PRICE,
                                  ZADATABASE_TABLE_EQUIP_KEY_ROLE_ID,
                                  ZADATABASE_TABLE_EQUIP_KEY_SERVER_ID,
                                  ZADATABASE_TABLE_EQUIP_KEY_EQUIP_ACCEPT];
             [fmdatabase executeUpdate:createSql];
             //建完文章表，顺便处理下文件不备份到icloud
             NSString *databasePath=[fmdatabase databasePath];
             NSFileManager *defaultFileManager=[NSFileManager defaultManager];
             BOOL isExit=[defaultFileManager fileExistsAtPath:databasePath];
             
             if (!isExit)
             {
                 [defaultFileManager createFileAtPath:databasePath contents:nil attributes:nil];
             }
             
         }
         
         //服务器名称列表 4个
         if(![fmdatabase tableExists:ZADATABASE_TABLE_EQUIP_SERVER])
         {
             NSString *createSql=[NSString stringWithFormat:@"create table %@(%@ text primary key,%@ text,%@ int,%@ int);",ZADATABASE_TABLE_EQUIP_SERVER,
                                  ZADATABASE_TABLE_SERVER_KEY_TIME,//change表用selltime
                                  ZADATABASE_TABLE_SERVER_KEY_NAME,
                                  ZADATABASE_TABLE_SERVER_KEY_ID,
                                  ZADATABASE_TABLE_SERVER_KEY_TEST
                                ];
             [fmdatabase executeUpdate:createSql];
             //建完文章表，顺便处理下文件不备份到icloud
             NSString *databasePath=[fmdatabase databasePath];
             NSFileManager *defaultFileManager=[NSFileManager defaultManager];
             BOOL isExit=[defaultFileManager fileExistsAtPath:databasePath];
             
             if (!isExit)
             {
                 [defaultFileManager createFileAtPath:databasePath contents:nil attributes:nil];
             }
             
         }

     }];
    });
}
-(void)clearTotalSoldOutLocations
{
    fcm_onMainThread(^{
        
        [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
         {
             if (!fmdatabase.open) {
                 [fmdatabase open];
             }
             
             //******************************
             //*-begin-- 创建相关的表
             //******************************
             NSString *deleteSql = [NSString stringWithFormat:@"delete from %@",ZADATABASE_TABLE_LOCATIONS_SOLDOUT];
             BOOL isSuccessed = [fmdatabase executeUpdate:deleteSql];
             if (isSuccessed == NO) {
                 //更新语句执行失败
                 NSLog(@"delete from --删除语句执行失败:%@",fmdatabase.lastErrorMessage);
             }
             
             [fmdatabase close];
         }];
    });
}
-(void)clearTotalLocations
{
    fcm_onMainThread(^{

    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         
         //******************************
         //*-begin-- 创建相关的表
         //******************************
         NSString *deleteSql = [NSString stringWithFormat:@"delete from %@",ZADATABASE_TABLE_LOCATIONS];
         BOOL isSuccessed = [fmdatabase executeUpdate:deleteSql];
         if (isSuccessed == NO) {
             //更新语句执行失败
             NSLog(@"delete from --删除语句执行失败:%@",fmdatabase.lastErrorMessage);
         }
         
         [fmdatabase close];
     }];
    });
}
-(void)clearUploadedLocations:(NSArray *)current
{
    [current enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self deleteLocationWithCurrentObj:obj];
    }];
    

}
-(void)deleteLocationWithCurrentObj:(id)obj
{

    Equip_listModel * model = (Equip_listModel *)obj;

    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         
         BOOL isAlreadyIn = NO;
         NSString * time = model.equipid;
         //检查使用
//         NSString *sqlGetArticle=[NSString stringWithFormat:@"select * from %@ where %@ = '%@';",ZADATABASE_TABLE_LOCATIONS,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,time];
//         FMResultSet *resultSet=[fmdatabase executeQuery:sqlGetArticle];
//         
//         if ([resultSet next])
//         {
//             isAlreadyIn=YES;
//         }
         
//         NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
//         NSString * valueStr = [data base64Encoding];

//         if (isAlreadyIn)
         {
             NSString *deleteArticleString=[NSString stringWithFormat:@"delete from %@ where %@ = '%@';",ZADATABASE_TABLE_LOCATIONS,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,time];
             BOOL isSuccessed = [fmdatabase executeUpdate:deleteArticleString];
             if (isSuccessed == NO) {
                 //更新语句执行失败
                 NSLog(@"insert error--删除语句执行失败:%@",fmdatabase.lastErrorMessage);
             }
         }

         
         [fmdatabase close];
     }];
}

-(void)localSaveDetailUpdateArray:(NSArray *)arr
{
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self localSaveDisappearLocation:obj];
    }];
}

-(BOOL)localSaveCurrentLocation:(id)obj
{
    return NO;
    Equip_listModel * model = (Equip_listModel *)obj;
    
    __block BOOL success = NO;
    __block BOOL firstSave = YES;
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase) {
        if (!fmdatabase.open) {
            [fmdatabase open];
        }
        
        BOOL isAlreadyIn = NO;
        NSString * time = model.equipid;
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
        NSString * valueStr = [data base64Encoding];
        
        NSString *sqlGetArticle=[NSString stringWithFormat:@"select * from %@ where %@ = %@;",ZADATABASE_TABLE_LOCATIONS,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,time];
        FMResultSet *resultSet=[fmdatabase executeQuery:sqlGetArticle];
        
        if ([resultSet next])
        {
            isAlreadyIn=YES;
            firstSave = NO;
        }
        

        NSString * sqlString = nil;
        if(isAlreadyIn)
        {
            sqlString=[NSString stringWithFormat:@"update %@ set %@=? where %@=?;",ZADATABASE_TABLE_LOCATIONS,ZADATABASE_TABLE_LOCATIONS_KEY_DIC,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,nil];
            
            NSArray *sqlarray=[NSArray arrayWithObjects: valueStr,time,nil];
            success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
        }else
        {
            sqlString=[NSString stringWithFormat:@"insert into %@ values(?,?);",ZADATABASE_TABLE_LOCATIONS];
            NSArray *sqlarray=[NSArray arrayWithObjects:time,valueStr, nil];
            success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
        }
        
        [fmdatabase close];
        
    }];
    
    if(firstSave){
        self.latestLocation = obj;
    }
    
    return firstSave;
}
-(void)localSaveDisappearLocation:(id)obj{
    return;
    Equip_listModel * model = (Equip_listModel *)obj;
    
    __block BOOL success = NO;
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase) {
        if (!fmdatabase.open) {
            [fmdatabase open];
        }
        
        BOOL isAlreadyIn = NO;
        NSString * time = model.equipid;
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
        NSString * valueStr = [data base64Encoding];
        
        NSString *sqlGetArticle=[NSString stringWithFormat:@"select * from %@ where %@ = %@;",ZADATABASE_TABLE_LOCATIONS,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,time];
        FMResultSet *resultSet=[fmdatabase executeQuery:sqlGetArticle];
        
        if ([resultSet next])
        {
            isAlreadyIn=YES;
        }
        
        
        NSString * sqlString = nil;
        if(isAlreadyIn)
        {
            sqlString=[NSString stringWithFormat:@"update %@ set %@=? where %@=?;",ZADATABASE_TABLE_LOCATIONS,ZADATABASE_TABLE_LOCATIONS_KEY_DIC,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,nil];
            
            NSArray *sqlarray=[NSArray arrayWithObjects: valueStr,time,nil];
            success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
        }else
        {
            sqlString=[NSString stringWithFormat:@"insert into %@ values(?,?);",ZADATABASE_TABLE_LOCATIONS];
            NSArray *sqlarray=[NSArray arrayWithObjects:time,valueStr, nil];
            success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
        }
        
        [fmdatabase close];
        
    }];
    
}
-(NSArray *)localLocationsArrayForCurrent
{
    return nil;
    NSMutableArray *totalArray=[NSMutableArray array];
    
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase){
        if (!fmdatabase.open) {
            [fmdatabase open];
        }
        NSMutableString *sqlMutableString=[[NSMutableString alloc]init];
        //是某分类的
//        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
        
        [sqlMutableString appendFormat:@"select * from %@ ;",ZADATABASE_TABLE_LOCATIONS];

        FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
        while ([resultSet next]) {
            Equip_listModel *location=[self createArticleWithResultSet:resultSet];
            [totalArray addObject:location];
        }
        
        [resultSet close];
        [fmdatabase close];

    }];
    return totalArray;
}
-(NSArray *)localLocationsArrayForAppendingDB
{
    return nil;
    NSMutableArray *totalArray=[NSMutableArray array];
    
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase){
        if (!fmdatabase.open) {
            [fmdatabase open];
        }
        NSMutableString *sqlMutableString=[[NSMutableString alloc]init];
        //是某分类的
        //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
        
        [sqlMutableString appendFormat:@"select * from %@ ;",ZADATABASE_TABLE_LOCATIONS_HISTORY];
        
        FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
        while ([resultSet next]) {
            ZWDataDetailModel *location=[self createArticleWithResultSet:resultSet];
            [totalArray addObject:location];
        }
        
        [resultSet close];
        [fmdatabase close];
        
    }];
    return totalArray;
}
-(void)exchangeLocalSaveLocationsToSave
{
    //遍历当前列表，存储到中read中
    NSArray * array = [self localLocationsArrayForCurrent];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self readDBlocalSaveCurrentLocation:obj];
    }];
    
}
-(BOOL)readDBlocalSaveCurrentLocation:(id)obj
{
    return NO;
    ZWDataDetailModel * model = (ZWDataDetailModel *)obj;
    
    __block BOOL success = NO;
    __block BOOL firstSave = YES;
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase) {
        if (!fmdatabase.open) {
            [fmdatabase open];
        }
        
        BOOL isAlreadyIn = NO;
        NSString * time = model.product_id;
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
        NSString * valueStr = [data base64Encoding];
        
        NSString *sqlGetArticle=[NSString stringWithFormat:@"select * from %@ where %@ = %@;",ZADATABASE_TABLE_LOCATIONS_HISTORY,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,time];
        FMResultSet *resultSet=[fmdatabase executeQuery:sqlGetArticle];
        
        if ([resultSet next])
        {
            isAlreadyIn=YES;
            firstSave = NO;
        }
        
        
        NSString * sqlString = nil;
        if(isAlreadyIn)
        {
            sqlString=[NSString stringWithFormat:@"update %@ set %@=? where %@=?;",ZADATABASE_TABLE_LOCATIONS_HISTORY,ZADATABASE_TABLE_LOCATIONS_KEY_DIC,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,nil];
            
            NSArray *sqlarray=[NSArray arrayWithObjects: valueStr,time,nil];
            success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
        }else
        {
            sqlString=[NSString stringWithFormat:@"insert into %@ values(?,?);",ZADATABASE_TABLE_LOCATIONS_HISTORY];
            NSArray *sqlarray=[NSArray arrayWithObjects:time,valueStr, nil];
            success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
        }
        
        [fmdatabase close];
        
    }];
    
    
    return firstSave;
}


-(ZWDataDetailModel*)createArticleWithResultSet:(FMResultSet*)resultSet
{//从记录集中的一条创建一个文章
    NSString * valueStr = [resultSet stringForColumn:ZADATABASE_TABLE_LOCATIONS_KEY_DIC];
    NSData * data = [[NSData alloc] initWithBase64Encoding:valueStr];
    Equip_listModel * model = [Equip_listModel objectWithContentsOfData:data];
    NSDictionary * dic = [model dictionaryRepresentation];
    Equip_listModel * backModel = [Equip_listModel ac_objectWithAny:dic];
    
    return backModel;
}

-(NSArray *)localSystemSellArray
{
    return nil;
    NSMutableArray *totalArray=[NSMutableArray array];
    
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase){
        if (!fmdatabase.open) {
            [fmdatabase open];
        }
        NSMutableString *sqlMutableString=[[NSMutableString alloc]init];
        //是某分类的
        //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
        
        [sqlMutableString appendFormat:@"select * from %@ ;",ZADATABASE_TABLE_LOCATIONS_SYSTEM_SELL];
        
        FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
        while ([resultSet next]) {
            ZWSysSellModel *location=[self createSysSellModelArticleWithResultSet:resultSet];
            [totalArray addObject:location];
        }
        
        [resultSet close];
        [fmdatabase close];
        
    }];
    return totalArray;

}
-(void)clearSystemSellArray:(NSArray *)current
{
    [current enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self deleteSystemSellModelWithCurrentObj:obj];
    }];
}
-(void)deleteSystemSellModelWithCurrentObj:(id)obj
{
    return ;
    ZWSysSellModel * model = (ZWSysSellModel *)obj;
    
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         
         BOOL isAlreadyIn = NO;
         NSString * time = model.product_id;
         {
             NSString *deleteArticleString=[NSString stringWithFormat:@"delete from %@ where %@ = '%@';",ZADATABASE_TABLE_LOCATIONS_SYSTEM_SELL,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,time];
             BOOL isSuccessed = [fmdatabase executeUpdate:deleteArticleString];
             if (isSuccessed == NO) {
                 //更新语句执行失败
                 NSLog(@"insert error--删除语句执行失败:%@",fmdatabase.lastErrorMessage);
             }
         }
         
         
         [fmdatabase close];
     }];
}

-(BOOL)localSaveSystemSellModel:(id)obj
{
    return NO;
    ZWSysSellModel * model = (ZWSysSellModel *)obj;
    
    __block BOOL success = NO;
    __block BOOL firstSave = YES;
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase) {
        if (!fmdatabase.open) {
            [fmdatabase open];
        }
        
        BOOL isAlreadyIn = NO;
        NSString * time = model.product_id;
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
        NSString * valueStr = [data base64Encoding];
        
        NSString *sqlGetArticle=[NSString stringWithFormat:@"select * from %@ where %@ = %@;",ZADATABASE_TABLE_LOCATIONS_SYSTEM_SELL,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,time];
        FMResultSet *resultSet=[fmdatabase executeQuery:sqlGetArticle];
        
        if ([resultSet next])
        {
            isAlreadyIn=YES;
            firstSave = NO;
        }
        
        
        NSString * sqlString = nil;
        if(isAlreadyIn)
        {
            sqlString=[NSString stringWithFormat:@"update %@ set %@=? where %@=?;",ZADATABASE_TABLE_LOCATIONS_SYSTEM_SELL,ZADATABASE_TABLE_LOCATIONS_KEY_DIC,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,nil];
            
            NSArray *sqlarray=[NSArray arrayWithObjects: valueStr,time,nil];
            success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
        }else
        {
            sqlString=[NSString stringWithFormat:@"insert into %@ values(?,?);",ZADATABASE_TABLE_LOCATIONS_SYSTEM_SELL];
            NSArray *sqlarray=[NSArray arrayWithObjects:time,valueStr, nil];
            success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
        }
        
        [fmdatabase close];
        
    }];
    
    return firstSave;
}

-(ZWSysSellModel *)createSysSellModelArticleWithResultSet:(FMResultSet*)resultSet
{//从记录集中的一条创建一个文章
    NSString * valueStr = [resultSet stringForColumn:ZADATABASE_TABLE_LOCATIONS_KEY_DIC];
    NSData * data = [[NSData alloc] initWithBase64Encoding:valueStr];
    ZWSysSellModel * model = [ZWSysSellModel objectWithContentsOfData:data];
    NSDictionary * dic = [model dictionaryRepresentation];
    ZWSysSellModel * backModel = [ZWSysSellModel ac_objectWithAny:dic];
    
    return backModel;
}
-(void)localSaveSoldOutEquipWithSoldOutDataBaseModelArray:(id)objArray
{
    [databaseQueue_read inTransaction:^(FMDatabase *db, BOOL *rollback)
     {
         if (!db.open)
         {
             [db open];
         }
         
         BOOL result = YES;
         for (int i = 0; i < [objArray count]; i++)
         {
             id dataObj = [objArray objectAtIndex:i];
             result = [self localSaveEquipModelWithDB:db andEquipModel:dataObj withSoldOut:YES];
             if (!result)
             {
                 NSLog(@"%s break",__FUNCTION__);
                 *rollback = YES;
                 break;
             }
         }
         [db close];
     }];
}

-(void)localSaveSoldOutEquipModelArray:(id)objArray
{
    [databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback)
     {
         if (!db.open)
         {
             [db open];
         }
         
         BOOL result = YES;
         for (int i = 0; i < [objArray count]; i++)
         {
             id dataObj = [objArray objectAtIndex:i];
             result = [self localSaveEquipModelWithDB:db andEquipModel:dataObj withSoldOut:YES];
             if (!result)
             {
                 NSLog(@"break");
                 *rollback = YES;
                 break;
             }
         }
         [db close];
     }];
}
-(NSArray *)localSaveEquipArrayForSoldOut_database
{
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue_read inDatabase:^(FMDatabase *fmdatabase){
        if (!fmdatabase.open) {
            [fmdatabase open];
        }
        NSMutableString *sqlMutableString=[[NSMutableString alloc]init];
        //是某分类的
        //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
        
        //全部数据
//        [sqlMutableString appendFormat:@"select * from %@ ORDER BY %@ DESC;",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE];
        
        
        //5月份数据
        NSString * time = @"201";
        [sqlMutableString appendFormat:@"select * from %@ where %@ like'%@%%' ORDER BY %@ DESC;",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE,time,ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE];

        
        //临时由change表获取数据
//        [sqlMutableString appendFormat:@"select * from %@ ORDER BY %@ DESC;",ZADATABASE_TABLE_EQUIP_CHANGE,ZADATABASE_TABLE_EQUIP_KEY_ORDER_SN];
        
//        [sqlMutableString appendString:@"select * from ZADATABASE_TABLE_EQUIP_CHANGE where ORDER_SN in (select ORDER_SN from ZADATABASE_TABLE_EQUIP_CHANGE group by ORDER_SN having count(ORDER_SN) > 0)"];
        
        FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
        while ([resultSet next]) {
            CBGListModel *location=[self listModelFromDatabaseResult:resultSet];
//            location.equip_status = 4;
            [totalArray addObject:location];
            

        }
        
        [resultSet close];
        [fmdatabase close];
        
    }];
    return totalArray;
    
}

-(NSArray *)localSaveEquipArrayForSoldOut
{
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase){
        if (!fmdatabase.open) {
            [fmdatabase open];
        }
        NSMutableString *sqlMutableString=[[NSMutableString alloc]init];
        //是某分类的
        //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
        
        [sqlMutableString appendFormat:@"select * from %@ ORDER BY %@ DESC;",ZADATABASE_TABLE_LOCATIONS_SOLDOUT,ZADATABASE_TABLE_LOCATIONS_KEY_START];        
//        [sqlMutableString appendFormat:@"select * from %@ ;",ZADATABASE_TABLE_LOCATIONS_SOLDOUT];

        
        FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
        while ([resultSet next]) {
            Equip_listModel *location=[self createEquipDetailModelArticleWithResultSet:resultSet];
            [totalArray addObject:location];
        }
        
        [resultSet close];
        [fmdatabase close];
        
    }];
    return totalArray;
    
}


-(void)localSaveEquipModelArray:(id)objArray
{
    [databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback)
    {
        if (!db.open)
        {
            [db open];
        }
        
        BOOL result = YES;
        for (int i = 0; i < [objArray count]; i++)
        {
            id dataObj = [objArray objectAtIndex:i];
            result = [self localSaveEquipModelWithDB:db andEquipModel:dataObj];
            if (!result)
            {
                NSLog(@"break");
                *rollback = YES;
                break;
            }
        }
        
        [db close];

    }];
}
-(void)localSaveEquipModel:(id)obj
{
    if(!obj) return;
    
    __block BOOL success = NO;
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase) {
        if (!fmdatabase.open)
        {
            [fmdatabase open];
        }
        success = [self localSaveEquipModelWithDB:fmdatabase andEquipModel:obj];
        
        [fmdatabase close];
    }];
}
-(BOOL)localSaveEquipModelWithDB:(FMDatabase *)fmdatabase andEquipModel:(id)dataObj
{
    BOOL success = [self localSaveEquipModelWithDB:fmdatabase andEquipModel:dataObj withSoldOut:NO];
    return success;
}
-(BOOL)localSaveEquipModelWithDB:(FMDatabase *)fmdatabase andEquipModel:(id)dataObj withSoldOut:(BOOL)sold
{
    BOOL success = NO;
    
    NSString * databaseName = sold? ZADATABASE_TABLE_LOCATIONS_SOLDOUT:ZADATABASE_TABLE_LOCATIONS;
    
    Equip_listModel * model = (Equip_listModel *)dataObj;
    
    BOOL isAlreadyIn = NO;
    NSString * time = model.game_ordersn;
    
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
    
    EquipModel * detail = model.equipModel;
//    model.detaiModel = nil;
    
    
    
    
    NSString * valueStr = [[model mj_keyValues] JSONStringRepresentation_Dic];
    
    NSString *sqlGetArticle=[NSString stringWithFormat:@"select * from %@ where %@ = '%@';",databaseName,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,time];
    FMResultSet *resultSet=[fmdatabase executeQuery:sqlGetArticle];
    
    if ([resultSet next])
    {
        isAlreadyIn=YES;
    }
    
    
    NSString * create = model.createTime;
    NSString * fav = model.favTag;
    NSString * detailStr = @"";
    if(detail)
    {
//        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:detail];
//        detailStr = [data base64Encoding];
        detailStr = [[detail mj_keyValues] JSONStringRepresentation_Dic];
    }
    if(!fav)
    {
        fav = @"";
    }
    if(!create)
    {
        create = [NSDate unixDate];
    }
    
    NSString * sqlString = nil;
    if(isAlreadyIn)
    {
        if(!detail)
        {
            sqlString=[NSString stringWithFormat:@"update %@ set %@=? where %@=?;",databaseName,ZADATABASE_TABLE_LOCATIONS_KEY_DIC,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,nil];
            NSArray *sqlarray=[NSArray arrayWithObjects: valueStr,detailStr,create,fav,time,nil];
            success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
        }else{
            sqlString=[NSString stringWithFormat:@"update %@ set %@=?,%@=?,%@=?,%@=? where %@=?;",databaseName,ZADATABASE_TABLE_LOCATIONS_KEY_DIC,ZADATABASE_TABLE_LOCATIONS_KEY_DETAIL,ZADATABASE_TABLE_LOCATIONS_KEY_START,ZADATABASE_TABLE_LOCATIONS_KEY_FAV,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,nil];
            NSArray *sqlarray=[NSArray arrayWithObjects: valueStr,detailStr,create,fav,time,nil];
            success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
        }
    }else
    {
        //            ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS_KEY_DIC,ZADATABASE_TABLE_LOCATIONS_KEY_DETAIL,ZADATABASE_TABLE_LOCATIONS_KEY_START,ZADATABASE_TABLE_LOCATIONS_KEY_FAV
        sqlString=[NSString stringWithFormat:@"insert into %@ values(?,?,?,?,?);",databaseName];
        NSArray *sqlarray=[NSArray arrayWithObjects:time,valueStr,detailStr,create,fav, nil];
        success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
    }
    return success;
}

-(NSArray *)localSaveEquipModelArray
{
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase){
        if (!fmdatabase.open) {
            [fmdatabase open];
        }
        NSMutableString *sqlMutableString=[[NSMutableString alloc]init];
        //是某分类的
        //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
        
        [sqlMutableString appendFormat:@"select * from %@ ;",ZADATABASE_TABLE_LOCATIONS];
        
        FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
        while ([resultSet next]) {
            Equip_listModel *location=[self createEquipDetailModelArticleWithResultSet:resultSet];
            [totalArray addObject:location];
        }
        
        [resultSet close];
        [fmdatabase close];
        
    }];
    return totalArray;

    return nil;
}
-(NSArray *)latestLocalSaveEquipModelArray
{
    //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];

    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase){
        if (!fmdatabase.open) {
            [fmdatabase open];
        }
        NSMutableString *sqlMutableString=[[NSMutableString alloc]init];
        //是某分类的
        //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
        
//        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' DESC limit 20;",ZADATABASE_TABLE_LOCATIONS,ZADATABASE_TABLE_LOCATIONS_KEY_START];
        [sqlMutableString appendFormat:@"select * from %@ ORDER BY %@ DESC limit 225;",ZADATABASE_TABLE_LOCATIONS,ZADATABASE_TABLE_LOCATIONS_KEY_START];

        
        FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
        while ([resultSet next]) {
            Equip_listModel *location=[self createEquipDetailModelArticleWithResultSet:resultSet];
            [totalArray addObject:location];
        }
        
        [resultSet close];
        [fmdatabase close];
        
    }];
    return totalArray;
    return nil;
}
-(NSArray *)localTotalSaveEquipArray
{
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase){
        if (!fmdatabase.open) {
            [fmdatabase open];
        }
        NSMutableString *sqlMutableString=[[NSMutableString alloc]init];
        //是某分类的
        //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
        
        [sqlMutableString appendFormat:@"select * from %@ ORDER BY %@ DESC;",ZADATABASE_TABLE_LOCATIONS,ZADATABASE_TABLE_LOCATIONS_KEY_START];
        
        FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
        while ([resultSet next]) {
            Equip_listModel *location=[self createEquipDetailModelArticleWithResultSet:resultSet];
            [totalArray addObject:location];
        }
        
        [resultSet close];
        [fmdatabase close];
        
    }];
    return totalArray;
}
-(void)clearLocalTotalModelArray
{
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         
         //******************************
         //*-begin-- 创建相关的表
         //******************************
         NSString *deleteSql = [NSString stringWithFormat:@"delete from %@",ZADATABASE_TABLE_LOCATIONS];
         BOOL isSuccessed = [fmdatabase executeUpdate:deleteSql];
         if (isSuccessed == NO) {
             //更新语句执行失败
             NSLog(@"delete from --删除语句执行失败:%@",fmdatabase.lastErrorMessage);
         }
         
         [fmdatabase close];
     }];
}
-(NSArray *)localSaveEquipArrayForFav
{
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase){
        if (!fmdatabase.open) {
            [fmdatabase open];
        }
        NSMutableString *sqlMutableString=[[NSMutableString alloc]init];
        //是某分类的
        //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
        
        [sqlMutableString appendFormat:@"select * from %@ where %@='1' ORDER BY %@ DESC;",ZADATABASE_TABLE_LOCATIONS,ZADATABASE_TABLE_LOCATIONS_KEY_FAV,ZADATABASE_TABLE_LOCATIONS_KEY_START];
        
        FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
        while ([resultSet next]) {
            Equip_listModel *location=[self createEquipDetailModelArticleWithResultSet:resultSet];
            [totalArray addObject:location];
        }
        
        [resultSet close];
        [fmdatabase close];
        
    }];
    return totalArray;

}

-(Equip_listModel *)createEquipDetailModelArticleWithResultSet:(FMResultSet *)resultSet
{
    NSString * valueStr = [resultSet stringForColumn:ZADATABASE_TABLE_LOCATIONS_KEY_DIC];
    NSDictionary * objDic = [valueStr objectFromJSONString];
    
    Equip_listModel * backModel = nil;
    
    if(objDic)
    {
        backModel = [[Equip_listModel alloc] initWithDictionary:objDic];
    }else
    {
        NSData * data = [[NSData alloc] initWithBase64Encoding:valueStr];
        backModel = [Equip_listModel objectWithContentsOfData:data];
//        NSDictionary * dic = [model dictionaryRepresentation];
//        backModel = [Equip_listModel ac_objectWithAny:dic];
    }
    
    valueStr = [resultSet stringForColumn:ZADATABASE_TABLE_LOCATIONS_KEY_DETAIL];
    NSDictionary * detailDic = [valueStr objectFromJSONString];
    if(detailDic)
    {
        EquipModel *model = [[EquipModel alloc] initWithDictionary:detailDic];
        backModel.equipModel = model;
    }else{
        NSData * data = [[NSData alloc] initWithBase64Encoding:valueStr];
        EquipModel * model = [EquipModel objectWithContentsOfData:data];
//        NSDictionary * dic = [model dictionaryRepresentation];
//        model = [EquipModel ac_objectWithAny:dic];
        
        backModel.equipModel = model;
    }
    
    
    backModel.favTag = [resultSet stringForColumn:ZADATABASE_TABLE_LOCATIONS_KEY_FAV];
    backModel.createTime = [resultSet stringForColumn:ZADATABASE_TABLE_LOCATIONS_KEY_START];
    
    
    return backModel;
}
-(void)localSaveMakeOrderArrayListDetailCBGModelArray:(NSArray *)objArray
{
    [databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback)
     {
         if (!db.open)
         {
             [db open];
         }
         //NSLog(@"%s %ld",__FUNCTION__,[objArray count]);
         BOOL result = YES;
         for (int i = 0; i < [objArray count]; i++)
         {
             id dataObj = [objArray objectAtIndex:i];
             result = [self privateSearchAndUpdateMakeOrderDetailCBGModel:dataObj withDataBase:db];
             if (!result)
             {
                 NSLog(@"%s break",__FUNCTION__);
                 *rollback = YES;
                 break;
             }
         }
         
         [db close];
     }];
}
//存储刷新 下单数据  ORDER表
-(void)localSaveMakeOrderDetailCBGModel:(id)orderModel
{

}

-(BOOL)privateSearchAndUpdateMakeOrderDetailCBGModel:(CBGListModel *)model withDataBase:(FMDatabase *)fmdatabase
{
    BOOL success = NO;
    if(model.latestEquipListStatus == CBGEquipRoleState_InOrdering)
    {
        model.sell_cancel_time = @"";
        //进行插入操作
        success = [self privateLocalSaveUpdateOrderDetailCBGModel:model withDataBase:fmdatabase];
    }else if(model.latestEquipListStatus == CBGEquipRoleState_InSelling)
    {
        //先查找
        NSString * orderTime = [self privateLatestCBGOrderTimeFromHistoryWithOrderSN:model.game_ordersn
                                                                        withDatabase:fmdatabase];
        
        //进行更新操作
        if(orderTime)
        {
            model.sell_order_time = orderTime;
            success = [self privateLocalSaveUpdateOrderDetailCBGModel:model withDataBase:fmdatabase];
        }else{
            success = YES;
        }
    }else{
        success = YES;
    }
    
    return success;
}

-(BOOL)privateLocalSaveUpdateOrderDetailCBGModel:(CBGListModel *)model withDataBase:(FMDatabase *)fmdatabase
{
    //查找是否存在，不存在，进行插入
    BOOL success = NO;
    
    BOOL isAlreadyIn = NO;
    NSString * changeKey = [NSString stringWithFormat:@"%@-%@",model.game_ordersn,model.sell_order_time];
    NSString *sqlGetArticle=[NSString stringWithFormat:@"select * from %@ where %@ = '%@';",ZADATABASE_TABLE_EQUIP_ORDER,ZADATABASE_TABLE_EQUIP_KEY_ORDER_SN_ORDER_TIME,changeKey];
    FMResultSet *resultSet=[fmdatabase executeQuery:sqlGetArticle];
    if ([resultSet next])
    {
        isAlreadyIn=YES;
    }
    
    NSString * sqlString = nil;
    if(isAlreadyIn)
    {
        sqlString=[NSString stringWithFormat:@"update %@ set %@=?  where %@=?;",ZADATABASE_TABLE_EQUIP_ORDER,ZADATABASE_TABLE_EQUIP_KEY_SELL_CANCEL,ZADATABASE_TABLE_EQUIP_KEY_ORDER_SN_ORDER_TIME,nil];
        
        NSArray *sqlarray=[NSArray arrayWithObjects:
                           model.sell_cancel_time,
                           changeKey,
                           nil];
        success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
    }else
    {
        sqlString=[NSString stringWithFormat:@"insert into %@ values(?,?,?,?,?,?,?,?,?);",ZADATABASE_TABLE_EQUIP_ORDER];
        NSArray *sqlarray=[NSArray arrayWithObjects:
                           changeKey,
                           model.game_ordersn,
                           model.sell_start_time,
                           [NSNumber numberWithInteger:model.equip_price],
                           model.owner_roleid,
                           [NSNumber numberWithInteger:model.server_id],
                           model.sell_order_time,
                           model.sell_cancel_time,
                           [NSNumber numberWithInteger:model.equip_accept],
                           nil];
        success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
    }
    
    return success;
}

-(NSString *)privateLatestCBGOrderTimeFromHistoryWithOrderSN:(NSString *)ordersn withDatabase:(FMDatabase *)fmdatabase
{
    NSMutableString *sqlMutableString=[NSMutableString string];
    
    [sqlMutableString appendFormat:@"select * from %@ ORDER BY %@ DESC limit 1;",ZADATABASE_TABLE_EQUIP_ORDER,ZADATABASE_TABLE_EQUIP_KEY_SELL_START];
    FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
    if([resultSet next])
    {
        //如果当前的取消时间为空，则返回下单时间
        NSString * cancel = [resultSet stringForColumn:ZADATABASE_TABLE_EQUIP_KEY_SELL_CANCEL];
        NSString * start = [resultSet stringForColumn:ZADATABASE_TABLE_EQUIP_KEY_SELL_ORDER];
        if(!cancel || [cancel length] == 0)
        {
            return start;
        }
        return nil;
    }
    return  nil;
}


-(NSArray *)localSaveMakeOrderHistoryListForOrderSN:(NSString *)ordersn{
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         NSMutableString *sqlMutableString=[NSMutableString string];
         //是某分类的
         //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
         
         [sqlMutableString appendFormat:@"select * from %@ where %@ = '%@' ORDER BY %@ DESC;",ZADATABASE_TABLE_EQUIP_ORDER,ZADATABASE_TABLE_EQUIP_KEY_ORDER_SN,ordersn,ZADATABASE_TABLE_EQUIP_KEY_SELL_ORDER];
         
         FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
         while ([resultSet next])
         {
             CBGListModel *location = [self listModelFromDatabaseResult:resultSet];
//             location.equip_status = 3;
             [totalArray addObject:location];
         }
         
         [resultSet close];
         [fmdatabase close];
         
     }];
    return totalArray;
    return nil;
}
-(NSArray *)localSaveMakeOrderHistoryListForRoleId:(NSString *)roleId
{
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         NSMutableString *sqlMutableString=[NSMutableString string];
         //是某分类的
         //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
         
         [sqlMutableString appendFormat:@"select * from %@ where %@ = '%@' ORDER BY %@ DESC;",ZADATABASE_TABLE_EQUIP_ORDER,ZADATABASE_TABLE_EQUIP_KEY_ROLE_ID,roleId,ZADATABASE_TABLE_EQUIP_KEY_SELL_ORDER];
         
         FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
         while ([resultSet next])
         {
             CBGListModel *location = [self listModelFromDatabaseResult:resultSet];
//             location.equip_status = 3;
             [totalArray addObject:location];
         }
         
         [resultSet close];
         [fmdatabase close];
         
     }];
    return totalArray;
    return nil;
}
-(void)localSaveUserChangeArrayListWithDetailCBGModelArray:(NSArray *)objArray
{
    [databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback)
     {
         if (!db.open)
         {
             [db open];
         }
         //NSLog(@"%s %ld",__FUNCTION__,[objArray count]);

         BOOL result = YES;
         for (int i = 0; i < [objArray count]; i++)
         {
             id dataObj = [objArray objectAtIndex:i];
             result = [self privateLocalSaveUpdateChangeDetailCBGModel:dataObj withDataBase:db];
             if (!result)
             {
                 NSLog(@"%s break",__FUNCTION__);
                 *rollback = YES;
                 break;
             }
         }
         
         [db close];
     }];
}
//存储  刷新卖家变动数据  CHANGE表
-(void)localSaveUserChangeDetailCBGModel:(id)changeModel
{
    CBGListModel * model = (CBGListModel *)changeModel;
//    BOOL success = NO;
    //需要之前是未上架，库表没存储，通过缓存判定
    
    if(model.latestEquipListStatus == CBGEquipRoleState_InSelling)
    {
        //销售中
        //进行插入或更新操作
        [self privateLocalSaveUpdateChangeDetailCBGModel:model withDataBase:nil];
    }
}
-(BOOL)privateLocalSaveUpdateChangeDetailCBGModel:(CBGListModel *)model withDataBase:(FMDatabase *)fmdatabase
{
    //查找是否存在，不存在，进行插入
    BOOL success = NO;
    
    BOOL isAlreadyIn = NO;
    NSString * changeKey = [NSString stringWithFormat:@"%@-%@",model.game_ordersn,model.sell_start_time];
    NSString *sqlGetArticle=[NSString stringWithFormat:@"select * from %@ where %@ = '%@';",ZADATABASE_TABLE_EQUIP_CHANGE,ZADATABASE_TABLE_EQUIP_KEY_ORDER_SN_SELL_TIME,changeKey];
    FMResultSet *resultSet=[fmdatabase executeQuery:sqlGetArticle];
    if ([resultSet next])
    {
        isAlreadyIn=YES;
    }
    
    NSString * sqlString = nil;
    if(isAlreadyIn)
    {
        sqlString=[NSString stringWithFormat:@"update %@ set %@=? , %@=? where %@=?;",ZADATABASE_TABLE_EQUIP_CHANGE,ZADATABASE_TABLE_EQUIP_KEY_EQUIP_PRICE,ZADATABASE_TABLE_EQUIP_KEY_EQUIP_ACCEPT,ZADATABASE_TABLE_EQUIP_KEY_ORDER_SN_SELL_TIME,nil];
        
        NSArray *sqlarray=[NSArray arrayWithObjects:
                           [NSNumber numberWithInteger:model.equip_price],
                           [NSNumber numberWithInteger:model.equip_accept],
                           changeKey,
                           nil];
        //NSLog(@"sqlarray %@ ",sqlarray);
        success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
    }else
    {
        sqlString=[NSString stringWithFormat:@"insert into %@ values(?,?,?,?,?,?,?);",ZADATABASE_TABLE_EQUIP_CHANGE];
        NSArray *sqlarray=[NSArray arrayWithObjects:
                           changeKey,
                           model.game_ordersn,
                           model.sell_start_time,
                           [NSNumber numberWithInteger:model.equip_price],
                           model.owner_roleid,
                           [NSNumber numberWithInteger:model.server_id],
                           [NSNumber numberWithInteger:model.equip_accept],
                           nil];
        success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
    }
    
    return success;
}

-(NSArray *)localSaveUserChangeHistoryListForOrderSN:(NSString *)ordersn
{
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         NSMutableString *sqlMutableString=[NSMutableString string];
         //是某分类的
         //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
         
         [sqlMutableString appendFormat:@"select * from %@ where %@ = '%@' ORDER BY %@ DESC;",ZADATABASE_TABLE_EQUIP_CHANGE,ZADATABASE_TABLE_EQUIP_KEY_ORDER_SN,ordersn,ZADATABASE_TABLE_EQUIP_KEY_SELL_START];
         
         FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
         while ([resultSet next])
         {
             CBGListModel *location = [self listModelFromDatabaseResult:resultSet];
//             location.equip_status = 2;
             [totalArray addObject:location];
         }
         
         [resultSet close];
         [fmdatabase close];
         
     }];
    return totalArray;
    return nil;
}
-(NSArray *)localSaveUserChangeHistoryListForRoleId:(NSString *)roleId
{
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         NSMutableString *sqlMutableString=[NSMutableString string];
         //是某分类的
         //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
         
         [sqlMutableString appendFormat:@"select * from %@ where %@ = '%@' ORDER BY %@ DESC;",ZADATABASE_TABLE_EQUIP_CHANGE,ZADATABASE_TABLE_EQUIP_KEY_ROLE_ID,roleId,ZADATABASE_TABLE_EQUIP_KEY_SELL_START];
         
         FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
         while ([resultSet next])
         {
             CBGListModel *location = [self listModelFromDatabaseResult:resultSet];
//             location.equip_status = 2;
             [totalArray addObject:location];
         }
         
         [resultSet close];
         [fmdatabase close];
         
     }];
    return totalArray;
    return nil;
}

-(void)localSaveEquipHistoryArrayListWithDetailCBGModelArray:(NSArray *)objArray
{

    [databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback)
     {
         if (!db.open)
         {
             [db open];
         }
         //NSLog(@"%s %ld",__FUNCTION__,[objArray count]);
         BOOL result = YES;
         for (int i = 0; i < [objArray count]; i++)
         {
             id  dataObj = [objArray objectAtIndex:i];
             result = [self privateCheckAndUpdateEquipHistoryDetailCBGModel:dataObj withDataBase:db];
             if (!result)
             {
                 NSLog(@"%s break",__FUNCTION__);
                 *rollback = YES;
                 break;
             }
         }
         
         
         
         [db close];
     }];
    
    
    
}
//存储数据  主表
-(void)localSaveEquipHistoryDetailCBGModel:(id)historyModel
{
    
}
-(BOOL)privateCheckAndUpdateEquipHistoryDetailCBGModel:(CBGListModel *)model withDataBase:(FMDatabase *)fmdatabase
{
    BOOL success = NO;
    
    //判定补全操作，看之前有没有处理
    if(model.latestEquipListStatus == CBGEquipRoleState_BuyFinish || model.latestEquipListStatus == CBGEquipRoleState_PayFinish)
    {
        //更新
        success = [self privateLocalSaveEquipHistoryDetailCBGModel:model withDataBase:fmdatabase];

    }else if(model.latestEquipListStatus == CBGEquipRoleState_Backing)
    {
        //更新
        model.sell_back_time = [NSDate unixDate];
        success = [self privateLocalSaveEquipHistoryDetailCBGModel:model withDataBase:fmdatabase];
    }else
//        if(model.latestEquipListStatus == CBGEquipRoleState_InSelling || model.latestEquipListStatus == CBGEquipRoleState_unSelling)
    {
        //新增
        model.sell_sold_time = @"";
        model.sell_back_time = @"";
        success = [self privateLocalSaveEquipHistoryDetailCBGModel:model withDataBase:fmdatabase];
    }
    
    return success;
}

//int evalPrice = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_EQUIP_EVAL_PRICE];
//之前为0或有变更
//BOOL evalPriceUpdate = (evalPrice == 0 || evalPrice != model.equip_eval_price);
-(BOOL)privateLocalSaveEquipHistoryDetailCBGModel:(CBGListModel *)model withDataBase:(FMDatabase *)fmdatabase
{
    CBGLocalDataBaseListUpdateStyle style = model.dbStyle;
    
    //查找是否存在，不存在，进行插入
    BOOL success = NO;
    NSArray * preArr = [self privateLocalSaveEquipHistroyPreModelForOrderSN:model.game_ordersn withDataBase:fmdatabase];
    CBGListModel * preModel = nil;
    if([preArr count] > 0)
    {
        preModel = [preArr lastObject];
    }
    
    if(!preModel)
    {
        success = [self privateLocalSaveEquipHistoryWithInsertModel:model withDataBase:fmdatabase];
    }else
    {
        switch (style)
        {
                
            case CBGLocalDataBaseListUpdateStyle_RefreshEval:
            {//刷新系统估价
                BOOL ingoreRefresh = YES;
                if(preModel.equip_eval_price == 0 && model.equip_eval_price > 0)
                {
                    preModel.equip_eval_price = model.equip_eval_price;
                    ingoreRefresh = NO;
                }
                
                if(preModel.equip_price != model.equip_price)
                {
                    preModel.equip_price = model.equip_price;
                    ingoreRefresh = NO;
                }
                if(preModel.plan_rate != model.plan_rate)
                {
                    preModel.plan_rate = model.plan_rate;
                    ingoreRefresh = NO;
                }
                if(preModel.equip_accept != model.equip_accept)
                {
                    preModel.equip_accept = model.equip_accept;
                    ingoreRefresh = NO;
                }
                
                if(preModel.appointed != model.appointed)
                {
                    preModel.appointed = model.appointed;
                    ingoreRefresh = NO;
                }
                
                if(preModel.equip_status != model.equip_status)
                {
                    preModel.equip_status = model.equip_status;
                    ingoreRefresh = NO;
                }

                
                if(ingoreRefresh)
                {
                    success = YES;
                }
            }
                break;
            case CBGLocalDataBaseListUpdateStyle_TimeAndPrice:
            {//刷新结束时间
                
                BOOL ingoreRefresh = YES;
                if(([model.sell_sold_time length] > 0 && ![model.sell_sold_time isEqualToString:preModel.sell_sold_time])
                   || ([preModel.sell_back_time length] == 0 && [model.sell_back_time length] > 0))
                {
                    ingoreRefresh = NO;
                    preModel.sell_sold_time = model.sell_sold_time;
                    preModel.sell_back_time = model.sell_back_time;
                    preModel.sell_space = model.sell_space;
                }
                
                if(preModel.equip_price != model.equip_price)
                {
                    preModel.equip_price = model.equip_price;
                    ingoreRefresh = NO;
                }
                
                if(preModel.equip_accept != model.equip_accept)
                {
                    preModel.equip_accept = model.equip_accept;
                    ingoreRefresh = NO;
                }
                
                if(preModel.appointed != model.appointed)
                {
                    preModel.appointed = model.appointed;
                    ingoreRefresh = NO;
                }

                if(preModel.plan_rate != model.plan_rate)
                {
                    preModel.plan_rate = model.plan_rate;
                    ingoreRefresh = NO;
                }
                
                if(preModel.equip_status != model.equip_status)
                {
                    //排除特殊存储情况
                    if(model.equip_status == 1 && (preModel.equip_status == 11 || preModel.equip_status == 12)){
                        
                    }else
                    {
                        preModel.equip_status = model.equip_status;
                        ingoreRefresh = NO;
                    }
                }


                
                if(ingoreRefresh)
                {
                    success = YES;
                }
            }
                break;
            case CBGLocalDataBaseListUpdateStyle_RefreshPlan:
            {
                if(preModel.plan_total_price != model.plan_total_price || preModel.plan_rate != model.plan_rate)
                {
                    //估价相关，
                    preModel.plan_total_price = model.plan_total_price;
                    preModel.plan_xiulian_price = model.plan_xiulian_price;
                    preModel.plan_chongxiu_price = model.plan_chongxiu_price;
                    preModel.plan_jineng_price = model.plan_jineng_price;
                    preModel.plan_jingyan_price = model.plan_jingyan_price;
                    preModel.plan_qianyuandan_price = model.plan_qianyuandan_price;
                    preModel.plan_qiannengguo_price = model.plan_qiannengguo_price;
                    preModel.plan_dengji_price = model.plan_dengji_price;
                    preModel.plan_jiyuan_price = model.plan_jiyuan_price;
                    preModel.plan_menpai_price = model.plan_menpai_price;
                    preModel.plan_fangwu_price = model.plan_fangwu_price;
                    preModel.plan_xianjin_price = model.plan_xianjin_price;
                    preModel.plan_haizi_price = model.plan_haizi_price;
                    preModel.plan_xiangrui_price = model.plan_xiangrui_price;
                    preModel.plan_zuoji_price = model.plan_zuoji_price;
                    preModel.plan_fabao_price = model.plan_fabao_price;
                    preModel.plan_zhaohuanshou_price = model.plan_zhaohuanshou_price;
                    preModel.plan_zhuangbei_price = model.plan_zhuangbei_price;
                    preModel.plan_des = model.plan_des;
                    preModel.plan_rate = model.plan_rate;
                    preModel.sell_space = model.sell_space;

                }else{
                    success = YES;
                }
            }
                break;
            case CBGLocalDataBaseListUpdateStyle_TimeAndPlan:
            {
                BOOL ingoreRefresh = YES;
                
                //估价变化
                if(preModel.plan_total_price != model.plan_total_price || preModel.plan_rate != model.plan_rate)
                {
                    //估价相关，
                    preModel.plan_total_price = model.plan_total_price;
                    preModel.plan_xiulian_price = model.plan_xiulian_price;
                    preModel.plan_chongxiu_price = model.plan_chongxiu_price;
                    preModel.plan_jineng_price = model.plan_jineng_price;
                    preModel.plan_jingyan_price = model.plan_jingyan_price;
                    preModel.plan_qianyuandan_price = model.plan_qianyuandan_price;
                    preModel.plan_qiannengguo_price = model.plan_qiannengguo_price;
                    preModel.plan_dengji_price = model.plan_dengji_price;
                    preModel.plan_jiyuan_price = model.plan_jiyuan_price;
                    preModel.plan_menpai_price = model.plan_menpai_price;
                    preModel.plan_fangwu_price = model.plan_fangwu_price;
                    preModel.plan_xianjin_price = model.plan_xianjin_price;
                    preModel.plan_haizi_price = model.plan_haizi_price;
                    preModel.plan_xiangrui_price = model.plan_xiangrui_price;
                    preModel.plan_zuoji_price = model.plan_zuoji_price;
                    preModel.plan_fabao_price = model.plan_fabao_price;
                    preModel.plan_zhaohuanshou_price = model.plan_zhaohuanshou_price;
                    preModel.plan_zhuangbei_price = model.plan_zhuangbei_price;
                    preModel.plan_des = model.plan_des;
                    preModel.plan_rate = model.plan_rate;
                    preModel.sell_space = model.sell_space;
                    
                    ingoreRefresh = NO;
                }
                
                
                if(preModel.equip_id != model.equip_id)
                {
                    ingoreRefresh = NO;
                    preModel.equip_id = model.equip_id;
                }
                
                if(preModel.sell_space != model.sell_space)
                {
                    ingoreRefresh = NO;
                    preModel.sell_space = model.sell_space;
                }
                
                //附带变化时间  当前结束时间>0且和之前不同，或者历史取回时间不存在，当前存在
                if(([model.sell_sold_time length] > 0 && ![model.sell_sold_time isEqualToString:preModel.sell_sold_time])
                   || ([preModel.sell_back_time length] == 0 && [model.sell_back_time length] > 0))
                {
                    ingoreRefresh = NO;
                    preModel.sell_sold_time = model.sell_sold_time;
                    preModel.sell_back_time = model.sell_back_time;
                }
                
                //数据迁移造成的数据不全
                if([preModel.equip_type length] == 0)
                {
                    ingoreRefresh = NO;
                    preModel.equip_type = model.equip_type;
                    preModel.equip_more_append = model.equip_more_append;
                }
                
                if([preModel.equip_name length] != [model.equip_name length]){
                    ingoreRefresh = NO;
                    preModel.equip_name = model.equip_name;
                }
                
                //价格变化
                if(preModel.equip_price != model.equip_price && model.equip_price > 0)
                {
                    ingoreRefresh = NO;
                    preModel.equip_price = model.equip_price;
                }

                //还价状态变化
                if(preModel.equip_accept != model.equip_accept)
                {
                    ingoreRefresh = NO;
                    preModel.equip_accept = model.equip_accept;
                }
                
                if(preModel.appointed != model.appointed)
                {
                    preModel.appointed = model.appointed;
                    ingoreRefresh = NO;
                }
                
                if(preModel.equip_status != model.equip_status)
                {
                    //排除特殊存储情况
                    if(model.equip_status == 1 && (preModel.equip_status == 11 || preModel.equip_status == 12)){
                        
                    }else
                    {
                        preModel.equip_status = model.equip_status;
                        ingoreRefresh = NO;
                    }
                }

                
                if(ingoreRefresh)
                {
                    success = YES;
                }
            }
                break;
            case CBGLocalDataBaseListUpdateStyle_CopyRefresh:
            {
                preModel.server_id = model.server_id;
            }
                break;
            case CBGLocalDataBaseListUpdateStyle_RefreshStatus:
            {//状态、价格、时间
                preModel.ingore = model.ingore;
                preModel.ownerBuy = model.ownerBuy;
                preModel.errored = model.errored;
                
            }
                break;
            case CBGLocalDataBaseListUpdateStyle_RefreshTotal:
            {
                BOOL ingoreRefresh = YES;
                if(preModel.equip_eval_price == 0 && model.equip_eval_price > 0)
                {
                    preModel.equip_eval_price = model.equip_eval_price;
                    ingoreRefresh = NO;
                }
                
                if(([model.sell_sold_time length] > 0 && ![model.sell_sold_time isEqualToString:preModel.sell_sold_time])
                   || ([preModel.sell_back_time length] == 0 && [model.sell_back_time length] > 0))
                {
                    ingoreRefresh = NO;
                    preModel.sell_sold_time = model.sell_sold_time;
                    preModel.sell_back_time = model.sell_back_time;
                    preModel.sell_space = model.sell_space;
                }
                
                if(preModel.errored != model.errored && model.errored)
                {
                    preModel.errored = model.errored;
                    ingoreRefresh = NO;
                }
                
                if(preModel.ingore != model.ingore && model.ingore)
                {
                    preModel.ingore = model.ingore;
                    ingoreRefresh = NO;
                }

                if(preModel.ownerBuy != model.ownerBuy && model.ownerBuy)
                {
                    preModel.ownerBuy = model.ownerBuy;
                    ingoreRefresh = NO;
                }
                
                if(preModel.bargainBuy != model.bargainBuy && model.bargainBuy)
                {
                    preModel.bargainBuy = model.bargainBuy;
                    ingoreRefresh = NO;
                }
                
                if(preModel.appointed != model.appointed)
                {
                    preModel.appointed = model.appointed;
                    ingoreRefresh = NO;
                }

                
                if(preModel.equip_price != model.equip_price)
                {
                    preModel.equip_price = model.equip_price;
                    ingoreRefresh = NO;
                }
                
                if(preModel.equip_accept != model.equip_accept)
                {
                    preModel.equip_accept = model.equip_accept;
                    ingoreRefresh = NO;
                }
                
                if(preModel.equip_status != model.equip_status)
                {
                    //排除特殊存储情况
                    if(model.equip_status == 1 && (preModel.equip_status == 11 || preModel.equip_status == 12)){
                        
                    }else
                    {
                        preModel.equip_status = model.equip_status;
                        ingoreRefresh = NO;
                    }
                }


                
                
                if(ingoreRefresh)
                {
                    success = YES;
                }
                
            }
                break;

            default:
                break;
        }
        
        if(success) return success;
        
        success = [self privateLocalSaveEquipHistoryWithUpdateModel:preModel withDataBase:fmdatabase];
    }
    if(!success){
        
    }
    
    return success;
}
-(BOOL)privateLocalSaveEquipHistoryWithUpdateModel:(CBGListModel *)model  withDataBase:(FMDatabase *)fmdatabase
{
    //更新全部信息，后续无需更新的数据读取后使用历史数据补全，补全可能更新的数据

    BOOL success = NO;
    NSString * changeKey = model.game_ordersn;
    NSString * sqlString = nil;
    //更新  时间信息(有历史用历史的)  追加信息 价格 估值 估值详情
    sqlString=[NSString stringWithFormat:@"update %@ set %@=?, %@=? ,%@=?,%@=? ,%@=?, %@=? , %@=?,%@=?, %@=? , %@=?,%@=?, %@=? , %@=?,%@=?, %@=? , %@=? , %@=?,%@=? , %@=?, %@=?, %@=?, %@=?, %@=?, %@=?, %@=?, %@=?, %@=?, %@=? , %@=?, %@=?, %@=?, %@=? , %@=?, %@=?, %@=?, %@=? , %@=? , %@=? , %@=?, %@=? where %@=?;",ZADATABASE_TABLE_EQUIP_TOTAL,
               ZADATABASE_TABLE_EQUIP_KEY_SERVER_ID,
               ZADATABASE_TABLE_EQUIP_KEY_SELL_SOLD,
               ZADATABASE_TABLE_EQUIP_KEY_SELL_BACK,
               ZADATABASE_TABLE_EQUIP_KEY_EQUIP_PRICE,
               ZADATABASE_TABLE_EQUIP_KEY_PLAN_RATE,
               ZADATABASE_TABLE_EQUIP_KEY_EQUIP_ACCEPT,
               ZADATABASE_TABLE_EQUIP_KEY_COMMON_PRICE,
               ZADATABASE_TABLE_EQUIP_KEY_PLAN_DES,
               ZADATABASE_TABLE_EQUIP_KEY_PLAN_TOTAL,
               ZADATABASE_TABLE_EQUIP_KEY_PLAN_XIULIAN,
               ZADATABASE_TABLE_EQUIP_KEY_PLAN_CHONGXIU,
               ZADATABASE_TABLE_EQUIP_KEY_PLAN_JINENG,
               ZADATABASE_TABLE_EQUIP_KEY_PLAN_JINGYAN,
               ZADATABASE_TABLE_EQUIP_KEY_PLAN_QIANNENGGUO,
               ZADATABASE_TABLE_EQUIP_KEY_PLAN_QIANYUANDAN,
               ZADATABASE_TABLE_EQUIP_KEY_PLAN_DENGJI,
               ZADATABASE_TABLE_EQUIP_KEY_PLAN_JIYUAN,
               ZADATABASE_TABLE_EQUIP_KEY_PLAN_MENPAI,
               ZADATABASE_TABLE_EQUIP_KEY_PLAN_FANGWU,
               ZADATABASE_TABLE_EQUIP_KEY_PLAN_XIANJIN,
               ZADATABASE_TABLE_EQUIP_KEY_PLAN_HAIZI,
               ZADATABASE_TABLE_EQUIP_KEY_PLAN_XIANGRUI,
               ZADATABASE_TABLE_EQUIP_KEY_PLAN_ZUOJI,
               ZADATABASE_TABLE_EQUIP_KEY_PLAN_FABAO,
               ZADATABASE_TABLE_EQUIP_KEY_PLAN_ZHAOHUAN,
               ZADATABASE_TABLE_EQUIP_KEY_PLAN_ZHUANGBEI,
               ZADATABASE_TABLE_EQUIP_KEY_EQUIP_EVAL_PRICE,
               ZADATABASE_TABLE_EQUIP_KEY_EQUIP_MORE_DETAIL,
               ZADATABASE_TABLE_EQUIP_KEY_SELL_SPACE,
               ZADATABASE_TABLE_EQUIP_KEY_FAV_OR_INGORE,
               ZADATABASE_TABLE_EQUIP_KEY_EQUIP_KINDID,
               ZADATABASE_TABLE_EQUIP_KEY_EQUIP_SERVERCHECK,
               ZADATABASE_TABLE_EQUIP_KEY_EQUIP_STATUS,
               ZADATABASE_TABLE_EQUIP_KEY_EQUIP_APPOINTED,
               ZADATABASE_TABLE_EQUIP_KEY_EQUIP_INGORE,
               ZADATABASE_TABLE_EQUIP_KEY_EQUIP_OWNERBUY,
               ZADATABASE_TABLE_EQUIP_KEY_EQUIP_BARGAINBUY,
               ZADATABASE_TABLE_EQUIP_KEY_EQUIP_ERRORED,
               ZADATABASE_TABLE_EQUIP_KEY_EQUIP_TYPE,
               ZADATABASE_TABLE_EQUIP_KEY_EQUIP_ID,
               ZADATABASE_TABLE_EQUIP_KEY_ORDER_SN,
               nil];
    
    
    
    NSArray *sqlarray=[NSArray arrayWithObjects:
                       [NSNumber numberWithInteger:model.server_id],
                       model.sell_sold_time,
                       model.sell_back_time,
                       [NSNumber numberWithInteger:model.equip_price],
                       [NSNumber numberWithInteger:model.plan_rate],
                       [NSNumber numberWithInteger:model.equip_accept],
                       [NSNumber numberWithInteger:model.equip_price_common],
                       model.plan_des,
                       [NSNumber numberWithInteger:model.plan_total_price],
                       [NSNumber numberWithInteger:model.plan_xiulian_price],
                       [NSNumber numberWithInteger:model.plan_chongxiu_price],
                       [NSNumber numberWithInteger:model.plan_jineng_price],
                       [NSNumber numberWithInteger:model.plan_jingyan_price],
                       [NSNumber numberWithInteger:model.plan_qiannengguo_price],
                       [NSNumber numberWithInteger:model.plan_qianyuandan_price],
                       [NSNumber numberWithInteger:model.plan_dengji_price],
                       [NSNumber numberWithInteger:model.plan_jiyuan_price],
                       [NSNumber numberWithInteger:model.plan_menpai_price],
                       [NSNumber numberWithInteger:model.plan_fangwu_price],
                       [NSNumber numberWithInteger:model.plan_xianjin_price],
                       [NSNumber numberWithInteger:model.plan_haizi_price],
                       [NSNumber numberWithInteger:model.plan_xiangrui_price],
                       [NSNumber numberWithInteger:model.plan_zuoji_price],
                       [NSNumber numberWithInteger:model.plan_fabao_price],
                       [NSNumber numberWithInteger:model.plan_zhaohuanshou_price],
                       [NSNumber numberWithInteger:model.plan_zhuangbei_price],
                       [NSNumber numberWithInteger:model.equip_eval_price],
                       model.equip_more_append,
                       [NSNumber numberWithInteger:model.sell_space],
                       [NSNumber numberWithInteger:model.fav_or_ingore],
                       [NSNumber numberWithInteger:model.kindid],
                       [NSNumber numberWithInteger:model.server_check],
                       [NSNumber numberWithInteger:model.equip_status],
                       [NSNumber numberWithInteger:model.appointed],
                       [NSNumber numberWithInteger:model.ingore],
                       [NSNumber numberWithInteger:model.ownerBuy],
                       [NSNumber numberWithInteger:model.bargainBuy],
                       [NSNumber numberWithInteger:model.errored],
                       model.equip_type,
                       [NSNumber numberWithInteger:model.equip_id],
                       changeKey,
                       nil];
    success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
    if(!success){
        NSLog(@"update error %@",fmdatabase.lastError);
    }
    return success;
}

-(BOOL)privateLocalSaveEquipHistoryWithInsertModel:(CBGListModel *)model  withDataBase:(FMDatabase *)fmdatabase
{
    BOOL success = NO;
    NSString * changeKey = model.game_ordersn;
    NSString * sqlString = nil;
    sqlString=[NSString stringWithFormat:@"insert into %@ values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);",ZADATABASE_TABLE_EQUIP_TOTAL];
    NSArray *sqlarray=[NSArray arrayWithObjects:
                       changeKey,
                       model.owner_roleid,
                       [NSNumber numberWithInteger:model.server_id],
                       [NSNumber numberWithInteger:model.equip_id],
                       model.equip_type,
                       [NSNumber numberWithInteger:model.equip_level],
                       [NSNumber numberWithInteger:model.equip_school],
                       [NSNumber numberWithInteger:model.equip_start_price],
                       [NSNumber numberWithInteger:model.equip_price],
                       [NSNumber numberWithInteger:model.equip_price_common],
                       model.equip_name,
                       model.plan_des,
                       model.sell_create_time,
                       model.sell_sold_time,
                       model.sell_back_time,
                       [NSNumber numberWithInteger:model.plan_total_price],
                       [NSNumber numberWithInteger:model.plan_xiulian_price],
                       [NSNumber numberWithInteger:model.plan_chongxiu_price],
                       [NSNumber numberWithInteger:model.plan_jineng_price],
                       [NSNumber numberWithInteger:model.plan_jingyan_price],
                       [NSNumber numberWithInteger:model.plan_qiannengguo_price],
                       [NSNumber numberWithInteger:model.plan_qianyuandan_price],
                       [NSNumber numberWithInteger:model.plan_dengji_price],
                       [NSNumber numberWithInteger:model.plan_jiyuan_price],
                       [NSNumber numberWithInteger:model.plan_menpai_price],
                       [NSNumber numberWithInteger:model.plan_fangwu_price],
                       [NSNumber numberWithInteger:model.plan_xianjin_price],
                       [NSNumber numberWithInteger:model.plan_haizi_price],
                       [NSNumber numberWithInteger:model.plan_xiangrui_price],
                       [NSNumber numberWithInteger:model.plan_zuoji_price],
                       [NSNumber numberWithInteger:model.plan_fabao_price],
                       [NSNumber numberWithInteger:model.plan_zhaohuanshou_price],
                       [NSNumber numberWithInteger:model.plan_zhuangbei_price],
                       [NSNumber numberWithInteger:model.equip_accept],
                       [NSNumber numberWithInteger:model.equip_eval_price],
                       model.equip_more_append,
                       [NSNumber numberWithInteger:model.plan_rate],
                       [NSNumber numberWithInteger:model.sell_space],
                       [NSNumber numberWithInteger:model.fav_or_ingore],
                       [NSNumber numberWithInteger:model.kindid],
                       [NSNumber numberWithInteger:model.server_check],
                       [NSNumber numberWithInteger:model.equip_status],
                       [NSNumber numberWithInteger:model.appointed],
                       [NSNumber numberWithInteger:model.ingore],
                       [NSNumber numberWithInteger:model.ownerBuy],
                       [NSNumber numberWithInteger:model.bargainBuy],
                       [NSNumber numberWithInteger:model.errored],
                       nil];
    success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
    if(!success){
        NSLog(@"insert into error %@",fmdatabase.lastError);
    }
    
    return success;
}
-(void)deleteLocalSaveEquipHistoryObjectWithCBGModelOrderSN:(NSString *)ordersn
{
    if(!ordersn) return;
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         
         //******************************
         //*-begin-- 创建相关的表
         //******************************
         NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ = '%@'",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_ORDER_SN,ordersn];
         
//         NSString * deleteSql = @"delete from ZADATABASE_TABLE_EQUIP_TOTAL where SERVER_ID = 0;";
         
         BOOL isSuccessed = [fmdatabase executeUpdate:deleteSql];
         if (isSuccessed == NO) {
             //更新语句执行失败
             NSLog(@"delete from --删除语句执行失败:%@",fmdatabase.lastErrorMessage);
         }
         
         [fmdatabase close];
     }];

}
-(void)deleteTotalLocalSaveEquipHistory{
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         
         //******************************
         //*-begin-- 创建相关的表
         //******************************
         NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ != ''",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_ORDER_SN];
         
         //         NSString * deleteSql = @"delete from ZADATABASE_TABLE_EQUIP_TOTAL where SERVER_ID = 0;";
         
         BOOL isSuccessed = [fmdatabase executeUpdate:deleteSql];
         if (isSuccessed == NO) {
             //更新语句执行失败
             NSLog(@"delete from --删除语句执行失败:%@",fmdatabase.lastErrorMessage);
         }
         
         [fmdatabase close];
     }];

}
-(NSArray *)localSaveEquipHistoryModelListWithIngoreNumber:(NSInteger)number
{
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         NSMutableString *sqlMutableString=[NSMutableString string];
         //是某分类的
         //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
         
         [sqlMutableString appendFormat:@"select * from %@ where %@ =%ld ORDER BY %@ DESC;",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_FAV_OR_INGORE,number,ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE];
         
         FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
         while ([resultSet next])
         {
             CBGListModel *location = [self listModelFromDatabaseResult:resultSet];
//             location.equip_status = 4;
             [totalArray addObject:location];
         }
         
         [resultSet close];
         [fmdatabase close];
         
     }];
    return totalArray;
}
-(NSArray *)localSaveEquipHistoryModelListTotal
{
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         NSMutableString *sqlMutableString=[NSMutableString string];
         //是某分类的
         //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
//         [sqlMutableString appendString:@"select * from ZADATABASE_TABLE_EQUIP_TOTAL where EQUIP_PRICE < 100000"];
         [sqlMutableString appendFormat:@"select * from %@ where %@ = 0 ORDER BY %@ DESC;",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_EQUIP_ERRORED,ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE];
         
         FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
         while ([resultSet next])
         {
             CBGListModel *location = [self listModelFromDatabaseResult:resultSet];
//             location.equip_status = 4;
             [totalArray addObject:location];
         }
         
         [resultSet close];
         [fmdatabase close];
         
     }];
    return totalArray;
}
-(NSArray *)localSaveEquipHistoryModelListEquipUnSell
{
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         NSMutableString *sqlMutableString=[NSMutableString string];
         //是某分类的
         //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
         //         [sqlMutableString appendString:@"select * from ZADATABASE_TABLE_EQUIP_TOTAL where EQUIP_PRICE < 200000"];
         [sqlMutableString appendFormat:@"select * from %@ where %@ = 1 or %@ = 11 or  %@ = 12 ORDER BY %@ DESC;",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_EQUIP_STATUS,ZADATABASE_TABLE_EQUIP_KEY_EQUIP_STATUS,ZADATABASE_TABLE_EQUIP_KEY_EQUIP_STATUS,ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE];
         
         FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
         while ([resultSet next])
         {
             CBGListModel *location = [self listModelFromDatabaseResult:resultSet];
             //             location.equip_status = 4;
             [totalArray addObject:location];
         }
         
         [resultSet close];
         [fmdatabase close];
         
     }];
    return totalArray;
}

-(NSArray *)localSaveEquipHistoryModelListEquipPriceError
{
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         NSMutableString *sqlMutableString=[NSMutableString string];
         //是某分类的
         //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
//         [sqlMutableString appendString:@"select * from ZADATABASE_TABLE_EQUIP_TOTAL where EQUIP_PRICE < 200000"];
         [sqlMutableString appendFormat:@"select * from %@ where %@ > 100 or %@ = 1 ORDER BY %@ DESC;",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_PLAN_RATE,ZADATABASE_TABLE_EQUIP_KEY_EQUIP_ERRORED,ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE];

         FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
         while ([resultSet next])
         {
             CBGListModel *location = [self listModelFromDatabaseResult:resultSet];
//             location.equip_status = 4;
             [totalArray addObject:location];
         }
         
         [resultSet close];
         [fmdatabase close];
         
     }];
    return totalArray;
}

-(NSArray *)localSaveEquipHistoryModelListTotalWithSoldOut
{
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         NSMutableString *sqlMutableString=[NSMutableString string];
         //是某分类的
         //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
         
         [sqlMutableString appendFormat:@"select * from %@ where %@ !='' ORDER BY %@ DESC;",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_SELL_SOLD,ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE];
         
         FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
         while ([resultSet next])
         {
             CBGListModel *location = [self listModelFromDatabaseResult:resultSet];
//             location.equip_status = 4;
             [totalArray addObject:location];
         }
         
         [resultSet close];
         [fmdatabase close];
         
     }];
    return totalArray;
}
-(NSArray *)localSaveEquipHistoryModelListTotalWithUnFinished
{
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         NSMutableString *sqlMutableString=[NSMutableString string];
         //是某分类的
         //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
         
         [sqlMutableString appendFormat:@"select * from %@ where %@ =='' AND %@ == '' ORDER BY %@ DESC;",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_SELL_SOLD,ZADATABASE_TABLE_EQUIP_KEY_SELL_BACK,ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE];
         
         FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
         while ([resultSet next])
         {
             CBGListModel *location = [self listModelFromDatabaseResult:resultSet];
//             location.equip_status = 4;
             [totalArray addObject:location];
         }
         
         [resultSet close];
         [fmdatabase close];
         
     }];
    return totalArray;
}
-(NSArray *)localSaveEquipHistoryModelListTotalWithPlanBuy
{
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         NSMutableString *sqlMutableString=[NSMutableString string];
         //是某分类的
         //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
         
         [sqlMutableString appendFormat:@"select * from %@ where %@ * 100 > %@ And %@ > 0  ORDER BY %@ DESC;",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_PLAN_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_EQUIP_PRICE,ZADATABASE_TABLE_EQUIP_KEY_PLAN_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE];
         
         FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
         while ([resultSet next])
         {
             CBGListModel *location = [self listModelFromDatabaseResult:resultSet];
//             location.equip_status = 4;
             [totalArray addObject:location];
         }
         
         [resultSet close];
         [fmdatabase close];
         
     }];
    return totalArray;
}
-(NSArray *)localSaveEquipHistoryModelListTotalWithPlanFail
{
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         NSMutableString *sqlMutableString=[NSMutableString string];
         //是某分类的
         //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
         
         [sqlMutableString appendFormat:@"select * from %@ where %@ = 0 or %@ = 1 ORDER BY %@ DESC;",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_PLAN_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_EQUIP_ERRORED,ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE];
         
         FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
         while ([resultSet next])
         {
             CBGListModel *location = [self listModelFromDatabaseResult:resultSet];
//             location.equip_status = 4;
             [totalArray addObject:location];
         }
         
         [resultSet close];
         [fmdatabase close];
         
     }];
    return totalArray;
}
-(NSArray *)localSaveEquipHistoryModelListTotalWithNameErrored
{
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         NSMutableString *sqlMutableString=[NSMutableString string];
         //是某分类的
         //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
         
         [sqlMutableString appendFormat:@"select * from %@ where %@ LIKE '\\u%%' ORDER BY %@ DESC;",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_EQUIP_NAME,ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE];
         
         FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
         while ([resultSet next])
         {
             CBGListModel *location = [self listModelFromDatabaseResult:resultSet];
             //             location.equip_status = 4;
             [totalArray addObject:location];
         }
         
         [resultSet close];
         [fmdatabase close];
         
     }];
    return totalArray;

}
-(NSArray *)privateLocalSaveEquipHistroyPreModelForOrderSN:(NSString *)orderId withDataBase:(FMDatabase *)fmdatabase
{
    NSMutableArray * totalArray = [NSMutableArray array];
    NSMutableString *sqlMutableString=[NSMutableString string];
    //是某分类的
    //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
    
    [sqlMutableString appendFormat:@"select * from %@ where %@ = '%@' ORDER BY %@ DESC;",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_ORDER_SN,orderId,ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE];
    
    FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
    while ([resultSet next])
    {
        CBGListModel *location = [self listModelFromDatabaseResult:resultSet];
//        location.equip_status = 4;
        [totalArray addObject:location];
    }
    [resultSet close];
    return totalArray;
}
-(NSArray *)localSaveEquipHistoryModelListForOrderSN:(NSString *)ordersn
{
    if(!ordersn) return nil;
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         
         NSArray * array = [self privateLocalSaveEquipHistroyPreModelForOrderSN:ordersn withDataBase:fmdatabase];
         [totalArray addObjectsFromArray:array];
         
         [fmdatabase close];
         
     }];
    return totalArray;
}
-(NSArray *)localSaveEquipHistoryModelListForTime:(NSString *)time
{
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
    {
        if (!fmdatabase.open) {
            [fmdatabase open];
        }
        NSMutableString *sqlMutableString=[NSMutableString string];
        //是某分类的
        //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];

        //仅上架
        [sqlMutableString appendFormat:@"select * from %@ where %@ like'%@%%' ORDER BY %@ DESC;",ZADATABASE_TABLE_EQUIP_TOTAL,
         ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE,
         time,
         ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE];

        
        //今日上架 或售出 取回
//        [sqlMutableString appendFormat:@"select * from %@ where %@ like'%@%%' or %@ like '%@%%' or %@ like '%@%%' ORDER BY %@ DESC;",ZADATABASE_TABLE_EQUIP_TOTAL,
//         ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE,
//         time,
//         ZADATABASE_TABLE_EQUIP_KEY_SELL_SOLD,
//         time,
//         ZADATABASE_TABLE_EQUIP_KEY_SELL_BACK,
//         time,
//         ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE];
        
        FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
        while ([resultSet next])
        {
            CBGListModel *location = [self listModelFromDatabaseResult:resultSet];
//            location.equip_status = 4;
            [totalArray addObject:location];
        }
        

        [resultSet close];
        [fmdatabase close];
        
    }];
    return totalArray;
    return nil;
}
-(NSArray *)localSaveEquipHistoryModelListForRoleId:(NSString *)roleId
{
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         NSMutableString *sqlMutableString=[NSMutableString string];
         
         [sqlMutableString appendFormat:@"select * from %@ where %@ = '%@' ORDER BY %@;",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_ROLE_ID,roleId,ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE];
         
         FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
         while ([resultSet next])
         {
             CBGListModel *location = [self listModelFromDatabaseResult:resultSet];
//             location.equip_status = 4;
             [totalArray addObject:location];
         }
         
         [resultSet close];
         [fmdatabase close];
         
     }];
    return totalArray;
    return nil;
}
-(NSArray *)localSaveEquipHistoryModelListForSchoolId:(NSString *)school{
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         NSMutableString *sqlMutableString=[NSMutableString string];
         
         [sqlMutableString appendFormat:@"select * from %@ where %@ = %@ AND %@ =='' AND %@ == '' ORDER BY %@;",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_EQUIP_SCHOOL,school,ZADATABASE_TABLE_EQUIP_KEY_SELL_SOLD,ZADATABASE_TABLE_EQUIP_KEY_SELL_BACK,ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE];
         
         FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
         while ([resultSet next])
         {
             CBGListModel *location = [self listModelFromDatabaseResult:resultSet];
//             location.equip_status = 4;
             [totalArray addObject:location];
         }
         
         [resultSet close];
         [fmdatabase close];
         
     }];
    return totalArray;
}
-(NSArray *)localSaveEquipHistoryModelListForServerId:(NSString *)server andSchool:(NSString *)school
{
    if(!server && !school)
    {
        return nil;
    }
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         NSMutableString *sqlMutableString=[NSMutableString string];
         //是某分类的
         
         //全部相关记录，不再区分是否售出
         //两者均存在
         if(server && school)
         {
              [sqlMutableString appendFormat:@"select * from %@ where %@ = %@ AND %@ = %@ ORDER BY %@;",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_SERVER_ID,server,ZADATABASE_TABLE_EQUIP_KEY_EQUIP_SCHOOL,school,ZADATABASE_TABLE_EQUIP_KEY_EQUIP_START_PRICE];
         }else if(!server)
         {
             [sqlMutableString appendFormat:@"select * from %@ where %@ = %@ ORDER BY %@;",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_EQUIP_SCHOOL,school,ZADATABASE_TABLE_EQUIP_KEY_EQUIP_START_PRICE];

         }else
         {
             [sqlMutableString appendFormat:@"select * from %@ where %@ = %@  ORDER BY %@;",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_SERVER_ID,server,ZADATABASE_TABLE_EQUIP_KEY_EQUIP_START_PRICE];
         }
         
         FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
         while ([resultSet next])
         {
             CBGListModel *location = [self listModelFromDatabaseResult:resultSet];
//             location.equip_status = 4;
             [totalArray addObject:location];
         }
         
//         //未售出
//         sqlMutableString=[NSMutableString string];
//         if(server && school)
//         {
//             [sqlMutableString appendFormat:@"select * from %@ where %@ = %@ AND %@ = %@ ORDER BY %@ limit 3;",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_SERVER_ID,server,ZADATABASE_TABLE_EQUIP_KEY_EQUIP_SCHOOL,school,ZADATABASE_TABLE_EQUIP_KEY_EQUIP_START_PRICE];
//         }else if(!server)
//         {
//             [sqlMutableString appendFormat:@"select * from %@ where %@ = %@ ORDER BY %@ limit 3;",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_EQUIP_SCHOOL,school,ZADATABASE_TABLE_EQUIP_KEY_EQUIP_START_PRICE];
//             
//         }else
//         {
//             [sqlMutableString appendFormat:@"select * from %@ where %@ = %@ ORDER BY %@ limit 3;",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_SERVER_ID,server,ZADATABASE_TABLE_EQUIP_KEY_EQUIP_START_PRICE];
//         }
//         
//         resultSet=[fmdatabase executeQuery:sqlMutableString];
//         while ([resultSet next])
//         {
//             CBGListModel *location = [self listModelFromDatabaseResult:resultSet];
//             location.equip_status = 4;
//             [totalArray addObject:location];
//         }

         
         [resultSet close];
         [fmdatabase close];
         
     }];
    return totalArray;
    return nil;
}
-(NSArray *)localSaveEquipHistoryModelListForCompareCBGModel:(CBGListModel *)model
{
    //两处价格均为0 ，标识 无可用比对价格，无售价也无估价
    NSInteger price = model.plan_total_price;
    if(price == 0) {
        price = model.equip_price;
    }
    if(price == 0) return nil;
    NSInteger comparePrice =    model.plan_xiulian_price +
                                model.plan_chongxiu_price +
                                model.plan_jineng_price +
                                model.plan_jingyan_price +
                                model.plan_qianyuandan_price +
                                model.plan_qiannengguo_price +
                                model.plan_menpai_price;
    
    NSInteger school = model.equip_school;
    NSInteger equipPrice = model.equip_price ;
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSInteger minServerId = total.minServerId;
    
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         FMResultSet *resultSet = nil;
         NSMutableString *sqlMutableString=[NSMutableString string];
         //是某分类的
         //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
         
         //查询估价大于比较model  已售出 未售出  最低价   同区  同门派
         //查询同门派 估价大于比较model (非特殊区) 已售出 未售出  最低价
         //(估价为0 价格为0 不计算)
         
//         NSInteger rolePrice = model.plan_jineng_price + model.plan_jingyan_price + model.plan_xiulian_price + model.plan_xiulian_price + model.plan_chongxiu_price;
         
         //判定是否存在，估价更好，价格更低的账号
         //估价大于比较model  同门派  已售出  最低价  plan_rate  0-100
         
         //每项均大
//         [sqlMutableString appendFormat:@"select * from %@ where %@ != '' AND %@ = %ld AND %@ == 0  AND %@ != 0 AND %@ != 45 AND %@ > 0 AND %@ < 100 AND %@ >= %ld AND %@ >= %ld AND %@ >= %ld AND %@ >= %ld AND %@ >= %ld AND %@ < %ld ORDER BY %@",ZADATABASE_TABLE_EQUIP_TOTAL,
//          ZADATABASE_TABLE_EQUIP_KEY_SELL_SOLD,
//          ZADATABASE_TABLE_EQUIP_KEY_EQUIP_SCHOOL,
//          school,
//          ZADATABASE_TABLE_EQUIP_KEY_FAV_OR_INGORE,
//          ZADATABASE_TABLE_EQUIP_KEY_EQUIP_PRICE,
//          ZADATABASE_TABLE_EQUIP_KEY_SERVER_ID,
//          ZADATABASE_TABLE_EQUIP_KEY_PLAN_RATE,
//          ZADATABASE_TABLE_EQUIP_KEY_PLAN_RATE,
//          ZADATABASE_TABLE_EQUIP_KEY_PLAN_XIULIAN,
//          model.plan_xiulian_price,
//          ZADATABASE_TABLE_EQUIP_KEY_PLAN_CHONGXIU,
//          model.plan_chongxiu_price,
//          ZADATABASE_TABLE_EQUIP_KEY_PLAN_JINENG,
//          model.plan_jineng_price,
//          ZADATABASE_TABLE_EQUIP_KEY_PLAN_JINGYAN,
//          model.plan_qianyuandan_price,
//          ZADATABASE_TABLE_EQUIP_KEY_PLAN_QIANYUANDAN,
//          comparePrice,
//          ZADATABASE_TABLE_EQUIP_KEY_EQUIP_PRICE,
//          equipPrice,
//          ZADATABASE_TABLE_EQUIP_KEY_EQUIP_PRICE];
//         
//         FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
//         while ([resultSet next])
//         {
//             //(价格要低于当前价格的)
//             CBGListModel *location = [self listModelFromDatabaseResult:resultSet];
//             location.equip_status = 4;
//             //             if(equipPrice > location.equip_price || equipPrice == 0)
//             {
//                 [totalArray addObject:location];
//             }
//         }

         
         //总值较大，且未售出
         sqlMutableString  = [NSMutableString string];
         [sqlMutableString appendFormat:@"select * from %@ where %@ = %ld AND %@ == 0  AND %@ != 0 AND %@ != 45 AND %@ < 100 AND %@ + %@ + %@ + %@ + %@  + %@  + %@ >= %ld AND %@ <= %ld ORDER BY %@",ZADATABASE_TABLE_EQUIP_TOTAL,
          ZADATABASE_TABLE_EQUIP_KEY_EQUIP_SCHOOL,
          school,
          ZADATABASE_TABLE_EQUIP_KEY_FAV_OR_INGORE,
          ZADATABASE_TABLE_EQUIP_KEY_EQUIP_PRICE,
          ZADATABASE_TABLE_EQUIP_KEY_SERVER_ID,
          ZADATABASE_TABLE_EQUIP_KEY_PLAN_RATE,
          ZADATABASE_TABLE_EQUIP_KEY_PLAN_XIULIAN,
          ZADATABASE_TABLE_EQUIP_KEY_PLAN_CHONGXIU,
          ZADATABASE_TABLE_EQUIP_KEY_PLAN_JINENG,
          ZADATABASE_TABLE_EQUIP_KEY_PLAN_JINGYAN,
          ZADATABASE_TABLE_EQUIP_KEY_PLAN_QIANYUANDAN,
          ZADATABASE_TABLE_EQUIP_KEY_PLAN_QIANNENGGUO,
          ZADATABASE_TABLE_EQUIP_KEY_PLAN_MENPAI,
          comparePrice,
          ZADATABASE_TABLE_EQUIP_KEY_SERVER_ID,
          minServerId,
          ZADATABASE_TABLE_EQUIP_KEY_EQUIP_PRICE];

         resultSet=[fmdatabase executeQuery:sqlMutableString];
         while ([resultSet next])
         {
             //(价格要低于当前价格的)
             CBGListModel *location = [self listModelFromDatabaseResult:resultSet];
//             location.equip_status = 4;
//             if(equipPrice > location.equip_price || equipPrice == 0)
             {
                 [totalArray addObject:location];
             }
         }
         
         //无相关更低价售出数据，取未售出数据
//         if([totalArray count] == 0)
//         {
//             //比当前号便宜售价便宜，但价格高的是否有卖出
//             //未售出的数据,未售出 未取回，价格不为0 估价大于当前估价，认为低价的号全都会售出状态，不判定
//             sqlMutableString  = [NSMutableString string];
//             [sqlMutableString appendFormat:@"select * from %@ where %@ = %ld AND %@ == 0  AND %@ != 0 AND %@ != 45 AND %@ > 0 AND %@ < 100 AND %@ + %@ + %@ + %@ + %@ >= %ld AND %@ <= %ld And %@ < %ld ORDER BY %@",ZADATABASE_TABLE_EQUIP_TOTAL,
//              ZADATABASE_TABLE_EQUIP_KEY_EQUIP_SCHOOL,
//              school,
//              ZADATABASE_TABLE_EQUIP_KEY_FAV_OR_INGORE,
//              ZADATABASE_TABLE_EQUIP_KEY_EQUIP_PRICE,
//              ZADATABASE_TABLE_EQUIP_KEY_SERVER_ID,
//              ZADATABASE_TABLE_EQUIP_KEY_PLAN_RATE,
//              ZADATABASE_TABLE_EQUIP_KEY_PLAN_RATE,
//              ZADATABASE_TABLE_EQUIP_KEY_PLAN_XIULIAN,
//              ZADATABASE_TABLE_EQUIP_KEY_PLAN_CHONGXIU,
//              ZADATABASE_TABLE_EQUIP_KEY_PLAN_JINENG,
//              ZADATABASE_TABLE_EQUIP_KEY_PLAN_JINGYAN,
//              ZADATABASE_TABLE_EQUIP_KEY_PLAN_QIANYUANDAN,
//              comparePrice,
//              ZADATABASE_TABLE_EQUIP_KEY_EQUIP_PRICE,
//              equipPrice,
//              ZADATABASE_TABLE_EQUIP_KEY_SERVER_ID,
//              minServerId,
//              ZADATABASE_TABLE_EQUIP_KEY_EQUIP_PRICE];;
//             
//             resultSet=[fmdatabase executeQuery:sqlMutableString];
//             while ([resultSet next])
//             {
//                 CBGListModel *location = [self listModelFromDatabaseResult:resultSet];
//                 location.equip_status = 4;
//                 [totalArray addObject:location];
//             }
//
//         }
         
         [resultSet close];
         [fmdatabase close];
     }];
    return totalArray;
}
-(void)updateFavAndIngoreStateForMaxedPlanRateListAndClearChange
{
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         
         FMResultSet *resultSet = nil;
         NSMutableString *sqlMutableString=[NSMutableString string];
         
         [sqlMutableString appendFormat:@"update %@ set %@ = 1 WHERE %@ > 30",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_FAV_OR_INGORE,ZADATABASE_TABLE_EQUIP_KEY_PLAN_RATE];
         
         resultSet=[fmdatabase executeQuery:sqlMutableString];
         while ([resultSet next])
         {
         }
         
         sqlMutableString=[NSMutableString string];
         [sqlMutableString appendFormat:@"delete from %@",ZADATABASE_TABLE_EQUIP_CHANGE];
         resultSet=[fmdatabase executeQuery:sqlMutableString];
         while ([resultSet next])
         {
             
         }
         
         sqlMutableString=[NSMutableString string];
         [sqlMutableString appendFormat:@"delete from %@ where %@ < 173",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_EQUIP_LEVEL];
         resultSet=[fmdatabase executeQuery:sqlMutableString];
         while ([resultSet next])
         {
             
         }
         
         
         [resultSet close];
         [fmdatabase close];
         
     }];
}
-(NSArray *)localSaveEquipHistoryModelListRepeatSoldTimesMore:(BOOL)more
{
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSInteger minServerId = total.minServerId;
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         
         
         NSMutableString *sqlMutableString=[NSMutableString string];
         //是某分类的
         //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
         //         [sqlMutableString appendString:@"select * from ZADATABASE_TABLE_EQUIP_TOTAL where EQUIP_PRICE < 100000"];
         
         NSString * minNum = @"1";
         if(more)
         {
             minNum = @"2";
         }
         
         [sqlMutableString appendFormat:@"select * from %@ where %@ in (select %@ from %@ where %@ == '' and %@ < %ld group by %@ having count(%@) > %@) order by  %@ , %@",ZADATABASE_TABLE_EQUIP_TOTAL,
          ZADATABASE_TABLE_EQUIP_KEY_ROLE_ID,
          ZADATABASE_TABLE_EQUIP_KEY_ROLE_ID,
          ZADATABASE_TABLE_EQUIP_TOTAL,
          ZADATABASE_TABLE_EQUIP_KEY_SELL_BACK,
          ZADATABASE_TABLE_EQUIP_KEY_SERVER_ID,
          (long)minServerId,
          ZADATABASE_TABLE_EQUIP_KEY_ROLE_ID,
          ZADATABASE_TABLE_EQUIP_KEY_ROLE_ID,
          minNum,
          ZADATABASE_TABLE_EQUIP_KEY_ROLE_ID,
          ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE];
         
         FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
         while ([resultSet next])
         {
             CBGListModel *location = [self listModelFromDatabaseResult:resultSet];
//             location.equip_status = 4;
             [totalArray addObject:location];
         }
         
         [resultSet close];
         [fmdatabase close];
         
     }];
    return totalArray;
}
-(NSArray *)localSaveEquipHistoryModelListOwnerList
{
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         NSMutableString *sqlMutableString=[NSMutableString string];
         //是某分类的
         //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
         [sqlMutableString appendFormat:@"select * from %@ where %@ = 1 ORDER BY %@;",ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_EQUIP_OWNERBUY,ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE];;
         
         FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
         while ([resultSet next])
         {
             CBGListModel *location = [self listModelFromDatabaseResult:resultSet];
//             location.equip_status = 4;
             [totalArray addObject:location];
         }
         
         [resultSet close];
         [fmdatabase close];
         
     }];
    return totalArray;
}
-(void)refreshLocalSaveEquipHistoryModelServerId:(NSString *)preId withLatest:(NSString *)latestId
{
    if([preId integerValue] > 0 && [latestId integerValue] > 0)
    {
        [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
         {
             if (!fmdatabase.open) {
                 [fmdatabase open];
             }
             
             FMResultSet *resultSet = nil;
             NSMutableString *sqlMutableString=[NSMutableString string];
             
             [sqlMutableString appendFormat:@"update %@ set %@ = %@ WHERE %@ = %@",ZADATABASE_TABLE_EQUIP_TOTAL,
              ZADATABASE_TABLE_EQUIP_KEY_SERVER_ID,
              latestId,
              ZADATABASE_TABLE_EQUIP_KEY_SERVER_ID,
              preId];
             
             resultSet=[fmdatabase executeQuery:sqlMutableString];
             while ([resultSet next])
             {
             }
             
             [resultSet close];
             [fmdatabase close];
             
         }];
    }
}

-(NSArray *)localSaveEquipServerMaxEquipIdAndServerIdList
{
//    NSMutableArray * txtArr = [NSMutableArray array];
//    ZWServerEquipModel * eve1 = [[ZWServerEquipModel alloc] init];
//    eve1.equipId = 2284251;
//    eve1.serverId = 33;
//    [txtArr addObject:eve1];
////
////    ZWServerEquipModel * eve2 = [[ZWServerEquipModel alloc] init];
////    eve2.equipId = 1499977;
////    eve2.serverId = 11;
////    [txtArr addObject:eve2];
//
////  http://xyq.cbg.163.com/cgi-bin/equipquery.py?act=buy_show_equip_info&equip_id=1079107&server_id=60&from=game
//
//
////    ZWServerEquipModel * eve = [[ZWServerEquipModel alloc] init];
////    eve.equipId = 1079107;
////    eve.serverId = 60;
////    [txtArr addObject:eve];
//    
//    return txtArr;
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSInteger maxNum = total.minServerId;
    
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         NSMutableString *sqlMutableString=[NSMutableString string];
         
         [sqlMutableString appendFormat:@"select max(%@) as %@, %@ from %@  group by %@",ZADATABASE_TABLE_EQUIP_KEY_EQUIP_ID,ZADATABASE_TABLE_EQUIP_KEY_EQUIP_ID,ZADATABASE_TABLE_EQUIP_KEY_SERVER_ID,ZADATABASE_TABLE_EQUIP_TOTAL,ZADATABASE_TABLE_EQUIP_KEY_SERVER_ID];
         
         FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
         while ([resultSet next])
         {
             NSInteger equipId = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_EQUIP_ID];
             NSInteger serverId = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_SERVER_ID];
             
//             NSDictionary * maxDic = @{@"equipid":[NSNumber numberWithInteger:equipId],
//                                       @"serverid":[NSNumber numberWithInteger:serverId]};
             if(serverId != 45 && serverId != 0 && serverId < maxNum)
             {
                 ZWServerEquipModel * eve = [[ZWServerEquipModel alloc] init];
                 eve.equipId = equipId + 1;
                 eve.serverId = serverId;
                 
                 [totalArray addObject:eve];
             }
         }
         
         [resultSet close];
         [fmdatabase close];
         
     }];
    
    return totalArray;
}

-(CBGListModel *)listModelFromDatabaseResult:(FMResultSet *)resultSet
{
    CBGListModel * list = [[CBGListModel alloc] init];
    
    list.game_ordersn = [resultSet stringForColumn:ZADATABASE_TABLE_EQUIP_KEY_ORDER_SN];
    list.owner_roleid = [resultSet stringForColumn:ZADATABASE_TABLE_EQUIP_KEY_ROLE_ID];
    list.server_id = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_SERVER_ID];
    list.equip_id = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_EQUIP_ID];
    
    list.equip_status = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_EQUIP_STATUS];
    list.equip_school =     [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_EQUIP_SCHOOL];
    list.equip_price_common =     [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_COMMON_PRICE];
    list.appointed =     [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_EQUIP_APPOINTED];
    list.errored =     [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_EQUIP_ERRORED];
    list.ingore =     [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_EQUIP_INGORE];
    list.ownerBuy =     [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_EQUIP_OWNERBUY];
    list.bargainBuy =     [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_EQUIP_BARGAINBUY];
    
    list.equip_type = [resultSet stringForColumn:ZADATABASE_TABLE_EQUIP_KEY_EQUIP_TYPE];
    list.kindid =     [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_EQUIP_KINDID];
    list.server_check =     [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_EQUIP_SERVERCHECK];

    list.equip_level =      [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_EQUIP_LEVEL];
    list.equip_name =       [resultSet stringForColumn:ZADATABASE_TABLE_EQUIP_KEY_EQUIP_NAME];
    list.equip_price =      [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_EQUIP_PRICE];
    list.equip_accept =     [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_EQUIP_ACCEPT];
    list.equip_start_price = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_EQUIP_START_PRICE];
    list.equip_eval_price = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_EQUIP_EVAL_PRICE];
    list.equip_more_append = [resultSet stringForColumn:ZADATABASE_TABLE_EQUIP_KEY_EQUIP_MORE_DETAIL];
    [list readDataFromMoreAppendString];
    
    list.plan_total_price = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_PLAN_TOTAL];
    list.plan_xiulian_price = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_PLAN_XIULIAN];
    list.plan_chongxiu_price = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_PLAN_CHONGXIU];
    list.plan_jineng_price = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_PLAN_JINENG];
    list.plan_jingyan_price = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_PLAN_JINGYAN];
    list.plan_qiannengguo_price = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_PLAN_QIANNENGGUO];
    list.plan_qianyuandan_price = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_PLAN_QIANYUANDAN];
    list.plan_dengji_price = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_PLAN_DENGJI];
    list.plan_jiyuan_price = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_PLAN_JIYUAN];
    list.plan_menpai_price = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_PLAN_MENPAI];
    list.plan_fangwu_price = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_PLAN_FANGWU];
    list.plan_xianjin_price = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_PLAN_XIANJIN];
    list.plan_haizi_price = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_PLAN_HAIZI];
    list.plan_xiangrui_price = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_PLAN_XIANGRUI];
    list.plan_zuoji_price = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_PLAN_ZUOJI];
    list.plan_fabao_price = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_PLAN_FABAO];
    list.plan_zhaohuanshou_price = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_PLAN_ZHAOHUAN];
    list.plan_zhuangbei_price = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_PLAN_ZHUANGBEI];
    list.plan_des = [resultSet stringForColumn:ZADATABASE_TABLE_EQUIP_KEY_PLAN_DES];
    list.plan_rate = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_PLAN_RATE];

    list.sell_create_time = [resultSet stringForColumn:ZADATABASE_TABLE_EQUIP_KEY_SELL_CREATE];
    list.sell_start_time = [resultSet stringForColumn:ZADATABASE_TABLE_EQUIP_KEY_SELL_START];
    list.sell_sold_time = [resultSet stringForColumn:ZADATABASE_TABLE_EQUIP_KEY_SELL_SOLD];
    list.sell_back_time = [resultSet stringForColumn:ZADATABASE_TABLE_EQUIP_KEY_SELL_BACK];
    list.sell_order_time = [resultSet stringForColumn:ZADATABASE_TABLE_EQUIP_KEY_SELL_ORDER];
    list.sell_cancel_time = [resultSet stringForColumn:ZADATABASE_TABLE_EQUIP_KEY_SELL_CANCEL];
    list.sell_space = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_SELL_SPACE];

    list.fav_or_ingore = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_FAV_OR_INGORE];
    list.equip_status = [resultSet intForColumn:ZADATABASE_TABLE_EQUIP_KEY_EQUIP_STATUS];
    
    if(!list.equip_more_append || [list.equip_more_append length] == 0)
    {
        list.equip_more_append = @"";
    }
    
    return list;
}
-(NSArray *)localServerNameAndIDTotalDictionaryArray
{
    NSMutableArray *totalArray=[NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         NSMutableString *sqlMutableString=[NSMutableString string];
         
         [sqlMutableString appendFormat:@"select * from %@ ORDER BY %@ DESC;",ZADATABASE_TABLE_EQUIP_SERVER,ZADATABASE_TABLE_EQUIP_KEY_SERVER_ID];
         
         FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
         while ([resultSet next])
         {
             NSString * name  = [resultSet stringForColumn:ZADATABASE_TABLE_SERVER_KEY_NAME];
             NSNumber * idNum  = [NSNumber numberWithInt:[resultSet intForColumn:ZADATABASE_TABLE_SERVER_KEY_ID]];
             NSNumber * tagNum = [NSNumber numberWithInt:[resultSet intForColumn:ZADATABASE_TABLE_SERVER_KEY_TEST]];
             
             NSDictionary * serverDic = @{ZADATABASE_TABLE_SERVER_KEY_NAME:name,
                                          ZADATABASE_TABLE_SERVER_KEY_ID:idNum,
                                          ZADATABASE_TABLE_SERVER_KEY_TEST:tagNum};
             [totalArray addObject:serverDic];
         }
         
         [resultSet close];
         [fmdatabase close];
         
     }];
    return totalArray;
    
}


-(void)localSaveServerNameAndIDDictionaryArray:(NSArray *)objArray
{
    [databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback)
     {
         if (!db.open)
         {
             [db open];
         }
         //NSLog(@"%s %ld",__FUNCTION__,[objArray count]);
         BOOL result = YES;
         for (int i = 0; i < [objArray count]; i++)
         {
             NSDictionary *  dataObj = [objArray objectAtIndex:i];
             NSString * name = [dataObj objectForKey:ZADATABASE_TABLE_SERVER_KEY_NAME];
             NSNumber * idNum = [dataObj objectForKey:ZADATABASE_TABLE_SERVER_KEY_ID];
             NSNumber * tag = [dataObj objectForKey:ZADATABASE_TABLE_SERVER_KEY_TEST];
             
             result = [self privateLocalSaveAndCheckWithServerName:name
                                                       andServerID:[idNum integerValue]
                                                           TestTag:[tag integerValue]
                                                    withFmDataBase:db];
             if (!result)
             {
                 NSLog(@"%s break",__FUNCTION__);
                 *rollback = YES;
                 break;
             }
         }
         
         [db close];
     }];

}
-(BOOL)privateLocalSaveAndCheckWithServerName:(NSString *)name andServerID:(NSInteger)serverId TestTag:(NSInteger)tag withFmDataBase:(FMDatabase *)fmdatabase
{
    BOOL success = NO;
    BOOL isAlreadyIn = NO;
    NSString *sqlGetArticle=[NSString stringWithFormat:@"select * from %@ where %@ = '%ld';",ZADATABASE_TABLE_EQUIP_SERVER,ZADATABASE_TABLE_SERVER_KEY_ID,serverId];
    FMResultSet *resultSet=[fmdatabase executeQuery:sqlGetArticle];
    if(([resultSet next]))
    {
        isAlreadyIn = YES;
    }

    NSString * sqlString = nil;
    if(!isAlreadyIn)
    {
        NSString * timeKey = [NSString stringWithFormat:@"%@%@",[NSDate unixDate],name];
        sqlString=[NSString stringWithFormat:@"insert into %@ values(?,?,?,?);",ZADATABASE_TABLE_EQUIP_SERVER];

        NSArray *sqlarray=[NSArray arrayWithObjects:
                           timeKey,
                           name,
                           [NSNumber numberWithInteger:serverId],
                           [NSNumber numberWithInteger:tag],
                            nil];
        success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
    }else
    {
        NSString * timeKey = [NSString stringWithFormat:@"%@%@",[NSDate unixDate],name];
        sqlString=[NSString stringWithFormat:@"update %@ set %@=? , %@=? , %@=? where %@=?;",ZADATABASE_TABLE_EQUIP_SERVER,ZADATABASE_TABLE_SERVER_KEY_NAME,ZADATABASE_TABLE_SERVER_KEY_TIME,ZADATABASE_TABLE_SERVER_KEY_TEST,ZADATABASE_TABLE_SERVER_KEY_ID,nil];
        
        NSArray *sqlarray=[NSArray arrayWithObjects:name,timeKey,[NSNumber numberWithInteger:tag],[NSNumber numberWithInteger:serverId],nil];
        success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
    }
    
    return success;
}

-(void)localSaveServerName:(NSString *)name withServerID:(NSInteger)serverId{
    //库表存储，库表存储前先进行判定
    __block BOOL success = NO;
    __block BOOL firstSave = YES;
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase) {
        if (!fmdatabase.open) {
            [fmdatabase open];
        }
        
        BOOL isAlreadyIn = NO;
        
        NSString *sqlGetArticle=[NSString stringWithFormat:@"select * from %@ where %@ = %ld;",ZADATABASE_TABLE_EQUIP_SERVER,ZADATABASE_TABLE_SERVER_KEY_ID,serverId];
        FMResultSet *resultSet=[fmdatabase executeQuery:sqlGetArticle];
        if([resultSet next])
        {
            isAlreadyIn = YES;
        }
        
    }];
    
    
}




@end
