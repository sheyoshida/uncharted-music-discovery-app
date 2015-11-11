//
//  ViewController.m
//  city array
//
//  Created by Shena Yoshida on 11/10/15.
//  Copyright © 2015 Shena Yoshida. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic) NSMutableArray *cities;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    NSArray *cities = [[NSArray alloc]initWithObjects: @"New York", @"Brooklyn", @"Queens", @"Huntington", @"Long Island", @"Bay Shore", @"Manhattan", @"Flushing", @"Bushwick", @"Bay Ridge", @"Park Slope", @"Jamaica", @"Soho", @"Harlem", @"Hoboken", @"Ozone Park", @"Holbrook", @"Fort Greene", nil];
//
    
    NSMutableArray *cities = [[NSMutableArray alloc] init];
    [cities addObject:@"New York"];
    [cities addObject:@"Brooklyn"];
    [cities addObject:@"Queens"];
    [cities addObject:@"Holbrook"];
    [cities addObject:@"Fort Greene"];
    [cities addObject:@"Ozone Park"];
    [cities addObject:@"Holbrook"];
    [cities addObject:@"Hoboken"];
    [cities addObject:@"Harlem"];
    [cities addObject:@"Flushing"];

  
    NSLog(@"cities: %@", cities);
    
    


}



@end
