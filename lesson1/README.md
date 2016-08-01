
## 寄宿图
### contents属性
CALayer的寄宿图即图层中包含的图。

CALayer有一个属性叫做contents，这个属性的类型被定义为id，意味着它可以是任何类型的对象。在这种情况下，你可以给contents属性赋任何值，你的app仍然能够编译通过。但是，在实践中，如果你给contents赋的不是CGImage，那么你得到的图层将是空白的。

`contents`这个奇怪的表现是由Mac OS的历史原因造成的。它之所以被定义为id类型，是因为在Mac OS系统上，这个属性对CGImage和NSImage类型的值都起作用。如果你试图在iOS平台上将UIImage的值赋给它，只能得到一个空白的图层。事实上，你真正要赋值类型应该是CGImageRef,它是一个指向CGImage结构的指针。UIImage有一个CGImage属性，它返回一个”CGImageRef”，如果你如果想要把这个值直接赋给CALayer的contents，那你将会得到一个编译错误。因为CGImageRef并不是一个真正的Cocoa对象，而是一个Core Foundation类型。

尽管Core Foundation 类型跟Cocoa对象在运行时貌似很像(被称作toll-free bridging)，他们并不是一个类型兼容的，不过你可以通过bridged关键字转换。如果你要给图层的寄宿图赋值，你可以按照以下这个方法:

```
layer.contents= (__bridge id)image.CGImage;
```

*contentGravity*

为了适配视图,UIView用这个方法`view.contentMode = UIViewContentModeScaleAspectFit`;
CALayer与`contentMode`对应的属性叫做`contentsGravity`，但是它是一个NSString类型。和`contentMode`一样，`contentGravity`的目的是为了决定内容在图层的边界中怎么对齐。

*contentScale*

`contentScale`属性定义了寄宿图的像素尺寸和视图大小的比例，默认情况下它是一个值为1.0的浮点数。如果是1.0，将会以每个点1个像素绘制图片，如果设置为2.0，则会以每个点2个像素绘制图片，这个就是我们熟知的Retina屏幕。

`contentScale`的目的并不是那么明显。它并不是总会对屏幕时的寄宿图有影响。如果你尝试设置不同的值，你会发现根本没任何影响。因为`contents`由于设置了`contentFravity`属性，所以它已经被拉伸了以适应图层的边界。


*maskToBounds*

UIView又一个叫做`clipsToBounds`的属性可以用来决定是否显示超出边界的内容，CALayer对应的属性叫做`maskToBounds`。

*contentsRect*

contentRect允许我们在图层边框里显示寄宿图的一个子域。这涉及到图片是如何拉伸的，所以要比`contentsGravity`灵活多了。它使用了单位坐标，单位坐标指定在0到1之间，是一个相对值。

contentsRect在app中最有趣的地方在于一个叫做image sprites（图片拼合）的用法。如果你有游戏编程的经验，那么你一定对图片拼合的概念很熟悉，图片能够在屏幕上独立地变更位置。抛开游戏编程不谈，这个技术常用来指代载入拼合的图片，跟移动图片一点关系也没有。

典型地，图片拼合后可以打包整合到一张大图上一次性载入。相比多次载入不同的图片，这样做能够带来很多方面的好处：内存使用，载入时间，渲染性能等等

```
@interface ViewController ()
@property (nonatomic, weak) IBOutlet UIView *coneView;
@property (nonatomic, weak) IBOutlet UIView *shipView;
@property (nonatomic, weak) IBOutlet UIView *iglooView;
@property (nonatomic, weak) IBOutlet UIView *anchorView;
@end

@implementation ViewController

- (void)addSpriteImage:(UIImage *)image withContentRect:(CGRect)rect ￼toLayer:(CALayer *)layer //set image
{
  layer.contents = (__bridge id)image.CGImage;

  //scale contents to fit
  layer.contentsGravity = kCAGravityResizeAspect;

  //set contentsRect
  layer.contentsRect = rect;
}

- (void)viewDidLoad 
{
  [super viewDidLoad]; //load sprite sheet
  UIImage *image = [UIImage imageNamed:@"Sprites.png"];
  //set igloo sprite
  [self addSpriteImage:image withContentRect:CGRectMake(0, 0, 0.5, 0.5) toLayer:self.iglooView.layer];
  //set cone sprite
  [self addSpriteImage:image withContentRect:CGRectMake(0.5, 0, 0.5, 0.5) toLayer:self.coneView.layer];
  //set anchor sprite
  [self addSpriteImage:image withContentRect:CGRectMake(0, 0.5, 0.5, 0.5) toLayer:self.anchorView.layer];
  //set spaceship sprite
  [self addSpriteImage:image withContentRect:CGRectMake(0.5, 0.5, 0.5, 0.5) toLayer:self.shipView.layer];
}
@end
```

