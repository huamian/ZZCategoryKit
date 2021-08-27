//
//  UIButton+Extension.m
//  BXlive
//
//  Created by sweetloser on 2020/5/24.
//  Copyright © 2020 cat. All rights reserved.
//

#import "UIButton+Extension.h"
@implementation UIButton (Extension)

-(void)yh_setNormalTitleColor:(nullable UIColor *)color{
    [self setTitleColor:color forState:UIControlStateNormal];
}
-(void)yh_setTitleNormalColor:(nullable UIColor *)normalColor selectedColor:(UIColor *)selectedColor heightLightColor:(UIColor *)heightLightColor{
    [self setTitleColor:normalColor forState:UIControlStateNormal];
    
    [self setTitleColor:heightLightColor forState:UIControlStateHighlighted];
    
    [self setTitleColor:selectedColor forState:UIControlStateSelected];
}

-(void)yh_setNormalTitleText:(NSString *)text{
    [self setTitle:text forState:UIControlStateNormal];
}

-(void)yh_setTitleText:(nullable NSString *)text selectedTitleText:(NSString *)selectedText{
    [self setTitle:text forState:UIControlStateNormal];
    [self setTitle:selectedText forState:UIControlStateSelected];
}

-(void)yh_setNormalFont:(UIFont *)font{
    self.titleLabel.font = font;
    
}
@end
