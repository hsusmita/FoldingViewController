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
#import "UIView+Sliding.h"
#import "Configurations.h"

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

@property (nonatomic, strong) UIView *menuContainerView;
@property (nonatomic, strong) UIView *showContainerView;
@property (nonatomic, strong) ShowViewController *showViewController;
@property (nonatomic, strong) SideNavigationMenuViewController *menuViewController;

@property (nonatomic, assign) TransitionAnimationStyle transitionStyle;
@property (nonatomic, assign) TransitionDirection transitionDirection;
@property (nonatomic, assign) float animationDuration;

- (void)initialSetup;
- (void)displayViewController:(UIViewController *)viewController;

-(void)showAnimationForDuration:(float)animationDuration
            withTransitionStyle:(TransitionAnimationStyle)style
                     completion:(animationCompletionBlock) block;
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
   
    self.transitionStyle = [Configurations sharedInstance].animationConfig.animationStyle;
    self.transitionDirection = [Configurations sharedInstance].animationConfig.animationDirection;
    self.animationDuration = [Configurations sharedInstance].animationConfig.animationDuration;

    self.showContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
    float menuOffset = [Configurations sharedInstance].sideNavigationConfig.sideMenuOffset;
    
    CGRect menuFrame = (self.transitionDirection >1)?
    CGRectMake(0, 0, self.view.bounds.size.width, menuOffset):CGRectMake(0, 0, menuOffset, self.view.bounds.size.height-20);
    
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
    [self showAnimationForDuration:1
               withTransitionStyle:self.transitionStyle
                        completion:^{
                            menuViewVisible = NO;
                            [viewController didMoveToParentViewController:self.showViewController];
                            [[NSNotificationCenter defaultCenter]
                             postNotificationName:kContainerControllerDidHideMenu
                             object:self];
                        }];
    /*[self.showContainerView unfoldView:self.menuContainerView
                                withNumberOfFolds:1
                                      forDuration:1
                                    withDirection:FoldingDirectionFromLeft
                                       completion:^(BOOL finished){
                                           menuViewVisible = NO;
                                           [viewController didMoveToParentViewController:self.showViewController];
                                           [[NSNotificationCenter defaultCenter]
                                            postNotificationName:kContainerControllerDidHideMenu
                                            object:self];
                                       }];*/
    
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
    
    [self hideAnimationForDuration:1
               withTransitionStyle:self.transitionStyle
                        completion:^{
                            menuViewVisible = NO;
                            [[NSNotificationCenter defaultCenter]
                             postNotificationName:kContainerControllerDidHideMenu
                             object:self];
                        }];

    
    
   /*[self.showContainerView foldView:self.menuContainerView withNumberOfFolds:1
                         forDuration:1
                       withDirection:FoldingDirectionFromLeft
                          completion:^(BOOL finished){
                              menuViewVisible = NO;
                              [[NSNotificationCenter defaultCenter]
                               postNotificationName:kContainerControllerDidHideMenu
                               object:self];

     }];*/
}
- (void)showMenuAnimated:(BOOL)animated {
    CGFloat animationDuration = 0.0;
    if (animated) {
        animationDuration = 0.5;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kContainerControllerWillShowMenu
     object:self];
    [self showAnimationForDuration:1
               withTransitionStyle:self.transitionStyle
                        completion:^{
                            menuViewVisible = YES;
                            [[NSNotificationCenter defaultCenter]
                             postNotificationName:kContainerControllerDidShowMenu
                             object:self];
                        }];

     /*[self.showContainerView unfoldView:self.menuContainerView
                                withNumberOfFolds:1
                                      forDuration:1
                                    withDirection:FoldingDirectionFromLeft
                                       completion:^(BOOL finished){
                                           menuViewVisible = YES;
                                           [[NSNotificationCenter defaultCenter]
                                            postNotificationName:kContainerControllerDidShowMenu
                                            object:self];
                                       }];*/

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

-(void)setFrameOfSideMenu
{
    CGRect menuFrame;
    float menuOffset = [Configurations sharedInstance].sideNavigationConfig.sideMenuOffset;
    switch (self.transitionDirection) {
        case TransitionDirectionFromRight:
            menuFrame = CGRectMake(0, self.view.bounds.size.width-menuOffset, menuOffset, self.view.bounds.size.height);
            break;
        case TransitionDirectionFromLeft:
            menuFrame = CGRectMake(0, 0, menuOffset, self.view.bounds.size.height);
            break;
        case TransitionDirectionFromTop:
             menuFrame = CGRectMake(0, 0, self.view.bounds.size.width, menuOffset);
            break;
        case TransitionDirectionFromBottom:
             menuFrame = CGRectMake(0, self.view.bounds.size.height-menuOffset, self.view.bounds.size.width, menuOffset);
            break;
        default:
            break;
    }
    [self.menuContainerView setFrame:menuFrame];
}
-(void)showAnimationForDuration:(float)animationDuration
            withTransitionStyle:(TransitionAnimationStyle)style
                     completion:(animationCompletionBlock)block
{
    switch(style)
    {
            
        case TransitionAnimationStyleSliding:
        {
//            [self setFrameOfSideMenu];
//            [UIView animateWithDuration:animationDuration
//                             animations:^{
//                                 CGRect rect = self.showContainerView.frame;
//                                 switch (self.transitionDirection) {
//                                     case TransitionDirectionFromRight:
//                                         rect.origin.x = -self.menuContainerView.frame.size.width;
//                                         break;
//                                     case TransitionDirectionFromLeft:
//                                          rect.origin.x = self.menuContainerView.frame.size.width;
//                                         break;
//                                     case TransitionDirectionFromTop:
//                                         rect.origin.y = self.menuContainerView.frame.size.height;
//                                         break;
//                                     case TransitionDirectionFromBottom:
//                                         rect.origin.y = -self.menuContainerView.frame.size.height;
//                                         break;
//                                     default:
//                                         break;
//                                 }
//                                 rect.origin.x = self.menuContainerView.frame.size.width;
//                                 [self.showContainerView setFrame:rect];
//                                }
//
//                             completion:^(BOOL finished) {
//                                 if(block)block();
//            }];

            [self.showContainerView slideInView:self.menuContainerView
                                    forDuration:self.animationDuration
                                  withDirection:self.transitionDirection
                                     completion:^(BOOL finished){
                                         if(block) block();
                                     }];
            break;
        }
        case TransitionAnimationStyleFolding:
        {
            [self.showContainerView unfoldView:self.menuContainerView
                             withNumberOfFolds:1
                                   forDuration:self.animationDuration
                                 withDirection:self.transitionDirection
                                    completion:^(BOOL finished){
                                        if(block) block();
                                    }];
            break;
        }
        default:
            break;
    }
}

-(void)hideAnimationForDuration:(float)animationDuration
            withTransitionStyle:(TransitionAnimationStyle)style
                     completion:(animationCompletionBlock)block
{
    switch (style) {
        case TransitionAnimationStyleSliding:
        {
            [self.showContainerView slideBackView:self.menuContainerView
                                    forDuration:self.animationDuration
                                  withDirection:self.transitionDirection
                                     completion:^(BOOL finished)
                                    {
                                        if(block)block();
                                    }];
//            [UIView animateWithDuration:animationDuration
//                             animations:^{
//                                 CGRect rect = self.showContainerView.frame;
//                                 
//                                 if(self.transitionDirection >1)
//                                     rect.origin.y = 0;
//                                 else
//                                     rect.origin.x = 0;
//                                 self.showContainerView.frame = rect;
//                            }
//                             completion:^(BOOL finished) {
//                                 if(block)block();
//            }];
//            
            break;
        }
        case TransitionAnimationStyleFolding:
        {
            [self.showContainerView foldView:self.menuContainerView
                           withNumberOfFolds:1
                                 forDuration:self.animationDuration
                               withDirection:self.transitionDirection
                                  completion:^(BOOL finished){
                                      if(block) block();
                                  }];
            break;
        }
        default:
            break;
    }
}

@end
