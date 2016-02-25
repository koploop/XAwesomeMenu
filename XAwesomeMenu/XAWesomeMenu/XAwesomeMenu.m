//
//  XAwesomeMenu.m
//  CMuneBarDemo
//
//  Created by ErosLii on 16/2/24.
//  Copyright © 2016年 XPay. All rights reserved.
//

#import "XAwesomeMenu.h"
#import "AnimationTool.h"

#define kStartMenuWidth          self.frame.size.width
#define kStartMenuHeight         self.frame.size.height
#define kRotationAngle           M_PI / 20

//长按动画
#define kAnimationLayerWidth    100     //波纹动画大小
#define kAnimationDuration      1.0f    //动画时间

@interface XAwesomeMenu ()
//==========================Menu属性相关==================================
//=======================================================================
@property (nonatomic,strong) NSArray     *itemsImages;
@property (nonatomic,strong) NSArray     *itemsHeighightedImages;
@property (nonatomic,strong) UIView      *startMenu;
@property (nonatomic,strong) UIImageView *contentImageView; //StartMenu ContentImageView
@property (nonatomic,strong) NSArray     *menuItems;
//==========================长按动画相关==================================
//=======================================================================
@property (nonatomic, strong) CAAnimationGroup *animaTionGroup;
@property (nonatomic, strong) CADisplayLink    *disPlayLink;//类似定时器
//==========================拖拽效果相关==================================
//=======================================================================
@property (nonatomic, assign) BOOL                   isExpandDrag;  //标记拖拽之前的状态
@property (nonatomic, strong) UIPanGestureRecognizer *pan;          //拖拽手势,使用KVC赋值才能addObserver

@end

@implementation XAwesomeMenu

#pragma mark - Public
- (instancetype)initMenuWithType:(XMenuType)type
                            size:(CGSize)size
                     itemsImages:(NSArray *)itemsImages
          itemsHeighightedImages:(NSArray *)itemsHeighightedImages {
    if ([super init]) {
        self.itemsImages = itemsImages;
        self.itemsHeighightedImages = itemsHeighightedImages;
        self.isExpand = NO;
        self.menuType = type;
        self.frame = CGRectMake(0, 0, size.width, size.height);
        self.layer.cornerRadius = size.width / 2.0;
        self.backgroundColor = [UIColor redColor];
        [self configureSubviews];
    }
    return self;
}

/**
 *  显示菜单
 */
-(void)showXAwesomeMenu {
    if (!self.isExpand) {
        self.isExpand = YES;
        
        if ([self.delegate respondsToSelector:@selector(awesomeMenuDidShow:)]) {
            [self.delegate awesomeMenuDidShow:self];
        }
        
        switch (self.menuType) {
            case XMenuType_windRight:
            case XMenuType_windLeft:
                [self showItemWithWindType];
                break;
            case XMenuType_lineUp:
            case XMenuType_lineRight:
            case XMenuType_lineDown:
            case XMenuType_lineLeft:
                [self showItemWithLineType];
                break;
            case XMenuType_fanShapeUp:
            case XMenuType_fanShapeRight:
            case XMenuType_fanShapeDown:
            case XMenuType_fanShapeLeft:
                [self showItemWithFanShapeType];
                break;
            default:
                break;
        }
    } else {
        [self hideXAwesomeMenu];
    }
}

/**
 *  隐藏菜单
 */
-(void)hideXAwesomeMenu {
    for (XMenuItem *item in self.menuItems) {
        [item itemHideWithType:self.menuType];
    }
    if ([self.delegate respondsToSelector:@selector(awesomeMenuDidHide:)]) {
        [self.delegate awesomeMenuDidHide:self];
    }
    self.isExpand = NO;
    
}

#pragma mark - Helper method

#pragma mark - 弯曲状
/**
 *  弯曲向上展开
 */
- (void)showItemWithWindType {
    NSInteger count = self.menuItems.count;
    for (XMenuItem *item in self.menuItems) {
        [item windType:self.menuType itemShowWithAngle:kRotationAngle * count];
        count --;
    }
}

#pragma mark - 直线状
/**
 *  直线形状展开
 */
- (void)showItemWithLineType {
    switch (self.menuType) {
        case XMenuType_lineUp:
            [self showLineTypeWithRadius:CGPointMake(kStartMenuWidth/2, kStartMenuHeight/2) offset:CGSizeMake(0, -(kStartMenuHeight + 10))];
            break;
        case XMenuType_lineRight:
            [self showLineTypeWithRadius:CGPointMake(kStartMenuWidth/2, kStartMenuHeight/2) offset:CGSizeMake(kStartMenuHeight + 10, 0)];
            break;
        case XMenuType_lineDown:
            [self showLineTypeWithRadius:CGPointMake(kStartMenuWidth/2, kStartMenuHeight/2) offset:CGSizeMake(0, kStartMenuHeight + 10)];
            break;
        case XMenuType_lineLeft:
            [self showLineTypeWithRadius:CGPointMake(kStartMenuWidth/2, kStartMenuHeight/2) offset:CGSizeMake(-(kStartMenuHeight + 10), 0)];
            break;
        default:
            break;
    }
}

