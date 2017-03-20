//
//  ZAIAddDynamicProperty.h
//  ZAInsurance
//
//  Created by Vincent Hu on 15/9/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#ifndef ZAInsurance_ZAIAddDynamicProperty_h
#define ZAInsurance_ZAIAddDynamicProperty_h

#import <objc/runtime.h>

#define ADD_DYNAMIC_PROPERTY(PROPERTY_TYPE, OBJC_ASSOCIATION_TYPE, PROPERTY_NAME, SETTER_NAME) \
@dynamic PROPERTY_NAME ; \
static char kProperty##PROPERTY_NAME; \
- ( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
return ( PROPERTY_TYPE ) objc_getAssociatedObject(self, &(kProperty##PROPERTY_NAME ) ); \
} \
\
- (void) SETTER_NAME :( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
objc_setAssociatedObject(self, &kProperty##PROPERTY_NAME , PROPERTY_NAME , OBJC_ASSOCIATION_TYPE); \
} \

#endif
