//
//  UIView+Origami.m
//  origami
//
//  Created by XY Feng on 4/6/12.
//  Copyright (c) 2012 Xiaoyang Feng. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.

#import "UIView+Origami.h"

KeyframeParametricBlock openFunction = ^double(double time) {
    return sin(time*M_PI_2);
};
KeyframeParametricBlock closeFunction = ^double(double time) {
    return -cos(time*M_PI_2)+1;
};
KeyframeParametricBlock rotateFunction = ^double(double time) {
    return -cos(time*M_PI_2)+1;
};

static XYOrigamiTransitionState XY_Origami_Current_State = XYOrigamiTransitionStateIdle;

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

@implementation UIView (Origami)

XYOrigamiDirection origamiDirection;
CGRect selfFrame;
CGPoint startPoint;
CGPoint endPoint;

- (void)showOrigamiTransitionWith:(UIView *)view
                    withNumberOfFolds:(NSInteger)folds 
                         forDuration:(CGFloat)duration
                        withDirection:(XYOrigamiDirection)direction
                       completion:(void (^)(BOOL finished))completion
{
    origamiDirection = direction;
    if (XY_Origami_Current_State != XYOrigamiTransitionStateIdle) {
        return;
    }
    XY_Origami_Current_State = XYOrigamiTransitionStateUpdateToShow;
    
    //add view as parent subview
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
 
    [CATransaction setValue:[NSNumber numberWithFloat:duration]
                     forKey:kCATransactionAnimationDuration];
//  Add Translation animation
    CGPoint start = (origamiDirection<2)?
    CGPointMake(self.frame.origin.x+self.frame.size.width/2,self.frame.origin.y):
    CGPointMake(self.frame.origin.x,self.frame.origin.y+self.frame.size.height/2);
    CGPoint end = (origamiDirection<2)?
    CGPointMake(selfFrame.origin.x+self.frame.size.width/2,self.frame.origin.y):
    CGPointMake(self.frame.origin.x,selfFrame.origin.y+self.frame.size.height/2);

    [self translateWithDirection:direction
                    fromPosition:start
                      toPosition:end
                    withFunction:openFunction
                     forDuration:duration];
    [CATransaction commit];
}

