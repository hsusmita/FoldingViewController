//
//  SideNavigationMenuViewController.h
//  FoldingViewController
//
//  Created by hsusmita  on 07/05/13.
//  Copyright (c) 2013 hsusmita. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SideNavigationMenuViewControllerDelegate;

@interface SideNavigationMenuViewController :UIViewController
@property(nonatomic, weak)id<SideNavigationMenuViewControllerDelegate> delegate;

-(void)selectCellAtIndex:(int)index;
-(void)refreshView;
@end

@protocol SideNavigationMenuViewControllerDelegate <NSObject>
@required
- (void)menuViewController:(SideNavigationMenuViewController *)menuViewController
   didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end