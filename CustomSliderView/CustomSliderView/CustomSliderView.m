//
//  CustomSliderView.m
//  CustomSliderView
//
//  Created by apple on 2018/6/15.
//

#import "CustomSliderView.h"

#import "UIView+ColorOfPoint.h"

//总选项数
#define kUnit ((self.section == 0) ? 4 : self.section)
//结点直径
#define kUnitWidth ((self.unitWidth == 0) ? 5 : self.unitWidth)
//背景色值条高度
#define kTrackingBarHeight ((self.trackingBarHeight == 0) ? 2 : self.trackingBarHeight)
//当前选中点圆环直径
#define kIndicatorHeight ((self.indicatorHeight == 0) ? 21 : self.indicatorHeight)
//预留空间
#define kReservedSpace ((self.reservedSpace == 0) ? 40 : self.reservedSpace)
//十六进制颜色
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]

@interface CustomSliderView ()

@property (nonatomic, strong) UIView *colorView;                            /**< 渐变视图  */
@property (nonatomic, strong) UIView *indicatorView;                        /**< 指示视图  */

@property (nonatomic, assign) CGPoint touchBeginPoint;                      /**< 触摸视图的坐标点  */
@property (nonatomic, assign) NSInteger touchBeginTimestamp;                /**< 开始触摸的时间戳  */

@end

@implementation CustomSliderView

- (void)willMoveToSuperview:(UIView *)newSuperview {
    //添加渐变色视图
    [self addSubview:self.colorView];
    [self addSubview:self.indicatorView];
    //初始化视图
    [self resetView];
}

#pragma mark - 初始化
- (void)resetView {
    
    //获取滑动的色值
    self.indicatorView.backgroundColor = [self.colorView colorOfPoint:CGPointMake(CGRectGetMinX(self.colorView.frame), CGRectGetHeight(self.colorView.frame)/2.0)];
    //确定当前滑动的位置
    CGPoint indicatorViewCenter = self.indicatorView.center;
    self.indicatorView.center = CGPointMake(CGRectGetMinX(self.colorView.frame), indicatorViewCenter.y);
    
    //添加数据点
    CGFloat unit = CGRectGetWidth(self.colorView.frame) / kUnit;
    for (NSInteger i=0; i<=kUnit; i++) {
        //单位距离点
        UIView *unitView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kUnitWidth, kUnitWidth)];
        
        CGFloat centerX = unit * i + CGRectGetMinX(self.colorView.frame);
        CGFloat centerY = CGRectGetHeight(self.frame)/2.0;
        unitView.center = CGPointMake(centerX, centerY);
        unitView.layer.cornerRadius = kUnitWidth/2.0;
        unitView.backgroundColor = [self.colorView colorOfPoint:CGPointMake(centerX - CGRectGetMinX(self.colorView.frame) - ((i == kUnit)?1:0), CGRectGetHeight(self.colorView.frame)/2.0)];
        unitView.userInteractionEnabled = NO;
        [self addSubview:unitView];
        [self insertSubview:unitView atIndex:0];
    }
}

#pragma mark - 手势
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    //获得当前触摸的点
    self.touchBeginPoint = [touch locationInView:self];
    self.touchBeginTimestamp = [self getCurrentTimestamp];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    //获得当前触摸的点
    self.touchBeginPoint = [touch locationInView:self];
    //优化处理，如果从beginTracking 到 continueTracking的时间周期不到60毫秒，则不显示当前触摸的点
    //添加此处理可以避免在单选某个值时，出现选中点跳动的问题
    NSInteger continueTrackTimestamp = [self getCurrentTimestamp];
    if (continueTrackTimestamp - self.touchBeginTimestamp > 60) {
        [self dealTouchMove:self.touchBeginPoint];
    }
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    //处理触摸结束
    [self dealTouchEnd];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    //处理触摸结束
    [self dealTouchEnd];
}

#pragma mark - event
//手势移动
- (void)dealTouchMove:(CGPoint)touchPoint {
    
    //校正位置
    CGFloat locationPointX = touchPoint.x;
    if (touchPoint.x <= CGRectGetMinX(self.colorView.frame)) {
        locationPointX = CGRectGetMinX(self.colorView.frame);
    } else if (touchPoint.x >= CGRectGetMaxX(self.colorView.frame)) {
        locationPointX = CGRectGetMaxX(self.colorView.frame);
    }
    
    CGPoint point = CGPointMake(locationPointX, CGRectGetHeight(self.frame)/2.0);
    //修复数字精准度问题
    //解决滑动到最后时，颜色不一致的问题
    if (point.x >= CGRectGetWidth(self.colorView.frame) - 1) {
        point.x = CGRectGetWidth(self.colorView.frame) - 1;
        
        UIColor *colorOfLastPoint = [self getLastPointColor];
        if (colorOfLastPoint) {
            self.indicatorView.backgroundColor = colorOfLastPoint;
        } else {
            self.indicatorView.backgroundColor = [self.colorView colorOfPoint:[self convertPoint:point toView:self.colorView]];
        }
    } else {
        //获取滑动的色值
        self.indicatorView.backgroundColor = [self.colorView colorOfPoint:[self convertPoint:point toView:self.colorView]];
    }
    
    //确定当前滑动的位置
    CGPoint indicatorViewCenter = self.indicatorView.center;
    self.indicatorView.center = CGPointMake(locationPointX, indicatorViewCenter.y);
    
    //重新计算当前下标
    CGFloat touchX = locationPointX - CGRectGetMinX(self.colorView.frame);
    CGFloat unit = CGRectGetWidth(self.colorView.frame) / (kUnit * 1.0);
    NSInteger index = roundl(touchX / unit);
    if (index < 0) {
        index = 0;
    } else if (index > kUnit) {
        index = kUnit;
    }
    _currentSelectIndex = index;
    if ([self.delegate respondsToSelector:@selector(didSelectAtIndex:color:)]) {
        [self.delegate didSelectAtIndex:self.currentSelectIndex color:self.indicatorView.backgroundColor];
    }
}