- (void)hideOrigamiTransitionWith:(UIView *)view
                    withNumberOfFolds:(NSInteger)folds
                         forDuration:(CGFloat)duration
                        withDirection:(XYOrigamiDirection)direction
                       completion:(void (^)(BOOL finished))completion
{
    origamiDirection = direction;
    if (XY_Origami_Current_State != XYOrigamiTransitionStateShow) {
        return;
    }
    
    XY_Origami_Current_State = XYOrigamiTransitionStateUpdateToHide;
    
    //set frame
    CGRect selfFrame = [self newCenterFrameForSideView:view ForDirection:direction];
    
    UIGraphicsBeginImageContext(view.frame.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewSnapShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //set 3D depth
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
    for(CALayer* transLayer in transformLayers){
        [prevLayer addSublayer:transLayer];
        prevLayer = transLayer;
    }
    
    [CATransaction setCompletionBlock:^{
        self.frame = selfFrame;
        [origamiLayer removeFromSuperlayer];
        XY_Origami_Current_State = XYOrigamiTransitionStateIdle;
        
		if (completion)
			completion(YES);
    }];
    
    [CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
    
    CGPoint start = (origamiDirection<2)? CGPointMake(self.frame.origin.x+self.frame.size.width/2,self.frame.origin.y):CGPointMake(self.frame.origin.x,self.frame.origin.y+self.frame.size.height/2);
    CGPoint end = (origamiDirection<2)?CGPointMake(selfFrame.origin.x+self.frame.size.width/2,self.frame.origin.y):CGPointMake(self.frame.origin.x,selfFrame.origin.y+self.frame.size.height/2);
    
    [self translateWithDirection:direction fromPosition:start toPosition:end withFunction:closeFunction forDuration:duration];
    [CATransaction commit];
}

-(BOOL)isSideViewVisible
{
    if(XY_Origami_Current_State == XYOrigamiTransitionStateIdle)
        return NO;
    else
        return YES;
}

#pragma mark - helper methods

-(void)translateWithDirection:(XYOrigamiDirection)direction
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
-(CGPoint)anchorPointForDirection:(XYOrigamiDirection)direction
{
    CGPoint anchorPoint;
    switch (direction) {
        case XYOrigamiDirectionFromLeft:
            anchorPoint = CGPointMake(0, 0.5);
            break;
        case XYOrigamiDirectionFromRight:
            anchorPoint = CGPointMake(1, 0.5);
            break;
        case XYOrigamiDirectionFromTop:
            anchorPoint = CGPointMake(0.5, 0);
            break;
        case XYOrigamiDirectionFromBottom:
            anchorPoint = CGPointMake(0.5, 1);
            break;
            
    }
    return anchorPoint;
}

-(CGRect)newFrameForView:(UIView*)view forDirection:(XYOrigamiDirection)direction
{
    CGRect viewFrame;
    switch (direction) {
        case XYOrigamiDirectionFromLeft:
            viewFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, view.frame.size.width, view.frame.size.height);
            break;
        case XYOrigamiDirectionFromRight:
            viewFrame = CGRectMake(self.frame.origin.x+self.frame.size.width-view.frame.size.width, self.frame.origin.y, view.frame.size.width, view.frame.size.height);
            break;
        case XYOrigamiDirectionFromTop:
            viewFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, view.frame.size.width, view.frame.size.height);
            break;
        case XYOrigamiDirectionFromBottom:
            viewFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y+self.frame.size.height-view.frame.size.height, view.frame.size.width, view.frame.size.height);
            break;
            
    }
    return viewFrame;
}
-(CGRect) newCenterFrameForSideView:(UIView*)sideView ForDirection:(XYOrigamiDirection)direction
{
    CGRect centerFrame = self.frame;
    if(XY_Origami_Current_State == XYOrigamiTransitionStateUpdateToShow){
        switch (direction) {
            case XYOrigamiDirectionFromRight:
                centerFrame.origin.x = self.frame.origin.x - sideView.bounds.size.width;
                break;
            case XYOrigamiDirectionFromLeft:
                centerFrame.origin.x = self.frame.origin.x + sideView.bounds.size.width;
                break;
            case XYOrigamiDirectionFromTop:
                centerFrame.origin.y = self.frame.origin.y + sideView.bounds.size.height;
                break;
            case XYOrigamiDirectionFromBottom:
                centerFrame.origin.y = self.frame.origin.y - sideView.bounds.size.height;
                break;
        }
    }
    else if(XY_Origami_Current_State == XYOrigamiTransitionStateUpdateToHide){
        switch(direction){
            case XYOrigamiDirectionFromRight:
                centerFrame.origin.x = self.frame.origin.x + sideView.bounds.size.width;
                break;
            case XYOrigamiDirectionFromLeft:
                centerFrame.origin.x = self.frame.origin.x - sideView.bounds.size.width;
                break;
            case XYOrigamiDirectionFromTop:
                centerFrame.origin.y = self.frame.origin.y - sideView.bounds.size.height;
                break;
            case XYOrigamiDirectionFromBottom:
                centerFrame.origin.y = self.frame.origin.y + sideView.bounds.size.height;
                break;
        
        }
    }
        return centerFrame;
}
-(NSArray*)transformlayersForImage:(UIImage*)image
                    withDirection:(XYOrigamiDirection)direction
                    withFoldCount:(NSInteger)folds
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
            case XYOrigamiDirectionFromRight:
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
            case XYOrigamiDirectionFromLeft:
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
            case XYOrigamiDirectionFromTop:
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
            case XYOrigamiDirectionFromBottom:
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
        if(XY_Origami_Current_State == XYOrigamiTransitionStateUpdateToShow)
            transLayer = [self transformLayerFromImage:image Frame:imageFrame Duration:duration AnchorPoint:anchorPoint StartAngle:newAngle EndAngle:0];
        else if(XY_Origami_Current_State == XYOrigamiTransitionStateUpdateToHide)
            transLayer = [self transformLayerFromImage:image Frame:imageFrame Duration:duration AnchorPoint:anchorPoint StartAngle:0 EndAngle:newAngle];
        [layerList addObject:transLayer];
        
        }
    return layerList;
}
- (CATransformLayer *)transformLayerFromImage:(UIImage *)image
                                        Frame:(CGRect)frame
                                     Duration:(CGFloat)duration
                                  AnchorPoint:(CGPoint)anchorPoint
                                   StartAngle:(double)start
                                     EndAngle:(double)end;
{
    CATransformLayer *jointLayer = [CATransformLayer layer];
    jointLayer.anchorPoint = anchorPoint;
    CALayer *imageLayer = [CALayer layer];
    CAGradientLayer *shadowLayer = [CAGradientLayer layer];
    double shadowAniOpacity;
    
    if (anchorPoint.y == 0.5) {
        CGFloat layerWidth;
        if (anchorPoint.x == 0 ) //from left to right
        {
            layerWidth = image.size.width - frame.origin.x;
            jointLayer.frame = CGRectMake(0, 0, layerWidth, frame.size.height);
            if (frame.origin.x) {
                jointLayer.position = CGPointMake(frame.size.width, frame.size.height/2);
            }
            else {
                jointLayer.position = CGPointMake(0, frame.size.height/2);
            }
        }
        else { //from right to left
            layerWidth = frame.origin.x + frame.size.width;
            jointLayer.frame = CGRectMake(0, 0, layerWidth, frame.size.height);
            jointLayer.position = CGPointMake(layerWidth, frame.size.height/2);
        }
        
        //map image onto transform layer
        imageLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        imageLayer.anchorPoint = anchorPoint;
        imageLayer.position = CGPointMake(layerWidth*anchorPoint.x, frame.size.height/2);
        [jointLayer addSublayer:imageLayer];
        CGImageRef imageCrop = CGImageCreateWithImageInRect(image.CGImage, frame);
        imageLayer.contents = (__bridge id)imageCrop;
        imageLayer.backgroundColor = [UIColor clearColor].CGColor;
        
        //add shadow
        NSInteger index = frame.origin.x/frame.size.width;
        shadowLayer.frame = imageLayer.bounds;
        shadowLayer.backgroundColor = [UIColor darkGrayColor].CGColor;
        shadowLayer.opacity = 0.0;
        shadowLayer.colors = [NSArray arrayWithObjects:
                              (id)[UIColor blackColor].CGColor,
                              (id)[UIColor clearColor].CGColor, nil];
        if (index%2) {
            shadowLayer.startPoint = CGPointMake(0, 0.5);
            shadowLayer.endPoint = CGPointMake(1, 0.5);
            shadowAniOpacity = (anchorPoint.x)?0.24:0.32;
        }
        else {
            shadowLayer.startPoint = CGPointMake(1, 0.5);
            shadowLayer.endPoint = CGPointMake(0, 0.5);
            shadowAniOpacity = (anchorPoint.x)?0.32:0.24;
        }
    }
    else{
        CGFloat layerHeight;
        if (anchorPoint.y == 0 ) //from top
        {
            layerHeight = image.size.height - frame.origin.y;
            jointLayer.frame = CGRectMake(0, 0, frame.size.width, layerHeight);
            if (frame.origin.y) {
                jointLayer.position = CGPointMake(frame.size.width/2, frame.size.height);
            }
            else {
                jointLayer.position = CGPointMake(frame.size.width/2, 0);
            }
        }
        else { //from bottom
            layerHeight = frame.origin.y + frame.size.height;
            jointLayer.frame = CGRectMake(0, 0, frame.size.width, layerHeight);
            jointLayer.position = CGPointMake(frame.size.width/2, layerHeight);
        }
        
        //map image onto transform layer
        imageLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        imageLayer.anchorPoint = anchorPoint;
        imageLayer.position = CGPointMake(frame.size.width/2, layerHeight*anchorPoint.y);
        [jointLayer addSublayer:imageLayer];
        CGImageRef imageCrop = CGImageCreateWithImageInRect(image.CGImage, frame);
        imageLayer.contents = (__bridge id)imageCrop;
        imageLayer.backgroundColor = [UIColor clearColor].CGColor;
        
        //add shadow
        NSInteger index = frame.origin.y/frame.size.height;
        shadowLayer.frame = imageLayer.bounds;
        shadowLayer.backgroundColor = [UIColor darkGrayColor].CGColor;
        shadowLayer.opacity = 0.0;
        shadowLayer.colors = [NSArray arrayWithObjects:(id)[UIColor blackColor].CGColor, (id)[UIColor clearColor].CGColor, nil];
        if (index%2) {
            shadowLayer.startPoint = CGPointMake(0.5, 0);
            shadowLayer.endPoint = CGPointMake(0.5, 1);
            shadowAniOpacity = (anchorPoint.x)?0.24:0.32;
        }
        else {
            shadowLayer.startPoint = CGPointMake(0.5, 1);
            shadowLayer.endPoint = CGPointMake(0.5, 0);
            shadowAniOpacity = (anchorPoint.x)?0.32:0.24;
        }
    }
    
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

#pragma mark - controlling transition with touch

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = (UITouch*)[[touches allObjects]objectAtIndex:0];
    startPoint = [touch locationInView:self];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = (UITouch*)[[touches allObjects]objectAtIndex:0];
    endPoint = [touch locationInView:self];
  
}


@end
