//
//  SideNavigation.m
//  FoldingViewController
//
//  Created by hsusmita  on 07/05/13.
//  Copyright (c) 2013 hsusmita. All rights reserved.
/
//

#import "SideNavigation.h"
                                                       
#define kSideMenuItemsKey  @"menu-items-array"

@implementation SideNavigation

- (id)init {
    return [self initWithDetails:nil];
}

- (id)initWithDetails:(NSDictionary *)configDetails {
    if (self = [super init]) {
        
        NSArray *sideMenuItems = [configDetails objectForKey:kSideMenuItemsKey];
        NSMutableArray *allSideMenuItems = [NSMutableArray array];
        for (NSDictionary *itemInfo in sideMenuItems) {
            SideMenuItem *item = [[SideMenuItem alloc] initWithDetails:itemInfo];
            [allSideMenuItems addObject:item];
        }
       _sideMenuItems = [NSArray arrayWithArray:allSideMenuItems];
    }
    return self;
}

@end

#define kDefaultBGImageKey    @"item-bg"
#define kSelectedBGImageKey   @"item-selected-bg"

@implementation SideMenuItem

- (id)init {
    return [self initWithDetails:nil];
}

- (id)initWithDetails:(NSDictionary *)menuDetails {
    if (self = [super init]) {
                _defaultBGImage =
        [UIImage imageNamed:[menuDetails objectForKey:kDefaultBGImageKey]];
        
        _selectedBGImage =
        [UIImage imageNamed:[menuDetails objectForKey:kSelectedBGImageKey]];
        }

    return self;
}

@end
