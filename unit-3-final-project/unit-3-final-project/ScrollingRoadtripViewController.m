//
//  ScrollingRoadtripViewController.m
//  unit-3-final-project
//
//  Created by Shena Yoshida on 11/27/15.
//  Copyright © 2015 Shena Yoshida. All rights reserved.
//

#import "ScrollingRoadtripViewController.h"
#import <MapKit/MapKit.h>
#import "HomeScreenTableViewCell.h"



@interface ScrollingRoadtripViewController ()
<
MKMapViewDelegate,
UITableViewDelegate,
UITableViewDelegate
>

@property (weak, nonatomic) IBOutlet UIView *tableHeader;
@property (strong, nonatomic) IBOutlet UISearchBar *startSearchBar;
@property (strong, nonatomic) IBOutlet UISearchBar *endSearchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewTopSpaceConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet MKMapView *roadTripMapView;


@property(nonatomic,strong) UIView *blockingView;


@end

@implementation ScrollingRoadtripViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.tableHeader.clipsToBounds = YES;
    
    // Starting with the table view a bit scrolled down to hide the search bar
    [self.tableView setContentOffset:CGPointMake(0, 105)];
    
    // serach bars
    self.startSearchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.endSearchBar.searchBarStyle = UISearchBarStyleMinimal;
    for(UIView *subView in self.startSearchBar.subviews) {
        if ([subView isKindOfClass:[UITextField class]]) {
            UITextField *searchField = (UITextField *)subView;
            searchField.font = [UIFont fontWithName:@"Varela Round" size:16];
        }
    }
    for(UIView *subView in self.endSearchBar.subviews) {
        if ([subView isKindOfClass:[UITextField class]]) {
            UITextField *searchField = (UITextField *)subView;
            searchField.font = [UIFont fontWithName:@"Varela Round" size:16];
        }
    }
    
    // add nav bar button
    UIBarButtonItem *routeButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Route"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(routeButtonTapped)];
    self.navigationItem.rightBarButtonItem = routeButton;
    
    

}

- (void)routeButtonTapped {
    NSLog(@"route button tapped!!");
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
