//
//  GooeyCircle.m
//  animatedPageControl
//
//  Created by Jack on 16/8/13.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import "GooeyCircle.h"
#import "AnimatedPageControl.h"
#import "SpringLayerAnimation.h"

@interface GooeyCircle ()

@end

@implementation GooeyCircle
{
    CGFloat lastcontentoffset;
    BOOL beginGooeyAnim;
}

#pragma mark - Initialize

-(id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


-(id)initWithLayer:(GooeyCircle *)layer
{
    self = [super initWithLayer:layer];
    if (self) {
        
        self.indicatorSize  = layer.indicatorSize;
        self.indicatorColor = layer.indicatorColor;
        self.currentRect = layer.currentRect;
        self.lastContentOffset = layer.lastContentOffset;
        self.scrollDirection = layer.scrollDirection;
        self.factor = layer.factor;
    }
    return self;
}

#pragma mark - override class func

- (void)drawInContext:(CGContextRef)ctx
{
    /*
     *offset 指的是 A-C1,B-C2... 的距离，当该值设置为正方形边长的 1/3.6 倍时，画出来的圆弧近似贴合 1/4 圆。为什么是 3.6 ？这里 有一篇文章。文章
     *里三阶贝塞尔曲线拟合 1/4 圆的时候最佳参数 h=0.552,  表示的意义是：当正方形边长的 1/2 为 1 （ 即正方形边长为 2） 时， offset  等于 0.552
     *就能使圆弧近似贴近 1/4 圆。所以比例系数为 1/0.552 ，即正方形边长和 offset 的比例系数为：2/0.552 = 3.623。近似于 3.6。其实还有种更直观的
     *近似方法：如果圆心为 O，OC1, OC2  就一定是三等分点，也就是夹角为 30°，那么 AC1 （也就是 offset  ）就等于 1/2的边长 *  tan30°
     http://blog.csdn.net/nibiewuxuanze/article/details/48103059
     */
    CGFloat offset = self.currentRect.size.width / 3.6;  //设置3.6 出来的弧度最像圆形
    
    CGPoint rectCenter = CGPointMake(self.currentRect.origin.x + self.currentRect.size.width/2 , self.currentRect.origin.y + self.currentRect.size.height/2);

    //8个控制点实际的偏移距离。 The real distance of 8 control points.
    CGFloat extra = (self.currentRect.size.width * 2 / 5) * _factor;
    
    CGPoint pointA = CGPointMake(rectCenter.x ,self.currentRect.origin.y + extra);
    CGPoint pointB = CGPointMake(_scrollDirection == ScrollDirectionLeft ? rectCenter.x + self.currentRect.size.width/2 : rectCenter.x + self.currentRect.size.width/2 + extra*2 ,rectCenter.y);
    
    CGPoint pointC = CGPointMake(rectCenter.x ,rectCenter.y + self.currentRect.size.height/2 - extra);
    CGPoint pointD = CGPointMake(_scrollDirection == ScrollDirectionLeft ? self.currentRect.origin.x - extra*2 : self.currentRect.origin.x, rectCenter.y);
    
    CGPoint c1 = CGPointMake(pointA.x + offset, pointA.y);
    CGPoint c2 = CGPointMake(pointB.x, pointB.y - offset);
    
    CGPoint c3 = CGPointMake(pointB.x, pointB.y + offset);
    CGPoint c4 = CGPointMake(pointC.x + offset, pointC.y);
    
    CGPoint c5 = CGPointMake(pointC.x - offset, pointC.y);
    CGPoint c6 = CGPointMake(pointD.x, pointD.y + offset);
    
    CGPoint c7 = CGPointMake(pointD.x, pointD.y - offset);
    CGPoint c8 = CGPointMake(pointA.x - offset, pointA.y);
    
    // 更新界面
    UIBezierPath* ovalPath = [UIBezierPath bezierPath];

    [ovalPath moveToPoint: pointA];
    [ovalPath addCurveToPoint:pointB controlPoint1:c1 controlPoint2:c2];
    [ovalPath addCurveToPoint:pointC controlPoint1:c3 controlPoint2:c4];
    [ovalPath addCurveToPoint:pointD controlPoint1:c5 controlPoint2:c6];
    [ovalPath addCurveToPoint:pointA controlPoint1:c7 controlPoint2:c8];
    
    [ovalPath closePath];
    
    CGContextAddPath(ctx, ovalPath.CGPath);
    CGContextSetFillColorWithColor(ctx, self.indicatorColor.CGColor);
    CGContextFillPath(ctx);
    
}

+(BOOL)needsDisplayForKey:(NSString *)key{
    if ([key isEqual:@"factor"]) {
        return  YES;
    }
    return  [super needsDisplayForKey:key];
}

#pragma mark -- override superclass method


-(void)animateIndicatorWithScrollView:(UIScrollView *)scrollView andIndicator:(AnimatedPageControl *)pgctl{
    
    
    if ((scrollView.contentOffset.x - self.lastContentOffset) >= 0 && (scrollView.contentOffset.x - self.lastContentOffset) <= (scrollView.frame.size.width)/2) {
        self.scrollDirection = ScrollDirectionLeft;
    }else if ((scrollView.contentOffset.x - self.lastContentOffset) <= 0 && (scrollView.contentOffset.x - self.lastContentOffset) >= -(scrollView.frame.size.width)/2){
        self.scrollDirection = ScrollDirectionRight;
    }
    
    
    if (!beginGooeyAnim) {
        //首先，A、B、C、D是四个动点，控制他们动的变量是ScrollView的contentOffset.x。我们可以在-(void)scrollViewDidScroll:(UIScrollView *)scrollView中实时获取这个变量，并把它转换成一个控制在 0~1 的系数，取名为factor。
        //假设A、B、C、D的最大变化距离为小球直径的2/5。那么结合这个0~1的系数，我们可以得出A、B、C、D的真实变化距离 extra 为：extra = (self.width * 2 / 5) * factor。当factor == 1时，达到最大形变状态，此时四个点的变化距离均为(self.width * 2 / 5)。
        _factor = MIN(1, MAX(0, (ABS(scrollView.contentOffset.x - self.lastContentOffset) / scrollView.frame.size.width)));
    }
    
    CGFloat originX = (scrollView.contentOffset.x / scrollView.frame.size.width) * (pgctl.frame.size.width / (pgctl.pageCount-1));
    
    if (originX - self.indicatorSize/2 <= 0) {
        
        self.currentRect = CGRectMake(0, self.frame.size.height/2-self.indicatorSize/2, self.indicatorSize, self.indicatorSize);
        
    }else if ((originX - self.indicatorSize/2) >= self.frame.size.width - self.indicatorSize){
        
        self.currentRect = CGRectMake(self.frame.size.width - self.indicatorSize, self.frame.size.height/2-self.indicatorSize/2, self.indicatorSize, self.indicatorSize);
        
    }else{
        
        self.currentRect = CGRectMake(originX - self.indicatorSize/2, self.frame.size.height/2-self.indicatorSize/2, self.indicatorSize, self.indicatorSize);
    }
    
    [self setNeedsDisplay];
}

- (void)restoreAnimation:(id)howmanydistance
{
    CAKeyframeAnimation *anim = [SpringLayerAnimation createSpring:@"factor"
                                                          duration:0.8
                                            usingSpringWithDamping:0.5
                                             initialSpringVelocity:3
                                                         fromValue:@(0.5+[howmanydistance floatValue]* 1.5)
                                                           toValue:@(0)];
    anim.delegate = self;
    self.factor = 0;
    [self addAnimation:anim forKey:@"restoreAnimation"];
}


#pragma mark - CAAnimation Delegate


-(void)animationDidStart:(CAAnimation *)anim{
    
    beginGooeyAnim = YES;
}


-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (flag) {
        beginGooeyAnim = NO;
    }
}



@end
