//
//  GooeyCircle.h
//  animatedPageControl
//
//  Created by Jack on 16/8/13.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "Indicator.h"

typedef enum : NSUInteger
{
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

@interface GooeyCircle :Indicator

@property(nonatomic,assign)CGFloat factor;
@property(nonatomic,assign)ScrollDirection scrollDirection;

@end
