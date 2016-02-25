//
//  XMenuItem.h
//  CMuneBarDemo
//
//  Created by ErosLii on 16/2/23.
//  Copyright © 2016年 XPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMenuUtility.m"

@interface XMenuItem : UIButton

/**
*  MenuItem初始化方法
*  @param size        大小
*  @param image       Normal样式下图片
*  @param heightImage 高亮图片
*  @param target      target
*  @param action      action
*/
-(instancetype)initWithSize:(CGSize)size image:(UIImage *)image heightImage:(UIImage *)heightImage target:(id)target action:(SEL)action;
+(XMenuItem *)menuItemWithSize:(CGSize)size image:(UIImage *)image heightImage:(UIImage *)heightImage target:(id)target action:(SEL)action;


#pragma mark - Item的动画展示
- (void)windType:(XMenuType)type itemShowWithAngle:(CGFloat)angle;
- (void)lineType:(XMenuType)type itemShowWithTargetPoint:(CGPoint)targetPoint;
- (void)fanShapeType:(XMenuType)type itemShowWithAngle:(CGFloat)angle;

- (void)itemHideWithType:(XMenuType)type;
@end
