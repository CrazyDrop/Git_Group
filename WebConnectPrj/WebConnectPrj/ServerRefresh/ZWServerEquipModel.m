//
//  ZWServerEquipModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/7/31.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWServerEquipModel.h"

@implementation ZWServerEquipModel

-(NSString *)description
{
    NSMutableString * edit = [NSMutableString string];
    [edit appendFormat:@"serverid %ld  equipId %ld",self.serverId,self.equipId];
    if(self.equipDesc){
        [edit appendString:@"des"];
    }
    return edit;
}

@end
