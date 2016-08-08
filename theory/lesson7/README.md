# 显式动画
上一章介绍了隐式动画的概念。隐式动画是在iOS平台创建动态用户界面的一种直接方式，也是UIKit动画机制的基础，不过它并不能涵盖所有的动画类型。在这一章中，*我们将要研究一下显式动画，它能够对一些属性做指定的自定义动画，或者创建非线性动画，比如沿着任意一条曲线移动。*

## 属性动画

`CAAnimationDelegate`在任何头文件中都找不到，但是可以在CAAnimation头文件或者苹果开发者文档中找到相关函数。在这个例子中，我们用`-animationDidStop:finished:`方法在动画结束之后来更新图层的`backgroundColor`。

当更新属性的时候，我们需要设置一个新的事务，并且禁用图层行为。否则动画会发生两次，一个是因为显式的CABasicAnimation，另一次是因为隐式动画。

```
@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	//create sublayer
	self.colorLayer = [CALayer layer];
	self.colorLayer.frame = CGRectMake(50.0f, 50.0f, 100.0f, 100.0f);
	self.colorLayer.backgroundColor = [UIColor blueColor].CGColor;
	//add it to our view
	[self.layerView.layer addSublayer:self.colorLayer];
}

- (IBAction)changeColor
{
	//create a new random color
	CGFloat red = arc4random() / (CGFloat)INT_MAX;
	CGFloat green = arc4random() / (CGFloat)INT_MAX;
	CGFloat blue = arc4random() / (CGFloat)INT_MAX;
	UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
	//create a basic animation
	CABasicAnimation *animation = [CABasicAnimation animation];
	animation.keyPath = @"backgroundColor";
	animation.toValue = (__bridge id)color.CGColor;
	animation.delegate = self;
	//apply animation to layer
	[self.colorLayer addAnimation:animation forKey:nil];
}

- (void)animationDidStop:(CABasicAnimation \*)anim finished:(BOOL)flag
{
	//set the backgroundColor property to match animation toValue
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	self.colorLayer.backgroundColor = (__bridge CGColorRef)anim.toValue;
	[CATransaction commit];
}

@end
```
对CAAnimation而言，使用委托模式而不是一个完成块会带来一个问题，就是当你有多个动画的时候，无法在在回调方法中区分。在一个视图控制器中创建动画的时候，通常会用控制器本身作为一个委托（如清单8.3所示），但是所有的动画都会调用同一个回调方法，所以你就需要判断到底是那个图层的调用。

考虑一下“图层几何学”，我们通过简单地每秒更新指针的角度来实现一个钟，但如果指针动态地转向新的位置会更加真实。+


当使用-addAnimation:forKey:把动画添加到图层，这里有一个到目前为止我们都设置为nil的key参数。这里的键是-animationForKey:方法找到对应动画的唯一标识符，而当前动画的所有键都可以用animationKeys获取。如果我们对每个动画都关联一个唯一的键，就可以对每个图层循环所有键，然后调用-animationForKey:来比对结果。尽管这不是一个优雅的实现。

幸运的是，还有一种更加简单的方法。像所有的NSObject子类一样，CAAnimation实现了KVC（键-值-编码）协议，于是你可以用-setValue:forKey:和-valueForKey:方法来存取属性。但是CAAnimation有一个不同的性能：它更像一个NSDictionary，可以让你随意设置键值对，即使和你使用的动画类所声明的属性并不匹配。
这意味着你可以对动画用任意类型打标签。在这里，我们给UIView类型的指针添加的动画，所以可以简单地判断动画到底属于哪个视图，然后在委托方法中用这个信息正确地更新钟的指针。

