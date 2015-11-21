//
//  FirstSpotifyApiManager.h
//  unit-3-final-project
//
//  Created by Henna Ahmed on 11/15/15.
//  Copyright © 2015 Shena Yoshida. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LocationInfoObject;
@class ArtistInfoData;

@interface SpotifyApiManager : NSObject



+ (void)getAlbumInfoForCities:(NSArray *)cities
                   completion:(void(^)())completion;
+ (void)passAlbumIDToSpotifyWithArtistObject:(ArtistInfoData*)artistObject;



@end
