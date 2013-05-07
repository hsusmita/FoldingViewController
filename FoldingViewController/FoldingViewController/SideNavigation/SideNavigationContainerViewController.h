//
//  SideNavigationContainerViewController.h
//  FoldingViewController
//
//  Created by hsusmita  on 07/05/13.
//  Copyright (c) 2013 hsusmita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideNavigationMenuViewController.h"

extern NSString *const kContainerControllerWillShowMenu;
extern NSString *const kContainerControllerDidShowMenu;
extern NSString *const kContainerControllerWillHideMenu;
extern NSString *const kContainerControllerDidHideMenu;

@interface SideNavigationContainerViewController :UIViewController
<SideNavigationMenuViewControllerDelegate>

@property(nonatomic, strong)NSArray *displayingControllers;
@property(nonatomic, strong)UIViewController *selectedViewController;
@property(nonatomic, assign)int selectedIndex;
@property(nonatomic, readonly)BOOL menuVisible;

- (void)hideMenuAnimated:(BOOL)animated;
- (void)showMenuAnimated:(BOOL)animated;
- (void)toggleMenuViewVisibilityAnimated:(BOOL)animated;

@end
