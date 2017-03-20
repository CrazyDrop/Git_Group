//
//  ZAContactListController+DataRequest.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/8.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZAContactListController.h"

//完成数据请求相关处理
//列表数据请求，删除数据请求，通知他请求
@interface ZAContactListController (DataRequest)


//列表请求
-(void)requestForContactList;

//通知他调用时请求
-(void)startContactTelllRequestWithContactId:(NSString *)idStr;

//删除用户时的请求
-(void)deleteContactWithCurrentContactId:(NSString *)contactId;


@end
