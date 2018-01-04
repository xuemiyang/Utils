//
//  TagsView.m
//  yzyx
//
//  Created by xuemiyang on 2017/12/20.
//  Copyright © 2017年 TCLios2. All rights reserved.
//

#import "TagsView.h"
#import "Category.h"

@implementation RoundCountView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.width)]) {
        _color = [UIColor redColor];
        _attrbutes = @{NSFontAttributeName:[UIFont systemFontOfSize:11], NSForegroundColorAttributeName: [UIColor whiteColor]};
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, _color.CGColor);
    CGContextAddArc(context, rect.size.width / 2, rect.size.height / 2, rect.size.width / 2, 0, M_PI * 2, 1);
    CGContextFillPath(context);
    NSString *countText = [NSString stringWithFormat:@"%d", (int)_count];
    CGSize size = [countText sizeWithAttributes:_attrbutes];
    [countText drawInRect:CGRectMake((rect.size.width - size.width) / 2, (rect.size.height - size.height) / 2, size.width, size.height) withAttributes:_attrbutes];
}

- (void)setCount:(NSInteger)count {
    _count = count;
    [self setNeedsDisplay];
}

@end

@interface TagsView () <UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray<NSValue *> *buttons;
@property (nonatomic, weak) UIButton *line;
@property (nonatomic, assign) CGFloat beginOffset;
@property (nonatomic, assign) BOOL isSelect;
@end

@implementation TagsView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _lineWidth = 1;
        _lineColor = [UIColor blueColor];
        _textNormalFontAttribute = @{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:[UIColor lightGrayColor]};
        _textSelectFontAttribute = @{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:[UIColor blueColor]};
        
    }
    return self;
}

- (void)setup {
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    NSUInteger count = _texts.count;
    if (count > 0) {
        CGFloat w = self.frame.size.width / count;
        CGFloat h = self.frame.size.height;
        _buttons = [NSMutableArray arrayWithCapacity:count];
        CGFloat lastW = 0;
        for (int i=0; i<count; i++) {
            CGFloat textW = [_texts[i] sizeWithAttributes:_textNormalFontAttribute].width + width(20);
            if (textW > w) {
                w = textW;
            }
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(lastW, 0, w, h)];
            [self addSubview:button];
            CGFloat countViewW = width(18);
            RoundCountView *countView = [[RoundCountView alloc] initWithFrame:CGRectMake(w - countViewW, 0, countViewW, countViewW)];
            countView.hidden = YES;
            [button insertSubview:countView aboveSubview:button.titleLabel];
            NSValue *value = [NSValue valueWithNonretainedObject:button];
            [_buttons addObject:value];
            button.tag = i;
            [button setAttributedTitle:[[NSAttributedString alloc] initWithString:_texts[i] attributes:_textNormalFontAttribute] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(_clickButton:) forControlEvents:UIControlEventTouchUpInside];
            if (i == 0) {
                [button setAttributedTitle:[[NSAttributedString alloc] initWithString:_texts[i] attributes:_textSelectFontAttributes ? _textSelectFontAttributes[i] : _textSelectFontAttribute] forState:UIControlStateNormal];
                UIButton *line = [[UIButton alloc] initWithFrame:CGRectMake(0, h - _lineWidth, textW + _lineLengthExtend, _lineWidth)];
                _line = line;
                line.xm_centerX = button.xm_centerX;
                line.backgroundColor = _lineColors ? _lineColors[i] : _lineColor;
                [self insertSubview:line atIndex:0];
            }
            lastW += w;
            w = (self.frame.size.width - lastW) / (i == count - 1 ? 1 : count - 1 - i);
        }
        self.contentSize = CGSizeMake(lastW, h);
        if (!_scrollView || !_views || _views.count != _texts.count) {
            return;
        }
        for (UIView *subview in _scrollView.subviews) {
            [subview removeFromSuperview];
        }
        CGFloat scrollViewW = _scrollView.frame.size.width;
        CGFloat scrollViewH = _scrollView.frame.size.height;
        _scrollView.contentSize = CGSizeMake(scrollViewW * _views.count, scrollViewH);
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        for (int i=0; i<_views.count; i++) {
            UIView *view = _views[i].nonretainedObjectValue;
            view.frame = CGRectMake(i * scrollViewW, 0, scrollViewW, scrollViewH);
            [_scrollView addSubview:view];
        }
    }
}

