//
//  NearbyLocationProcessor.m
//  unit-3-final-project
//
//  Created by Henna Ahmed on 11/15/15.
//  Copyright © 2015 Shena Yoshida. All rights reserved.
//

#define FIVE_MILES 16093.4

#import "NearbyLocationProcessor.h"

@implementation NearbyLocationProcessor

+ (void)findCitiesNearLocation:(CLLocation *)location
                    completion:(void(^)(NSArray <LocationInfoObject *> *cities))completion {
//    self.foundCities = 0;
    double latitude = location.coordinate.latitude;
    double latitudeMin = latitude - 0.2;
    double latMax = latitude + 0.2;
    
    double longitude = location.coordinate.longitude;
    double longitudeMin = longitude - 0.2;
    double longitudeMax = longitude + 0.2;
    
    BOOL doneLocations = NO;
    
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    
    while(!doneLocations) {
        
        CLLocation * currLocation = [[CLLocation alloc]initWithLatitude:latitudeMin longitude:longitudeMin];
        if([currLocation distanceFromLocation:location] < FIVE_MILES){
            //NSLog(@"getting new location");
            [locations addObject:currLocation];
            //            [self addReverseGeoCodedLocation:currLocation];
            
        }
        
        longitudeMin = longitudeMin + 0.01;
        latitudeMin = latitudeMin + 0.01;
        
        if (latitudeMin >= latMax && longitudeMin >= longitudeMax) {
            doneLocations = YES;
        }
        

        
    }
    
    // we know the total number of queries
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    for (CLLocation *location in locations) {
        [self reverseGeoCodeLocation:location completion:^(LocationInfoObject *locationInfo) {
            [results addObject:locationInfo];
            if (results.count == locations.count - 1) {
                
                // filter to make sure location has state
                // uniq array to make sure there are no repeats
                
                completion(results);
            }
        }];
    }

}

+ (void)reverseGeoCodeLocation:(CLLocation*)location completion:(void(^)(LocationInfoObject *locationInfo))completion {
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location // You can pass aLocation here instead
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       dispatch_async(dispatch_get_main_queue(),^ {
//                           // do stuff with placemarks on the main thread
//                           BOOL objectExists = NO;
//
//                           for(LocationInfoObject* object in self.nearbyCities){
//                               if ([[place.addressDictionary objectForKey:@"SubAdministrativeArea"] isEqualToString:object.SubAdministrativeArea]) {
//                                   objectExists = YES;
//                               }
//                           }
                           
//                           if (!objectExists) {
                           CLPlacemark *place = [placemarks firstObject];

                           LocationInfoObject * locObject = [[LocationInfoObject alloc] init];
//                           if ([place.addressDictionary objectForKey:@"State"]) {
                               locObject.State =[place.addressDictionary objectForKey:@"State"];
                               locObject.SubAdministrativeArea =[place.addressDictionary objectForKey:@"SubAdministrativeArea"];
                               locObject.Sublocality = [place.addressDictionary objectForKey:@"SubLocality"];
                               completion(locObject);
                               //NSLog(@"%@, %@, %@", locObject.SubAdministrativeArea, locObject.State, locObject.Sublocality);
//                               [self.nearbyCities addObject: locObject];
//                               self.foundCities++;
//                               NSLog(@"%@", self.nearbyCities);
                               
//                           }
//                           }
                           
                       });
                       
                   }];
    
    
}


@end
