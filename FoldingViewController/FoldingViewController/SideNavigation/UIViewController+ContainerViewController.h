//
//  UIViewController+ContainerViewController.h
//  FoldingViewController
//
//  Created by hsusmita  on 07/05/13.
//  Copyright (c) 2013 hsusmita. All rights reserved.
//
// Category is defined so that child controller in the side wise navigation
// can send messges to container view controller ,
// In this way , they dont have to have the reference of their container view controller
//

#import <UIKit/UIKit.h>
#import "SideNavigationContainerViewController.h"

@interface UIViewController (ContainerViewController)

- (SideNavigationContainerViewController *)containerViewController;

@end
