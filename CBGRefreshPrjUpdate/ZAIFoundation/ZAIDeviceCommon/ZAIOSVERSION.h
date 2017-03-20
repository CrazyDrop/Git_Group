//
//  ZAIOSVERSION.h
//  ZAFTest
//
//  Created by VincentHu on 15/6/16.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//

#ifndef ZAIOSVERSION_h
#define ZAIOSVERSION_h

#define ADD_DYNAMIC_PROPERTY(PROPERTY_TYPE,PROPERTY_NAME,SETTER_NAME) \
@dynamic PROPERTY_NAME ; \
static char kProperty##PROPERTY_NAME; \
- ( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
return ( PROPERTY_TYPE ) objc_getAssociatedObject(self, &(kProperty##PROPERTY_NAME ) ); \
} \
\
- (void) SETTER_NAME :( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
objc_setAssociatedObject(self, &kProperty##PROPERTY_NAME , PROPERTY_NAME , OBJC_ASSOCIATION_RETAIN); \
} \


#define OSVERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


#define FloatEqual(a,b) (fabs((a) - (b)) < FLT_EPSILON)

#ifndef CLIP
#define CLIP(x, a, b)			{					\
if ((x) < (a))	\
(x) = (a);	\
if ((x) > (b))	\
(x) = (b);	\
}
#endif


#endif
