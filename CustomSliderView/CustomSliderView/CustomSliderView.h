//
//  CustomSliderView.h
//  CustomSliderView
//
//  Created by apple on 2018/6/15.
//

#import <UIKit/UIKit.h>

@protocol CustomSliderViewDelegate <NSObject>

@optional
/** 当前选中的下标和当前选中的颜色 */
- (void)didSelectAtIndex:(NSInteger)index color:(UIColor *)color;

@end

@interface CustomSliderView : UIControl

@property (nonatomic, weak) id<CustomSliderViewDelegate> delegate;
@property (nonatomic, assign) NSInteger currentSelectIndex;         /**< 当前选中下标  */
//可选属性设置
@property (nonatomic, assign) CGFloat trackingBarHeight;            /**< 渐变颜色条高度  */
@property (nonatomic, assign) CGFloat indicatorHeight;              /**< 选中圆环直径  */
@property (nonatomic, assign) NSInteger section;                    /**< 分段数  */
@property (nonatomic, assign) CGFloat unitWidth;                    /**< 结点直径(结点数 = section + 1)  */
//reservedSpace用于处理点击边缘结点的体验
@property (nonatomic, assign) CGFloat reservedSpace;                /**< 预留空间  */

@end 
