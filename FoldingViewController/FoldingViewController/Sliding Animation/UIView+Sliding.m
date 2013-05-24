//
//  UIView+Sliding.m
//  FoldingViewController
//
//  Created by sah-fueled on 24/05/13.
//  Copyright (c) 2013 hsusmita. All rights reserved.
//

#import "UIView+Sliding.h"

@implementation UIView (Sliding)

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
                     }];

}

@end
