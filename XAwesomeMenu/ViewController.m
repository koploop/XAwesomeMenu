//
//  ViewController.m
//  XAwesomeMenu
//
//  Created by ErosLii on 16/2/25.
//  Copyright © 2016年 weelh. All rights reserved.
//

#import "ViewController.h"
#import "XAwesomeMenu.h"

@interface ViewController ()<XAwesomeMenuDelegate>

@property (nonatomic, strong) XAwesomeMenu *menu;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"左缠绕",@"右",@"直线上",@"右",@"下",@"左",@"扇形上",@"右",@"下",@"左",nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentedArray];
    [segmentedControl setFrame:CGRectMake(20, 100, self.view.frame.size.width-40, 30)];
    [segmentedControl addTarget:self action:@selector(didClicksegmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.selectedSegmentIndex = 0;
    [[UIApplication sharedApplication].keyWindow addSubview:segmentedControl];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.menu];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
-(void)didClicksegmentedControlAction:(UISegmentedControl *)segmentedControl{
    if (self.menu.isExpand) {
        [self.menu hideXAwesomeMenu];
    }
    self.menu.menuType = segmentedControl.selectedSegmentIndex;
    [self.menu showXAwesomeMenu];
}

#pragma mark - Delegate

- (void)awesomeMenu:(XAwesomeMenu *)menu didSelectIndex:(NSInteger)index {
    NSLog(@"didi select %ld", index);
}


- (XAwesomeMenu *)menu {
    if (!_menu) {
        _menu = [[XAwesomeMenu alloc] initMenuWithType:XMenuType_fanShapeRight size:CGSizeMake(50, 50) itemsImages:@[@"gallery",@"dropbox",@"camera",@"draw"] itemsHeighightedImages:@[@"gallery",@"dropbox",@"camera",@"draw"]];
        _menu.delegate = self;
        _menu.center = CGPointMake(150, 480);
    }
    return _menu;
}

@end
