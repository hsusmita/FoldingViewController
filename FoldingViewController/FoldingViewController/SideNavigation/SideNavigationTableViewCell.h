//
//  SideNavigationCell.h
//  FoldingViewController
//
//  Created by hsusmita  on 07/05/13.
//  Copyright (c) 2013 hsusmita. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideNavigationTableViewCell : UITableViewCell
+ (SideNavigationTableViewCell *)cell ;
- (void)setupCell:(UITableViewCell *)cell AtIndexpath:(NSIndexPath *)indexPath;
@end
