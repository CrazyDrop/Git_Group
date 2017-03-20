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
#define ZADATABASE_NAME @"zadatabase_total.db" //缓存的数据库名称
#define ZADATABASE_NAME_READ @"zadatabase_part.db" //缓存的数据库名称

#define ZADATABASE_TABLE_LOCATIONS @"ZADATABASE_TABLE_LOCATIONS" //缓存的数据库名称
#define ZADATABASE_TABLE_LOCATIONS_SOLDOUT @"ZADATABASE_TABLE_LOCATIONS_SOLDOUT" //已售出数据库

#define ZADATABASE_TABLE_LOCATIONS_HISTORY @"ZADATABASE_TABLE_LOCATIONS_HISTORY" //缓存的数据库名称
#define ZADATABASE_TABLE_LOCATIONS_SYSTEM_SELL @"ZADATABASE_TABLE_LOCATIONS_SYSTEM_SELL" //系统销售数据


#define ZADATABASE_TABLE_LOCATIONS_KEY_TIME @"ZADATABASE_TABLE_LOCATIONS_KEY_TIME"  //时间
#define ZADATABASE_TABLE_LOCATIONS_KEY_DIC  @"ZADATABASE_TABLE_LOCATIONS_KEY_DIC"   //字典数据
#define ZADATABASE_TABLE_LOCATIONS_KEY_DETAIL @"ZADATABASE_TABLE_LOCATIONS_KEY_DETAIL"  //详情数据
#define ZADATABASE_TABLE_LOCATIONS_KEY_START @"ZADATABASE_TABLE_LOCATIONS_KEY_START"    //创建时间
#define ZADATABASE_TABLE_LOCATIONS_KEY_FAV @"ZADATABASE_TABLE_LOCATIONS_KEY_FAV"        //是否加关注

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
    FMDatabaseQueue * databaseQueue_soldout;
    
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
-(void)localCopySoldOutDataToPartDataBase
{
    NSArray * soldout = [self localSaveEquipArrayForSoldOut];
    
    for (NSInteger index = 0;index < [soldout count]; index ++ )
    {
        Equip_listModel * list = [soldout objectAtIndex:index];
        NSArray * array = list.detaiModel.equipExtra.AllSummon;
        
        for (AllSummonModel * eve in array)
        {
            NSArray * eveArr = eve.summon_core.sumonModelsArray;
            NSMutableArray * refreshArr = [NSMutableArray array];
            if([eveArr count]>0)
            {
                NSArray * subArr = [eveArr firstObject];
                if([subArr isKindOfClass:[NSArray class]])
                {
                    for (NSInteger eveIndex = 0 ;eveIndex < [eveArr count] ;eveIndex ++)
                    {
                        id objArr = [eveArr objectAtIndex:eveIndex];
                        [refreshArr addObjectsFromArray:objArr];
                    }
                }
            }
            
            eve.summon_core.sumonModelsArray = refreshArr;
        }
        
    }
    
    
    NSArray * arr = [self localSaveEquipArrayForSoldOut_database];
    
    [self localSaveSoldOutEquipWithSoldOutDataBaseModelArray:soldout];
    arr = [self localSaveEquipArrayForSoldOut_database];
    
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
        }
        NSString *databasePath=[path stringByAppendingPathComponent:ZADATABASE_NAME];
        databaseQueue= [[FMDatabaseQueue alloc]initWithPath:databasePath];
        
//        path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        
        databasePath=[path stringByAppendingPathComponent:ZADATABASE_NAME_READ];
        databaseQueue_soldout= [[FMDatabaseQueue alloc]initWithPath:databasePath];

        
        [self checkLocalTables];
    }
    return self;
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
         
         //缓存列表
        if(![fmdatabase tableExists:ZADATABASE_TABLE_LOCATIONS])
        {
            NSString *createSql=[NSString stringWithFormat:@"create table %@(%@ text primary key,%@ text,%@ text,%@ text,%@ text);",ZADATABASE_TABLE_LOCATIONS,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS_KEY_DIC,ZADATABASE_TABLE_LOCATIONS_KEY_DETAIL,ZADATABASE_TABLE_LOCATIONS_KEY_START,ZADATABASE_TABLE_LOCATIONS_KEY_FAV];
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
         //已售出列表
         if(![fmdatabase tableExists:ZADATABASE_TABLE_LOCATIONS_SOLDOUT])
         {
             NSString *createSql=[NSString stringWithFormat:@"create table %@(%@ text primary key,%@ text,%@ text,%@ text,%@ text);",ZADATABASE_TABLE_LOCATIONS_SOLDOUT,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS_KEY_DIC,ZADATABASE_TABLE_LOCATIONS_KEY_DETAIL,ZADATABASE_TABLE_LOCATIONS_KEY_START,ZADATABASE_TABLE_LOCATIONS_KEY_FAV];
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
         if(![fmdatabase tableExists:ZADATABASE_TABLE_LOCATIONS_HISTORY])
         {
             NSString *createSql=[NSString stringWithFormat:@"create table %@(%@ text primary key,%@ text);",ZADATABASE_TABLE_LOCATIONS_HISTORY,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS_KEY_DIC];
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
         if(![fmdatabase tableExists:ZADATABASE_TABLE_LOCATIONS_SYSTEM_SELL])
         {
             NSString *createSql=[NSString stringWithFormat:@"create table %@(%@ text primary key,%@ text);",ZADATABASE_TABLE_LOCATIONS_SYSTEM_SELL,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS_KEY_DIC];
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
    [databaseQueue_soldout inTransaction:^(FMDatabase *db, BOOL *rollback)
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
    [databaseQueue_soldout inDatabase:^(FMDatabase *fmdatabase){
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
    
    EquipModel * detail = model.detaiModel;
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
        backModel.detaiModel = model;
    }else{
        NSData * data = [[NSData alloc] initWithBase64Encoding:valueStr];
        EquipModel * model = [EquipModel objectWithContentsOfData:data];
//        NSDictionary * dic = [model dictionaryRepresentation];
//        model = [EquipModel ac_objectWithAny:dic];
        
        backModel.detaiModel = model;
    }
    
    
    backModel.favTag = [resultSet stringForColumn:ZADATABASE_TABLE_LOCATIONS_KEY_FAV];
    backModel.createTime = [resultSet stringForColumn:ZADATABASE_TABLE_LOCATIONS_KEY_START];
    
    
    return backModel;
}



@end
