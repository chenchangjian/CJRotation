//
//  ViewController.m
//  CJRotationDemo
//
//  Created by ccj on 16/1/9.
//  Copyright (c) 2016年 ccj. All rights reserved.
//  CJRotation积分转盘 工具类源码: https://github.com/chenchangjian/CJRotation

#import "ViewController.h"
#import "CJRotation.h"
#define AppWidth [[UIScreen mainScreen] bounds].size.width
#define AppHeight [[UIScreen mainScreen] bounds].size.height
#define WhiteColor Color(255,255,255)
#define Color(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]
#define TotalIntegral @"integral"

@interface ViewController ()
@property (assign, nonatomic) CGFloat totalNum;
@property (strong, nonatomic) UILabel *lab1;
@property (strong, nonatomic) UILabel *lab0;
@property (strong, nonatomic) CJRotation *rotation;
@end

@implementation ViewController

/**
 * 使用方法: 1. 导入CJIntegralRotation文件夹进入你的工程,并包含 #import "CJRoationView.h"
 *          2. 拷贝,宏定义部分, 和Property属性部分
 *          3. 把横线内的所有内容全部拷贝(即 42行 -- 182行)
 *          4. 通过以下方法可控制转盘的相应属性:
 *          4.1 //动画停止后回调
 [roationView rotatingDidFinishBlock:^(NSInteger index, CGFloat score) {
 NSLog(@"indx=%ld,score=%.f",index,score);
 label.text = [NSString stringWithFormat:@"分数:%.f",score];
 }];
 */

//------------------------------------------------------------------------------------


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, AppWidth, AppHeight)];
    image.image = [UIImage imageNamed:@"mmm"];
    [self.view addSubview:image];
    
    [self setUpRoationView];
    
}

- (void)setUpRoationView
{
    CJRotation *rotation = [[CJRotation alloc] initWithFrame:CGRectMake(40, 84, AppWidth - 80, AppWidth - 80)];
    
    self.rotation = rotation;
    __weak typeof(self) weak = self;
    [rotation rotatViewDidStareRotating:^{
        weak.lab1.textColor = WhiteColor;
        weak.lab0.textColor = WhiteColor;
    }];
    [rotation rotatingDidFinishBlock:^(NSInteger index, CGFloat score) {
        NSLog(@"indx=%ld,score=%.f",(long)index,score);
        
        weak.totalNum += score;
        
        NSLog(@"totalNum = %f",weak.totalNum);
        NSString *str = [NSString stringWithFormat:@"%f",weak.totalNum];
        
        [[NSUserDefaults standardUserDefaults] setObject:str forKey:TotalIntegral];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString *totalStr = [[NSUserDefaults standardUserDefaults] objectForKey:TotalIntegral];
        int totalInt = [totalStr integerValue];
        NSString *totalStrs = [NSString stringWithFormat:@"%d",totalInt];
        NSLog(@"totalStrs = %@", totalStrs);
        if (totalStrs) {
            weak.lab1.text = [weak totalStringFromString:totalStrs];
        }else{
            weak.lab1.text = @"0000";
        }
        weak.lab1.textColor = Color(250, 105, 92);
        weak.lab0.textColor = Color(250, 105, 92);
        
    }];
    
    [self.view addSubview:rotation];
    [self setUpLabel];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    NSString *totalStr = [[NSUserDefaults standardUserDefaults] objectForKey:TotalIntegral];
    long int totalInt = [totalStr integerValue];
    NSString *totalStrs = [NSString stringWithFormat:@"%ld",totalInt];
    NSLog(@"totalStrs = %@", totalStrs);
    if (totalStrs) {
        self.lab1.text = [self totalStringFromString:totalStrs];
    }else{
        self.lab1.text = @"0000";
    }
    self.totalNum = [totalStr floatValue];
    
}


-(NSString *)totalStringFromString:(NSString *)fromStr{
    if (fromStr.length == 0) {
        return @"0000";
    }else if(fromStr.length == 1){
        if ([fromStr intValue] >= 0)
        {
            return [NSString stringWithFormat:@"000%@",fromStr];
        }else
        {
            return fromStr;
        }
        
    }else if(fromStr.length == 2){
        if ([fromStr intValue] > 0)
        {
            return [NSString stringWithFormat:@"00%@",fromStr];
        }else
        {
            return fromStr;
        }
        
    }else if(fromStr.length == 3){
        if ([fromStr intValue] > 0)
        {
            return [NSString stringWithFormat:@"0%@",fromStr];
        }else
        {
            return fromStr;
        }
        
        
    }else if(fromStr.length == 4){
        
        return fromStr;
    }else{
        return nil;
    }
}

- (void)setUpLabel
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithRed:75 green:75 blue:75 alpha:0.5f];
    view.layer.cornerRadius = 10;
    [self.view addSubview:view];
    
    UILabel *lab = [[UILabel alloc] init];
    
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = @"我的积分";
    lab.textColor = [UIColor whiteColor];
    lab.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:lab];
    self.lab0 = lab;
    
    UILabel *lab1 = [[UILabel alloc] init];
    
    lab1.text = @"0000";
    lab1.textColor = [UIColor whiteColor];
    lab1.textAlignment = NSTextAlignmentCenter;
    lab1.font = [UIFont systemFontOfSize:12];
    self.lab1 = lab1;
    lab1.bounds = CGRectMake(0, 0, 60, 40);
    [self.view addSubview:lab1];
    
    
    lab.frame = CGRectMake(30, 345, 60, 40);
    
    lab1.frame = CGRectMake(30, 360, 60, 40);
    
    view.frame = CGRectMake(30, 350, 60, 40);
    
}

// -----------------------------------------------------------------------------------
@end
