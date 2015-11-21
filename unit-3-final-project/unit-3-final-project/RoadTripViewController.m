//
//  RoadTripViewController.m
//  unit-3-final-project
//
//  Created by Henna Ahmed on 11/21/15.
//  Copyright © 2015 Shena Yoshida. All rights reserved.
//

#import "RoadTripViewController.h"
#import "CustomPin.h"
#import <AFNetworking/AFNetworking.h>
#import "ArtistInfoData.h"
#import "LocationInfoObject.h"
#import "InfoWindow.h"
#import <MapKit/MapKit.h>
#import "NearbyLocationProcessor.h"
#import "EchonestAPIManager.h"
#import "SpotifyApiManager.h"

@interface RoadTripViewController () <MKMapViewDelegate,
CLLocationManagerDelegate,
UITableViewDataSource,
UITableViewDelegate,
CLLocationManagerDelegate


>

// for model data
@property(nonatomic) NSMutableArray <LocationInfoObject *> *modelData;
@property (nonatomic) InfoWindow * annotation;
@property (weak, nonatomic) IBOutlet MKMapView *roadTripMapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) MKMapItem * destination;

@end

@implementation RoadTripViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.modelData = [[NSMutableArray alloc]init];
    self.annotation = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] objectAtIndex:0];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Location manager Stuff
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 500;
    [self.locationManager startUpdatingLocation];
    
    self.roadTripMapView.delegate = self;
    self.roadTripMapView.showsUserLocation = YES;
    self.roadTripMapView.showsBuildings = YES;
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    userLocation.title = @"Music";
}

- (void)zoomIntoLocation:(CLLocation *)location andZoom:(CLLocationDistance) distance {
    
    CLLocationCoordinate2D location2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    //zoom in
    MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:location2D fromEyeCoordinate:location2D eyeAltitude:distance];
    [self.roadTripMapView setCamera:camera animated:YES];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer *renderer =
    [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 5.0;
    return renderer;
}

-(void)showRoute:(MKDirectionsResponse *)response
{
    MKRoute *route = [response.routes firstObject];
    MKMapPoint middlePoint = route.polyline.points[route.polyline.pointCount/2];
    
    CLLocationCoordinate2D coordinate = MKCoordinateForMapPoint(middlePoint);
    
    [self zoomIntoLocation: [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude] andZoom:route.distance*1.5];
    [self.roadTripMapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    
    
    [NearbyLocationProcessor findCitiesInRoute:route completion:^(NSArray<LocationInfoObject *> *cities) {
        [self dropPinsForCities:cities];
//        
//        [EchonestAPIManager getArtistInfoForCities:cities completion:^{
//            [SpotifyApiManager getAlbumInfoForCities:cities completion:^{
//                [self setModel:cities];
//            }];
//        }];
        
    }];
    
}

- (void)setModel:(NSArray <LocationInfoObject *> *)cities {
    [self.modelData removeAllObjects];
    self.modelData = [cities mutableCopy];
    NSLog(@"%lu", (unsigned long)self.modelData.count);
    [self.tableView reloadData];
    //[self.tableView reloadData];
}

- (void)dropPinsForCities:(NSArray*)cities {
    
    for (LocationInfoObject *city in cities) {
//        if (city.artists.count == 0) {
//            //NSLog(@"nope: %@, %@", city.SubAdministrativeArea, city.State);
//        }
//        else{
            NSLog(@"yupp: %@, %@", city.SubAdministrativeArea, city.State);
            CLLocation *location = city.location;
            CLLocationCoordinate2D location2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
            MKPlacemark *placeMark = [[MKPlacemark alloc]initWithCoordinate:location2D addressDictionary:nil];
            [self.roadTripMapView addAnnotation:placeMark];
            
            
        //}
        
    }
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    [self.locationManager stopUpdatingLocation];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(42.3598, -71.0921);
    
    MKPlacemark *placeMark = [[MKPlacemark alloc]initWithCoordinate:coordinate addressDictionary:nil];
    [self.roadTripMapView addAnnotation:placeMark];
    self.destination = [[MKMapItem alloc]initWithPlacemark:placeMark];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = self.destination;
    [request setTransportType:MKDirectionsTransportTypeAutomobile];
    request.requestsAlternateRoutes = NO;
    MKDirections *directions =
    [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             // Handle Error
         } else {
             [self showRoute:response];
         }
     }];
    
}

#pragma mark - TableView Stuff

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    LocationInfoObject * currentCity = [self.modelData objectAtIndex:section];
    NSLog(@"%@", currentCity.SubAdministrativeArea);
    return [NSString stringWithFormat:@"%@, %@", currentCity.SubAdministrativeArea, currentCity.State];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.modelData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    LocationInfoObject * currentCity = [self.modelData objectAtIndex:section];
    
    return [currentCity.artists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mySongCell"];
    
    LocationInfoObject * currentCity = [self.modelData objectAtIndex:indexPath.section];
    
    ArtistInfoData *artist = [currentCity.artists objectAtIndex:indexPath.row];
    cell.textLabel.text = artist.artistName;
    cell.detailTextLabel.text = artist.songTitle; // need spotify api call #1 to use
    
    NSString *urlString = [[NSString alloc] init];
    
    if (artist.spotifyImages.count > 1) {
        urlString = [artist.spotifyImages objectAtIndex:1];
    }
    else {
        urlString = [artist.spotifyImages firstObject];
    }
    
    NSURL *artworkURL = [NSURL URLWithString: urlString]; // need spotify api call #1 to use
    NSData *artworkData = [NSData dataWithContentsOfURL:artworkURL];
    UIImage *artworkImage = [UIImage imageWithData:artworkData];
    cell.imageView.image = artworkImage;
    
    return cell;
}




@end
