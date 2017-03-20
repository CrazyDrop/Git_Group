//
//  LYTextAttachment.m
//  ViewControllerTest
//
//  Created by 李言 on 14-8-21.
//  Copyright (c) 2014年 ___李言___. All rights reserved.
//

#import "LYTextAttachment.h"

@implementation LYTextAttachment
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex NS_AVAILABLE_IOS(7_0)
{
    return CGRectMake( 0 , -3 , lineFrag.size.height , lineFrag.size.height );
}
@end
