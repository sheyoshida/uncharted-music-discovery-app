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
    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    // Starting with the table view a bit scrolled down to hide the search bar
    [self.tableView setContentOffset:CGPointMake(0, 105)];
    
    // This blocking view is used to hide the tableview cells when they scroll too far up
    // you can comment this view to see what happens
    self.blockingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 105)];
    [self.blockingView setBackgroundColor:[UIColor blueColor]];
    self.blockingView.hidden = YES;
    [self.view addSubview:_blockingView];
    
}

#pragma mark - table view cell stuff

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 80;
}

//-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 80)];
//    [headerView setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1]];
//    
//    UIButton *shuffle = [[UIButton alloc] initWithFrame:CGRectMake(40, 0, [UIScreen mainScreen].bounds.size.width - 80, 30)];
//    [shuffle setTitle:@"Shuffle Play" forState:UIControlStateNormal];
//    [shuffle setBackgroundColor:[UIColor greenColor]];
//    [headerView addSubview:shuffle];
//    
//    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, [UIScreen mainScreen].bounds.size.width - 20, 30)];
//    [headerTitle setText:@"Section Title"];
//    [headerTitle setTextColor:[UIColor whiteColor]];
//    [headerTitle setBackgroundColor:[UIColor clearColor]];
//    [headerView addSubview:headerTitle];
//    
//    
//    return headerView;
//}
//
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"songCell"];
    
    cell.textLabel.text = @"Song Name";
    cell.detailTextLabel.text = @"Artist Name";
    
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // This weird 44 - 64 is basically to mean:
    // Past 44 pixels (assuming the tableview starts at -64, which it does because of some automatic padding related to the status and nav bar)
    if(scrollView.contentOffset.y > 88 - 64){
        // Hide the search bar, and show the blocking view so when the content goes behind the nav bar, you dont see it
        if (self.startSearchBar.alpha == 1 && self.endSearchBar.alpha == 1) {
            [UIView animateWithDuration:0.3 animations:^{
                self.startSearchBar.alpha = 0;
                self.endSearchBar.alpha = 0;
            } completion:^(BOOL finished) {
                self.blockingView.hidden = NO;
            }];
        }

        
        // we move the top view down at the same pace we scroll up, to give the effect of it being always in the same place on the screen
        self.topViewTopSpaceConstraint.constant = MAX(0, scrollView.contentOffset.y - (88 - 64));
        
    }else{
        // showing the search bar again, and hiding the no longer needed blocking view (which would block the search bar)
        if (self.startSearchBar.alpha == 0) {
            self.blockingView.hidden = YES;
            [UIView animateWithDuration:0.3 animations:^{
                self.startSearchBar.alpha = 1;
            }];
        }
        
        self.topViewTopSpaceConstraint.constant = 0;
    }
}

@end
