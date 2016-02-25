//
//  XMenuItem.m
//  CMuneBarDemo
//
//  Created by ErosLii on 16/2/23.
//  Copyright © 2016年 XPay. All rights reserved.
//

#import "XMenuItem.h"
#import "AnimationTool.h"

@interface XMenuItem (){
    CGPoint _orginPoint; //记录平移前的位置
    CGFloat _angle;      //记录平移的角度
    CGFloat _radius;     //平移半径
    CGPoint _targetPoint;//平移目标点
}

@end

@implementation XMenuItem

-(instancetype)initWithSize:(CGSize)size image:(UIImage *)image heightImage:(UIImage *)heightImage target:(id)target action:(SEL)action {
    self = [super init];
    if (self) {
        [self setImage:image forState:UIControlStateNormal];
        [self setImage:heightImage forState:UIControlStateHighlighted];
        [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        self.frame = CGRectMake(0, 0, size.width, size.height);
        self.layer.cornerRadius = size.width / 2.0;
        _radius = 400.0f;
    }
    return self;
}

+(XMenuItem *)menuItemWithSize:(CGSize)size image:(UIImage *)image heightImage:(UIImage *)heightImage target:(id)target action:(SEL)action {
    return [[XMenuItem alloc] initWithSize:size image:image heightImage:heightImage target:target action:action];
}

- (void)itemHideWithType:(XMenuType)type {
    switch (type) {
        case XMenuType_windLeft:
        case XMenuType_windRight:
            [self windItemHideWithType:type];
            break;
            default:
            [self itemHideWithPoint:_orginPoint];
            break;
    }
}

#pragma mark - 显示动画

/**
 *  弯曲状下根据偏移角度展示
 *  @param angle 偏移角度
 */
- (void)windType:(XMenuType)type itemShowWithAngle:(CGFloat)angle {
    //展开动画属性设置
    //向右
    _angle = angle;
    CGFloat startAngle = - M_PI;
    CGPoint center = CGPointMake(self.center.x + _radius, self.center.y);
    _orginPoint = center;
    CGFloat endAngle = startAngle + angle;
    BOOL clockwise = NO;
    //向左
    if (type == XMenuType_windLeft) {
        startAngle = 0;
        center = CGPointMake(self.center.x - _radius, self.center.y);
        clockwise = YES;
        endAngle = startAngle - angle;
        _orginPoint = center;
    }
    
    //添加动画
    //1）移动动画
    CAKeyframeAnimation *moveAccAnimation = [AnimationTool moveAccWithDuration:0.4 fromPoint:self.center startAngle:startAngle endAngle:endAngle center:center radius:_radius delegate:self clockwise:clockwise];
    //2）缩放动画
    CABasicAnimation *scaleAnimation = [AnimationTool scaleAnimationWithDuration:0.4 frameValue:0.1 toValue:1.0];
    //3）透明度动画
    CABasicAnimation *opacityAnimation = [AnimationTool opacityAnimationWithDuration:0.4 frameValue:0.3 toValue:1];
    //4)动画组
    CAAnimationGroup *groupAnimation = [AnimationTool groupAnimationWithAnimations:@[scaleAnimation,moveAccAnimation,opacityAnimation] duration:0.4];
    //5）将动画添加到图层
    [self.layer addAnimation:groupAnimation forKey:nil];
    
    //动画完成后设置item的位置
    CGFloat y;
    CGFloat temp;
    CGFloat x;
    if (type == XMenuType_windLeft) {
        y = self.center.y + sin(endAngle) * _radius;
        temp = fabs(cos(endAngle) * _radius);
        x = self.center.x - (_radius - temp);
    } else {
        y = self.center.y + sin(endAngle) * _radius;
        temp = fabs(cos(endAngle) * _radius);
        x = self.center.x + _radius - temp;
    }
    self.center = CGPointMake( x, y);
}


/**
 *  直线类型Item展示到目标点
 *  @param target 目标点
 */
- (void)lineType:(XMenuType)type itemShowWithTargetPoint:(CGPoint)targetPoint {
    _orginPoint = self.center;
    CABasicAnimation *scaleAnimation = [AnimationTool scaleAnimationWithDuration:0.4 frameValue:0.1 toValue:1.0];
    CABasicAnimation *opacityAnimation = [AnimationTool opacityAnimationWithDuration:0.4 frameValue:0.3 toValue:1];
    CAKeyframeAnimation *keyframeAnimation = [AnimationTool moveLineWithDuration:0.4 fromPoint:self.center toPoint:targetPoint delegate:self];
    CAAnimationGroup *groupAnimation = [AnimationTool groupAnimationWithAnimations:@[scaleAnimation,keyframeAnimation,opacityAnimation] duration:0.4];
    
    [self.layer addAnimation:groupAnimation forKey:nil];
    self.center = targetPoint;
}



/**
 *  扇形Item展示
 *  @param angle 角度
 */
- (void)fanShapeType:(XMenuType)type itemShowWithAngle:(CGFloat)angle {
    CGPoint targetPoint = [self caculateTargetPointWithAngle:angle];
    _orginPoint = self.center;
    CABasicAnimation *scaleAnimation = [AnimationTool scaleAnimationWithDuration:0.4 frameValue:0.1 toValue:1.0];
    CABasicAnimation *opacityAnimation = [AnimationTool opacityAnimationWithDuration:0.4 frameValue:0.3 toValue:1];
    CAKeyframeAnimation *keyframeAnimation = [AnimationTool moveLineWithDuration:0.4 fromPoint:self.center toPoint:targetPoint delegate:self];
    CAAnimationGroup *groupAnimation = [AnimationTool groupAnimationWithAnimations:@[scaleAnimation,keyframeAnimation,opacityAnimation] duration:0.4];
    
    [self.layer addAnimation:groupAnimation forKey:nil];
    self.center = targetPoint;
}

/**
 *  根据角度计算出目标点
 *  @param angle 角度
 *  @return 目标点
 */
-(CGPoint)caculateTargetPointWithAngle:(CGFloat)angle{
    CGFloat x = self.center.x;
    CGFloat y = self.center.y;
    
    x += 100 * cos(angle);
    y -= 100 * sin(angle);
    CGPoint targetPoint = CGPointMake(x, y);
    return targetPoint;
}

#pragma mark - 隐藏动画
- (void)windItemHideWithType:(XMenuType)type {
    CGFloat endAngle;
    CGFloat startAngle;
    BOOL clockwise = YES;
    //展开方向
    if (type == XMenuType_windLeft) {
        endAngle = 0;
        startAngle = endAngle - _angle;
        clockwise = NO;
        
    }else{
        endAngle = - M_PI;
        startAngle = endAngle + _angle;
    }
    
    //添加动画
    //1)移动动画
    CAKeyframeAnimation *moveAccAnimation = [AnimationTool moveAccWithDuration:0.4 fromPoint:self.center startAngle:startAngle endAngle:endAngle center:_orginPoint radius:_radius delegate:self clockwise:clockwise];
    //2)缩放动画
    CABasicAnimation *scaleAnimation = [AnimationTool scaleAnimationWithDuration:0.4 frameValue:1 toValue:0.1];
    //3)透明度动画
    CABasicAnimation *opacityAnimation = [AnimationTool opacityAnimationWithDuration:0.4 frameValue:1 toValue:0.3];
    //动画组
    CAAnimationGroup *groupAnimation = [AnimationTool groupAnimationWithAnimations:@[moveAccAnimation,scaleAnimation,opacityAnimation] duration:0.4];
    //将动画添加到图层
    [self.layer addAnimation:groupAnimation forKey:nil];
    
    //动画完成设置item位置
    CGFloat y;
    CGFloat x;
    if (type == XMenuType_windLeft) {
        y = self.center.y - sin(startAngle) * _radius;
        CGFloat temp = _radius - fabs(cos(startAngle) * _radius);
        x = self.center.x + temp;
    }
    else{
        y = self.center.y - sin(startAngle) * _radius;
        CGFloat temp = _radius - fabs(cos(startAngle) * _radius);
        x = self.center.x - temp;
    }
    self.center = CGPointMake(x , y);
}

- (void)itemHideWithPoint:(CGPoint)point {
    //添加动画
    CABasicAnimation *scaleAnimation = [AnimationTool scaleAnimationWithDuration:0.4 frameValue:0.1 toValue:1.0];
    CABasicAnimation *opacityAnimation = [AnimationTool opacityAnimationWithDuration:0.4 frameValue:0.3 toValue:1];
    CAKeyframeAnimation *keyframeAnimation = [AnimationTool moveLineWithDuration:0.4 fromPoint:self.center toPoint:point delegate:self];
    CAAnimationGroup *groupAnimation = [AnimationTool groupAnimationWithAnimations:@[scaleAnimation,keyframeAnimation,opacityAnimation] duration:0.4];
    
    [self.layer addAnimation:groupAnimation forKey:nil];
    self.center = point;
    
}

@end
