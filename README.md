# CJRotation
数字大转盘,可以积分,有动画有声音,简单易用,使用方法ViewController中也有详细说明
 使用方法: 1. 导入CJIntegralRotation文件夹进入你的工程,并包含头文件
 ```objc
 #import "CJRoationView.h"
 ```
           2. 拷贝,宏定义部分, 和Property属性部分
           3. 把横线内的所有内容全部拷贝(即 42行 -- 182行)
           4. 通过以下方法可控制转盘的相应属性:
           4.1 动画停止后回调
  ```objc
   [roationView rotatingDidFinishBlock:^(NSInteger index, CGFloat score) {
 NSLog(@"indx=%ld,score=%.f",index,score);
 label.text = [NSString stringWithFormat:@"分数:%.f",score];
 }];
  ```

