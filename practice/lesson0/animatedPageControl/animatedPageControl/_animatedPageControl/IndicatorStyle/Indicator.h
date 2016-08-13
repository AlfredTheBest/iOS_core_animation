//
//  Indicator.h
//  animatedPageControl
//
//  Created by Jack on 16/8/13.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class AnimatedPageControl;

@interface Indicator : CALayer

@property(nonatomic,assign)CGFloat indicatorSize;
@property(nonatomic,strong)UIColor *indicatorColor;
@property(nonatomic,assign)CGRect currentRect;
@property(nonatomic,assign)CGFloat lastContentOffset;


-(void)animateIndicatorWithScrollView:(UIScrollView *)scrollView
                         andIndicator:(AnimatedPageControl *)pgctl;
-(void)restoreAnimation:(id)howmanydistance;
@end
