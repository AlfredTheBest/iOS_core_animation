//
//  SpringLayerAnimation.h
//  animatedPageControl
//
//  Created by Jack on 16/8/13.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SpringLayerAnimation : NSObject

+ (instancetype)sharedAnimManager;

// Normal Anim -- 线性函数
- (CAKeyframeAnimation *)createBasicAnima:(NSString *)keypath
                                 duration:(CFTimeInterval)duration
                                fromValue:(id)fromValue
                                  toValue:(id)toValue;

// Spring Anim -- 弹性曲线
- (CAKeyframeAnimation *)createSpringAnima:(NSString *)keypath
                                  duration:(CFTimeInterval)duration
                    usingSpringWithDamping:(CGFloat)damping
                     initialSpringVelocity:(CGFloat)velocity
                                 fromValue:(id)fromValue
                                   toValue:(id)toValue;

// Curve Anim -- 二次平滑抛物函数
- (CAKeyframeAnimation *)createCurveAnima:(NSString *)keypath
                                 duration:(CFTimeInterval)duration
                                fromValue:(id)fromValue
                                  toValue:(id)toValue;

// Curve Anim -- 抛到一半的二次平滑抛物函数
- (CAKeyframeAnimation *)createHalfCurveAnima:(NSString *)keypath
                                     duration:(CFTimeInterval)duration
                                    fromValue:(id)fromValue
                                      toValue:(id)toValue;


@end