//手势结束时
- (void)dealTouchEnd {
    
    //确定最后一次的X坐标
    CGFloat touchX = self.touchBeginPoint.x - CGRectGetMinX(self.colorView.frame);
    //每个单位宽
    CGFloat unit = CGRectGetWidth(self.colorView.frame) / (kUnit * 1.0);
    
    //确定最终的停留位置
    NSInteger index = roundl(touchX / unit);
    if (index < 0) {
        index = 0;
    } else if (index > kUnit) {
        index = kUnit;
    }
    
    self.currentSelectIndex = index;
}

//获取当前时间的毫秒戳
- (NSInteger)getCurrentTimestamp {
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    return interval * 1000;
}

//获取颜色条最后一个点的颜色
- (UIColor *)getLastPointColor {
    NSArray<CALayer *> *layers = self.colorView.layer.sublayers;
    if (layers.count > 0) {
        CALayer *sublayer = layers.lastObject;
        if ([sublayer isKindOfClass:[CAGradientLayer class]]) {
            CAGradientLayer *gradient = (CAGradientLayer *)sublayer;
            if (gradient.colors > 0) {
                CGColorRef ref = (__bridge CGColorRef)(gradient.colors.lastObject);
                return (UIColor *)[UIColor colorWithCGColor:ref];
            }
        }
    }
    return nil;
}

#pragma mark - setter
- (void)setCurrentSelectIndex:(NSInteger)currentSelectIndex {
    _currentSelectIndex = currentSelectIndex;
    
    //每个单位宽
    CGFloat unit = CGRectGetWidth(self.colorView.frame) / (kUnit * 1.0);
    CGPoint indicatorViewCenter = self.indicatorView.center;
    self.indicatorView.center = CGPointMake(unit * currentSelectIndex + CGRectGetMinX(self.colorView.frame), indicatorViewCenter.y);
    //获取滑动的色值
    self.indicatorView.backgroundColor = [self.colorView colorOfPoint:CGPointMake(unit * currentSelectIndex - ((currentSelectIndex == kUnit)?1:0), CGRectGetHeight(self.colorView.frame)/2.0)];
    
    if ([self.delegate respondsToSelector:@selector(didSelectAtIndex:color:)]) {
        [self.delegate didSelectAtIndex:_currentSelectIndex color:self.indicatorView.backgroundColor];
    }
}

#pragma mark - getter
- (UIView *)colorView {
    if (!_colorView) {
        _colorView = [[UIView alloc] initWithFrame:CGRectMake(kReservedSpace, (CGRectGetHeight(self.frame) - kTrackingBarHeight)/2.0, CGRectGetWidth(self.frame) - 2 * kReservedSpace, kTrackingBarHeight)];
        //添加渐变颜色
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = _colorView.bounds;
        //可修改此处的颜色
        gradient.colors = [NSArray arrayWithObjects:
                           (id)UIColorFromHex(0xC15023).CGColor,
                           (id)UIColorFromHex(0x309492).CGColor,
                           (id)UIColorFromHex(0x06D0F8).CGColor, nil];
        
        gradient.startPoint = CGPointMake(0, 0);
        gradient.endPoint = CGPointMake(1, 0);
        gradient.locations = @[@0.0, @0.5, @1.0];
        [_colorView.layer addSublayer:gradient];
        //移除交互事件
        _colorView.userInteractionEnabled = NO;
    }
    return _colorView;
}

- (UIView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, (CGRectGetHeight(self.frame) - kIndicatorHeight)/2.0, kIndicatorHeight, kIndicatorHeight)];
        _indicatorView.layer.cornerRadius = kIndicatorHeight/2.0;
        _indicatorView.userInteractionEnabled = NO;
        
        //设置阴影
        _indicatorView.layer.shadowColor = [UIColorFromHex(0xA2A2A2) colorWithAlphaComponent:.5f].CGColor;
        _indicatorView.layer.shadowOffset = CGSizeMake(0, 3);
        _indicatorView.layer.shadowOpacity = 1;
        _indicatorView.layer.shadowRadius = 3;
    }
    return _indicatorView;
}

@end
