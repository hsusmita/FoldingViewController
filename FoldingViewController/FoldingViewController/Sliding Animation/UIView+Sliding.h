//
//  UIView+Sliding.h
//  FoldingViewController
//
//  Created by sah-fueled on 24/05/13.
//  Copyright (c) 2013 hsusmita. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	SlidingDirectionFromRight     = 0,
	SlidingDirectionFromLeft      = 1,
    SlidingDirectionFromTop       = 2,
    SlidingDirectionFromBottom    = 3,
}SlidingDirection;

@interface UIView (Sliding)

- (void)slideInView:(UIView*)view
        forDuration:(CGFloat)duration
      withDirection:(SlidingDirection)direction
         completion:(void (^)(BOOL finished))completion;

- (void)slideBackView:(UIView*)view 
          forDuration:(CGFloat)duration
        withDirection:(SlidingDirection)direction
           completion:(void (^)(BOOL finished))completion;
@end