*contentCenter*

`contentsCenter`其实是一个CGRect，他定义一个固定的边框和一个在图层上可拉伸区域。改变`contentsCenter`的值并不会影响到寄宿图的显示，除非这个图层的大小改变了，你才看到效果。

默认情况下，contentsCenter是{0,0,1,1}，这意味着如果大小改变了，那么寄宿图将会均匀的拉盛开。他工作起来的效果和UIImage里的-resizableImageWithCapInsets:方法效果非常类似，只是它可以运用到任何寄宿图，甚至包括Core Graphics运行时绘制的图形。

###Custom Drawing
给contents赋CGImage的值不是唯一的设置寄宿图的方法。我们也可以直接用Core Graphics直接绘制寄宿图。能够通过继承UIView并实现-drawRect:方法来自定义绘制。

-drawRect: 方法没有默认的实现，因为对UIView来说，寄宿图并不是必须的，它不在意那到底是单调的颜色还是有一个图片的实例。如果UIView检测到-drawRect: 方法被调用了，它就会为视图分配一个寄宿图，这个寄宿图的像素尺寸等于视图大小乘以 contentsScale的值。

如果你不需要寄宿图，那就不要创建这个方法了，这会造成CPU资源和内存的浪费，这也是为什么苹果建议：如果没有自定义绘制的任务就不要在子类中写一个空的-drawRect:方法。

*drawRect:方法创建的就是CALayer的寄宿图。*
    
当视图在屏幕上出现的时候 -drawRect:方法就会被自动调用。-drawRect:方法里面的代码利用Core Graphics去绘制一个寄宿图，然后内容就会被缓存起来直到它需要被更新（通常是因为开发者调用了-setNeedsDisplay方法，尽管影响到表现效果的属性值被更改时，一些视图类型会被自动重绘，如bounds属性）。虽然-drawRect:方法是一个UIView方法，事实上都是底层的CALayer安排了重绘工作和保存了因此产生的图片。
    CALayer有一个可选的delegate属性，实现了CALayerDelegate协议，当CALayer需要一个内容特定的信息时，就会从协议中请求。CALayerDelegate是一个非正式协议，其实就是说没有CALayerDelegate @protocol可以让你在类里面引用啦。你只需要调用你想调用的方法，CALayer会帮你做剩下的。（delegate属性被声明为id类型，所有的代理方法都是可选的）。
    当需要被重绘时，CALayer会请求它的代理给他一个寄宿图来显示。它通过调用下面这个方法做到的:
    
```
(void)displayLayer:(CALayerCALayer *)layer;
```    

  趁着这个机会，如果代理想直接设置contents属性的话，它就可以这么做，不然没有别的方法可以调用了。如果代理不实现-displayLayer:方法，CALayer就会转而尝试调用下面这个方法：
  
```
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx;
```
###实例

```
@implementation ViewController
- (void)viewDidLoad
{
  [super viewDidLoad];
  ￼
  //create sublayer
  CALayer *blueLayer = [CALayer layer];
  blueLayer.frame = CGRectMake(50.0f, 50.0f, 100.0f, 100.0f);
  blueLayer.backgroundColor = [UIColor blueColor].CGColor;

  //set controller as layer delegate
  blueLayer.delegate = self;

  //ensure that layer backing image uses correct scale
  blueLayer.contentsScale = [UIScreen mainScreen].scale; //add layer to our view
  [self.layerView.layer addSublayer:blueLayer];

  //force layer to redraw
  [blueLayer display];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
  //draw a thick red circle
  CGContextSetLineWidth(ctx, 10.0f);
  CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
  CGContextStrokeEllipseInRect(ctx, layer.bounds);
}
@end
```