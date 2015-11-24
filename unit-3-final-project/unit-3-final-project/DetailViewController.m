//
//  DetailViewController.m
//  unit-3-final-project
//
//  Created by Shena Yoshida on 11/8/15.
//  Copyright © 2015 Shena Yoshida. All rights reserved.
//

#import "DetailViewController.h"
#import "DetailArtistCollectionViewCell.h"
#import "Chameleon.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *bandNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearsActiveLabel;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;

// for collection view
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *array;



@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setHidesNavigationBarHairline:YES];
    
    self.array = self.artist.echonestImages;
    [self.collectionView setPagingEnabled:YES];
    
    self.bandNameLabel.text = self.artist.artistName;
    self.cityStateLabel.text = self.artist.artistLocation;
    
    NSString *startDate = self.artist.artistYearsActiveStartDate;
    NSString *endDate = self.artist.artistYearsActiveEndDate;
    self.yearsActiveLabel.text = [NSString stringWithFormat:@"%@ - %@", startDate, endDate];
    
    

}

#pragma mark Collection View Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.array.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"Cell"; // set collection view cell identifier name
    
    DetailArtistCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    UIImageView *collectionImageView = (UIImageView *)[cell viewWithTag:100];
    collectionImageView.image = [UIImage imageNamed:[self.artist.echonestImages objectAtIndex:0]];
    
    NSString *urlString = self.array[indexPath.row];
    
    NSURL *artworkURL = [NSURL URLWithString: urlString];
    NSData *artworkData = [NSData dataWithContentsOfURL:artworkURL];
    UIImage *artworkImage = [UIImage imageWithData:artworkData];
    cell.imageView.image = artworkImage;

    return cell;
}



@end
