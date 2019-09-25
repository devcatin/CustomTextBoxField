//
//  ViewController.m
//  CustomTextBoxField
//
//  Created by Erik on 2019/9/25.
//  Copyright © 2019 zkt. All rights reserved.
//

#import "ViewController.h"
#import "TextBoxField.h"

@interface ViewController ()<TextBoxFieldDelegate>

@property (weak ,nonatomic) TextBoxField *testView;
@property (strong ,nonatomic) UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configWithUI];
}

- (void)configWithUI {
    CGFloat itemSize = 30;
    CGFloat space = 10;
    NSInteger count = 6;
    CGFloat itemW = itemSize * count + space * (count - 1);
    TextBoxField *textBoxField = [[TextBoxField alloc] init];
    textBoxField.frame = CGRectMake(0, 100, itemW, itemSize);
    textBoxField.center = CGPointMake(self.view.center.x, 150);
    textBoxField.numberOfItem = count;
    textBoxField.insets = UIEdgeInsetsMake(0, 10, 0, 10.f);
    textBoxField.delegate = self;
    [self.view addSubview:textBoxField];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(textBoxField.frame) + 44.f, self.view.frame.size.width, 44.f)];
    _label.font = [UIFont systemFontOfSize:15];
    _label.textColor = [UIColor blackColor];
    _label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_label];
    
    _testView = textBoxField;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_testView resignFirstResponder];
}

#pragma mark - delegate

- (void)textField:(TextBoxField *)textField textDidChange:(NSString *)text; {
    
}

- (void)textField:(TextBoxField *)textField didFinish:(NSString *)text; {
    [textField resignFirstResponder];
    _label.text = [NSString stringWithFormat:@"输入完成,当前输入: %@" ,textField.text];
}

@end
