//
//  CJRotation.m
//  CJRotationDemo
//
//  Created by ccj on 16/1/9.
//  Copyright (c) 2016年 ccj. All rights reserved.
//  CJRotation积分转盘 工具类源码: https://github.com/chenchangjian/CJRotation

#import "CJRotation.h"

@interface ScoreLabel : UILabel;

@end
@implementation ScoreLabel
- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        self.textColor = [UIColor whiteColor];
        self.font = [UIFont boldSystemFontOfSize:16];
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}


@end
@interface CJCollectViewCell : UICollectionViewCell
@property (nonatomic,strong)ScoreLabel *label;
@end
@implementation CJCollectViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        
        self.label = [[ScoreLabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:self.label];
        //        self.label.center = self.contentView.center;
        
    }
    return self;
}


- (void)setTitle:(NSString *)str IndexPath:(NSIndexPath *)indexPath
{
    self.label.text = str;
    CGFloat angle = (-M_PI / 8) + indexPath.row * M_PI / 4;//根据title的数量设置角度
    self.transform = CGAffineTransformMakeRotation(angle);
}
@end



typedef enum : NSUInteger {
    none,
    increasing,//递增
    diminishing,//递减
} VariableSpeedState;

typedef void(^RotationBlock)(NSInteger,CGFloat);

@interface CJRotation ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    SystemSoundID soundID;
    SystemSoundID getSoundID;
    SystemSoundID lostSoundID;
    SystemSoundID btnSoundID;
    SystemSoundID zeroSoundID;
    CGFloat al;//角度
    CFTimeInterval duration;//时间
    NSInteger titleCount;
    int roationCount;//旋转总次数
    int hasRoationCount;//已转的次数
    int lastIndex;//最后一次动画的index
}
@property (nonatomic,strong)UIImageView *turnView;
@property (nonatomic,strong)UIButton *button;
@property (nonatomic,assign)VariableSpeedState variableState;//变速方式
@property (nonatomic,copy)RotationBlock block;
@property (nonatomic,copy)void (^stareBlock)();
@property (nonatomic,strong)NSMutableArray *titles;
@property (nonatomic,strong)UICollectionView *collect;
@end
@implementation CJRotation

- (NSMutableArray *)titles
{
    if (!_titles) {
        _titles = @[@"+1",@"-3",@"+3",@"0",@"+2",@"+4",@"-1",@"-2"].mutableCopy;
    }
    return _titles;
}
- (void)rotatingDidFinishBlock:(void (^)(NSInteger, CGFloat))block
{
    if (block) {
        self.block = block;
    }
}
- (void)rotatViewDidStareRotating:(void (^)())block
{
    if (block) {
        self.stareBlock = block;
    }
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        [self initLayOutWithFrame:frame];
    }
    return self;
}
- (void)initLayOutWithFrame:(CGRect)frame
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"iPodClick" withExtension:@"aiff"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &soundID);
    
    
    NSURL *getUrl = [[NSBundle mainBundle] URLForResource:@"得" withExtension:@"wav"];
    NSURL *lostUrl = [[NSBundle mainBundle] URLForResource:@"扣" withExtension:@"wav"];
    NSURL *btnUrl = [[NSBundle mainBundle] URLForResource:@"按钮" withExtension:@"wav"];
    NSURL *zeroUrl = [[NSBundle mainBundle] URLForResource:@"零" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(getUrl), &getSoundID);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(lostUrl), &lostSoundID);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(btnUrl), &btnSoundID);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(zeroUrl), &zeroSoundID);
    
    
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(-15, -15, frame.size.width + 30, frame.size.height + 30)];
    image.image = [UIImage imageNamed:@"转盘-最底"];
    [self addSubview:image];
    
    
    UIImageView *image2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width * 3 / 4 - 5, frame.size.height * 3 / 4 - 5)];
    image2.image = [UIImage imageNamed:@"转盘-70"];
    image2.center = image.center;
    [self addSubview:image2];
    
    self.turnView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.turnView.image = [UIImage imageNamed:@"转盘-71"];
    self.turnView.highlightedImage = [UIImage imageNamed:@"转盘-转动高亮"];
    [self addSubview:self.turnView];
    
    CJRoundLayout * layout = [[CJRoundLayout alloc]init];
    self.collect  = [[UICollectionView alloc]initWithFrame:CGRectMake(-3, -3, frame.size.width + 6, frame.size.height + 6) collectionViewLayout:layout];
    _collect.delegate=self;
    _collect.dataSource=self;
    _collect.backgroundColor = [UIColor clearColor];
    [_collect registerClass:[CJCollectViewCell class] forCellWithReuseIdentifier:@"cellid"];
    [self addSubview:_collect];
    
    
    
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setImage:[UIImage imageNamed:@"启动按钮"] forState:UIControlStateNormal];
    [self.button setImage:[UIImage imageNamed:@"启动按钮按下"] forState:UIControlStateHighlighted];
    [self.button setImage:[UIImage imageNamed:@"启动按钮按下"] forState:UIControlStateDisabled];
    self.button.frame = CGRectMake(0, 0, frame.size.width / 2, frame.size.height / 2);
    self.button.center = image.center;
    [self addSubview:self.button];
    [self.button addTarget:self action:@selector(startRotain:) forControlEvents:UIControlEventTouchUpInside];
    titleCount = self.titles.count;
    
    
    duration = 0.00001f;
    al = 0;
}

