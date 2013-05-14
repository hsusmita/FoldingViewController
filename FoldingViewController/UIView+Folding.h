//
//  UIView+Folding.h
//  FoldingViewController
//
//  Created by devmac46  on 14/05/13.
//  Copyright (c) 2013 hsusmita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef double (^KeyframeParametricBlock)(double);
@interface CAKeyframeAnimation (Parametric)

+ (id)animationWithKeyPath:(NSString *)path
                  function:(KeyframeParametricBlock)block
                 fromValue:(double)fromValue
                   toValue:(double)toValue;

@end

enum {
	FoldingDirectionFromRight     = 0,
	FoldingDirectionFromLeft      = 1,
    FoldingDirectionFromTop       = 2,
    FoldingDirectionFromBottom    = 3,
};
typedef NSUInteger FoldingDirection;

enum {
	FoldingTransitionStateIdle    = 0,
	FoldingTransitionStateUpdateToShow = 1,
    FoldingTransitionStateUpdateToHide = 2,
	FoldingTransitionStateShow    = 3
};
typedef NSUInteger FoldingTransitionState;


@interface UIView (Folding)

- (void)foldView:(UIView*)view
          withNumberOfFolds:(NSInteger)folds
                forDuration:(CGFloat)duration
              withDirection:(FoldingDirection)direction
                 completion:(void (^)(BOOL finished))completion;


- (void)unfoldView:(UIView*)view
            withNumberOfFolds:(NSInteger)folds
                  forDuration:(CGFloat)duration
                withDirection:(FoldingDirection)direction
                   completion:(void (^)(BOOL finished))completion;

- (BOOL)isSideViewVisible;

@end
