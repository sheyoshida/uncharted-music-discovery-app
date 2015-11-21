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
        
        NSArray *artistImages = [albumResult objectForKey:@"images"];
        
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
                                                          [ artistObject.spotifyImages addObject:urlString];
                                                      }
                                                      
                                                  }];
                    
                    [task resume];
                    
                    
                }
                
            }
            
        }
        
        else { // this doesn't fill in the null images as expected (ie: David Coffee)
            
            NSString *artworkURL = [NSString stringWithFormat:@"http://seattletwist.com/wp-content/uploads/awesomely-cute-kitten-1500.jpg"];
            [artistObject.spotifyImages addObject:artworkURL];
        }
        
        if (artistObject.albumID) {
            [self passAlbumIDToSpotifyWithArtistObject:artistObject];
        }

        
        
        completion();
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"Error - Spotify #1 API Call: %@", error.localizedDescription);
    }];
}


#pragma mark - spotify api call #2

+ (void)passAlbumIDToSpotifyWithArtistObject:(ArtistInfoData*)artistObject {
    
    // pass in album number - get song preview(url) + song name
    // https://api.spotify.com/v1/albums/4NnBDxnxiiXiMlssBi9Bsq/tracks?offset=0&limit=50
    

        
        NSString *url2 = [NSString stringWithFormat:@"https://api.spotify.com/v1/albums/%@/tracks?offset=0&limit=50", artistObject.albumID];
        
        NSString *encodedString2 = [url2 stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        AFHTTPRequestOperationManager *manager2 =[[AFHTTPRequestOperationManager alloc] init];
        
        [manager2 GET:encodedString2 parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
            NSArray *resultsSpotifySecondCall = responseObject[@"items"];
            
            for (NSDictionary *result in resultsSpotifySecondCall) {
                
                artistObject.songPreview = [result objectForKey:@"preview_url"];
                artistObject.songTitle = [result objectForKey:@"name"];
                
            }
            
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"Error - Spotify #2 API Call: %@", error.localizedDescription);
        }];
        
    
}


@end
