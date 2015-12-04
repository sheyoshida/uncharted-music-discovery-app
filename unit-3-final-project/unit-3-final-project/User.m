//
//  User.m
//  unit-3-final-project
//
//  Created by Artur Lan on 12/3/15.
//  Copyright © 2015 Shena Yoshida. All rights reserved.
//

#import "User.h"
#import "AppDelegate.h"
#import <Spotify/Spotify.h>

@implementation User

+ (User *)currentUser {
    static User *user = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        user = [[self alloc] init];
    });
    return user;
}

- (NSString *)accessToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:SPOTIFY_ACCESS_TOKEN_KEY];
}

- (NSString *)username {
    return [[NSUserDefaults standardUserDefaults] objectForKey:SPOTIFY_USERNAME_KEY];
}

- (BOOL)isLoggedInToSpotify {
    // you're logged in to spotify if there's an access token in NSUserDefaults
    return [[NSUserDefaults standardUserDefaults] objectForKey:SPOTIFY_ACCESS_TOKEN_KEY] != nil;

}

- (void)loginToSpotify {
    
    NSURL *loginURL = [[SPTAuth defaultInstance] loginURL];
    
    //     Opening a URL in Safari close to application launch may trigger
    //     an iOS bug, so we wait a bit before doing so.
    
    [[UIApplication sharedApplication] performSelector:@selector(openURL:)
                                            withObject:loginURL afterDelay:0.1];
}

@end
