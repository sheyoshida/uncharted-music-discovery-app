//
//  NearbyLocationProcessor.h
//  unit-3-final-project
//
//  Created by Henna Ahmed on 11/15/15.
//  Copyright © 2015 Shena Yoshida. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationInfoObject.h"

@interface NearbyLocationProcessor : NSObject

+ (void)findCitiesNearLocation:(CLLocation *)location
                completion:(void(^)(NSArray <LocationInfoObject *> *cities))completion;

@end
