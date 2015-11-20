//
//  FirstSpotifyApiManager.m
//  unit-3-final-project
//
//  Created by Henna Ahmed on 11/15/15.
//  Copyright © 2015 Shena Yoshida. All rights reserved.
//

#import "SpotifyApiManager.h"
#import "LocationInfoObject.h"
#import "ArtistInfoData.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>

@implementation SpotifyApiManager



+ (void)getAlbumInfoForCities:(NSArray *)cities completion:(void (^)())completion {
    __block int recievedCities = 0;
    
    for (LocationInfoObject* city in cities) {

        [self getAlbumInfoForCity:city completion:^{
            recievedCities++;

            if (recievedCities == cities.count) {
                completion();
            }
        }];
        
        
    }
    
}


+ (void)getAlbumInfoForCity:(LocationInfoObject*)city completion:(void(^)())completion {
    __block int receivedArtists = 0;
    
    if (city.artists.count == 0) {
        completion();
    }
    
    else{
        for (ArtistInfoData* artist in city.artists) {
            
            [self passArtistNameToSpotifyWithArtistObject:artist completion:^{
                
                receivedArtists++;
                
                if (receivedArtists == city.artists.count) {
                    completion();
                }
            }];
        }
    }
}

+ (void)passArtistNameToSpotifyWithArtistObject:(ArtistInfoData*)artistObject completion:(void(^)())completion {
    // goal: pass in artist name - get artwork, album name, album number
    
    NSString *url = [NSString stringWithFormat:@"https://api.spotify.com/v1/search?query=%@&offset=0&limit=20&type=album", artistObject.artistName];
    
    NSString *encodedString = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    AFHTTPRequestOperationManager *manager =[[AFHTTPRequestOperationManager alloc] init];
    
    [manager GET:encodedString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSDictionary *albumResult = [[[responseObject objectForKey:@"albums"] objectForKey:@"items"] firstObject];
        artistObject.albumTitle = [albumResult objectForKey:@"name"];
        artistObject.albumID = [albumResult objectForKey: @"id"];
        if ([[albumResult objectForKey: @"images"] count]>2) {
            artistObject.albumArtURL = [[[albumResult objectForKey: @"images"]objectAtIndex:1] objectForKey:@"url"];
        }
        else{
            artistObject.albumArtURL = [[[albumResult objectForKey: @"images"]firstObject] objectForKey:@"url"];
        }
        
       // NSLog(@"album title: %@, album id: %@, album art: %@", artistObject.albumTitle, artistObject.albumID, artistObject.albumArtURL);
        
        completion();
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"Error - Spotify #1 API Call: %@", error.localizedDescription);
    }];
}


@end
