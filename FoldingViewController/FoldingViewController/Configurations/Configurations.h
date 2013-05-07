//
//  Configurations.h
//  FoldingViewController
//
//  Created by devmac46  on 03/05/13.
//  Copyright (c) 2013 devmac46 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SideNavigation.h"

@interface Configurations : NSObject

+ (Configurations *)sharedInstance;

@property(nonatomic, readonly)SideNavigation *sideNavigationConfig;

@end
