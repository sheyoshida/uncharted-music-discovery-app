//
//  EchonestAPIManager.h
//  unit-3-final-project
//
//  Created by Henna Ahmed on 11/15/15.
//  Copyright © 2015 Shena Yoshida. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LocationInfoObject;

@interface EchonestAPIManager : NSObject

+ (void)getArtistInfoForCities:(NSArray <LocationInfoObject *> *)cities
                      andGenre:(NSString*)genre
                    completion:(void(^)())completion;

@end
