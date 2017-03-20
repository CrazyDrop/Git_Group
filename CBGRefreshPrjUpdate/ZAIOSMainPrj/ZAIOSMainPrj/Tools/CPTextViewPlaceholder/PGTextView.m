//
//  PGTextView.m
//  photographer
//
//  Created by zhangchaoqun on 15/4/24.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import "PGTextView.h"
@interface PGTextView()
{
    @private
    UILabel *placeHolderLabel;
}
@end

@implementation PGTextView
@synthesize placeHolder;
@synthesize placeholderColor;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [placeHolderLabel release]; placeHolderLabel = nil;
    [placeHolder release]; placeHolder = nil;
    [placeholderColor release]; placeholderColor = nil;
    
    [super dealloc];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initPGTextView];
}

-(void)initPGTextView
{
    self.font = [UIFont systemFontOfSize:14];
    self.placeholderColor = [UIColor lightGrayColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}


- (id)initWithFrame:(CGRect)frame
{
    if( (self = [super initWithFrame:frame]) )
    {
        [self initPGTextView];
    }
    return self;
}

- (void)textChanged:(NSNotification *)notification
{
    if([[self placeHolder] length] == 0)
    {
        return;
    }
    
    if([[self text] length] == 0)
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    else
    {
        [[self viewWithTag:999] setAlpha:0];
    }
}



- (void)setText:(NSString *)text {
    
    [super setText:text];
    
    [self textChanged:nil];
    
}



- (void)drawRect:(CGRect)rect

{
    
    if( [[self placeHolder] length] > 0 )
        
    {
        
        if ( placeHolderLabel == nil )
            
        {
            
            placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8,8,self.bounds.size.width - 16,0)];
            
//            placeHolderLabel.lineBreakMode = UILineBreakModeWordWrap;
            
            placeHolderLabel.numberOfLines = 0;
            
            placeHolderLabel.font = self.font;
            
            placeHolderLabel.backgroundColor = [UIColor clearColor];
            
            placeHolderLabel.textColor = self.placeholderColor;
            
            placeHolderLabel.alpha = 0;
            
            placeHolderLabel.tag = 999;
            
            [self addSubview:placeHolderLabel];
        }
        
        placeHolderLabel.text = self.placeHolder;
        [placeHolderLabel sizeToFit];
        [self sendSubviewToBack:placeHolderLabel];
    }
    
    if( [[self text] length] == 0 && [[self placeHolder] length] > 0 )
    {
        [[self viewWithTag:999] setAlpha:1];
    }
     [super drawRect:rect];
    
}

@end