```
@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIImageView \*hourHand;
@property (nonatomic, weak) IBOutlet UIImageView \*minuteHand;
@property (nonatomic, weak) IBOutlet UIImageView \*secondHand;
@property (nonatomic, weak) NSTimer \*timer;

@end

@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	//adjust anchor points
	self.secondHand.layer.anchorPoint = CGPointMake(0.5f, 0.9f);
	self.minuteHand.layer.anchorPoint = CGPointMake(0.5f, 0.9f);
	self.hourHand.layer.anchorPoint = CGPointMake(0.5f, 0.9f);
	//start timer
	self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
	//set initial hand positions
	[self updateHandsAnimated:NO];
}

- (void)tick
{
	[self updateHandsAnimated:YES];
}

- (void)updateHandsAnimated:(BOOL)animated
{
	//convert time to hours, minutes and seconds
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSUInteger units = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	NSDateComponents *components = [calendar components:units fromDate:[NSDate date]];
	CGFloat hourAngle = (components.hour / 12.0) * M_PI * 2.0;
	//calculate hour hand angle //calculate minute hand angle
	CGFloat minuteAngle = (components.minute / 60.0) * M_PI * 2.0;
	//calculate second hand angle
	CGFloat secondAngle = (components.second / 60.0) * M_PI * 2.0;
	//rotate hands
	[self setAngle:hourAngle forHand:self.hourHand animated:animated];
	[self setAngle:minuteAngle forHand:self.minuteHand animated:animated];
	[self setAngle:secondAngle forHand:self.secondHand animated:animated];
}

- (void)setAngle:(CGFloat)angle forHand:(UIView \*)handView animated:(BOOL)animated
{
	//generate transform
	CATransform3D transform = CATransform3DMakeRotation(angle, 0, 0, 1);
	if (animated) {
	    //create transform animation
	    CABasicAnimation *animation = [CABasicAnimation animation];
	    [self updateHandsAnimated:NO];
	    animation.keyPath = @"transform";
	    animation.toValue = [NSValue valueWithCATransform3D:transform];
	    animation.duration = 0.5;
	    animation.delegate = self;
	    [animation setValue:handView forKey:@"handView"];
	    [handView.layer addAnimation:animation forKey:nil];
	} else {
	    //set transform directly
	    handView.layer.transform = transform;
	}
}

- (void)animationDidStop:(CABasicAnimation \*)anim finished:(BOOL)flag
{
	//set final position for hand view
	UIView *handView = [anim valueForKey:@"handView"];
	handView.layer.transform = [anim.toValue CATransform3DValue];
}
```

不幸的是，即使做了这些，还是有个问题，清单8.4在模拟器上运行的很好，但当真正跑在iOS设备上时，我们发现在-animationDidStop:finished:委托方法调用之前，指针会迅速返回到原始值，这个清单8.3图层颜色发生的情况一样。+

问题在于回调方法在动画完成之前已经被调用了，但不能保证这发生在属性动画返回初始状态之前。这同时也很好地说明了为什么要在真实的设备上测试动画代码，而不仅仅是模拟器。
我们可以用一个fillMode属性来解决这个问题，下一章会详细说明，这里知道在动画之前设置它比在动画结束之后更新属性更加方便。

## 关键帧动画
`CABasicAnimation`揭示了大多数隐式动画背后依赖的机制，这的确很有趣，但是显式地给图层添加`CABasicAnimation`相较于隐式动画而言，只能说费力不讨好。

CAKeyframeAnimation是另一种UIKit没有暴露出来但功能强大的类。和CABasicAnimation类似，CAKeyframeAnimation同样是CAPropertyAnimation的一个子类，它依然作用于单一的一个属性，但是和CABasicAnimation不一样的是，它不限制于设置一个起始和结束的值，而是可以根据一连串随意的值来做动画。

关键帧起源于传动动画，意思是指主导的动画在显著改变发生时重绘当前帧（也就是关键帧），每帧之间剩下的绘制（可以通过关键帧推算出）将由熟练的艺术家来完成。*CAKeyframeAnimation也是同样的道理：你提供了显著的帧，然后Core Animation在每帧之间进行插入。*

我们来用一个宇宙飞船沿着一个简单曲线的实例演示一下。为了创建路径，我们需要使用一个三次贝塞尔曲线，它是一种使用开始点，结束点和另外两个控制点来定义形状的曲线，可以通过使用一个基于C的Core Graphics绘图指令来创建，不过用UIKit提供的UIBezierPath类会更简单。

我们这次用CAShapeLayer来在屏幕上绘制曲线，尽管对动画来说并不是必须的，但这会让我们的动画更加形象。绘制完CGPath之后，我们用它来创建一个CAKeyframeAnimation，然后用它来应用到我们的宇宙飞船。

