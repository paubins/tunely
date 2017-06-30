//
//  MLWInverseStatusBar.h
//  Overlap
//
//  Created by Anton Bukov on 02.03.17.
//  Copyright © 2016 MachineLearningWorks. All rights reserved.
//

#import <Overlap/Overlap.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLWInverseStatusBar : MLWOverlapView

- (instancetype)initWithGenerator:(UIView * (^)(NSUInteger overlapIndex))generator NS_UNAVAILABLE;
- (instancetype)initWithOverlapsCount:(NSUInteger)overlapsCount generator:(UIView * (^)(NSUInteger overlapIndex))generator NS_UNAVAILABLE;

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
