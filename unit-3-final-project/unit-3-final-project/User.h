//
//  User.h
//  unit-3-final-project
//
//  Created by Artur Lan on 12/3/15.
//  Copyright © 2015 Shena Yoshida. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic) NSString *username;
@property (nonatomic) NSString *accessToken;

@property (nonatomic, strong) void(^onLoginCallback)();

+ (User *)currentUser;
- (BOOL)isLoggedInToSpotify;
- (void)loginToSpotify;

@end