```
@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView \*containerView;

@end

@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	//create a path
	UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
	[bezierPath moveToPoint:CGPointMake(0, 150)];
	[bezierPath addCurveToPoint:CGPointMake(300, 150) controlPoint1:CGPointMake(75, 0) controlPoint2:CGPointMake(225, 300)];
	//draw the path using a CAShapeLayer
	CAShapeLayer *pathLayer = [CAShapeLayer layer];
	pathLayer.path = bezierPath.CGPath;
	pathLayer.fillColor = [UIColor clearColor].CGColor;
	pathLayer.strokeColor = [UIColor redColor].CGColor;
	pathLayer.lineWidth = 3.0f;
	[self.containerView.layer addSublayer:pathLayer];
	//add the ship
	CALayer *shipLayer = [CALayer layer];
	shipLayer.frame = CGRectMake(0, 0, 64, 64);
	shipLayer.position = CGPointMake(0, 150);
	shipLayer.contents = (__bridge id)[UIImage imageNamed: @"Ship.png"].CGImage;
	[self.containerView.layer addSublayer:shipLayer];
	//create the keyframe animation
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
	animation.keyPath = @"position";
	animation.duration = 4.0;
	animation.path = bezierPath.CGPath;
	[shipLayer addAnimation:animation forKey:nil];
}

@end
```

![](lesson7_0.jpeg)


运行示例，你会发现飞船的动画有些不太真实，这是因为当它运动的时候永远指向右边，而不是指向曲线切线的方向。你可以调整它的affineTransform来对运动方向做动画，但很可能和其它的动画冲突。
幸运的是，苹果预见到了这点，并且给CAKeyFrameAnimation添加了一个rotationMode的属性。设置它为常量kCAAnimationRotateAuto。通过rotationMode自动对齐图层到曲线。

```
- (void)viewDidLoad
{
	[super viewDidLoad];
	//create a path
	...
	//create the keyframe animation
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
	animation.keyPath = @"position";
	animation.duration = 4.0;
	animation.path = bezierPath.CGPath;
	animation.rotationMode = kCAAnimationRotateAuto;
	[shipLayer addAnimation:animation forKey:nil];
}
```

![](lesson7_1.jpeg)

## 虚拟属性
之前提到过属性动画实际上是针对于关键路径而不是一个键，这就意味着可以对子属性甚至是虚拟属性做动画。但是虚拟属性到底是什么呢？

考虑一个旋转的动画：如果想要对一个物体做旋转的动画，那就需要作用于transform属性，因为CALayer没有显式提供角度或者方向之类的属性

```
@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView \*containerView;

@end

@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	//add the ship
	CALayer *shipLayer = [CALayer layer];
	shipLayer.frame = CGRectMake(0, 0, 128, 128);
	shipLayer.position = CGPointMake(150, 150);
	shipLayer.contents = (__bridge id)[UIImage imageNamed: @"Ship.png"].CGImage;
	[self.containerView.layer addSublayer:shipLayer];
	//animate the ship rotation
	CABasicAnimation *animation = [CABasicAnimation animation];
	animation.keyPath = @"transform";
	animation.duration = 2.0;
	animation.toValue = [NSValue valueWithCATransform3D: CATransform3DMakeRotation(M_PI, 0, 0, 1)];
	[shipLayer addAnimation:animation forKey:nil];
}

@end
```

这么做是可行的，但看起来更因为是运气而不是设计的原因，如果我们把旋转的值从M\_PI（180度）调整到2 \* M\_PI（360度），然后运行程序，会发现这时候飞船完全不动了。这是因为这里的矩阵做了一次360度的旋转，和做了0度是一样的，所以最后的值根本没变。+

现在继续使用M\_PI，但这次用byValue而不是toValue。也许你会认为这和设置toValue结果一样，因为0 + 90度 == 90度，但实际上飞船的图片变大了，并没有做任何旋转，这是因为变换矩阵不能像角度值那样叠加。

那么如果需要独立于角度之外单独对平移或者缩放做动画呢？由于都需要我们来修改transform属性，实时地重新计算每个时间点的每个变换效果，然后根据这些创建一个复杂的关键帧动画，这一切都是为了对图层的一个独立做一个简单的动画。

```
@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView \*containerView;

@end

@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	//add the ship
	CALayer *shipLayer = [CALayer layer];
	shipLayer.frame = CGRectMake(0, 0, 128, 128);
	shipLayer.position = CGPointMake(150, 150);
	shipLayer.contents = (__bridge id)[UIImage imageNamed: @"Ship.png"].CGImage;
	[self.containerView.layer addSublayer:shipLayer];
	//animate the ship rotation
	CABasicAnimation *animation = [CABasicAnimation animation];
	animation.keyPath = @"transform.rotation";
	animation.duration = 2.0;
	animation.byValue = @(M_PI * 2);
	[shipLayer addAnimation:animation forKey:nil];
}

@end
```