/**
 *  直线类型下按钮展开的偏移
 *  @param radius       半径
 *  @param offset       偏移量(二维,x左右方向,y上下方向)
 */
- (void)showLineTypeWithRadius:(CGPoint)radius offset:(CGSize)offset {
    
    CGFloat count = self.menuItems.count;
    for (XMenuItem *item in self.menuItems) {
        //根据偏移量计算目标坐标点
        CGPoint targetPoint = [self caculateTargetPointWithRadius:radius offset:offset index:count];
        [item lineType:self.menuType itemShowWithTargetPoint:targetPoint];
        count --;
    }
}

/**
 *  根据按钮的偏移计算出目标点
 *  @param radius 半径
 *  @param offset 偏移量
 *  @param index  序列号
 */
- (CGPoint)caculateTargetPointWithRadius:(CGPoint)radius offset:(CGSize)offset index:(NSInteger)index {
    CGFloat x = radius.x;
    CGFloat y = radius.y;
    x += offset.width * index;
    y += offset.height * index;
    CGPoint point = CGPointMake(x, y);
    return point;
}


#pragma mark - 扇形状
/**
 *  扇形展开
 */
- (void)showItemWithFanShapeType {
    switch (self.menuType) {
        case XMenuType_fanShapeUp:
            [self showFanShapeTypeWithOffsetAngle:0];
            break;
        case XMenuType_fanShapeRight:
            [self showFanShapeTypeWithOffsetAngle:- M_PI / 2.0];
            break;
        case XMenuType_fanShapeDown:
            [self showFanShapeTypeWithOffsetAngle:- M_PI];
            break;
        case XMenuType_fanShapeLeft:
            [self showFanShapeTypeWithOffsetAngle:M_PI / 2.0];
            break;
        default:
            break;
    }
}

/**
 *  扇形状态下Item展示
 *  @param offsetAngle 扇形顺时针转的角度
 */
- (void)showFanShapeTypeWithOffsetAngle:(CGFloat)offsetAngle {

    CGFloat count = self.menuItems.count;
    for (XMenuItem *item in self.menuItems) {
        //计算每个按钮的偏移角度
        CGFloat angle = [self caculateFanShapeAngleWithOffsetAngle:offsetAngle index:count];
        [item fanShapeType:self.menuType itemShowWithAngle:angle];
        count -- ;
    }
}

/**
 *  扇形状态下计算偏移角度
 *  @param offsetAngle 偏移角度
 *  @param index       序列
 *  @return 偏移的角度
 */
- (CGFloat)caculateFanShapeAngleWithOffsetAngle:(CGFloat)offsetAngle index:(NSInteger)index {
    
    CGFloat angle = M_PI / (self.menuItems.count);
    angle = angle * index - angle / 2.0 + offsetAngle;
    return angle;
}




#pragma mark - Setter && Getter

- (void)setStartMenuImage:(UIImage *)startMenuImage {
    [self.contentImageView setImage:startMenuImage];
}

- (void)setStartMenuHeighLightImage:(UIImage *)startMenuHeighLightImage {
    [self.contentImageView setHighlightedImage:startMenuHeighLightImage];
}

- (void)setStartMenuTitle:(NSString *)startMenuTitle {
    
}

- (void)setMenuType:(XMenuType)menuType {
    _menuType = menuType;
}

- (NSArray *)menuItems {
    if (!_menuItems) {
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:self.itemsImages.count];
        for (NSInteger i = 0; i < self.itemsImages.count; i++) {
            UIImage *image = [UIImage imageNamed:self.itemsImages[i]];
            UIImage *hImage = [UIImage imageNamed:self.itemsHeighightedImages[i]];
            XMenuItem *menuItem = [XMenuItem menuItemWithSize:CGSizeMake(kStartMenuWidth, kStartMenuHeight) image:image heightImage:hImage target:self action:@selector(tapItem:)];
            menuItem.tag = 100 + i;
            menuItem.center = self.center;
            [items addObject:menuItem];
        }
        _menuItems = items;
    }
    return _menuItems;
}

#pragma mark - Private

-(void)configureSubviews {
    //StartMenu
    self.startMenu = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kStartMenuWidth, kStartMenuHeight)];
    self.startMenu.backgroundColor     = [UIColor blueColor];
    self.startMenu.layer.cornerRadius  = self.frame.size.width / 2;
    self.startMenu.layer.masksToBounds = YES;
    [self addSubview:self.startMenu];
    //contentImageView
    self.contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, kStartMenuWidth - 10, kStartMenuHeight - 10)];
    self.contentImageView.layer.cornerRadius  = (kStartMenuWidth - 10) / 2;
    self.contentImageView.layer.masksToBounds = YES;
    self.contentImageView.layer.borderColor = [UIColor redColor].CGColor;
    self.contentImageView.layer.borderWidth = 2;
    //添加手势
    UITapGestureRecognizer *tap         = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu:)];
    UIPanGestureRecognizer *pan         = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragMenu:)];
    [self setPan:pan];
    [self addObserver:self forKeyPath:@"pan.state" options:NSKeyValueObservingOptionNew context:NULL];
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressMenu:)];
    [self.startMenu addGestureRecognizer:tap];
    [self.startMenu addGestureRecognizer:self.pan];
    [self.startMenu addGestureRecognizer:press];
    
    //MenuItems
    for (XMenuItem *item in self.menuItems) {
        [self addSubview:item];
    }
    [self addSubview:_startMenu];
    [self addSubview:self.contentImageView];
}


