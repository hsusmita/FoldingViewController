//
//  SideNavigationContainerViewController.m
//  FoldingViewController
//
//  Created by hsusmita  on 07/05/13.
//  Copyright (c) 2013 hsusmita. All rights reserved.
//

#import "SideNavigationContainerViewController.h"
#import "SideNavigationMenuViewController.h"
#import "ShowViewController.h"
#import "UIView+Folding.h"

NSString *const kContainerControllerWillShowMenu =
@"kContainerControllerWillShowMenu";
NSString *const kContainerControllerDidShowMenu =
@"kContainerControllerDidShowMenu";
NSString *const kContainerControllerWillHideMenu =
@"kContainerControllerWillHideMenu";
NSString *const kContainerControllerDidHideMenu =
@"kContainerControllerDidHideMenu";

typedef void (^animationCompletionBlock)();

@interface SideNavigationContainerViewController ()
{
    BOOL menuViewVisible;

}

@property(nonatomic, strong)UIView *menuContainerView;
@property(nonatomic, strong)UIView *showContainerView;
@property(nonatomic, strong)ShowViewController *showViewController;
@property(nonatomic, strong)SideNavigationMenuViewController *menuViewController;

- (void)initialSetup;
- (void)displayViewController:(UIViewController *)viewController;
@end

@implementation SideNavigationContainerViewController

@synthesize displayingControllers = _displayingControllers;
@synthesize selectedViewController = _selectedViewController;
@synthesize selectedIndex = _selectedIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initialSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialSetup];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];    
    // Do any additional setup after loading the view.
    
    self.showContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
    
    CGRect menuFrame =  CGRectMake(0, 0, 100, self.view.bounds.size.height-20);
    self.menuContainerView = [[UIView alloc] initWithFrame:menuFrame];
    
    [self.view addSubview:self.menuContainerView];
    [self.view addSubview:self.showContainerView];
    
    [self.showViewController willMoveToParentViewController:self];
    [self.menuViewController willMoveToParentViewController:self];
    
    [self.menuContainerView addSubview:self.menuViewController.view];
    [self.showContainerView addSubview:self.showViewController.view];
    
    [self.showViewController didMoveToParentViewController:self];
    [self.menuViewController didMoveToParentViewController:self];
}
- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --
#pragma mark Private Methods
- (void)initialSetup {
    _selectedIndex = -1;
    menuViewVisible = NO;
    _showViewController = [[ShowViewController alloc] init];
    _menuViewController = [[SideNavigationMenuViewController alloc] init];
    _menuViewController.delegate = self;
    
    [self addChildViewController:_showViewController];
    [self addChildViewController:_menuViewController];
    
}

- (void)displayViewController:(UIViewController *)viewController {
    
    [self.showViewController addChildViewController:viewController];
    [viewController willMoveToParentViewController:self.showViewController];
    [self.showViewController addViewController:viewController];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kContainerControllerWillHideMenu
     object:self];
    [self.showContainerView unfoldView:self.menuContainerView
                                withNumberOfFolds:1
                                      forDuration:1
                                    withDirection:FoldingDirectionFromLeft
                                       completion:^(BOOL finished){
                                           menuViewVisible = NO;
                                           [viewController didMoveToParentViewController:self.showViewController];
                                           [[NSNotificationCenter defaultCenter]
                                            postNotificationName:kContainerControllerDidHideMenu
                                            object:self];
                                       }];
    
}
-(void)refreshSideTableView
{
    [self.menuViewController refreshView];
}

#pragma mark --
#pragma mark Changing Views

- (void)hideMenuAnimated:(BOOL)animated {
    CGFloat animationDuration = 0.0;
    if (animated) {
        animationDuration = 0.5;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kContainerControllerWillHideMenu
     object:self];
    
   [self.showContainerView foldView:self.menuContainerView withNumberOfFolds:1
                         forDuration:1
                       withDirection:FoldingDirectionFromLeft
                          completion:^(BOOL finished){
                              menuViewVisible = NO;
                              [[NSNotificationCenter defaultCenter]
                               postNotificationName:kContainerControllerDidHideMenu
                               object:self];

     }];
}
- (void)showMenuAnimated:(BOOL)animated {
    CGFloat animationDuration = 0.0;
    if (animated) {
        animationDuration = 0.5;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kContainerControllerWillShowMenu
     object:self];
     [self.showContainerView unfoldView:self.menuContainerView
                                withNumberOfFolds:1
                                      forDuration:1
                                    withDirection:FoldingDirectionFromLeft
                                       completion:^(BOOL finished){
                                           menuViewVisible = YES;
                                           [[NSNotificationCenter defaultCenter]
                                            postNotificationName:kContainerControllerDidShowMenu
                                            object:self];
                                       }];

}

- (void)toggleMenuViewVisibilityAnimated:(BOOL)animated {
    if (menuViewVisible) {
        [self hideMenuAnimated:animated];
    }
    else {
        [self showMenuAnimated:animated];
    }
}


#pragma mark - Accesors
- (BOOL)menuVisible {
    return menuViewVisible;
}

- (void)setSelectedIndex:(int)selectedIndex {
    BOOL isIndexValid =
    (selectedIndex >= 0) && (selectedIndex < [self.displayingControllers count]);
    NSAssert(isIndexValid, @"Index out of bounds");
    if (_selectedIndex != selectedIndex) {
        [self.selectedViewController removeFromParentViewController];
        [self.selectedViewController.view removeFromSuperview];
        _selectedIndex = selectedIndex;
        UIViewController *vc =
        [self.displayingControllers objectAtIndex:selectedIndex];
        _selectedViewController = vc;
        [self displayViewController:vc];
        
        [self.menuViewController selectCellAtIndex:selectedIndex];
    }
    else {
        [self displayViewController:self.selectedViewController];
    }
}

- (int)selectedIndex {
    return _selectedIndex;
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController {
    NSInteger index =
    [self.displayingControllers indexOfObject:selectedViewController];
    NSAssert(index != NSNotFound, @"Couldnot find View controller");
    
    if (_selectedViewController != selectedViewController) {
        [self.selectedViewController removeFromParentViewController];
        [self.selectedViewController.view removeFromSuperview];
        _selectedIndex = index;
        _selectedViewController = selectedViewController;
        [self displayViewController:self.selectedViewController];
        
        [self.menuViewController selectCellAtIndex:index];
    }
    else {
        [self displayViewController:self.selectedViewController];
    }
    
}

- (UIViewController *)selectedViewController {
    return _selectedViewController;
}

#pragma mark - MenuViewControllerDelegate
- (void)menuViewController:(SideNavigationContainerViewController *)menuViewController
   didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isIndexValid =
    (indexPath.row >= 0) && (indexPath.row < [self.displayingControllers count]);
    NSAssert(isIndexValid, @"Index out of bounds");
    self.selectedIndex = indexPath.row;
}
/*
 Method dealing with notification 
 when new conversation is created
 */

-(void)showConversation
{
    [self setSelectedIndex:0];
}

@end
