//
//  MLInitialAvatar.m
//  monalxmpp
//
//  Created by mohanchandaluri on 24/05/22.
//  Copyright © 2022 Monal.im. All rights reserved.
//

#import "MLInitialAvatar.h"

@implementation MLInitialAvatar

- (instancetype)initWithRect:(CGRect)frame fullName:(NSString *)fullName
{
    self = [super init];
    if (self) {
        self.frame = frame;
        self.fullName = fullName;
         CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        self.backgroundColor = color;
        self.initialsColor = [UIColor whiteColor];
        self.initialsFont = nil;
    }
    return self;
}

- (NSString *)initials {
    NSMutableString * firstCharacters = [NSMutableString string];
    NSArray * words = [self.fullName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    for (NSString * word in words) {
        if ([word length] > 0) {
            NSString * firstLetter = [word substringWithRange:[word rangeOfComposedCharacterSequenceAtIndex:0]];
            [firstCharacters appendString:[firstLetter uppercaseString]];
        }
    }
    return firstCharacters;
}

- (UIImage *)imageRepresentation
{
    CGRect frame = self.frame;
    
    // General Declarations
    UIGraphicsBeginImageContextWithOptions(frame.size, YES, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Color Declarations
    UIColor* backgroundColor = self.backgroundColor;
    
    // Variable Declarations
    NSString* initials = self.initials;
    CGFloat fontSize = frame.size.height / 2.2;
    
    // Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame))];
    [backgroundColor setFill];
    [rectanglePath fill];
    
    // Initials String Drawing
    CGRect initialsStringRect = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame));
    NSMutableParagraphStyle* initialsStringStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    initialsStringStyle.alignment = NSTextAlignmentCenter;
    
    UIFont *font;
    if (!self.initialsFont) {
        font = [UIFont systemFontOfSize:fontSize];
    } else {
        font = self.initialsFont;
    }
    
    NSDictionary* initialsStringFontAttributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: self.initialsColor, NSParagraphStyleAttributeName: initialsStringStyle};
    
    CGFloat initialsStringTextHeight = [initials boundingRectWithSize: CGSizeMake(initialsStringRect.size.width, INFINITY)  options: NSStringDrawingUsesLineFragmentOrigin attributes: initialsStringFontAttributes context: nil].size.height;
    CGContextSaveGState(context);
    CGContextClipToRect(context, initialsStringRect);
    [initials drawInRect: CGRectMake(CGRectGetMinX(initialsStringRect), CGRectGetMinY(initialsStringRect) + (CGRectGetHeight(initialsStringRect) - initialsStringTextHeight) / 2, CGRectGetWidth(initialsStringRect), initialsStringTextHeight) withAttributes: initialsStringFontAttributes];
    CGContextRestoreGState(context);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end
