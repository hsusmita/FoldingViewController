//
//  SideNavigationCell.m
//  FoldingViewController
//
//  Created by hsusmita  on 07/05/13.
//  Copyright (c) 2013 hsusmita. All rights reserved.
//

#import "SideNavigationTableViewCell.h"

@interface SideNavigationTableViewCell  ()

@property (weak, nonatomic) IBOutlet UIImageView *BgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@end

@implementation SideNavigationTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    // Configure the view for the selected state
    [super setSelected:selected animated:animated];
    _BgImageView.highlighted = selected;
    _iconImageView.highlighted = selected;
    
}
+ (SideNavigationTableViewCell *)cell
{
    SideNavigationTableViewCell *cell = nil;
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SideNavigationTableViewCell"
                                                     owner:nil
                                                   options:nil];
    if ([objects count] > 0)
    {
        if ([[objects objectAtIndex:0] class] == NSClassFromString(@"SideNavigationTableViewCell"))
        {
            cell = (SideNavigationTableViewCell *)[objects objectAtIndex:0];
            
        }
    }
    
    return cell;
}
- (void)setupCell:(UITableViewCell *)cell AtIndexpath:(NSIndexPath *)indexPath {
    [cell.textLabel setText:@"hello"];
 }
- (void)setupCellForSideMenuItem:(SideMenuItem*)sideMenuItem
{
    [self.iconImageView setImage:sideMenuItem.defaultBGImage];
    [self.iconImageView setHighlightedImage:sideMenuItem.selectedBGImage];
}
@end
