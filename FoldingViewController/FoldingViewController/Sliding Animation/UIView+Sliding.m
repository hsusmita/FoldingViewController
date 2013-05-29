//
//  UIView+Sliding.m
//  FoldingViewController
//
//  Created by sah-fueled on 24/05/13.
//  Copyright (c) 2013 hsusmita. All rights reserved.
//

#import "UIView+Sliding.h"

@implementation UIView (Sliding)

UIView *sideView;
CGPoint initialPosition;
CGPoint finalPosition;
CGPoint currentPoint;
int draggingDirection;
float offset;

DraggingTransitionState draggingState;

-(void)slideInView:(UIView *)view
       forDuration:(CGFloat)duration
     withDirection:(SlidingDirection)direction
        completion:(void (^)(BOOL))completion
{
    [UIView animateWithDuration:duration
                     animations:^{
                         CGRect rect = self.frame;
                         switch (direction) {
                             case SlidingDirectionFromRight:
                                 rect.origin.x = -view.frame.size.width;
                                 break;
                             case SlidingDirectionFromLeft:
                                 rect.origin.x = view.frame.size.width;
                                 break;
                             case SlidingDirectionFromTop:
                                 rect.origin.y = view.frame.size.height;
                                 break;
                             case SlidingDirectionFromBottom:
                                 rect.origin.y = -view.frame.size.height;
                                 break;
                             default:
                                 break;
                         }
                         self.frame = rect;
                     }
                     completion:^(BOOL finished) {
                         if(completion)
                             completion(YES);
                         draggingState = DraggingTransitionStateShow;
                     }];

}

-(void)slideBackView:(UIView *)view
         forDuration:(CGFloat)duration
       withDirection:(SlidingDirection)direction
          completion:(void (^)(BOOL))completion
{
    [UIView animateWithDuration:duration
                     animations:^{
                         CGRect rect = view.frame;
                         
                         if(direction >1)
                             rect.origin.y = 0;
                         else
                             rect.origin.x = 0;
                         self.frame = rect;
                     }
                     completion:^(BOOL finished) {
                         if(completion)
                             completion(YES);
                         draggingState = DraggingTransitionStateIdle;
                         [self setFrame:CGRectMake(0, 0, 320, 480)];
                     }];

}
-(void)enableDragForDirection:(DraggingDirection) dragDirection
                 withSideView:(UIView *)view
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:panGesture];
    draggingDirection = dragDirection;
    NSLog(@"dragging direction = %d",dragDirection);
    initialPosition = [self initialCenter];
    draggingState = DraggingTransitionStateIdle;
    currentPoint = initialPosition;
    sideView = view;
//    offset = sideView.frame.size.width;
    if(draggingDirection == DraggingDirectionToRight || draggingDirection == DraggingDirectionToLeft)
        offset = sideView.frame.size.width;
    else if(draggingDirection == DraggingDirectionToTop || draggingDirection == DraggingDirectionToBottom)
         offset = sideView.frame.size.height;
//    offset = 100;
  }

-(CGPoint)initialCenter
{
    return CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}
