//
//  GooeySlideMenu.h
//  JKGooeySlideMenuDemo
//
//  Created by Jack on 16/8/14.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MenuButtonClickedBlock)(NSInteger index,NSString *title,NSInteger titleCounts);

@interface GooeySlideMenu : UIView

/**
 *  Convenient init method
 *
 *  @param titles Your menu options
 *
 *  @return object
 */

-(id)initWithTitles:(NSArray *)titles;


/**
 *  Custom init method
 *
 *  @param titles Your menu options
 *
 *  @return object
 */
-(id)initWithTitles:(NSArray *)titles withButtonHeight:(CGFloat)height withMenuColor:(UIColor *)menuColor withBackBlurStyle:(UIBlurEffectStyle)style;


/**
 *  Method to trigger the animation
 */
-(void)trigger;


/**
 *  The block of menu buttons cliced
 */
@property(nonatomic,copy)MenuButtonClickedBlock menuClickBlock;


@end
