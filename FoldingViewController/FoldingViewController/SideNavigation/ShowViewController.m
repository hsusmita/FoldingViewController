//
//  ShowViewController.m
//  FoldingViewController
//
//  Created by hsusmita  on 07/05/13.
//  Copyright (c) 2013 hsusmita. All rights reserved.
//

#import "ShowViewController.h"
#import "UIViewController+ContainerViewController.h"

@interface ShowViewController ()

@property(nonatomic, strong)UIView *invisibleView;
@property(nonatomic, strong)UIImageView * shadowImageView;
@end

@implementation ShowViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] init];
    [self.view setAutoresizesSubviews:YES];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.frame = [[UIScreen mainScreen] applicationFrame];
    CGRect rect = self.view.frame;
    rect.origin.y = 0;
    self.view.frame = rect;
    UIImage *shadowImage = [[UIImage imageNamed:@"Sidebar-Shadow"]
                                       resizableImageWithCapInsets:UIEdgeInsetsMake(10,0,10,0)];
    
    self.shadowImageView = [[UIImageView alloc]initWithFrame:CGRectMake(-10,0,16, self.view.bounds.size.height)];
    [self.shadowImageView setImage:shadowImage];
    [self.view addSubview:self.shadowImageView];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Public methods
- (void)addViewController:(UIViewController *)viewController {
    CGRect rect = viewController.view.frame;
    rect.origin.y = 0;
    rect.size.height = self.view.frame.size.height;
    viewController.view.frame = rect;
    [self.view addSubview:viewController.view];
    
    [self.view bringSubviewToFront:self.invisibleView];
}

@end
