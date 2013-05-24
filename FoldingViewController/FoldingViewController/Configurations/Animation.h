//
//  Animation.h
//  FoldingViewController
//
//  Created by sah-fueled on 24/05/13.
//  Copyright (c) 2013 hsusmita. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    TransitionAnimationStyleSliding = 0,
    TransitionAnimationStyleFolding
} TransitionAnimationStyle;

typedef enum
{
    TransitionDirectionFromRight    = 0,
	TransitionDirectionFromLeft     = 1,
    TransitionDirectionFromTop      = 2,
    TransitionDirectionFromBottom   = 3,

}TransitionDirection;

@interface Animation : NSObject

@property (nonatomic, readonly) float animationDuration;
@property (nonatomic, readonly) TransitionDirection animationDirection;
@property (nonatomic, readonly) TransitionAnimationStyle animationStyle;

- (id)initWithDetails:(NSDictionary *)animationDetails;

@end
