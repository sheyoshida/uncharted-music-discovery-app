//
//  SpotifyPlaylistManager.h
//  unit-3-final-project
//
//  Created by Artur Lan on 12/3/15.
//  Copyright © 2015 Shena Yoshida. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpotifyPlaylistManager : NSObject

+ (void)addTrackToPlaylist:(NSString *)trackURI
                completion:(void(^)(BOOL success))completion;

@end