- (void)selectTagAtIndex:(NSUInteger)index animated:(BOOL)animated {
    if (index >= _buttons.count) {
        return;
    }
    _isSelect = YES;
    _currenIndex = index;
    UIButton *button = _buttons[index].nonretainedObjectValue;
    CGFloat textW = [_texts[index] sizeWithAttributes:_textSelectFontAttribute].width;
    __weak typeof(self) weakSelf = self;
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.line.xm_w = textW + _lineLengthExtend;
            weakSelf.line.xm_centerX = button.xm_centerX;
            weakSelf.line.backgroundColor = weakSelf.lineColors ? weakSelf.lineColors[index] : weakSelf.lineColor;
        }];
    } else {
        _line.xm_w = textW + _lineLengthExtend;
        _line.xm_centerX = button.xm_centerX;
        _isSelect = NO;
    }
    [self _setupButtonsAtIndex:index];
    [self _scrollToVisibleButtonAtIndex:index withAnimated:animated];
    if (!_scrollView) {
        if (_tagDelegate && [_tagDelegate respondsToSelector:@selector(tagsView:didSelectTextInIndex:atText:withView:)]) {
            [_tagDelegate tagsView:self didSelectTextInIndex:index atText:_texts[index] withView:nil];
        }
        return;
    }
    [_scrollView setContentOffset:CGPointMake(index * _scrollView.frame.size.width, 0) animated:animated];
    if (!animated) {
        if (_tagDelegate && [_tagDelegate respondsToSelector:@selector(tagsView:didSelectTextInIndex:atText:withView:)]) {
            [_tagDelegate tagsView:self didSelectTextInIndex:index atText:_texts[index] withView:_views[index].nonretainedObjectValue];
        }
    }
}

- (void)setCount:(NSUInteger)count atIndex:(NSUInteger)index {
    if (index >= _buttons.count) {
        return;
    }
    UIButton *button = _buttons[index].nonretainedObjectValue;
    RoundCountView *countView;
    for (UIView *subview in button.subviews) {
        if ([subview isKindOfClass:[RoundCountView class]]) {
            countView = (RoundCountView *)subview;
            break;
        }
    }
    if (countView) {
        countView.count = count;
        countView.hidden = count == 0;
    }
}

#pragma mark - private
- (void)_clickButton:(UIButton *)btn {
    [self selectTagAtIndex:btn.tag animated:YES];
}

- (void)_setupButtonsAtIndex:(NSUInteger)index {
    UIButton *button = _buttons[index].nonretainedObjectValue;
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:_texts[index] attributes:_textSelectFontAttributes ? _textSelectFontAttributes[index] : _textSelectFontAttribute];
    [button setAttributedTitle:attributedString forState:UIControlStateNormal];
    for (int i=0; i<_buttons.count; i++) {
        if (i != index) {
            UIButton *btn = _buttons[i].nonretainedObjectValue;
            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:_texts[i] attributes:_textNormalFontAttribute];
            [btn setAttributedTitle:attributedString forState:UIControlStateNormal];
        }
    }
}

