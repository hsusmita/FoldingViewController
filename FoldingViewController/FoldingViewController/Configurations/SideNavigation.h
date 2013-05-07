//
//  SideNavigation.h
//  FoldingViewController
//
//  Created by devmac46  on 03/05/13.
//  Copyright (c) 2013 devmac46 . All rights reserved.
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