-(CGPoint)finalCenterForView:(UIView*)view
{
    CGPoint finalCenter; 
    switch (draggingDirection) {
        case DraggingDirectionToRight:
        {
            finalCenter = CGPointMake(self.frame.size.width/2+offset, self.frame.size.height/2);
            break;
        }
        case DraggingDirectionToLeft:
        {
            finalCenter = CGPointMake(self.frame.size.width/2-offset, self.frame.size.height/2);
            break;
        }
        case DraggingDirectionToTop:
        {
            finalCenter = CGPointMake(self.frame.size.width/2, self.frame.size.height/2+offset);
            break;
        }
        case DraggingDirectionToBottom:
        {
            finalCenter = CGPointMake(self.frame.size.width/2, self.frame.size.height/2-offset);
            break;
        }
        default:
            break;
    }
    
    return finalCenter;
}
-(float)translationForGesture:(UIPanGestureRecognizer*)gesture
{
    CGPoint velocity = [gesture velocityInView:self.superview];
    CGPoint point = [gesture translationInView:self.superview];
    float translation;
    
    switch(draggingDirection)
    {
        case DraggingDirectionToRight:
        {
            if(draggingState == DraggingTransitionStateUpdateToShow && point.x<0 && abs(velocity.x) > abs(velocity.y))
                translation = 0;
            else if(draggingState == DraggingTransitionStateUpdateToHide && point.x>0 && abs(velocity.x) > abs(velocity.y))
                translation = 0;
            else
                translation = abs(point.x);
            
            break;
        }
        case DraggingDirectionToLeft:
        {
            if(draggingState == DraggingTransitionStateUpdateToShow && point.x>0 && abs(velocity.x) > abs(velocity.y))
                translation = 0;
            else if(draggingState == DraggingTransitionStateUpdateToHide && point.x<0 && abs(velocity.x) > abs(velocity.y))
                translation = 0;
            else
                translation = abs(point.x);

            break;
        }
        case DraggingDirectionToTop:
        {
            if(draggingState == DraggingTransitionStateUpdateToShow && point.y<0 && abs(velocity.x) < abs(velocity.y))
                translation = 0;
            else if(draggingState == DraggingTransitionStateUpdateToHide && point.y>0 && abs(velocity.x) < abs(velocity.y))
                translation = 0;
            else
                translation = abs(point.y);

            break;
        }
        case DraggingDirectionToBottom:
        {
            if(draggingState == DraggingTransitionStateUpdateToShow && point.y>0 && abs(velocity.x) < abs(velocity.y))
                translation = 0;
            else if(draggingState == DraggingTransitionStateUpdateToHide && point.y<0 && abs(velocity.x) < abs(velocity.y))
                translation = 0;
            else
                translation = abs(point.y);

            break;
        }
    }
    
    return translation;
}
-(void)handlePan:(UIPanGestureRecognizer *)gesture
{
    CGPoint point = [gesture translationInView:self.superview];
    CGPoint velocity = [gesture velocityInView:self.superview];
    finalPosition = [self finalCenterForView:sideView];
    
    if(gesture.state == UIGestureRecognizerStateBegan){
        
        if(draggingState == DraggingTransitionStateIdle){
            
            draggingState = DraggingTransitionStateUpdateToShow;
            currentPoint = [self initialCenter];
        }
        
        else if(draggingState == DraggingTransitionStateShow){
            draggingState = DraggingTransitionStateUpdateToHide;
            currentPoint = [self finalCenterForView:sideView];
        }
    }
//    NSLog(@"point = %f %f",point.x,point.y);
//    NSLog(@"state= %d",draggingState);

    if(gesture.state == UIGestureRecognizerStateChanged)
    {
        switch (draggingDirection) {
            case DraggingDirectionToRight:
            {
            if(abs(velocity.x)>abs(velocity.y) && abs(point.x) <offset)
                {
                    if(draggingState == DraggingTransitionStateUpdateToShow && point.x>0)
                         currentPoint.x = initialPosition.x + point.x;
                    else if(draggingState == DraggingTransitionStateUpdateToHide && point.x<0)
                        currentPoint.x = finalPosition.x + point.x;
                }
                
             break;
            }
            case DraggingDirectionToLeft:
            {
                if(abs(velocity.x)>abs(velocity.y) && abs(point.x) <offset)
                {
                    if(draggingState == DraggingTransitionStateUpdateToShow && point.x<0)
                        currentPoint.x = initialPosition.x + point.x;
                    else if(draggingState == DraggingTransitionStateUpdateToHide && point.x>0)
                        currentPoint.x = finalPosition.x + point.x;
                }

                break;
            }
            case DraggingDirectionToTop:
            {
                if(abs(velocity.x)<abs(velocity.y) && abs(point.y) <offset)
                {
                    if(draggingState == DraggingTransitionStateUpdateToShow && point.y>0)
                        currentPoint.y = initialPosition.y + point.y;
                    else if(draggingState == DraggingTransitionStateUpdateToHide && point.y<0)
                        currentPoint.y = finalPosition.y + point.y;
                }
                break;
            }
            case DraggingDirectionToBottom:
            {
                if(abs(velocity.x)<abs(velocity.y) && abs(point.y) <offset)
                {
                    if(draggingState == DraggingTransitionStateUpdateToShow && point.y<0)
                        currentPoint.y = initialPosition.y + point.y;
                    else if(draggingState == DraggingTransitionStateUpdateToHide && point.y>0)
                        currentPoint.y = finalPosition.y + point.y;
                }

                break;
            }
        }
        
        self.center = currentPoint;
    }
    if(gesture.state == UIGestureRecognizerStateEnded)
    {
        float translation = [self translationForGesture:gesture];
        switch(draggingState)
        {
                
            case DraggingTransitionStateUpdateToShow:
            {
                if(translation>0){
                if(translation<offset/2){
                    self.center = [self initialCenter];
                    draggingState = DraggingTransitionStateIdle;
                }else{
                    self.center = finalPosition;
                    draggingState = DraggingTransitionStateShow;
                }
                }
                    break;
            }
            case DraggingTransitionStateUpdateToHide:
            {
                if(translation >0){
                if(translation<offset/2){
                    self.center = finalPosition;
                    draggingState = DraggingTransitionStateShow;
                }else{
                    self.center = initialPosition;
                    draggingState = DraggingTransitionStateIdle;
                }
                }
                break;
            }
            default:
                break;
        }
    }
    
}


@end