- (void)_scrollToVisibleButtonAtIndex:(NSUInteger)index withAnimated:(BOOL)animated {
    UIButton *btn1 = _buttons[index].nonretainedObjectValue;
    CGFloat maxX = CGRectGetMaxX(btn1.frame);
    if (index + 1 < _buttons.count) {
        UIButton *btn2 = _buttons[index + 1].nonretainedObjectValue;
        maxX = CGRectGetMaxX(btn2.frame);
    }
    CGFloat offset = maxX - self.frame.size.width + self.contentInset.right;
    [self setContentOffset:CGPointMake(offset > 0 ? offset : 0, 0) animated:animated];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _currenIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    if (scrollView.contentOffset.x - _currenIndex * scrollView.frame.size.width > 0.01) {
        if (_beginOffset - scrollView.contentOffset.x < 0.01) { // 连续滚动时如果还没完成目标页面应++
            _currenIndex++;
        }
    }
    _beginOffset = scrollView.contentOffset.x;
    if (_tagDelegate && [_tagDelegate respondsToSelector:@selector(tagsViewWillBeginDragging:)]) {
        [_tagDelegate tagsViewWillBeginDragging:self];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_currenIndex >= 0 && _currenIndex < _texts.count && !_isSelect) {
        CGFloat offset = (scrollView.contentOffset.x - _beginOffset) / scrollView.frame.size.width;
        NSInteger toIndex = offset; // 连续滚动时fabs(offset) > 1
        if (_currenIndex + toIndex < 0 || _currenIndex + toIndex >= _buttons.count) {
            return;
        }
        UIButton *toBtn1 = _buttons[_currenIndex + toIndex].nonretainedObjectValue;
        offset = offset - toIndex;
        if (offset > 0) {
            toIndex = _currenIndex + 1;
        } else if (offset < 0) {
            toIndex = _currenIndex - 1;
        } else {
            toIndex = -1;
        }
        CGFloat lineToMoveX = 0;
        if (toIndex >= 0 && toIndex < _texts.count) {
            UIButton *toBtn2 = _buttons[toIndex].nonretainedObjectValue;
            lineToMoveX = fabs(toBtn2.xm_centerX - toBtn1.xm_centerX);
            lineToMoveX = offset * lineToMoveX;
            _line.xm_centerX = toBtn1.xm_centerX + lineToMoveX;
            CGFloat textW = [toBtn1.titleLabel.text sizeWithAttributes:_textNormalFontAttribute].width;
            CGFloat toTextW = [_texts[toIndex] sizeWithAttributes:_textNormalFontAttribute].width;
            CGFloat toLineW = textW + (toTextW - textW) * fabs(offset);
            _line.xm_w = toLineW + _lineLengthExtend;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _currenIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    UIButton *button = _buttons[_currenIndex].nonretainedObjectValue;
    CGFloat textW = [_texts[_currenIndex] sizeWithAttributes:_textSelectFontAttribute].width;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.line.xm_w = textW + weakSelf.lineLengthExtend;
        weakSelf.line.xm_centerX = button.xm_centerX;
        weakSelf.line.backgroundColor = weakSelf.lineColors ? weakSelf.lineColors[weakSelf.currenIndex] : weakSelf.lineColor;
    }];
    [self _setupButtonsAtIndex:_currenIndex];
    [self _scrollToVisibleButtonAtIndex:_currenIndex withAnimated:YES];
    if (_tagDelegate) {
        if ([_tagDelegate respondsToSelector:@selector(tagsView:didSelectTextInIndex:atText:withView:)]) {
            [_tagDelegate tagsView:self didSelectTextInIndex:_currenIndex atText:_texts[_currenIndex] withView:_views[_currenIndex].nonretainedObjectValue];
        }
        if ([_tagDelegate respondsToSelector:@selector(tagsViewDidEndDeceleratingAndScrollingAnimationEnd:)]) {
            [_tagDelegate tagsViewDidEndDeceleratingAndScrollingAnimationEnd:self];
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    _isSelect = NO;
    if (_tagDelegate) {
        if ([_tagDelegate respondsToSelector:@selector(tagsView:didSelectTextInIndex:atText:withView:)]) {
            [_tagDelegate tagsView:self didSelectTextInIndex:_currenIndex atText:_texts[_currenIndex] withView:_views[_currenIndex].nonretainedObjectValue];
        }
        if ([_tagDelegate respondsToSelector:@selector(tagsViewDidEndDeceleratingAndScrollingAnimationEnd:)]) {
            [_tagDelegate tagsViewDidEndDeceleratingAndScrollingAnimationEnd:self];
        }
    }
}

@end















