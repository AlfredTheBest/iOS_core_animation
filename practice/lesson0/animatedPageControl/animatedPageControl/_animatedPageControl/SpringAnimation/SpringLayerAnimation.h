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

//Normal Animation
+ (CABasicAnimation *)create:(NSString *)keypath
                    duration:(CFTimeInterval)duration
                   fromValue:(id)fromValue
                     toValue:(id)toValue;


//Spring Animation
+(CAKeyframeAnimation *)createSpring:(NSString *)keypath
                            duration:(CFTimeInterval)duration
              usingSpringWithDamping:(CGFloat)damping
               initialSpringVelocity:(CGFloat)velocity
                           fromValue:(id)fromValue
                             toValue:(id)toValue;


@end
