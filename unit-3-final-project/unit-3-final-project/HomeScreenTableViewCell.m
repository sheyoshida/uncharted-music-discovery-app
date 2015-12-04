//
//  HomeScreenTableViewCell.m
//  unit-3-final-project
//
//  Created by Shena Yoshida on 11/20/15.
//  Copyright © 2015 Shena Yoshida. All rights reserved.
//


#import "HomeScreenTableViewCell.h"
#import "Pop.h"
#import "Chameleon.h"
#import "User.h"
#import "SpotifyPlaylistManager.h"

@implementation HomeScreenTableViewCell

- (void)awakeFromNib {
   
    // slightly round borders
    self.artistImageView.clipsToBounds = YES;
    self.artistImageView.layer.cornerRadius = 5.0;
    self.artistContainerView.layer.cornerRadius = 5.0;
    DGActivityIndicatorView * activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeLineScalePulseOutRapid tintColor:[UIColor colorWithRed:0.0f/255.0f green:153.0f/255.0f blue:204.0f/255.0f alpha:1.0f] size:40.0f];
    activityIndicatorView.frame = CGRectMake(300.0f, 19.0f, 50.0f, 50.0f);
    [activityIndicatorView startAnimating];
    [self.activityIndicatorView addSubview: activityIndicatorView];
    
    
    // button!
    [self.buttonFavorite setImage:[UIImage imageNamed:@"heart-button.png"] forState:UIControlStateNormal];
}
    


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (IBAction)heartButtonTapped:(id)sender {

    UIButton *btn = (UIButton *)sender;
    
    if( [[btn imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"heart-button.png"]]) {
        [btn setImage:[UIImage imageNamed:@"heart-selected.png"] forState:UIControlStateNormal];
        
        __block NSString *uri = self.songURI;
        void (^addTrack)() = ^void() {
            [SpotifyPlaylistManager addTrackToPlaylist:uri completion:^(BOOL success) {
                if (success) {
                    NSLog(@"WE DID IT!!!!!");
                } else {
                    NSLog(@"womp womp");
                }
            }];
        };
        
        if (![[User currentUser] isLoggedInToSpotify]) {
            [User currentUser].onLoginCallback = ^{
                addTrack();
            };
            [[User currentUser] loginToSpotify];
        } else {
            addTrack();
        }
        
        
    } else {
        [btn setImage:[UIImage imageNamed:@"heart-button.png"] forState:UIControlStateNormal];
        // other statements
    }
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
   
    [super setHighlighted:highlighted animated:animated];
    
//    // animate cells when tapped
//    if (self.highlighted) {
//        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
//        scaleAnimation.duration = 0.1;
//        scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
//        [self.artistContainerView pop_addAnimation:scaleAnimation forKey:nil];
//        [self.artistImageView pop_addAnimation:scaleAnimation forKey:nil];
//        [self.artistNameLabel pop_addAnimation:scaleAnimation forKey:nil];
//        [self.artistDetailLabel pop_addAnimation:scaleAnimation forKey:nil];
//        [self.buttonFavorite pop_addAnimation:scaleAnimation forKey:nil];
//        
//    } else {
//        POPSpringAnimation *sprintAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
//        sprintAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(0.9, 0.9)];
//        sprintAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
//        sprintAnimation.springBounciness = 20.f;
//        [self.artistContainerView pop_addAnimation:sprintAnimation forKey:nil];
//        [self.artistImageView pop_addAnimation:sprintAnimation forKey:nil];
//        [self.artistNameLabel pop_addAnimation:sprintAnimation forKey:nil];
//        [self.artistDetailLabel pop_addAnimation:sprintAnimation forKey:nil];
//        [self.buttonFavorite pop_addAnimation:sprintAnimation forKey:nil];
//    }
}

@end
