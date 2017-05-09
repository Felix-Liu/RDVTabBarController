// RDVTabBarItem.h
// RDVTabBarController
//
// Copyright (c) 2013 Robert Dimitrov
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "RDVTabBarItem.h"

@interface RDVTabBarItem () {
    NSString *_title;
    UIOffset _imagePositionAdjustment;
    NSDictionary *_unselectedTitleAttributes;
    NSDictionary *_selectedTitleAttributes;
}

@property UIImage *unselectedBackgroundImage;
@property UIImage *selectedBackgroundImage;
@property UIImage *unselectedImage;
@property UIImage *selectedImage;

@end

@implementation RDVTabBarItem

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (void)commonInitialization {
    // Setup defaults
    
    //    [self setBackgroundColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]];
    [self setBackgroundColor:[UIColor whiteColor]];
    
    _title = @"";
    _titlePositionAdjustment = UIOffsetZero;
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        _unselectedTitleAttributes = @{
                                       NSFontAttributeName: [UIFont systemFontOfSize:12],
                                       NSForegroundColorAttributeName: [UIColor blackColor],
                                       };
    } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        _unselectedTitleAttributes = @{
                                       UITextAttributeFont: [UIFont systemFontOfSize:12],
                                       UITextAttributeTextColor: [UIColor blackColor],
                                       };
#endif
    }
    
    _selectedTitleAttributes = [_unselectedTitleAttributes copy];
    _badgeBackgroundColor = [UIColor redColor];
    _badgeTextColor = [UIColor whiteColor];
    _badgeTextFont = [UIFont systemFontOfSize:12];
    _badgePositionAdjustment = UIOffsetZero;
    
    UIView* lineView = [[UIView alloc]init];
    lineView.tag = 10086;
    lineView.frame = CGRectMake(0, self.bounds.size.height - 3.0f, self.bounds.size.width, 3.0f);
    lineView.frame = self.bounds;
    lineView.backgroundColor = [UIColor redColor];
    [self addSubview:lineView];
}

- (void)drawRect:(CGRect)rect
{
    CGSize frameSize = self.frame.size;
    CGSize imageSize = CGSizeZero;
    CGSize titleSize = CGSizeZero;
    NSDictionary *titleAttributes = nil;
    UIImage *backgroundImage = nil;
    UIImage *image = nil;
    CGFloat imageStartingY = 0.0f;
    UIImage *lineImage = nil;
    
    if ([self isSelected]) {
        image = [self selectedImage];
        backgroundImage = [self selectedBackgroundImage];
        titleAttributes = [self selectedTitleAttributes];
        
        if (!titleAttributes) {
            titleAttributes = [self unselectedTitleAttributes];
        }
        
        lineImage = [self imageFromColor:[UIColor clearColor]];
        
    } else {
        image = [self unselectedImage];
        backgroundImage = [self unselectedBackgroundImage];
        titleAttributes = [self unselectedTitleAttributes];
        
        lineImage = [self imageFromColor:[UIColor clearColor]];
    }
    
    imageSize = [image size];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    [backgroundImage drawInRect:self.bounds];
    
    // Draw image and title
    
    if (![_title length]) {
        [image drawInRect:CGRectMake(roundf(frameSize.width / 2 - imageSize.width / 2) +
                                     _imagePositionAdjustment.horizontal,
                                     roundf(frameSize.height / 2 - imageSize.height / 2) +
                                     _imagePositionAdjustment.vertical,
                                     imageSize.width, imageSize.height)];
        
        [lineImage drawInRect:CGRectMake(0, frameSize.height - 2.0f ,  frameSize.width, 2.0f)];
    } else {
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            titleSize = [_title boundingRectWithSize:CGSizeMake(frameSize.width, 20)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName: titleAttributes[NSFontAttributeName]}
                                             context:nil].size;
            
            imageStartingY = roundf((frameSize.height - imageSize.height - titleSize.height) / 2);
            
            [image drawInRect:CGRectMake(roundf(frameSize.width / 2 - imageSize.width / 2) +
                                         _imagePositionAdjustment.horizontal,
                                         imageStartingY + _imagePositionAdjustment.vertical,
                                         imageSize.width, imageSize.height)];
            
            CGContextSetFillColorWithColor(context, [titleAttributes[NSForegroundColorAttributeName] CGColor]);
            
            [_title drawInRect:CGRectMake(roundf(frameSize.width / 2 - titleSize.width / 2) +
                                          _titlePositionAdjustment.horizontal,
                                          imageStartingY + imageSize.height + _titlePositionAdjustment.vertical,
                                          titleSize.width, titleSize.height)
                withAttributes:titleAttributes];
        }
    }
    
    // Draw badges
    
    if ([[self badgeValue] length]) {
        CGSize badgeSize = CGSizeZero;
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            badgeSize = [_badgeValue boundingRectWithSize:CGSizeMake(frameSize.width, 20)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName: [self badgeTextFont]}
                                                  context:nil].size;
        } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            badgeSize = [_badgeValue sizeWithFont:[self badgeTextFont]
                                constrainedToSize:CGSizeMake(frameSize.width, 20)];