结果运行的特别好，用transform.rotation而不是transform做动画的好处如下：

* 我们可以不通过关键帧一步旋转多于180度的动画。
* 可以用相对值而不是绝对值旋转（设置byValue而不是toValue）。
* 可以不用创建CATransform3D，而是使用一个简单的数值来指定角度。
* 不会和transform.position或者transform.scale冲突（同样是使用关键路径来做独立的动画属性）。

**transform.rotation属性有一个奇怪的问题是它其实并不存在。这是因为CATransform3D并不是一个对象，它实际上是一个结构体，也没有符合KVC相关属性，transform.rotation实际上是一个CALayer用于处理动画变换的虚拟属性。**

CAValueFunction用于把我们赋给虚拟的transform.rotation简单浮点值转换成真正的用于摆放图层的CATransform3D矩阵值。你可以通过设置CAPropertyAnimation的valueFunction属性来改变，于是你设置的函数将会覆盖默认的函数。

CAValueFunction看起来似乎是对那些不能简单相加的属性（例如变换矩阵）做动画的非常有用的机制，但由于CAValueFunction的实现细节是私有的，所以目前不能通过继承它来自定义。你可以通过使用苹果目前已经提供的常量（目前都是和变换矩阵的虚拟属性相关，所以没太多使用场景了，


###动画组

CABasicAnimation和CAKeyframeAnimation仅仅作用于单独的属性，而CAAnimationGroup可以把这些动画组合在一起。CAAnimationGroup是另一个继承于CAAnimation的子类，它添加了一个animations数组的属性，用来组合别的动画。我们把清单8.6那种关键帧动画和调整图层背景色的基础动画组合起来。

```
- (void)viewDidLoad
{
    [super viewDidLoad];
    //create a path
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    [bezierPath moveToPoint:CGPointMake(0, 150)];
    [bezierPath addCurveToPoint:CGPointMake(300, 150) controlPoint1:CGPointMake(75, 0) controlPoint2:CGPointMake(225, 300)];
    //draw the path using a CAShapeLayer
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.path = bezierPath.CGPath;
    pathLayer.fillColor = [UIColor clearColor].CGColor;
    pathLayer.strokeColor = [UIColor redColor].CGColor;
    pathLayer.lineWidth = 3.0f;
    [self.containerView.layer addSublayer:pathLayer];
    //add a colored layer
    CALayer *colorLayer = [CALayer layer];
    colorLayer.frame = CGRectMake(0, 0, 64, 64);
    colorLayer.position = CGPointMake(0, 150);
    colorLayer.backgroundColor = [UIColor greenColor].CGColor;
    [self.containerView.layer addSublayer:colorLayer];
    //create the position animation
    CAKeyframeAnimation *animation1 = [CAKeyframeAnimation animation];
    animation1.keyPath = @"position";
    animation1.path = bezierPath.CGPath;
    animation1.rotationMode = kCAAnimationRotateAuto;
    //create the color animation
    CABasicAnimation *animation2 = [CABasicAnimation animation];
    animation2.keyPath = @"backgroundColor";
    animation2.toValue = (__bridge id)[UIColor redColor].CGColor;
    //create group animation
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.animations = @[animation1, animation2]; 
    groupAnimation.duration = 4.0;
    //add the animation to the color layer
    [colorLayer addAnimation:groupAnimation forKey:nil];
}
```

![](lesson7_2.jpeg)

##过渡

**有时候对于iOS应用程序来说，希望能通过属性动画来对比较难做动画的布局进行一些改变。比如交换一段文本和图片，或者用一段网格视图来替换，等等。属性动画只对图层的可动画属性起作用，所以如果要改变一个不能动画的属性（比如图片），或者从层级关系中添加或者移除图层，属性动画将不起作用。**

于是就有了过渡的概念。过渡并不像属性动画那样平滑地在两个值之间做动画，而是影响到整个图层的变化。过渡动画首先展示之前的图层外观，然后通过一个交换过渡到新的外观。

为了创建一个过渡动画，我们将使用`CATransition`，同样是另一个CAAnimation的子类，和别的子类不同，CATransition有一个type和subtype来标识变换效果。type属性是一个NSString类型，可以被设置成如下类型：

