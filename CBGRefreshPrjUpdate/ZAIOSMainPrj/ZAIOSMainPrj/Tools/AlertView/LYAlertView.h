//
//  LYAlertView.h
//  ShaiHuo
//  自定义弹框
//  Created by 李言 on 14-7-8.
//  Copyright (c) 2014年 CBSi. All rights reserved.
//

#import <UIKit/UIKit.h>
//实现弹出的功能相关
@protocol LYAlertViewDelegate

- (void)LYAlertdialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface LYAlertView : UIView<LYAlertViewDelegate>

@property (nonatomic, retain) UIView *parentView;    // The parent view this 'dialog' is attached to
@property (nonatomic, retain) UIView *dialogView;    // Dialog's container view
@property (nonatomic, retain) UIView *containerView; // Container within the dialog (place your ui elements here)
@property (nonatomic, retain) UIView *buttonView;    // Buttons on the bottom of the dialog

@property (nonatomic, assign) id<LYAlertViewDelegate> delegate;
@property (nonatomic, retain) NSArray *buttonTitles;
@property (nonatomic, assign) BOOL useMotionEffects;

@property (copy) void (^onButtonTouchUpInside)(LYAlertView *alertView, int buttonIndex) ;

- (id)init;

/*!
 DEPRECATED: Use the [CustomIOS7AlertView init] method without passing a parent view.
 */
- (id)initWithParentView: (UIView *)_parentView __attribute__ ((deprecated));

- (void)show;
- (void)close;

- (IBAction)customIOS7dialogButtonTouchUpInside:(id)sender;
- (void)setOnButtonTouchUpInside:(void (^)(LYAlertView *alertView, int buttonIndex))onButtonTouchUpInside;

- (void)deviceOrientationDidChange: (NSNotification *)notification;
- (void)dealloc;

@end
