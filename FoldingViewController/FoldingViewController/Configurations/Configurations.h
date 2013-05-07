//
//  Configurations.h
//  FoldingViewController
//
//  Created by hsusmita  on 07/05/13.
//  Copyright (c) 2013 hsusmita. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SideNavigation.h"

@interface Configurations : NSObject

+ (Configurations *)sharedInstance;

@property(nonatomic, readonly)SideNavigation *sideNavigationConfig;

@end
