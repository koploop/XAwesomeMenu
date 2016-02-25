//
//  XMenuUtility.m
//  CMuneBarDemo
//
//  Created by ErosLii on 16/2/24.
//  Copyright © 2016年 XPay. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  @author LiiHen, 02-23 19:02:28
 *  @brief 菜单展示的方式
 */
typedef NS_ENUM(NSInteger,XMenuType) {
    XMenuType_windLeft = 0,     /**< 弯曲 */
    XMenuType_windRight,
    XMenuType_lineUp,           /**< 直线 */
    XMenuType_lineRight,
    XMenuType_lineDown,
    XMenuType_lineLeft,
    XMenuType_fanShapeUp,       /**< 扇形 */
    XMenuType_fanShapeRight,
    XMenuType_fanShapeDown,
    XMenuType_fanShapeLeft
};
