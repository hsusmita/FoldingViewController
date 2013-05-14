//
//  UIView+Folding.m
//  FoldingViewController
//
//  Created by devmac46  on 14/05/13.
//  Copyright (c) 2013 hsusmita. All rights reserved.
//

#import "UIView+Folding.h"

KeyframeParametricBlock openFunction = ^double(double time) {
    return sin(time*M_PI_2);
};
KeyframeParametricBlock closeFunction = ^double(double time) {
    return -cos(time*M_PI_2)+1;
};
KeyframeParametricBlock rotateFunction = ^double(double time) {
    return -cos(time*M_PI_2)+1;
};

static FoldingTransitionState currentState = FoldingTransitionStateIdle;

@implementation CAKeyframeAnimation (Parametric)

+ (id)animationWithKeyPath:(NSString *)path function:(KeyframeParametricBlock)block fromValue:(double)fromValue toValue:(double)toValue
{
    // get a keyframe animation to set up
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:path];
    // break the time into steps (the more steps, the smoother the animation)
    NSUInteger steps = 100;
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:steps];
    double time = 0.0;
    double timeStep = 1.0 / (double)(steps - 1);
    for(NSUInteger i = 0; i < steps; i++) {
        double value = fromValue + (block(time) * (toValue - fromValue));
        [values addObject:[NSNumber numberWithDouble:value]];
        time += timeStep;
    }
    // we want linear animation between keyframes, with equal time steps
    animation.calculationMode = kCAAnimationLinear;
    // set keyframes and we're done
    [animation setValues:values];
    return(animation);
}

@end


@interface UIView (folding)
@end

@implementation UIView (Folding)


FoldingDirection foldingDirection;
CGRect selfFrame;
CGPoint startPoint;
CGPoint endPoint;
CALayer *foldingLayer;

-(void)unfoldView:(UIView *)view
           withNumberOfFolds:(NSInteger)folds
                 forDuration:(CGFloat)duration
               withDirection:(FoldingDirection)direction
                  completion:(void (^)(BOOL))completion
{
    foldingDirection = direction;
    if (currentState != FoldingTransitionStateIdle) {
        return;
    }
    currentState = FoldingTransitionStateUpdateToShow;
    selfFrame = [self newCenterFrameForSideView:view ForDirection:direction];
    view.frame = [self newFrameForView:view forDirection:direction];
    
   /* //add view as parent subview
    if (![view superview]) {
        [[self superview] insertSubview:view belowSubview:self];
    }
    //set frame
    selfFrame = [self newCenterFrameForSideView:view ForDirection:direction];//New position of centerView after animation
    view.frame = [self newFrameForView:view forDirection:direction];//Set new frame for the side view
    
    //Convert the side view to image
    UIGraphicsBeginImageContext(view.frame.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewSnapShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //set 3D depth (Add perspective transformation)
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0/800.0;
    CALayer *origamiLayer = [CALayer layer];
    origamiLayer.frame = view.bounds;
    origamiLayer.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1].CGColor;
    origamiLayer.sublayerTransform = transform;
    [view.layer addSublayer:origamiLayer];
    
    //Add CATransfromLayer to sideView
    NSArray *transformLayers = [[NSArray alloc]initWithArray:[self transformlayersForImage:viewSnapShot withDirection:direction withFoldCount:folds withAnimationDuration:duration]];
    CALayer *prevLayer = origamiLayer;
    for(CALayer* transLayer in transformLayers)
    {
        [prevLayer addSublayer:transLayer];
        prevLayer = transLayer;
    }
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        self.frame = selfFrame;
        for(CALayer *layer in [view.layer sublayers])
        {
            NSLog(@"layer = %@",layer);
        }
        [origamiLayer removeFromSuperlayer];
        for(CALayer *layer in [view.layer sublayers])
        {
            NSLog(@"layer = %@",layer);
            //            [layer removeFromSuperlayer];
        }
        NSLog(@"origami = %@",origamiLayer);
        XY_Origami_Current_State = XYOrigamiTransitionStateShow;
        
		if (completion)
			completion(YES);
    }];
    */
    
    [self showFoldingAnimationForView:view];
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        self.frame = selfFrame;
        currentState = FoldingTransitionStateShow;
		if (completion)
			completion(YES);
    }];
    [CATransaction setValue:[NSNumber numberWithFloat:duration]
                     forKey:kCATransactionAnimationDuration];

    //  Add Translation animation
    CGPoint start = (foldingDirection<2)?
    CGPointMake(self.frame.origin.x+self.frame.size.width/2,self.frame.origin.y):
    CGPointMake(self.frame.origin.x,self.frame.origin.y+self.frame.size.height/2);
    CGPoint end = (foldingDirection<2)?
    CGPointMake(selfFrame.origin.x+self.frame.size.width/2,self.frame.origin.y):
    CGPointMake(self.frame.origin.x,selfFrame.origin.y+self.frame.size.height/2);
    
    [self translateWithDirection:direction
                    fromPosition:start
                      toPosition:end
                    withFunction:openFunction
                     forDuration:duration];
    [CATransaction commit];
  
}

