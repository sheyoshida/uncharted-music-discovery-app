//
//  artistInfoData.m
//  Echonest API
//
//  Created by Zoufishan Mehdi on 11/8/15.
//  Copyright © 2015 Zoufishan Mehdi. All rights reserved.
//

#import "artistInfoData.h"
#import "AppDelegate.h"

@implementation ArtistInfoData

- (instancetype) initWithJSON:(NSDictionary *)json {
    
    if (self = [super init]) {
        
        self.echonestImages = [[NSMutableArray alloc]init];
        self.spotifyImages = [[NSMutableArray alloc]init];
        // echonest api call
        NSArray *artistImages = [json objectForKey:@"images"];
        
        if (artistImages) {
            for (int i = 0; i<artistImages.count; i++) {
                
                if ([[artistImages objectAtIndex:i] objectForKey:@"url"]) {
                    
                    NSString *urlString = [[artistImages objectAtIndex:i] objectForKey:@"url"];
                    NSURL *url = [[NSURL alloc] initWithString: urlString];
                    
                    
                    NSURLRequest *request = [NSURLRequest requestWithURL:url];
                    
                    NSURLSession *session = [NSURLSession sharedSession];
                    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                            completionHandler:
                                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                                      if (error) {
                                                          
                                                          
                                                      }
                                                      else{
                                                          [ self.echonestImages addObject:urlString];
                                                      }
                                                      
                                                  }];
                    
                    [task resume];
                    
                    
                }
                
            }
            
        }
        
        else { // this doesn't fill in the null images as expected (ie: David Coffee)
            
            NSString *artworkURL = [NSString stringWithFormat:@"http://seattletwist.com/wp-content/uploads/awesomely-cute-kitten-1500.jpg"];
            [self.echonestImages addObject:artworkURL];
        }
        
        
        self.artistName = [json objectForKey:@"name"];
        
        // years active start date
        if ([[json objectForKey:@"years_active"]firstObject]) {
            self.artistYearsActiveStartDate = [[[json objectForKey:@"years_active"]firstObject] objectForKey:@"start"];
        } else {
            self.artistYearsActiveStartDate = @"unknown";
        }
        
        // years active end date
        if ([[[json objectForKey:@"years_active"]lastObject] objectForKey:@"end"]) {
            self.artistYearsActiveEndDate = [[[json objectForKey:@"years_active"]lastObject] objectForKey:@"end"];
        } else {
            self.artistYearsActiveEndDate = [NSString stringWithFormat:@"present"];
        }
        
        self.artistLocation = [[json  objectForKey:@"artist_location"]objectForKey:@"location"];
        self.artistHometown = [[json objectForKey:@"artist_location"]objectForKey:@"city"];
        
        if ([[json objectForKey:@"biographies"]firstObject])
        {
            self.artistBio = [[[json objectForKey:@"biographies"]firstObject] objectForKey:@"text"];
        } else {
            self.artistBio = [NSString stringWithFormat:@"n/a"];
        }
        
        if ([[json objectForKey:@"genres"]firstObject])
        {
            self.artistGenre = [[[json objectForKey:@"genres"]firstObject] objectForKey:@"name"];
        }
        else {
            self.artistGenre = [NSString stringWithFormat:@"n/a"];
        }
        
        self.ratingDiscovery = [json objectForKey:@"discovery_rank"];
        self.ratingFamiliarity = [json objectForKey:@"familiarity_rank"];
        self.ratingHotttnesss = [json objectForKey:@"hotttnesss_rank"];
        
        //        // spotify api call #1
        //        self.albumTitle = [json objectForKey:@"name"];
        //        self.albumID = [json objectForKey: @"id"];
        //
        //        if ([[json objectForKey: @"images"] count]>2) {
        //            self.albumArtURL = [[[json objectForKey: @"images"]objectAtIndex:1] objectForKey:@"url"];
        //        }
        //        else{
        //            self.albumArtURL = [[[json objectForKey: @"images"]firstObject] objectForKey:@"url"];
        //        }
        //
        //       // NSLog(@"%@ song title: %@", self.artistName, self.songTitle );
        //
        //        // spotify api call #2
        //        self.songPreview = json[@"preview_url"];
        //        self.songTitle = json[@"name"];
        
        return self;
        
    }
    
    return nil;
    
}



@end
