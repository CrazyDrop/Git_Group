//
//  CBGCopyUrlDetailCehckVC.h
//  WebConnectPrj
//
//  Created by Apple on 17/3/27.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "DPWhiteTopController.h"
#import "CBGListModel.h"

typedef enum : NSUInteger
{
    CBGDetailTestURLFunctionStyle_None = 0,
    CBGDetailTestURLFunctionStyle_CheckDetail,
    CBGDetailTestURLFunctionStyle_WebShow,
    CBGDetailTestURLFunctionStyle_LocalSave,
    CBGDetailTestURLFunctionStyle_LocalRemove,
    CBGDetailTestURLFunctionStyle_NoticeAdd,
    CBGDetailTestURLFunctionStyle_NoticeRemove,
    CBGDetailTestURLFunctionStyle_StateIngore,
    CBGDetailTestURLFunctionStyle_StateNormal,
    CBGDetailTestURLFunctionStyle_DBClear,
    CBGDetailTestURLFunctionStyle_TotalHistory,
    CBGDetailTestURLFunctionStyle_NearHistory,
    CBGDetailTestURLFunctionStyle_ServerCombine,
    CBGDetailTestURLFunctionStyle_WebRefresh,
    CBGDetailTestURLFunctionStyle_WebInput,
    CBGDetailTestURLFunctionStyle_ReadRemove,
} CBGDetailTestURLFunctionStyle;

@interface CBGCopyUrlDetailCehckVC : DPWhiteTopController

+(CBGListModel *)listModelBaseDataFromLatestEquipUrlStr:(NSString *)url;

@end
