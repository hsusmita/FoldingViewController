//
//  SideNavigation.h
//  FoldingViewController
//
//  Created by hsusmita  on 07/05/13.
//  Copyright (c) 2013 hsusmita. All rights reserved.

//

#import <Foundation/Foundation.h>

@interface SideNavigation : NSObject

- (id)initWithDetails:(NSDictionary *)configDetails;
@property(nonatomic, readonly)NSArray *sideMenuItems;
@end

@interface SideMenuItem : NSObject

- (id)initWithDetails:(NSDictionary *)menuDetails;

@property(nonatomic, readonly)UIImage *defaultBGImage;
@property(nonatomic, readonly)UIImage *selectedBGImage;

@end


