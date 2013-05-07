//
//  Configurations.m
//  FoldingViewController
//
//  Created by hsusmita  on 07/05/13.
//  Copyright (c) 2013 hsusmita. All rights reserved.
//

#import "Configurations.h"
#define kSideNavigationKey  @"SideNavigation"

@implementation Configurations

static Configurations * _sharedInstance = nil;

#pragma mark Lifecycle
- (id)init {
    self = [super init];
    if (self) {
        [self loadInfo];
    }
    return self;
}

#pragma mark Class Methods
+ (Configurations *)sharedInstance {
    if (!_sharedInstance) {
        _sharedInstance = [[Configurations alloc] init];
    }
    return _sharedInstance;
}

#pragma mark Private Methods
- (void)loadInfo {
    NSString *pathString =
    [[NSBundle mainBundle] pathForResource:@"Configurations" ofType:@"plist"];
    NSDictionary *configurations =
    [[NSDictionary alloc] initWithContentsOfFile:pathString];
    
    _sideNavigationConfig =
    [[SideNavigation alloc] initWithDetails:[configurations objectForKey:
                                           kSideNavigationKey]];
    
}


@end
