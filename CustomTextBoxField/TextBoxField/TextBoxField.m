//
//  TextBoxField.m
//  CustomTextBoxField
//
//  Created by Erik on 2019/9/25.
//  Copyright © 2019 zkt. All rights reserved.
//

#import "TextBoxField.h"

@interface TextBox()

@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) UIView *twinkle_line;

@end

@implementation TextBox

- (id)init {
    self = [super init];
    if (self) {
        _normalColor = [UIColor grayColor];
        _activeColor = [UIColor orangeColor];
        
        self.layer.borderWidth = 2.f;
        self.layer.cornerRadius = 5.f;
        self.layer.masksToBounds = YES;
        
        _twinkle_line = [[UIView alloc] init];
        _twinkle_line.backgroundColor = _activeColor;
        _twinkle_line.hidden = YES;
        [self addSubview:_twinkle_line];
        
        _label = [[UILabel alloc] init];
        _label.font = [UIFont systemFontOfSize:15];
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _twinkle_line.bounds = CGRectMake(0, 0, 2.f, 15.f);
    _twinkle_line.center = CGPointMake(self.frame.size.width * .5, self.frame.size.height * .5);
    _label.frame = self.bounds;
}

- (void)update:(NSTimer *)sender {
    if (_active) {
        _twinkle_line.hidden = !_twinkle_line.hidden;
    }
}

- (void)setActive:(BOOL)active {
    _active = active;
    if (_active) {
        self.layer.borderColor = _activeColor.CGColor;
        _label.textColor = _activeColor;
        if (!_timer) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(update:) userInfo:nil repeats:YES];
            [_timer fire];
        }
    } else {
        self.layer.borderColor = _normalColor.CGColor;
        _label.textColor = _normalColor;
        [self destroy];
        _twinkle_line.hidden = YES;
    }
}

- (void)destroy; {
    [_timer invalidate];
    _timer = nil;
}

@end

@interface TextBoxField()<UIKeyInput>

// 设置当前正在编辑的位置
@property (nonatomic, assign) NSInteger editingIndex;

@property (nonatomic, strong) NSArray<TextBox *> *items;

@end

@implementation TextBoxField

#pragma mark -

- (void)reloadData {
    _items = nil;
    for (TextBox *subview in self.subviews) {
        if ([subview isKindOfClass:[TextBox class]]) {
            [subview destroy];
            [subview removeFromSuperview];
        }
    }
    
    // 计算 item size
    CGSize itemSize = CGSizeZero;
    itemSize.height = self.frame.size.height - _insets.top - _insets.bottom;
    itemSize.width = itemSize.height;
    
    // 计算间距
    CGFloat spacing = 0;
    if (_numberOfItem > 1) {
        spacing = (self.frame.size.width - _insets.left - _insets.right - itemSize.width * _numberOfItem) / (_numberOfItem - 1);
    }
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:_numberOfItem];
    for (int i = 0; i < _numberOfItem; i ++) {
        TextBox *item = [[TextBox alloc] init];
        item.frame = ({
            CGRect frame = item.frame;
            frame.origin.x = _insets.left + (itemSize.width + spacing) * i;
            frame.origin.y = _insets.top;
            frame.size = itemSize;
            frame;
        });
        item.active = [self isFirstResponder] && (i == _editingIndex);
        [self addSubview:item];
        item.backgroundColor = [UIColor whiteColor];
        [items addObject:item];
    }
    _items = [items copy];
}

- (void)resetAllItem {
    for (TextBox *object in _items) object.active = NO;
}

#pragma mark - setter

- (void)setInsets:(UIEdgeInsets)insets {
    _insets = insets;
    [self reloadData];
}

- (void)setNumberOfItem:(NSInteger)numberOfItem {
    _numberOfItem = numberOfItem;
    _editingIndex = 0;
    [self reloadData];
}

- (void)setEditingIndex:(NSInteger)editingIndex {
    _editingIndex = editingIndex;
    if (_editingIndex >= 0 && _editingIndex < _items.count) {
        for (int i = 0; i < _items.count; i ++) {
            _items[i].active = (i == _editingIndex);
        }
    } else {
        [self resetAllItem];
    }
}

#pragma mark - getter

- (NSString *)text; {
    NSMutableString *string = [[NSMutableString alloc] init];
    for (TextBox *object in _items) {
        NSString *c = object.label.text;
        if (c.length > 0) {
            [string appendString:[c stringByReplacingOccurrencesOfString:@" " withString:@""]];
        }
    }
    return [string copy];
}

#pragma mark - overwrite

- (BOOL)resignFirstResponder {
    [self resetAllItem];
    return [super resignFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self reloadData];
}

#pragma mark - key input

- (BOOL)hasText; {
    return YES;
}

- (void)insertText:(NSString *)text; {
    NSInteger editingIndex = -1;
    for (int i = 0; i < _items.count; i ++) {
        TextBox *object = _items[i];
        if (object.active) {
            editingIndex = i; break;
        }
    }
    if (editingIndex == -1) {
        return;
    }
    
    TextBox *editingItem = _items[editingIndex];
    editingItem.label.text = text;
    editingItem.active = NO;
    
    if ([_delegate respondsToSelector:@selector(textField:textDidChange:)]) {
        [_delegate textField:self textDidChange:self.text];
    }
    
    NSInteger nextIndex = editingIndex + 1;
    if (nextIndex < _items.count) {
        self.editingIndex = nextIndex;
    } else {
        if ([_delegate respondsToSelector:@selector(textField:didFinish:)]) {
            [_delegate textField:self didFinish:self.text];
        }
    }
}

- (void)deleteBackward; {
    if (_editingIndex > 0) {
        // 判断如果当前编辑的位置是最后一位并且最后一位已有内容，只做清空内容处理，不做退格处理
        UILabel *label = _items[_editingIndex].label;
        if (label.text.length > 0 && _editingIndex == _items.count - 1) {
            label.text = nil;
        } else {
            self.editingIndex = _editingIndex - 1;
            _items[_editingIndex].label.text = nil;
        }
    }
    if ([_delegate respondsToSelector:@selector(textField:textDidChange:)]) {
        [_delegate textField:self textDidChange:self.text];
    }
}

- (UIKeyboardType)keyboardType {
    return UIKeyboardTypeNumberPad;
}

#pragma mark -

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self becomeFirstResponder];
    self.editingIndex = _editingIndex;
}

- (void)dealloc {
    for (TextBox *object in _items) {
        [object destroy];
    }
}

@end
