//
//  XAwesomeMenu.h
//  CMuneBarDemo
//
//  Created by ErosLii on 16/2/24.
//  Copyright © 2016年 XPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMenuUtility.m"
#import "XMenuItem.h"

@class XAwesomeMenu;
@protocol XAwesomeMenuDelegate <NSObject>
@required
-(void)awesomeMenu:(XAwesomeMenu *)menu didSelectIndex:(NSInteger)index;
@optional
-(void)awesomeMenuDidShow:(XAwesomeMenu *)menu;
-(void)awesomeMenuDidHide:(XAwesomeMenu *)menu;
@end


@interface XAwesomeMenu : UIView

@property (nonatomic, weak  ) id<XAwesomeMenuDelegate> delegate;
@property (nonatomic, assign) XMenuType            menuType;

//StartMenu
@property (nonatomic, strong) UIImage              *startMenuImage;
@property (nonatomic, strong) UIImage              *startMenuHeighLightImage;
@property (nonatomic, copy  ) NSString             *startMenuTitle; /**< 暂时不用 */

@property (nonatomic, assign) BOOL                 isExpand;    //是否展开状态

//==============================================================

- (instancetype)initMenuWithType:(XMenuType)type size:(CGSize)size itemsImages:(NSArray *)itemsImages itemsHeighightedImages:(NSArray *)itemsHeighightedImages;

-(void)showXAwesomeMenu;

-(void)hideXAwesomeMenu;



@end