```
kCATransitionFade 
kCATransitionMoveIn 
kCATransitionPush 
kCATransitionReveal
```
kCATransitionMoveIn和kCATransitionReveal与kCATransitionPush类似，都实现了一个定向滑动的动画，但是有一些细微的不同，kCATransitionMoveIn从顶部滑动进入，但不像推送动画那样把老底层推走，然而kCATransitionReveal把原始的图层滑动出去来显示新的外观，而不是把新的图层滑动进入。

后面三种过渡类型都有一个默认的动画方向，它们都从左侧滑入，但是你可以通过subtype来控制它们的方向，提供了如下四种类型：

```
kCATransitionFromRight 
kCATransitionFromLeft 
kCATransitionFromTop 
kCATransitionFromBottom
```

一个简单的用CATransition来对非动画属性做动画的例子如清单8.11所示，这里我们对UIImage的image属性做修改，但是隐式动画或者CAPropertyAnimation都不能对它做动画，因为Core Animation不知道如何在插图图片。通过对图层应用一个淡入淡出的过渡，我们可以忽略它的内容来做平滑动画，我们来尝试修改过渡的type常量来观察其它效果。

 使用CATransition来对UIImageView做动画
 
 ```
 @interface ViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, copy) NSArray *images;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //set up images
    self.images = @[[UIImage imageNamed:@"Anchor.png"],
                    [UIImage imageNamed:@"Cone.png"],
                    [UIImage imageNamed:@"Igloo.png"],
                    [UIImage imageNamed:@"Spaceship.png"]];
}


- (IBAction)switchImage
{
    //set up crossfade transition
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionFade;
    //apply transition to imageview backing layer
    [self.imageView.layer addAnimation:transition forKey:nil];
    //cycle to next image
    UIImage *currentImage = self.imageView.image;
    NSUInteger index = [self.images indexOfObject:currentImage];
    index = (index + 1) % [self.images count];
    self.imageView.image = self.images[index];
}

@end
 ```

你可以从代码中看出，过渡动画和之前的属性动画或者动画组添加到图层上的方式一致，都是通过-addAnimation:forKey:方法。但是和属性动画不同的是，对指定的图层一次只能使用一次CATransition，因此，无论你对动画的键设置什么值，过渡动画都会对它的键设置成“transition”，也就是常量kCATransition。

![](lesson7_3.jpeg)

###隐式过渡
CATransision可以对图层任何变化平滑过渡的事实使得它成为那些不好做动画的属性图层行为的理想候选。苹果当然意识到了这点，并且当设置了CALayer的content属性的时候，CATransition的确是默认的行为。但是对于视图关联的图层，或者是其他隐式动画的行为，这个特性依然是被禁用的，但是对于你自己创建的图层，这意味着对图层contents图片做的改动都会自动附上淡入淡出的动画。

###对图层树的动画
CATransition并不作用于指定的图层属性，这就是说你可以在即使不能准确得知改变了什么的情况下对图层做动画，例如，在不知道UITableView哪一行被添加或者删除的情况下，直接就可以平滑地刷新它，或者在不知道UIViewController内部的视图层级的情况下对两个不同的实例做过渡动画。

这些例子和我们之前所讨论的情况完全不同，因为它们不仅涉及到图层的属性，而且是整个图层树的改变--我们在这种动画的过程中手动在层级关系中添加或者移除图层。

这里用到了一个小诡计，要确保CATransition添加到的图层在过渡动画发生时不会在树状结构中被移除，否则CATransition将会和图层一起被移除。一般来说，你只需要将动画添加到被影响图层的superlayer。

```
#import "AppDelegate.h"
#import "FirstViewController.h" 
#import "SecondViewController.h"
#import 
@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    UIViewController *viewController1 = [[FirstViewController alloc] init];
    UIViewController *viewController2 = [[SecondViewController alloc] init];
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[viewController1, viewController2];
    self.tabBarController.delegate = self;
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    ￼//set up crossfade transition
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionFade;
    //apply transition to tab bar controller's view
    [self.tabBarController.view.layer addAnimation:transition forKey:nil];
}
@end
```

###自定义动画

我们证实了过渡是一种对那些不太好做平滑动画属性的强大工具，但是CATransition的提供的动画类型太少了。

更奇怪的是苹果通过UIView +transitionFromView:toView:duration:options:completion:和+transitionWithView:duration:options:animations:方法提供了Core Animation的过渡特性。但是这里的可用的过渡选项和CATransition的type属性提供的常量完全不同。UIView过渡方法中options参数可以由如下常量指定：

```
UIViewAnimationOptionTransitionFlipFromLeft 
```

