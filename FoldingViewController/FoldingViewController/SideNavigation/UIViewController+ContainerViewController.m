//
//  UIViewController+ContainerViewController.m
//  FoldingViewController
//
//  Created by hsusmita  on 07/05/13.
//  Copyright (c) 2013 hsusmita. All rights reserved.
//

#import "UIViewController+ContainerViewController.h"

@implementation UIViewController (ContainerViewController)

- (SideNavigationContainerViewController *)containerViewController {
    UIViewController *vc = self.parentViewController;
    while (vc) {
        if ([vc isKindOfClass:[SideNavigationContainerViewController class]]) {
            return (SideNavigationContainerViewController *)vc;
        } else if (vc.parentViewController && vc.parentViewController != vc) {
            vc = vc.parentViewController;
        } else {
            vc = nil;
        }
    }
    return nil;
}
@end
