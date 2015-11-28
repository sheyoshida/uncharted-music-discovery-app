//
//  ScrollingRoadtripViewController.m
//  unit-3-final-project
//
//  Created by Shena Yoshida on 11/27/15.
//  Copyright © 2015 Shena Yoshida. All rights reserved.
//

#import "ScrollingRoadtripViewController.h"
#import "HomeScreenTableViewCell.h"



@interface ScrollingRoadtripViewController ()
<
UITableViewDelegate,
UITableViewDelegate
>

@property (weak, nonatomic) IBOutlet UIView *tableHeader;
@property (weak, nonatomic) IBOutlet UISearchBar *startSearchBar;
@property (weak, nonatomic) IBOutlet UISearchBar *endSearchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewTopSpaceConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic,strong) UIView *blockingView;


@end

@implementation ScrollingRoadtripViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.tableHeader.clipsToBounds = YES;
    
    [self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    
    // Starting with the table view a bit scrolled down to hide the search bar
    [self.tableView setContentOffset:CGPointMake(0, 105)];

}

#pragma mark - table view cell stuff

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 80;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 80)];
    [headerView setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1]];
    
    UIButton *playlistButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 0, [UIScreen mainScreen].bounds.size.width - 80, 30)];
    [playlistButton setTitle:@"Add To Playlist" forState:UIControlStateNormal];
    [playlistButton setBackgroundColor:[UIColor blueColor]];
    [headerView addSubview:playlistButton];
    
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, [UIScreen mainScreen].bounds.size.width - 20, 30)];
    [headerTitle setText:@"Section Title"];
    [headerTitle setTextColor:[UIColor whiteColor]];
    [headerTitle setBackgroundColor:[UIColor clearColor]];
    [headerView addSubview:headerTitle];
    
    return headerView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"songCell"];
    
    cell.textLabel.text = @"Song Name";
    cell.detailTextLabel.text = @"Artist Name";
    
    return cell;
}


@end
