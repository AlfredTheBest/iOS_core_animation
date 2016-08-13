//
//  Indicator.m
//  animatedPageControl
//
//  Created by Jack on 16/8/13.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import "Indicator.h"

@interface Indicator ()

@property (nonatomic, strong) id colorObserveToken;

@end

@implementation Indicator

-(void)setIndicatorSize:(CGFloat)indicatorSize{
    if (_indicatorSize != indicatorSize) {
        _indicatorSize = indicatorSize;
    }
}

@end