#pragma -mark CollectViewDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.titles.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CJCollectViewCell * cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid" forIndexPath:indexPath];
    [cell setTitle:[self.titles objectAtIndex:indexPath.row] IndexPath:indexPath];
    
    return cell;
}


- (void)startRotain:(UIButton *)button
{
    AudioServicesPlaySystemSound(btnSoundID);
    if (self.stareBlock) {
        self.stareBlock();
    }
    [self reSet];
    self.button.enabled = NO;
    roationCount = arc4random() % 145 + 64;
    NSLog(@"%d",roationCount);
    hasRoationCount = 0;
    duration = 0.00001f;
    self.variableState = increasing;
    self.turnView.highlighted = YES;
    [self startAnimatWithView:self.turnView];
}
- (void)startAnimatWithView:(UIView *)view
{
    
    CABasicAnimation *caAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    caAnimation.removedOnCompletion = NO;
    caAnimation.fillMode = kCAFillModeForwards;
    caAnimation.fromValue = @(al);
    CGFloat flot = al + M_PI / (titleCount / 2);
    caAnimation.toValue = @(flot);
    caAnimation.duration = duration;
    caAnimation.repeatCount = 1;
    caAnimation.delegate = self;
    
    [view.layer addAnimation:caAnimation forKey:@"anim"];
    al = [caAnimation.toValue floatValue];
    
}
- (void)animationDidStart:(CAAnimation *)anim
{
    hasRoationCount += 1;
    AudioServicesPlaySystemSound(soundID);
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (hasRoationCount >= roationCount) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.button.enabled = YES;
        });
        int curIndex = (roationCount%titleCount+lastIndex)%titleCount;
        lastIndex = curIndex;
        
        for (int i = 0; i<self.titles.count; i++) {
            CJCollectViewCell *cell = (CJCollectViewCell *)[self.collect cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
            if (i == curIndex) {
                cell.label.textColor = [UIColor redColor];
                cell.label.font = [UIFont boldSystemFontOfSize:22];
                self.turnView.highlighted = NO;
            }else{
                cell.label.textColor = [UIColor whiteColor];
                cell.label.font = [UIFont boldSystemFontOfSize:16];
            }
        }
        
        if (self.block) {
            CGFloat score = [[self.titles objectAtIndex:curIndex] floatValue];
            if (score > 0)
            {
                AudioServicesPlaySystemSound(getSoundID);
            }else if(score   < 0){
                //            self.subTile.text = @"再接再厉";
                AudioServicesPlaySystemSound(lostSoundID);
            }else{
                //            self.curIndex.text = @"再接再厉";
                AudioServicesPlaySystemSound(zeroSoundID);
            }
            
            self.block(curIndex,score);
        }
        return;
    }
    
    int limit = 18;
    if (hasRoationCount >= limit&&hasRoationCount <= roationCount - limit) {
        [self startAnimatWithView:self.turnView];
        return;
    }
    if (hasRoationCount < limit) {
        self.variableState = increasing;
    }else if (hasRoationCount > roationCount - limit){
        self.variableState = diminishing;
    }
    if (self.variableState == increasing) {
        duration -= 0.01;
    }else{
        duration += 0.01;
    }
    
    
    if (duration < 0.01) {
        duration = 0.01;
    }
    [self startAnimatWithView:self.turnView];
}

/**
 *  重置颜色
 */
- (void)reSet
{
    for (int i = 0; i < self.titles.count; i++) {
        CJCollectViewCell *cell = (CJCollectViewCell *)[self.collect cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        cell.label.textColor = [UIColor whiteColor];
        cell.label.font = [UIFont boldSystemFontOfSize:16];
    }
}





@end
