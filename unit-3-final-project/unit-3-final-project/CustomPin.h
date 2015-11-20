//
//  CustomPin.h
//  unit-3-final-project
//
//  Created by Artur Lan on 11/9/15.
//  Copyright © 2015 Shena Yoshida. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "LocationInfoObject.h"
#import "InfoWindow.h"

@interface CustomPin : NSObject <MKAnnotation>
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic) LocationInfoObject *city;

@end
