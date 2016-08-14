//
//  ViewController.m
//  CuteView
//
//  Created by Jack on 16/8/14.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import "ViewController.h"
#import "CuteView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CuteView *cuteView = [[CuteView alloc]initWithPoint:CGPointMake(25, [UIScreen mainScreen].bounds.size.height - 65) superView:self.view];
    cuteView.viscosity  = 20;
    cuteView.bubbleWidth = 35;
    cuteView.bubbleColor = [UIColor colorWithRed:0 green:0.722 blue:1 alpha:1];
    [cuteView setUp];
    
    //注意：设置 'bubbleLabel.text' 一定要放在 '-setUp' 方法之后
    //Tips:When you set the 'bubbleLabel.text',you must set it after '-setUp'
    cuteView.bubbleLabel.text = @"13";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
