//
//  artistInfoData.m
//  Echonest API
//
//  Created by Zoufishan Mehdi on 11/8/15.
//  Copyright © 2015 Zoufishan Mehdi. All rights reserved.
//

#import "artistInfoData.h"

@implementation artistInfoData

- (instancetype) initWithJSON:(NSDictionary *)json {
    
    if (self = [super init]) {
        
        NSArray *images = json[@"images"];
        self.imageURL = [images[0] objectForKey:@"url"];
        
        self.artist = json[@"name"];
        self.yearsActive = json[@"years_active"];
        self.hometown = json[@"artist_location"][@"city"];
        self.bio = json[@"biographies"][0][@"text"];
       
        return self;
    }
    return nil;
}


@end
