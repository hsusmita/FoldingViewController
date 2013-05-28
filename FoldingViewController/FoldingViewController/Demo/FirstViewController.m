//
//  FirstViewController.m
//  FoldingViewController
//
//  Created by hsusmita  on 07/05/13.
//  Copyright (c) 2013 hsusmita. All rights reserved.
//

#import "FirstViewController.h"
#import "UIViewController+ContainerViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface FirstViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic,strong) UIView *left;
@property (nonatomic,strong) UIView *right;

- (IBAction)buttonTapped:(id)sender;

@end

@implementation FirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (IBAction)buttonTapped:(id)sender {
    [self.containerViewController toggleMenuViewVisibilityAnimated:YES];
}

@end
