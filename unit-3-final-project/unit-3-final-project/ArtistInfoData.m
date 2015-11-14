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
        
        // echonest api call
        NSArray *artistImages = json[@"images"];
        self.artistImageURL = [artistImages[0] objectForKey:@"url"];
    
        self.artistName = json[@"name"];
        self.artistYearsActive = json[@"years_active"];
        self.artistHometown = json[@"artist_location"][@"city"];
        self.artistBio = json[@"biographies"][0][@"text"];
        
        // self.artistGenre
        // self.ratingDiscovery
        // self.ratingFamiliarity
        // self.ratingHotttness
        
        // spotify api call #1
        
        // self.albumArtURL
        // self.albumTitle
        // self.albumID
        
        // self.songPreview
        // self.songTitle
        
        // echonest api call

        return self;
    }
    return nil;
}


@end
