//
//  TextBoxField.h
//  CustomTextBoxField
//
//  Created by Erik on 2019/9/25.
//  Copyright © 2019 zkt. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TextBox : UIView

// 标记是否是正在编辑状态
@property (nonatomic, assign) BOOL active;
// 显示文本
@property (nonatomic, strong) UILabel *label;
// 正常状态主题色
@property (nonatomic, strong) UIColor *normalColor;
// 激活状态主题色
@property (nonatomic, strong) UIColor *activeColor;

- (void)destroy;

@end

@class TextBoxField;

@protocol TextBoxFieldDelegate <NSObject>

@optional
- (void)textField:(TextBoxField *)textField textDidChange:(NSString *)text;
- (void)textField:(TextBoxField *)textField didFinish:(NSString *)text;

@end

@interface TextBoxField : UIControl

@property (nonatomic, weak) id<TextBoxFieldDelegate> delegate;
// 设置文本框边距
@property (nonatomic, assign) UIEdgeInsets insets;
// 设置文本框数量
@property (nonatomic, assign) NSInteger numberOfItem;

// 获取文本内容
- (NSString *)text;

@end

NS_ASSUME_NONNULL_END
