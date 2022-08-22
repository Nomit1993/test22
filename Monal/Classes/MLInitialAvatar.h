//
//  MLInitialAvatar.h
//  monalxmpp
//
//  Created by mohanchandaluri on 24/05/22.
//  Copyright © 2022 Monal.im. All rights reserved.
//

#import <Foundation/Foundation.h>


#import <UIKit/UIKit.h>

@interface MLInitialAvatar : NSObject

/**
 Frame into which avatar will be rendered to. I would recommend to simple use `destinationImaveView.bounds` in `-initWithRect:fullName:` and forget about it. `CDCInitialsAvatar` _will_ adjust to your screen scale factor automatically, thus use points dimensions if assigned manually.
 
 @warning `frame` must not be `nil`.
 */
@property (readwrite, assign) CGRect frame;

/**
 Full name of person whose avatar should be displayed.
 
 @warning Do not use initials, `CDCInitialsAvatar` will calculate them automatically from full name. Also consider setting `initialsFont` manually when `frame` is anything other ran square.
 */
@property (readwrite, copy) NSString *fullName;

/**
 Background color of avatar. Default is `lightGrayColor`.
 */
@property (readwrite, strong) UIColor *backgroundColor;

/**
 Color of initials text in avatar. Default is white.
 */
@property (readwrite, strong) UIColor *initialsColor;

/**
 Font and size used generated initials. When `nil` system font with size of `frame.size.hight / 2.2` is used. Default value is `nil`.
 */
@property (readwrite, strong) UIFont *initialsFont;

/**
 Returns an `UIImage` object for using in `UIImageView` or anywhere else. If you want circular or different shaped avatars, consider masking `UIImageView` using its `mask` layer.
 
 @warning `CDCInitialsAvatar` _does not cache_ images, this means images will be generated each time. For example, when `UITableView` re-draws cell containing instance of `CDCInitialsAvatar`. Use your image caching strategy, which hopefully you already have implemented in your app.
 */
@property (readonly, strong, nonatomic) UIImage *imageRepresentation;

/**
 Returns an initials from `fullName`.
 */
@property (readonly, copy, nonatomic) NSString *initials;


/**
 Creates and returns an `CDCInitialsAvatar` generator object. No rendering is performed yet.
 */
- (instancetype)initWithRect:(CGRect)frame fullName:(NSString *)fullName;

@end
