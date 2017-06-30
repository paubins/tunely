//
//  MLWInverseStatusBar.m
//  Overlap
//
//  Created by Anton Bukov on 02.03.17.
//  Copyright © 2016 MachineLearningWorks. All rights reserved.
//

#import "MLWInverseStatusBar.h"

//

@interface MLWStatusBarWindow : UIWindow

@end

@implementation MLWStatusBarWindow

+ (instancetype)sharedWindow {
    static MLWStatusBarWindow *window;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        window = [[MLWStatusBarWindow alloc] initWithFrame:[UIApplication sharedApplication].statusBarFrame];
        window.windowLevel = UIWindowLevelStatusBar + 1;
        [window makeKeyAndVisible];
    });
    return window;
}

@end

//

@interface MLWInverseStatusBar ()

@property (strong, nonatomic) UIImageView *statusBarImageView;

@end

@implementation MLWInverseStatusBar

+ (instancetype)sharedInstance {
    static MLWInverseStatusBar *view;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __block UIImageView *imageView;
        view = [[[self class] alloc] initWithOverlapsCount:1 generator:^__kindof UIView * _Nonnull(NSUInteger overlapIndex) {
            return (imageView = [UIImageView new]);
        }];
        view.statusBarImageView = imageView;
        
        [[MLWStatusBarWindow sharedWindow] addSubview:view];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.frame = view.superview.bounds;
        [view.topAnchor constraintEqualToAnchor:view.superview.topAnchor].active = YES;
        [view.bottomAnchor constraintEqualToAnchor:view.superview.bottomAnchor].active = YES;
        [view.leadingAnchor constraintEqualToAnchor:view.superview.leadingAnchor].active = YES;
        [view.trailingAnchor constraintEqualToAnchor:view.superview.trailingAnchor].active = YES;
    });
    return view;
}

- (void)overlapWithViewPaths:(NSArray<UIBezierPath *> *)frames {
    NSString *statusBarKey = [@[@"s",@"t",@"a",@"t",@"u",@"s",@"B",@"a",@"r",@"W",@"i",@"n",@"d",@"o",@"w"] componentsJoinedByString:@""];
    UIView *statusBarWindow = [[UIApplication sharedApplication] valueForKey:statusBarKey];
    
    CGRect bounds = (CGRect){CGPointZero,[UIApplication sharedApplication].statusBarFrame.size};
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0.0);
    
    // Create mask
    CGContextSaveGState(UIGraphicsGetCurrentContext());
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, bounds.size.height);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    [statusBarWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
    UIImage *mask = UIGraphicsGetImageFromCurrentImageContext();
    
    // Draw with inverse color
    CGContextClearRect(UIGraphicsGetCurrentContext(), bounds);
    CGContextClipToMask(UIGraphicsGetCurrentContext(), bounds, mask.CGImage);
    if ([UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleDefault) {
        [[UIColor whiteColor] setFill];
    } else {
        [[UIColor blackColor] setFill];
    }
    CGContextFillRect(UIGraphicsGetCurrentContext(), bounds);
    self.statusBarImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [super overlapWithViewPaths:frames];
}

@end
