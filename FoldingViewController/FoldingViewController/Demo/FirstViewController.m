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
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onContentViewPanned:)];
	panGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:panGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonTapped:(id)sender {
    [self.containerViewController toggleMenuViewVisibilityAnimated:YES];
    
//    self.left = [[UIView alloc]initWithFrame:CGRectMake(0,0,60,self.view.bounds.size.height)];
//    self.right = [[UIView alloc]initWithFrame:CGRectMake(60,0,60,self.view.bounds.size.height)];
//    [self.left setBackgroundColor:[UIColor whiteColor]];
//    [self.right setBackgroundColor:[UIColor greenColor]];
//    [self.view addSubview:self.left];
//    [self.view addSubview:self.right];
}

//- (void)onContentViewPanned:(UIPanGestureRecognizer*)gesture
//{
//    // cancel gesture if another animation has not finished yet
//    
//    BOOL isVoiceOverRunning = UIAccessibilityIsVoiceOverRunning();
//    
//    if ([gesture state]==UIGestureRecognizerStateBegan)
//    {
//        
//		CGPoint velocity = [gesture velocityInView:self.view];
//        if ( abs(velocity.x) > abs(velocity.y))
//        {
//            NSLog(@"velocity x = %f",velocity.x);
//            if(velocity.x<0)
//            {
//                
//                CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
//                animation.fromValue = [NSNumber numberWithFloat:0.0f];
//                animation.toValue = [NSNumber numberWithFloat: 2*M_PI];
//                animation.duration = 0.5f;             // this might be too fast
//                animation.repeatCount = 1;     // HUGE_VALF is defined in math.h so import it
//                [self.left.layer setAnchorPoint:CGPointMake(1, 0.5)];
//                animation.fillMode = kCAFillModeForwards;
//                animation.removedOnCompletion = NO;
//                [self.left.layer addAnimation:animation forKey:@"rotation"];
//            }
//        }
//    }
//}

@end
