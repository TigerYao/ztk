//
//  ViewController.m
//  SuperWM
//
//  Created by 华图Android on 2019/8/23.
//  Copyright © 2019 华图Android. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView *view1 = [[UIView alloc]init];
    //状态栏高度为20px,我们在设置的时候需要扣除状态栏像素
    view1.frame = CGRectMake(0, 0, 414, 400);
    view1.backgroundColor = [UIColor blueColor];
    [self.view addSubview:view1];
    
    NSLog(@"x:%f  y:%f  w:%f  h:%f",[[UIScreen mainScreen] bounds].origin.x, [[UIScreen mainScreen]bounds].origin.y, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height);
    
    //父视图
    UIView *superView = view1.superview;
    superView.backgroundColor = [UIColor greenColor];
    UIView *view2 = [[UIView alloc]init];
    view2.frame = CGRectMake(0, 100, 200, 100);
    view2.backgroundColor = [UIColor redColor];
    [view1 addSubview: view2];
}



@end
