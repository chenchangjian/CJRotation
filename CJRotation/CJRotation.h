//
//  CJRotation.h
//  CJRotationDemo
//
//  Created by ccj on 16/1/9.
//  Copyright (c) 2016年 ccj. All rights reserved.
//  CJRotation积分转盘 工具类源码: https://github.com/chenchangjian/CJRotation

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CJRoundLayout.h"
#define Arc4random(a,b) arc4random()%(b-a+1)+a
#define lottery @"lottery"

@interface CJRotation : UIView
- (void)rotatingDidFinishBlock:(void(^)(NSInteger index,CGFloat score))block;
- (void)rotatViewDidStareRotating:(void(^)())block;
@end