事实证明，对图层做截图还是很简单的。CALayer有一个`-renderInContext:`方法，可以通过把它绘制到Core Graphics的上下文中捕获当前内容的图片，然后在另外的视图中显示出来。如果我们把这个截屏视图置于原始视图之上，就可以遮住真实视图的所有变化，于是重新创建了一个简单的过渡效果。
清单8.14演示了一个基本的实现。我们对当前视图状态截图，然后在我们改变原始视图的背景色的时候对截图快速转动并且淡出，图8.5展示了我们自定义的过渡效果。
为了让事情更简单，我们用UIView `-animateWithDuration:completion:`方法来实现。虽然用CABasicAnimation可以达到同样的效果，但是那样的话我们就需要对图层的变换和不透明属性创建单独的动画，然后当动画结束的是在CAAnimationDelegate中把coverView从屏幕中移除。

```
@implementation ViewController
- (IBAction)performTransition
{
    //preserve the current view snapshot
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *coverImage = UIGraphicsGetImageFromCurrentImageContext();
    //insert snapshot view in front of this one
    UIView *coverView = [[UIImageView alloc] initWithImage:coverImage];
    coverView.frame = self.view.bounds;
    [self.view addSubview:coverView];
    //update the view (we'll simply randomize the layer background color)
    CGFloat red = arc4random() / (CGFloat)INT_MAX;
    CGFloat green = arc4random() / (CGFloat)INT_MAX;
    CGFloat blue = arc4random() / (CGFloat)INT_MAX;
    self.view.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    //perform animation (anything you like)
    [UIView animateWithDuration:1.0 animations:^{
        //scale, rotate and fade the view
        CGAffineTransform transform = CGAffineTransformMakeScale(0.01, 0.01);
        transform = CGAffineTransformRotate(transform, M_PI_2);
        coverView.transform = transform;
        coverView.alpha = 0.0;
    } completion:^(BOOL finished) {
        //remove the cover view now we're finished with it
        [coverView removeFromSuperview];
    }];
}
@end
```
这里有个警告：-renderInContext:捕获了图层的图片和子图层，但是不能对子图层正确地处理变换效果，而且对视频和OpenGL内容也不起作用。但是用CATransition，或者用私有的截屏方式就没有这个限制了。


##在动画过程中取消动画
之前提到过，你可以用-addAnimation:forKey:方法中的key参数来在添加动画之后检索一个动画，使用如下方法：

```
- (CAAnimation *)animationForKey:(NSString *)key;
```
但并不支持在动画运行过程中修改动画，所以这个方法主要用来检测动画的属性，或者判断它是否被添加到当前图层中。
为了终止一个指定的动画，你可以用如下方法把它从图层移除掉：

```
- (void)removeAnimationForKey:(NSString *)key;
```
或者移除所有动画：

```
- (void)removeAllAnimations;
```

动画一旦被移除，图层的外观就立刻更新到当前的模型图层的值。一般说来，动画在结束之后被自动移除，除非设置removedOnCompletion为NO，如果你设置动画在结束之后不被自动移除，那么当它不需要的时候你要手动移除它；否则它会一直存在于内存中，直到图层被销毁。

我们来扩展之前旋转飞船的示例，这里添加一个按钮来停止或者启动动画。这一次我们用一个非nil的值作为动画的键，以便之后可以移除它。-animationDidStop:finished:方法中的flag参数表明了动画是自然结束还是被打断，我们可以在控制台打印出来。如果你用停止按钮来终止动画，它会打印NO，如果允许它完成，它会打印YES。

```
@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, strong) CALayer *shipLayer;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //add the ship
    self.shipLayer = [CALayer layer];
    self.shipLayer.frame = CGRectMake(0, 0, 128, 128);
    self.shipLayer.position = CGPointMake(150, 150);
    self.shipLayer.contents = (__bridge id)[UIImage imageNamed: @"Ship.png"].CGImage;
    [self.containerView.layer addSublayer:self.shipLayer];
}

- (IBAction)start
{
    //animate the ship rotation
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.rotation";
    animation.duration = 2.0;
    animation.byValue = @(M_PI * 2);
    animation.delegate = self;
    [self.shipLayer addAnimation:animation forKey:@"rotateAnimation"];
}

- (IBAction)stop
{
    [self.shipLayer removeAnimationForKey:@"rotateAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    //log that the animation stopped
    NSLog(@"The animation stopped (finished: %@)", flag? @"YES": @"NO");
}

@end
```










