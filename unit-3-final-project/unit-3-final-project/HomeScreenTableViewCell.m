//
//  HomeScreenTableViewCell.m
//  unit-3-final-project
//
//  Created by Shena Yoshida on 11/20/15.
//  Copyright © 2015 Shena Yoshida. All rights reserved.
//

#import "HomeScreenTableViewCell.h"
#import "Pop.h"

@implementation HomeScreenTableViewCell

- (void)awakeFromNib {
   
    // slightly round borders
    self.artistImageView.clipsToBounds = YES;
    self.artistImageView.layer.cornerRadius = 3.0;
    self.artistContainerView.layer.cornerRadius = 3.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
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
