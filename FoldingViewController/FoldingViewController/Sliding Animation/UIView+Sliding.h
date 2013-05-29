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

typedef enum {
    DraggingDirectionNone = 0,
    DraggingDirectionToRight     = 1 << 1,
	DraggingDirectionToLeft      = 1 << 2,
    DraggingDirectionToTop       = 1 << 3,
    DraggingDirectionToBottom    = 1 << 4,
}DraggingDirection;

//typedef enum {
//    DraggingDirectionNone = 0,
//    DraggingDirectionHorizontal    = 1 << 1,
//	DraggingDirectionVertical      = 1 << 2,
//}DraggingDirection;

typedef enum {
	DraggingTransitionStateIdle         = 0,
	DraggingTransitionStateUpdateToShow = 1,
    DraggingTransitionStateUpdateToHide = 2,
	DraggingTransitionStateShow         = 3
} DraggingTransitionState;

@interface UIView (Sliding)

- (void)slideInView:(UIView*)view
        forDuration:(CGFloat)duration
      withDirection:(SlidingDirection)direction
         completion:(void (^)(BOOL finished))completion;

- (void)slideBackView:(UIView*)view 
          forDuration:(CGFloat)duration
        withDirection:(SlidingDirection)direction
           completion:(void (^)(BOOL finished))completion;

- (void)enableDragForDirection:(DraggingDirection) dragDirection
                  withSideView:(UIView*)view;

@end
