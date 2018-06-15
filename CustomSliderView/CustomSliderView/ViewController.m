//
//  ViewController.m
//  CustomSliderView
//
//  Created by apple on 2018/6/15.
//

#import "ViewController.h"

#import "CustomSliderView.h"

@interface ViewController ()

@property (nonatomic, strong) CustomSliderView *slideControl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.slideControl = [[CustomSliderView alloc] initWithFrame:CGRectMake(15, 100, size.width - 30, 30)];
    //可选属性
    self.slideControl.trackingBarHeight = 2;                //渐变颜色条高度
    self.slideControl.indicatorHeight = 21;                 //选中圆环直径
    self.slideControl.section = 4;                          //分段数
    self.slideControl.unitWidth = 5;                        //结点直径(结点数 = section + 1)
    self.slideControl.reservedSpace = 20;                   //预留空间
    
    [self.view addSubview:self.slideControl];
}

#pragma mark - getter
- (CustomSliderView *)slideControl {
    if (!_slideControl) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        _slideControl = [[CustomSliderView alloc] initWithFrame:CGRectMake(15, 100, size.width - 30, 30)];
        //可选属性
        _slideControl.trackingBarHeight = 2;
        _slideControl.indicatorHeight = 21;
        _slideControl.section = 4;
        _slideControl.unitWidth = 5;
        _slideControl.reservedSpace = 20;
    }
    return _slideControl;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
