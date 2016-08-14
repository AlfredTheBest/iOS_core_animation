//
//  SlideMenuButton.h
//  JKGooeySlideMenuDemo
//
//  Created by Jack on 16/8/14.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlideMenuButton : UIView

/**
 *  onvenient init method
 *
 *  @param title title
 *
 *  @return object
 */
-(id)initWithTitle:(NSString *)title;


/**
 *  The button color
 */
@property(nonatomic,strong)UIColor *buttonColor;



/**
 *  button clicked block
 */
@property(nonatomic,copy)void(^buttonClickBlock)(void);

@end
