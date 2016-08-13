//
//  ViewController.m
//  animatedPageControl
//
//  Created by Jack on 16/8/13.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import "ViewController.h"
#import "DemoCell.h"
#import "AnimatedPageControl.h"

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property(nonatomic,strong)AnimatedPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UICollectionView *demoCollectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pageControl = [[AnimatedPageControl alloc]initWithFrame:CGRectMake(20, 450, 280, 50)];
    self.pageControl.pageCount = 8;
    self.pageControl.unSelectedColor = [UIColor colorWithWhite:0.9 alpha:1];
    self.pageControl.selectedColor = [UIColor redColor];
    self.pageControl.bindScrollView = self.demoCollectionView;
    self.pageControl.shouldShowProgressLine = YES;
    
    self.pageControl.indicatorStyle = IndicatorStyleGooeyCircle;
    self.pageControl.indicatorSize = 20;
    self.pageControl.swipeEnable = YES;
    [self.pageControl display];
    [self.view addSubview:self.pageControl];
}

#pragma mark - UICollectionView delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.pageControl.pageCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DemoCell *democell = (DemoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"democell" forIndexPath:indexPath];
    democell.cellNumLabel.text = [NSString stringWithFormat:@"%ld",indexPath.item + 1];
    
    return democell;
}

#pragma mark - UICollectionViewDataSource

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    //Indicator动画
    [self.pageControl.indicator animateIndicatorWithScrollView:scrollView andIndicator:self.pageControl];
    
    if (scrollView.dragging || scrollView.isDecelerating || scrollView.tracking) {
        //背景线条动画
        [self.pageControl.pageControlLine animateSelectedLineWithScrollView:scrollView];
    }
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    
    self.pageControl.indicator.lastContentOffset = scrollView.contentOffset.x;
    
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    
    
    [self.pageControl.indicator restoreAnimation:@(1.0/self.pageControl.pageCount)];
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    self.pageControl.indicator.lastContentOffset = scrollView.contentOffset.x;
}


#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
