//
//  UIButton+Extension.h
//  BXlive
//
//  Created by sweetloser on 2020/5/24.
//  Copyright © 2020 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (Extension)

-(void)yh_setNormalTitleColor:(nullable UIColor *)color;
-(void)yh_setTitleNormalColor:(nullable UIColor *)normalColor selectedColor:(UIColor *)selectedColor heightLightColor:(UIColor *)heightLightColor;

-(void)yh_setNormalTitleText:(nullable NSString *)text;
-(void)yh_setTitleText:(nullable NSString *)text selectedTitleText:(NSString *)selectedText;

-(void)yh_setNormalFont:(nullable UIFont *)font;

@end

NS_ASSUME_NONNULL_END
