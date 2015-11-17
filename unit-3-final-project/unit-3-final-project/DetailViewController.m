//
//  DetailViewController.m
//  unit-3-final-project
//
//  Created by Shena Yoshida on 11/8/15.
//  Copyright © 2015 Shena Yoshida. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITableViewCell *tableCell;
@property (weak, nonatomic) IBOutlet UILabel *bandNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearsActiveLabel;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (strong, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bandNameLabel.text = self.artist.artistName;
    
    self.cityStateLabel.text = self.artist.artistLocation;
    
    NSString *startDate = self.artist.artistYearsActiveStartDate;
    NSString *endDate = self.artist.artistYearsActiveEndDate;
    self.yearsActiveLabel.text = [NSString stringWithFormat:@"%@ - %@", startDate, endDate];
    
    self.bioLabel.text = self.artist.artistBio;
    
    NSURL *artworkURL = [NSURL URLWithString:self.artist.artistImageURL];
    NSData *artworkData = [NSData dataWithContentsOfURL:artworkURL];
    UIImage *artworkImage = [UIImage imageWithData:artworkData];
    self.imageView.image = artworkImage;
    
    UISwipeGestureRecognizer * swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight:)];
    swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swiperight];
}



-(void)swiperight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    
    [self.navigationController popToRootViewControllerAnimated:YES];

}

@end
