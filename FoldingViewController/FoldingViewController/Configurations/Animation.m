//
//  Animation.m
//  FoldingViewController
//
//  Created by sah-fueled on 24/05/13.
//  Copyright (c) 2013 hsusmita. All rights reserved.
//

#import "Animation.h"

#define kAnimationDurationKey @"animation-duration"
#define kAnimationStyleKey @"animation-style"
#define kAnimationDirectionKey @"animation-direction"

@implementation Animation

- (id)init {
    return [self initWithDetails:nil];
}

- (id)initWithDetails:(NSDictionary *)animationDetails {
    if (self = [super init]){
        
        _animationDuration = [((NSNumber*)[animationDetails objectForKey:kAnimationDurationKey]) floatValue];
        _animationStyle = [((NSNumber*)[animationDetails objectForKey:kAnimationStyleKey]) intValue];
        _animationDirection = [((NSNumber*)[animationDetails objectForKey:kAnimationDirectionKey]) intValue];
        
    }
    return self;
}

@end
