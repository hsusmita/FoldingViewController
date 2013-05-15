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
    
    //Get the final frame of the top view
    CGRect selfFrame = [self finalSelfFrameForSideView:view forDirection:direction];
    //Set the psotioning of the side view
    [self repositionSideView:view forDirection:direction];
    
    //Configure the folding layer by adding transform layer for rotation
    [self configureFoldingLayerForView:view
                     withNumberOfFolds:folds
                           withDuration:duration
                         withDirection:direction];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        
        self.frame = selfFrame;
        currentState = FoldingTransitionStateShow;
        [foldingLayer removeFromSuperlayer];  //remove the folding layer
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
    
    //Get the final frame of the top view
    CGRect selfFrame = [self finalSelfFrameForSideView:view
                                          forDirection:direction];
    
    [self configureFoldingLayerForView:view
                     withNumberOfFolds:folds
                           withDuration:duration
                         withDirection:direction];

    [CATransaction setCompletionBlock:^{
        self.frame = selfFrame;
        [foldingLayer removeFromSuperlayer];     //remove the folding layer
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

-(CGRect) finalSelfFrameForSideView:(UIView*)sideView
                     forDirection:(FoldingDirection)direction
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

-(void) repositionSideView:(UIView*)view forDirection:(FoldingDirection)direction
{
    CGRect viewFrame;
    switch (direction) {
        case FoldingDirectionFromLeft:
            viewFrame = CGRectMake(self.frame.origin.x,
                                   self.frame.origin.y,
                                   view.frame.size.width,
                                   view.frame.size.height);
            break;
        case FoldingDirectionFromRight:
            viewFrame = CGRectMake(self.frame.origin.x+self.frame.size.width-view.frame.size.width,
                                   self.frame.origin.y,
                                   view.frame.size.width,
                                   view.frame.size.height);
            break;
        case FoldingDirectionFromTop:
            viewFrame = CGRectMake(self.frame.origin.x,
                                   self.frame.origin.y,
                                   view.frame.size.width,
                                   view.frame.size.height);
            break;
        case FoldingDirectionFromBottom:
            viewFrame = CGRectMake(self.frame.origin.x,
                                   self.frame.origin.y+self.frame.size.height-view.frame.size.height,
                                   view.frame.size.width,
                                   view.frame.size.height);
            break;
            
    }
    view.frame = viewFrame;
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

- (CATransformLayer *)transformLayerFromImage:(UIImage *)image
                                    withFrame:(CGRect)frame
                                 withDuration:(CGFloat)duration
                              withAnchorPoint:(CGPoint)anchorPoint
                               withStartAngle:(double)start
                                 withEndAngle:(double)end;

{
    CATransformLayer *jointLayer = [CATransformLayer layer];
    CALayer *imageLayer = [CALayer layer];
    CAGradientLayer *shadowLayer = [CAGradientLayer layer];
    double shadowAniOpacity; 
    
    float imageLayerPositionX;
    float imageLayerPositionY;
    
    CGPoint shadowStartPoint;
    CGPoint shadowEndPoint;
    CGPoint jointLayerPosition;
    
    NSInteger index;
    CGFloat layerWidth;
    CGFloat layerHeight;
    
    if (anchorPoint.y == 0.5) {
       
        layerHeight = frame.size.height;
        if (anchorPoint.x == 0 ) //from left to right
        {
            layerWidth = image.size.width - frame.origin.x;
            jointLayerPosition = frame.origin.x ? CGPointMake(frame.size.width, frame.size.height/2):CGPointMake(0, frame.size.height/2);

        }
        else
        { //from right to left
            layerWidth = frame.origin.x + frame.size.width;
            jointLayerPosition = CGPointMake(layerWidth, frame.size.height/2);
        }
              
        imageLayerPositionX = layerWidth*anchorPoint.x;
        imageLayerPositionY = frame.size.height/2;
              
        index = frame.origin.x/frame.size.width;
        if (index%2) {
            
            shadowStartPoint = CGPointMake(0.5, 0);
            shadowEndPoint = CGPointMake(1, 0.5);
        }
        else {
            shadowStartPoint = CGPointMake(0.5, 1);
            shadowEndPoint = CGPointMake(0.5, 0);
        }

    }
    else{
        
        layerWidth = frame.size.width;
        if (anchorPoint.y == 0 ) //from top
        {
            layerHeight = image.size.height - frame.origin.y;
            jointLayerPosition = frame.origin.y?CGPointMake(frame.size.width/2, frame.size.height):CGPointMake(frame.size.width/2, 0);
        }
        else    //from bottom
        { 
            layerHeight = frame.size.height + frame.origin.y;
            jointLayerPosition = CGPointMake(frame.size.width/2, layerHeight);
        }
        
        imageLayerPositionX = frame.size.width/2;
        imageLayerPositionY = layerHeight*anchorPoint.y;
        
        index = frame.origin.y/frame.size.height;
        if (index%2) {
            
            shadowStartPoint = CGPointMake(0.5, 0);
            shadowEndPoint = CGPointMake(0.5, 1);
        }
        else {
            shadowStartPoint = CGPointMake(0.5, 1);
            shadowEndPoint = CGPointMake(0.5, 0);
        }
        
        }

    //Configure joint Layer
    jointLayer.anchorPoint = anchorPoint;
    jointLayer.frame = CGRectMake(0, 0, layerWidth, layerHeight);
    jointLayer.position =  jointLayerPosition;

    //Configure Image Layer
    imageLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    imageLayer.anchorPoint = anchorPoint;
    imageLayer.position = CGPointMake(imageLayerPositionX, imageLayerPositionY);
    [jointLayer addSublayer:imageLayer];
    CGImageRef imageCrop = CGImageCreateWithImageInRect(image.CGImage, frame);
    imageLayer.contents = (__bridge id)imageCrop;
    imageLayer.backgroundColor = [UIColor clearColor].CGColor;

    //Add shadow to image Layer
    shadowLayer.frame = imageLayer.bounds;
    shadowLayer.backgroundColor = [UIColor darkGrayColor].CGColor;
    shadowLayer.opacity = 0.0;
    shadowLayer.colors = [NSArray arrayWithObjects:
                      (id)[UIColor blackColor].CGColor,
                      (id)[UIColor clearColor].CGColor, nil];

    shadowLayer.startPoint = shadowStartPoint;
    shadowLayer.endPoint = shadowEndPoint;
    
    if(index%2)
        shadowAniOpacity = (anchorPoint.x)?0.24:0.32;
    else
        shadowAniOpacity = (anchorPoint.x)?0.32:0.24;

    [imageLayer addSublayer:shadowLayer];
    
    //animate open/close animation
    CABasicAnimation* animation = (anchorPoint.y == 0.5)?[CABasicAnimation animationWithKeyPath:@"transform.rotation.y"]:[CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    [animation setDuration:duration];
    [animation setFromValue:[NSNumber numberWithDouble:start]];
    [animation setToValue:[NSNumber numberWithDouble:end]];
    [animation setRemovedOnCompletion:NO];
    [jointLayer addAnimation:animation forKey:@"jointAnimation"];
    
    //animate shadow opacity
    animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [animation setDuration:duration];
    [animation setFromValue:[NSNumber numberWithDouble:(start)?shadowAniOpacity:0]];
    [animation setToValue:[NSNumber numberWithDouble:(start)?0:shadowAniOpacity]];
    [animation setRemovedOnCompletion:NO];
    [shadowLayer addAnimation:animation forKey:nil];
    
    return jointLayer;
}
-(NSArray*)transformlayersForImage:(UIImage*)image
                 withNumberOfFolds:(NSInteger)folds
                     withDirection:(FoldingDirection)direction
             withAnimationDuration:(float)duration
{
    NSMutableArray *layerList = [[NSMutableArray alloc]init];
    //setup rotation angle
    double newAngle;
    CGFloat frameWidth = image.size.width;
    CGFloat frameHeight = image.size.height;
    CGFloat foldWidth = (direction < 2)?frameWidth/(folds*2):frameHeight/(folds*2);
    CGPoint anchorPoint = [self anchorPointForDirection:direction]; //Set anchor Points
    for (int b=0; b < folds*2; b++) {
        CGRect imageFrame;
        switch(direction)
        {
            case FoldingDirectionFromRight:
                if(b == 0)
                    newAngle = -M_PI_2;
                else {
                    if (b%2)
                        newAngle = M_PI;
                    else
                        newAngle = -M_PI;
                }
                imageFrame = CGRectMake(frameWidth-(b+1)*foldWidth, 0, foldWidth, frameHeight);
                break;
            case FoldingDirectionFromLeft:
                if(b == 0)
                    newAngle = M_PI_2;
                else {
                    if (b%2)
                        newAngle = -M_PI;
                    else
                        newAngle = M_PI;
                }
                imageFrame = CGRectMake(b*foldWidth, 0, foldWidth, frameHeight);
                break;
            case FoldingDirectionFromTop:
                if(b == 0)
                    newAngle = -M_PI_2;
                else {
                    if (b%2)
                        newAngle = M_PI;
                    else
                        newAngle = -M_PI;
                }
                imageFrame = CGRectMake(0, b*foldWidth, frameWidth, foldWidth);
                break;
            case FoldingDirectionFromBottom:
                if(b == 0)
                    newAngle = M_PI_2;
                else {
                    if (b%2)
                        newAngle = -M_PI;
                    else
                        newAngle = M_PI;
                }
                imageFrame = CGRectMake(0, frameHeight-(b+1)*foldWidth, frameWidth, foldWidth);
                break;
        }
        CATransformLayer *transLayer;
        if(currentState== FoldingTransitionStateUpdateToShow)
            transLayer = [self transformLayerFromImage:image
                                                 withFrame:imageFrame
                                              withDuration:duration
                                           withAnchorPoint:anchorPoint
                                            withStartAngle:newAngle
                                              withEndAngle:0];
        else if(currentState == FoldingTransitionStateUpdateToHide)
            transLayer = [self transformLayerFromImage:image
                                             withFrame:imageFrame
                                          withDuration:duration withAnchorPoint:anchorPoint
                                        withStartAngle:0
                                          withEndAngle:newAngle];
        [layerList addObject:transLayer];
        
    }
    return layerList;
}

-(void)configureFoldingLayerForView:(UIView*)view
                  withNumberOfFolds:(NSInteger)folds
                        withDuration:(CGFloat)duration
                      withDirection:(FoldingDirection)direction

{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0/800.0;
    foldingLayer = [CALayer layer];
    foldingLayer.frame = view.bounds;
    foldingLayer.backgroundColor = [UIColor clearColor].CGColor;
    foldingLayer.sublayerTransform = transform;
    [view.layer addSublayer:foldingLayer];
    
    UIGraphicsBeginImageContext(view.frame.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewSnapShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSArray *transformLayers = [[NSArray alloc]initWithArray:
                                [self transformlayersForImage:viewSnapShot
                                            withNumberOfFolds:folds
                                                withDirection:direction
                                        withAnimationDuration:duration]];
    
    CALayer *prevLayer = foldingLayer;
    for(CALayer* transLayer in transformLayers){
        [prevLayer addSublayer:transLayer];
        prevLayer = transLayer;
    }
}

@end
