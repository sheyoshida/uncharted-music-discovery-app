//
//  HomeScreenTableViewCell.h
//  unit-3-final-project
//
//  Created by Shena Yoshida on 11/20/15.
//  Copyright © 2015 Shena Yoshida. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGActivityIndicatorView.h"

@interface HomeScreenTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *artistContainerView;
@property (strong, nonatomic) IBOutlet UIImageView *artistImageView;
@property (strong, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *buttonFavorite;
@property (weak, nonatomic) IBOutlet UILabel *SongNameLabel;
@property (weak, nonatomic) IBOutlet DGActivityIndicatorView *activityIndicatorView;
@property (nonatomic) DGActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) NSString *songURI;


@end
