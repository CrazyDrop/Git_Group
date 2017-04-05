//
//  OLTopicListRequest.m
//  WebConnectPrj
//
//  Created by Apple on 14-11-4.
//  Copyright (c) 2014年 zhangchaoqun. All rights reserved.
//

#import "OLTopicListRequest.h"
#import "OLTopicListDataModel.h"
@implementation OLTopicListRequest
-(id)responseCheckForWebData:(id)data
{
    if (!data)
    {
        return nil;
    }
    NSDictionary * deDic = [data valueForKey:@"de"];
    NSArray * pyArr = [deDic valueForKey:@"py"];
    
    NSMutableArray * array = [NSMutableArray array];
    for (NSDictionary * eveDic in pyArr)
    {
        OLTopicListDataModel * eve = [[OLTopicListDataModel alloc] initWithWebDic:eveDic];
        [array addObject:eve];
    }

    return array;
}
-(id)init
{
    self = [super initWithRequestIdStr:@"20"];
    self.page = 1;
    return self;
}

-(void)setPage:(NSInteger)page
{
    _page = page;
    [self setObject:[NSNumber numberWithLong:page] forKey:@"pm"];
    //增加
    //&se=0&sre=1
    [self setObject:[NSNumber numberWithInt:1] forKey:@"sre"];
    [self setObject:[NSNumber numberWithInt:0] forKey:@"se"];
//    &sjs=BjxNGAkN&sre=1&sud=12427789&ud=12427789&un=c86eqRKd8elrcUFgSEmDgg5xJnhkZn%252F2S9G4WS7DI6VQ%252FxIKtiVTyOnLYBUNOLbaWiHuV5pjSBwT7FgxhtbPbVADCFUJ%252BE7L%252FnI9eofbhPYb8ewXxVySX%252B3HVrm1u9D19xnbfkRyMTojeNEGZyVxaUdEQ24vjUjWHiAITbiXOYuJk6ZJBHFMKNpbGuDcxA3e4UF67LLQcejm3l28vmF6%252FJBIwsA1Tk8H3Dw%252FeUtho6v5frVgY09CAODp9WE
    [self setObject:@"12428402" forKey:@"sud"];
    [self setObject:@"12428402" forKey:@"ud"];
//    [self setObject:@"68A6v6zV" forKey:@"sjs"];
//    [self setObject:@"15adWFA6ZZw%2F8GcpURFWCH8GxazDjnxM%2B%2FaBMAEJO8XrJKeIjaVe99WCztbEj3tCH0jXweDHk7H0o0vliXnVgibrWAqLc7H4glN7AM5IrXe69DVRIxx%2FiS36LzooRYXtL3utxyreeHnK8%2FFim%2FEGrdmYu3MDpaZorz60xgpJFZZzjvFuAB5PRQ00SCL3a%2FfI%2FPxaz9%2Fe866XTxKpeghEKlyUUJrN5R9VEHDlbc3HJWeJUBqdHJiL7UrDwIs" forKey:@"un"];

    
}

@end
