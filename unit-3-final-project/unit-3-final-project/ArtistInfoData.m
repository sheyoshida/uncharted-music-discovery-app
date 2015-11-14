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
        self.artistImageURL = [[artistImages objectAtIndex:0] objectForKey:@"url"]; // many of the returned urls don't work :(
    
        self.artistName = json[@"name"];
        self.artistYearsActive = json[@"years_active"];
        self.artistHometown = json[@"artist_location"][@"city"];
        
        if ([[json objectForKey:@"biographies"]firstObject])
        {
            self.artistBio = [[[json objectForKey:@"biographies"]firstObject] objectForKey:@"text"];
        } else {
            self.artistBio = [NSString stringWithFormat:@"n/a"];
        }
        
        if ([[json objectForKey:@"genres"]firstObject])
        {
            self.artistGenre = [[[json objectForKey:@"genres"]firstObject] objectForKey:@"name"];
        } else {
            self.artistGenre = [NSString stringWithFormat:@"n/a"];
        }
        
        self.ratingDiscovery = json[@"discovery_rank"];
        self.ratingFamiliarity = json[@"familiarity_rank"];
        self.ratingHotttnesss = json[@"hotttnesss_rank"];
        
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
