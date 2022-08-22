//
//  UIColor+Theme.m
//  Monal
//
//  Created by Anurodh Pokharel on 4/1/18.
//  Copyright © 2018 Monal.im. All rights reserved.
//

#import "UIColor+Theme.h"

@implementation UIColor (Theme)

+(UIColor *) monalGreen {
    UIColor *monalGreen =[UIColor colorWithRed:30.0/255 green:91.0/255 blue:152.0/255 alpha:1.0f];
    return monalGreen;
}

+(UIColor *) monaldarkGreen {
    UIColor *monaldarkGreen =[UIColor colorWithRed:30.0/255 green:91.0/255 blue:152.0/255 alpha:1.0f];
    return monaldarkGreen;
}
+(UIColor *) monaldarkPurple {
    UIColor *monaldarkPurple =[UIColor colorWithRed:112.0/255 green:41.0/255 blue:99.0/255 alpha:1.0f];
    return monaldarkPurple;
}
+(UIColor *) monalrandomColor {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    return color;
}


@end
