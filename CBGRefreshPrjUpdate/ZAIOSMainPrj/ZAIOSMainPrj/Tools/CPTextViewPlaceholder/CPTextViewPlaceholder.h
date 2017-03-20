//
//  CPTextViewPlaceholder.h
//  Cassius Pacheco
//
//  Created by Cassius Pacheco on 30/01/13.
//  Copyright (c) 2013 Cassius Pacheco. All rights reserved.
//

#import <UIKit/UIKit.h>
//由于在使用时，展示placehold时，会出现placehold可选择情况，暂不使用
@interface CPTextViewPlaceholder : UITextView

@property (nonatomic, strong) NSString *placeholder;

-(void)doneTextViewInUse;

@end