#pragma mark - Action Selector

//item的点击事件
- (void)tapItem:(XMenuItem *)menu {
    if (self.delegate && [self.delegate respondsToSelector:@selector(awesomeMenu:didSelectIndex:)]) {
        [self.delegate awesomeMenu:self didSelectIndex:menu.tag - 100];
    }
}

//startMenu 点击
- (void)showMenu:(UITapGestureRecognizer *)tap {
    [self showXAwesomeMenu];
}

//startMenu 拖拽
-(void)dragMenu:(UIPanGestureRecognizer *)pan {

    //这里实现类似百度iPad客户端首页的效果,如果拖拽之前是展开状态,则拖拽时候先收起,停止拖拽之后再展开
    if (self.isExpand) {
        self.isExpandDrag = YES;
        if (pan.state == UIGestureRecognizerStateBegan) {
            [self hideXAwesomeMenu];
        }
    }
    if (pan.state == UIGestureRecognizerStateEnded) {
        self.isExpandDrag = NO;
    }
    CGPoint location = [pan locationInView:[UIApplication sharedApplication].keyWindow];
    self.center = location;
}

//拖拽监测
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"pan.state"] && self.pan.state == UIGestureRecognizerStateEnded && self.isExpandDrag) {
        [self showXAwesomeMenu];
    }
}

//startMenu 长按
- (void)pressMenu:(UILongPressGestureRecognizer *)press {

    if (press.state != UIGestureRecognizerStateEnded && press.state != UIGestureRecognizerStateChanged) {
        [self startLongPressAnimation];
    } else {
        NSLog(@"LongPress End");
        [self invalidateLayerAnimation];
    }
}



#pragma mark - 重写父类方法
/**
 *  重写hitTest:withEvent:方法，检查是否点击item
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *result = [super hitTest:point withEvent:event];
    if (self.isExpand) {
        for (XMenuItem *item in self.menuItems) {
            CGPoint buttonPoint = [item convertPoint:point fromView:self];
            if ([item pointInside:buttonPoint withEvent:event]) {
                return item;
            }
            
        }
    }
    return result;
}

#pragma mark - 长按动画
- (void)startLongPressAnimation {
    self.disPlayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(lastAnimation)];
    self.disPlayLink.frameInterval = 40;
    [self.disPlayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)lastAnimation
{
    [self layerAnimation];
}

- (void)layerAnimation {
    CALayer *layer = [[CALayer alloc] init];
    layer.bounds = CGRectMake(0, 0, kAnimationLayerWidth, kAnimationLayerWidth);
    layer.position = CGPointMake(self.layer.bounds.size.width / 2, self.layer.bounds.size.height / 2);
    layer.cornerRadius = kAnimationLayerWidth / 2;
    UIColor *color = [UIColor colorWithRed:arc4random()%10*0.1 green:arc4random()%10*0.1 blue:arc4random()%10*0.1 alpha:1];
    layer.backgroundColor = color.CGColor;
    [self.layer addSublayer:layer];
    
    CAMediaTimingFunction *defaultCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    self.animaTionGroup = [CAAnimationGroup animation];
    self.animaTionGroup.delegate = self;
    self.animaTionGroup.duration = kAnimationDuration;
    self.animaTionGroup.removedOnCompletion = YES;
    self.animaTionGroup.timingFunction = defaultCurve;
    
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
    basicAnimation.fromValue = @(self.frame.size.width/kAnimationLayerWidth);
    basicAnimation.toValue = @1.0f;
    basicAnimation.duration = kAnimationDuration;
    
    CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    keyframeAnimation.duration = kAnimationDuration;
    keyframeAnimation.values = @[@0.8,@0.6,@0.4,@0.2,@0];
    keyframeAnimation.keyTimes = @[@0,@0.25,@0.5,@0.75,@1];
    keyframeAnimation.removedOnCompletion = YES;
    
    NSArray *animationArr = @[basicAnimation, keyframeAnimation];
    self.animaTionGroup.animations = animationArr;
    [layer addAnimation:self.animaTionGroup forKey:nil];
    
    [self performSelector:@selector(removeLayer:) withObject:layer afterDelay:0.9f];
}

- (void)removeLayer:(CALayer *)layer {
    [layer removeFromSuperlayer];
}

- (void)invalidateLayerAnimation {
    [self.layer removeAllAnimations];
    [_disPlayLink invalidate];
    _disPlayLink = nil;
}

@end
