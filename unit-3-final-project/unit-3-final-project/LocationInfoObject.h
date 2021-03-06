//
//  LocationInfoObject.h
//  unit-3-final-project
//
//  Created by Henna Ahmed on 11/14/15.
//  Copyright © 2015 Shena Yoshida. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArtistInfoData.h"
#import <CoreLocation/CoreLocation.h>

@interface LocationInfoObject : NSObject
    @property (nonatomic) CLLocation * location;
    @property (nonatomic) NSString * SubAdministrativeArea ;
    @property (nonatomic) NSString * State;
    @property (nonatomic) NSString * Sublocality;
    @property (nonatomic) NSArray <ArtistInfoData*> *artists;
@end
