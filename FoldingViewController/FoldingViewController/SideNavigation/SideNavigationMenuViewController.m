//
//  FoldingViewController
//
//  Created by hsusmita  on 07/05/13.
//  Copyright (c) 2013 hsusmita. All rights reserved.
//

#import "SideNavigationMenuViewController.h"
#import "SideNavigationTableViewCell.h"
#import "Configurations.h"

#define kCellHeight 71.0
#define kTableViewWidth 78.0

@interface SideNavigationMenuViewController () <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong)UITableView* tableView;
- (void)setupViews;
@end

@implementation SideNavigationMenuViewController

- (id)init {
    
    self = [super init];
    if (self) {
        // Custom initialization
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] init];
    self.view.frame = [UIScreen mainScreen].bounds;
    
    CGRect tableFrame = self.view.bounds;
    tableFrame.size.width = kTableViewWidth;
    self.tableView.frame = tableFrame;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = NO;
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViews];
    
}

#pragma mark - Private Methods
- (void) setupViews {
//    self.view.backgroundColor = [UIColor colorWithRed:42.0/255 green:42.0/255 blue:56.0/255 alpha:1.0];
    
    self.view.backgroundColor = [UIColor grayColor];
}
-(void)refreshView
{
    [self.tableView reloadData];
}

#pragma mark - Public Methods

- (void)selectCellAtIndex:(int)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath
                                animated:YES
                          scrollPosition:UITableViewScrollPositionNone];
    SEL selector = @selector(menuViewController:didSelectRowAtIndexPath:);
    if ([self.delegate respondsToSelector:selector]) {
        [self.delegate menuViewController:self didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SEL selector = @selector(menuViewController:didSelectRowAtIndexPath:);
    if ([self.delegate respondsToSelector:selector]) {
        [self.delegate menuViewController:self didSelectRowAtIndexPath:indexPath];
    }
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    return [[Configurations sharedInstance].sideNavigationConfig.sideMenuItems count];

}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SideNavigationCellIdentifier";
    SideNavigationTableViewCell *cell =
    [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [SideNavigationTableViewCell cell];
    }
//    [cell setupCell:cell AtIndexpath:indexPath];
    SideMenuItem *sideMenuItem = (SideMenuItem*)
                [[Configurations sharedInstance].sideNavigationConfig.sideMenuItems objectAtIndex:indexPath.row];
    [cell setupCellForSideMenuItem:sideMenuItem];
    return cell;
}

@end
