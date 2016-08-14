//
//  CuteView.h
//  CuteView
//
//  Created by Jack on 16/8/14.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CuteView : UIView

//父视图
//set the view which you wanna add the 'cuteBubble'
@property (nonatomic,strong)UIView *containerView;

//气泡上显示数字的label
//the label on the bubble
@property (nonatomic,strong)UILabel *bubbleLabel;

//气泡的直径
//bubble's diameter
@property (nonatomic,assign)CGFloat bubbleWidth;

//气泡粘性系数，越大可以拉得越长
//viscosity of the bubble,the bigger you set,the longer you drag
@property (nonatomic,assign)CGFloat viscosity;

//气泡颜色
//bubble's color
@property (nonatomic,strong)UIColor *bubbleColor;

//需要隐藏气泡时候可以使用这个属性：self.frontView.hidden = YES;
//if you wanna hidden the bubble, you can ’self.frontView.hidden = YES‘
@property (nonatomic,strong)UIView *frontView;

-(id)initWithPoint:(CGPoint)point superView:(UIView *)view;
-(void)setUp;

@end