#endif
        }
        
        CGFloat textOffset = 2.0f;
        
        if (badgeSize.width < badgeSize.height) {
            badgeSize = CGSizeMake(badgeSize.height, badgeSize.height);
        }
        
        CGRect badgeBackgroundFrame = CGRectMake(roundf(frameSize.width / 2 + (image.size.width / 2) * 0.9) +
                                                 [self badgePositionAdjustment].horizontal,
                                                 textOffset + [self badgePositionAdjustment].vertical,
                                                 badgeSize.width + 2 * textOffset, badgeSize.height + 2 * textOffset);
        
        if ([self badgeBackgroundColor]) {
            CGContextSetFillColorWithColor(context, [[self badgeBackgroundColor] CGColor]);
            
            CGContextFillEllipseInRect(context, badgeBackgroundFrame);
        } else if ([self badgeBackgroundImage]) {
            [[self badgeBackgroundImage] drawInRect:badgeBackgroundFrame];
        }
        
        CGContextSetFillColorWithColor(context, [[self badgeTextColor] CGColor]);
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            NSMutableParagraphStyle *badgeTextStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            [badgeTextStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [badgeTextStyle setAlignment:NSTextAlignmentCenter];
            
            NSDictionary *badgeTextAttributes = @{
                                                  NSFontAttributeName: [self badgeTextFont],
                                                  NSForegroundColorAttributeName: [self badgeTextColor],
                                                  NSParagraphStyleAttributeName: badgeTextStyle,
                                                  };
            
            [[self badgeValue] drawInRect:CGRectMake(CGRectGetMinX(badgeBackgroundFrame) + textOffset,
                                                     CGRectGetMinY(badgeBackgroundFrame) + textOffset,
                                                     badgeSize.width, badgeSize.height)
                           withAttributes:badgeTextAttributes];
        } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            [[self badgeValue] drawInRect:CGRectMake(CGRectGetMinX(badgeBackgroundFrame) + textOffset,
                                                     CGRectGetMinY(badgeBackgroundFrame) + textOffset,
                                                     badgeSize.width, badgeSize.height)
                                 withFont:[self badgeTextFont]
                            lineBreakMode:NSLineBreakByTruncatingTail
                                alignment:NSTextAlignmentCenter];
#endif
        }
    }
    
    CGContextRestoreGState(context);
}

- (UIImage *)imageFromColor:(UIColor *)color{
    CGRect rect = CGRectMake(0, 0, 1000, 1000);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

#pragma mark - Image configuration

- (UIImage *)finishedSelectedImage {
    return [self selectedImage];
}

- (UIImage *)finishedUnselectedImage {
    return [self unselectedImage];
}

- (void)setFinishedSelectedImage:(UIImage *)selectedImage withFinishedUnselectedImage:(UIImage *)unselectedImage {
    if (selectedImage && (selectedImage != [self selectedImage])) {
        [self setSelectedImage:selectedImage];
    }
    
    if (unselectedImage && (unselectedImage != [self unselectedImage])) {
        [self setUnselectedImage:unselectedImage];
    }
}

- (void)setBadgeValue:(NSString *)badgeValue {
    _badgeValue = badgeValue;
    
    [self setNeedsDisplay];
}

#pragma mark - Background configuration

- (UIImage *)backgroundSelectedImage {
    
    return [self selectedBackgroundImage];
}

- (UIImage *)backgroundUnselectedImage {
    
    return [self unselectedBackgroundImage];
}

- (void)setBackgroundSelectedImage:(UIImage *)selectedImage withUnselectedImage:(UIImage *)unselectedImage {
    if (selectedImage && (selectedImage != [self selectedBackgroundImage])) {
        UIView* lineView = [self viewWithTag:10086];
        lineView.backgroundColor = [UIColor colorWithRed:227/255.0 green:38/255.0 blue:100/255.0 alpha:1];
        [self setSelectedBackgroundImage:selectedImage];
    }
    
    if (unselectedImage && (unselectedImage != [self unselectedBackgroundImage])) {
        UIView* lineView = [self viewWithTag:10086];
        lineView.backgroundColor = [UIColor clearColor];
        [self setUnselectedBackgroundImage:unselectedImage];
    }
}

@end