-(void)foldView:(UIView *)view
         withNumberOfFolds:(NSInteger)folds
               forDuration:(CGFloat)duration
             withDirection:(FoldingDirection)direction
                completion:(void (^)(BOOL))completion
{
    
    foldingDirection = direction;
    if (currentState != FoldingTransitionStateShow) {
        return;
    }
    
    currentState = FoldingTransitionStateUpdateToHide;
    
    //set frame
    CGRect selfFrame = [self newCenterFrameForSideView:view ForDirection:direction];
    [CATransaction setCompletionBlock:^{
        self.frame = selfFrame;
        currentState = FoldingTransitionStateIdle;
        
		if (completion)
			completion(YES);
    }];
    
    [CATransaction setValue:[NSNumber numberWithFloat:duration]
                     forKey:kCATransactionAnimationDuration];
    
    CGPoint start = (foldingDirection<2)? CGPointMake(self.frame.origin.x+self.frame.size.width/2,self.frame.origin.y):CGPointMake(self.frame.origin.x,self.frame.origin.y+self.frame.size.height/2);
    CGPoint end = (foldingDirection<2)?CGPointMake(selfFrame.origin.x+self.frame.size.width/2,self.frame.origin.y):CGPointMake(self.frame.origin.x,selfFrame.origin.y+self.frame.size.height/2);
    
    [self translateWithDirection:direction
                    fromPosition:start
                      toPosition:end
                    withFunction:closeFunction
                     forDuration:duration];
    [CATransaction commit];
}
-(BOOL)isSideViewVisible
{
    if(currentState == FoldingTransitionStateIdle)
        return NO;
    else
        return YES;
}

#pragma mark - helper methods

-(void)translateWithDirection:(FoldingDirection)direction
                 fromPosition:(CGPoint)start
                   toPosition:(CGPoint)end
                 withFunction:(KeyframeParametricBlock)block
                  forDuration:(float)duration
{
    CAAnimation *openAnimation = (direction < 2)?[CAKeyframeAnimation animationWithKeyPath:@"position.x" function:block fromValue:start.x toValue:end.x]:[CAKeyframeAnimation animationWithKeyPath:@"position.y" function:block fromValue:start.y toValue:end.y];
    
    openAnimation.fillMode = kCAFillModeForwards;
    [openAnimation setRemovedOnCompletion:NO];
    [self.layer addAnimation:openAnimation forKey:@"position"];
}

-(CGRect) newCenterFrameForSideView:(UIView*)sideView ForDirection:(FoldingDirection)direction
{
    CGRect centerFrame = self.frame;
    if(currentState == FoldingTransitionStateUpdateToShow){
        switch (direction) {
            case FoldingDirectionFromRight:
                centerFrame.origin.x = self.frame.origin.x - sideView.bounds.size.width;
                break;
            case FoldingDirectionFromLeft:
                centerFrame.origin.x = self.frame.origin.x + sideView.bounds.size.width;
                break;
            case FoldingDirectionFromTop:
                centerFrame.origin.y = self.frame.origin.y + sideView.bounds.size.height;
                break;
            case FoldingDirectionFromBottom:
                centerFrame.origin.y = self.frame.origin.y - sideView.bounds.size.height;
                break;
        }
    }
    else if(currentState == FoldingTransitionStateUpdateToHide){
        switch(direction){
            case FoldingDirectionFromRight:
                centerFrame.origin.x = self.frame.origin.x + sideView.bounds.size.width;
                break;
            case FoldingDirectionFromLeft:
                centerFrame.origin.x = self.frame.origin.x - sideView.bounds.size.width;
                break;
            case FoldingDirectionFromTop:
                centerFrame.origin.y = self.frame.origin.y - sideView.bounds.size.height;
                break;
            case FoldingDirectionFromBottom:
                centerFrame.origin.y = self.frame.origin.y + sideView.bounds.size.height;
                break;
                
        }
    }
    return centerFrame;
}
-(CGRect)newFrameForView:(UIView*)view forDirection:(FoldingDirection)direction
{
    CGRect viewFrame;
    switch (direction) {
        case FoldingDirectionFromLeft:
            viewFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, view.frame.size.width, view.frame.size.height);
            break;
        case FoldingDirectionFromRight:
            viewFrame = CGRectMake(self.frame.origin.x+self.frame.size.width-view.frame.size.width, self.frame.origin.y, view.frame.size.width, view.frame.size.height);
            break;
        case FoldingDirectionFromTop:
            viewFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, view.frame.size.width, view.frame.size.height);
            break;
        case FoldingDirectionFromBottom:
            viewFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y+self.frame.size.height-view.frame.size.height, view.frame.size.width, view.frame.size.height);
            break;
            
    }
    return viewFrame;
}

-(CGPoint)anchorPointForDirection:(FoldingDirection)direction
{
    CGPoint anchorPoint;
    switch (direction) {
        case FoldingDirectionFromLeft:
            anchorPoint = CGPointMake(0, 0.5);
            break;
        case FoldingDirectionFromRight:
            anchorPoint = CGPointMake(1, 0.5);
            break;
        case FoldingDirectionFromTop:
            anchorPoint = CGPointMake(0.5, 0);
            break;
        case FoldingDirectionFromBottom:
            anchorPoint = CGPointMake(0.5, 1);
            break;
            
    }
    return anchorPoint;
}

-(void)showFoldingAnimationForView:(UIView*)view
{
    //set 3D depth (Add perspective transformation)
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0/800.0;
    foldingLayer = [CALayer layer];
    foldingLayer.frame = view.bounds;
//    foldingLayer.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1].CGColor;
    foldingLayer.backgroundColor = [UIColor clearColor].CGColor;
    foldingLayer.sublayerTransform = transform;
    [view.layer addSublayer:foldingLayer];
    
}
@end
