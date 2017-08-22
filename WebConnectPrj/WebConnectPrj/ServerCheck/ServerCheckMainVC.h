//
//  ServerCheckMainVC.h
//  WebConnectPrj
//
//  Created by Apple on 2017/8/21.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "DPWhiteTopController.h"

typedef enum : NSUInteger
{
    CBGServerEquipCheckMainFunctionStyle_None = 0,
    CBGServerEquipCheckMainFunctionStyle_JuSeList,
    CBGServerEquipCheckMainFunctionStyle_EquipList,
    CBGServerEquipCheckMainFunctionStyle_EquipSignal,
} CBGServerEquipCheckMainFunctionStyle;


@interface ServerCheckMainVC : DPWhiteTopController

@end
