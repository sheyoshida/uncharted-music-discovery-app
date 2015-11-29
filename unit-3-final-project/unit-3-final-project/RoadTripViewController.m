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
#import <HNKGooglePlacesAutocomplete/HNKGooglePlacesAutocomplete.h>
#import "CLPlacemark+HNKAdditions.h"
#import "Chameleon.h"
#import "MBLoadingIndicator.h"

@interface RoadTripViewController () <MKMapViewDelegate,
CLLocationManagerDelegate,
UITableViewDataSource,
UITableViewDelegate,
CLLocationManagerDelegate,
UISearchBarDelegate


>

// for model data
@property(nonatomic) NSMutableArray <LocationInfoObject *> *modelData;
@property (nonatomic) InfoWindow * annotation;
@property (weak, nonatomic) IBOutlet MKMapView *roadTripMapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) CLLocationManager *locationManager;


@property (weak, nonatomic) IBOutlet UISearchBar *startSearchBar;
@property (weak, nonatomic) IBOutlet UISearchBar *endSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *searchResultsTableView;
@property (nonatomic) NSMutableArray *autoCompleteSearchResults;
@property (strong, nonatomic) HNKGooglePlacesAutocompleteQuery *searchQuery;


@property (nonatomic) CLLocation *start;
@property (nonatomic) CLLocation *end;

@property (nonatomic) BOOL startEdit;

@property (nonatomic, strong) MBLoadingIndicator *loadview;


@end

@implementation RoadTripViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Create the loader
    self.loadview = [[MBLoadingIndicator alloc] init];
    
    //NOTE: Any extra loader can be done here, including sizing, colors, animation speed, etc
    //      Pre-start changes will not be animated.
    [self.loadview  setLoaderStyle:MBLoaderFullCircle];
    [self.loadview setLoadedColor: [UIColor colorWithHexString:@"0099cc"]];
    [self.loadview setWidth:20];
    [self.loadview  setLoaderSize:MBLoaderLarge];
    [self.loadview  setStartPosition:MBLoaderRight];
    [self.loadview  setAnimationSpeed:MBLoaderSpeedFast];
    [self.loadview  offsetCenterXBy:-12.5f];
    
    
    
    
    self.startEdit= NO;
    self.autoCompleteSearchResults = [[NSMutableArray alloc]init];
    self.searchResultsTableView.delegate = self;
    self.searchResultsTableView.dataSource = self;
    self.searchResultsTableView.hidden = YES;
    
    self.startSearchBar.delegate = self;
    self.endSearchBar.delegate = self;
    self.startSearchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.endSearchBar.searchBarStyle = UISearchBarStyleMinimal;
    for(UIView *subView in self.startSearchBar.subviews) {
        if ([subView isKindOfClass:[UITextField class]]) {
            UITextField *searchField = (UITextField *)subView;
            searchField.font = [UIFont fontWithName:@"Varela Round" size:16];
        }
    }
    for(UIView *subView in self.endSearchBar.subviews) {
        if ([subView isKindOfClass:[UITextField class]]) {
            UITextField *searchField = (UITextField *)subView;
            searchField.font = [UIFont fontWithName:@"Varela Round" size:16];
        }
    }
    
    
    self.searchQuery = [HNKGooglePlacesAutocompleteQuery sharedQuery];
    
    
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
    
    [self.navigationController setHidesNavigationBarHairline:YES];

    
}


#pragma mark - searchbar stuff

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:YES animated:YES];
    
    if (searchBar == self.startSearchBar) {
        self.startEdit = YES;
    }
    else{
        self.startEdit = NO;
    }
    
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    self.searchResultsTableView.hidden = YES;
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchBar.text > 0) {
        self.searchResultsTableView.hidden = NO;
        [self.searchQuery fetchPlacesForSearchQuery:searchText completion:^(NSArray *places, NSError *error) {
            if (error) {
                NSLog(@"%@", error);
            }
            else{
                [self.autoCompleteSearchResults removeAllObjects];
                self.autoCompleteSearchResults = [places mutableCopy];
                [self.searchResultsTableView reloadData];
            }
        }];
        
        
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self.searchResultsTableView setHidden:YES];
}


#pragma mark - MKMapView Methods

- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    else if ([annotation isKindOfClass:[CustomPin class]]) // use whatever annotation class you used when creating the annotation
    {
        static NSString * const defaultPinID = @"com.invasivecode.pin";
        
        MKAnnotationView* annotationView = [self.roadTripMapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        
        if (annotationView)
        {
            annotationView.annotation = annotation;
        }
        else
        {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:defaultPinID];
        }
        annotationView.centerOffset = CGPointMake(0, -18.0);
        annotationView.canShowCallout = NO;
        annotationView.image = [UIImage imageNamed:@"MapPinOrange.png"];
        
        return annotationView;
    }
    return nil;
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    userLocation.title = @"Current Location";
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
    renderer.strokeColor = [UIColor colorWithHexString:@"0099cc"];
    renderer.lineWidth = 5.0;
    return renderer;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    id annotation = view.annotation;
    
    if(![annotation isKindOfClass:[MKUserLocation class]]){
        [self.annotation removeFromSuperview];
        CustomPin * pin = view.annotation;
        LocationInfoObject *obj = pin.city;
        
        self.annotation.cityStateLabel.text = [NSString stringWithFormat:@"%@, %@", obj.SubAdministrativeArea, obj.State];
        [self.annotation setFrame:CGRectMake(view.bounds.origin.x - self.annotation.bounds.size.width/2, view.bounds.origin.y, self.annotation.bounds.size.width, self.annotation.bounds.size.height)];
        [view addSubview:self.annotation];
        
        self.annotation.viewDetail.layer.cornerRadius = 10;
        
        
        
        [self.modelData enumerateObjectsUsingBlock:^(LocationInfoObject* object, NSUInteger idx, BOOL *stop)
        {
            if ([object.SubAdministrativeArea isEqualToString:obj.SubAdministrativeArea]) {
                [self.modelData exchangeObjectAtIndex:idx withObjectAtIndex:0];
            }
            
        }];
        
        
        [self.tableView reloadData];
    }
    
    
}




-(void)showRoute:(MKDirectionsResponse *)response
{
    [self.roadTripMapView removeOverlays: [self.roadTripMapView overlays]];
    [self.roadTripMapView removeAnnotations: [self.roadTripMapView annotations]];
    MKRoute *route = [response.routes firstObject];
    MKMapPoint middlePoint = route.polyline.points[route.polyline.pointCount/2];
    
    CLLocationCoordinate2D coordinate = MKCoordinateForMapPoint(middlePoint);
    
    [self zoomIntoLocation: [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude] andZoom:route.distance*1.5];
    
    [self.roadTripMapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    
    
    
    //Start the loader
    [self.loadview start];
    [self.loadview incrementPercentageBy:17];
    
    //Add the loader to our view
    [self.view addSubview:self.loadview];

        [NearbyLocationProcessor findCitiesInRoute:route completion:^(NSArray<LocationInfoObject *> *cities) {
            
    
            [EchonestAPIManager getArtistInfoForCities:cities andGenre:@" " completion:^{
                NSArray *finalCities = [cities filteredArrayUsingPredicate: [NSPredicate predicateWithBlock:^BOOL(LocationInfoObject* evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                    return evaluatedObject.artists.count > 0;
                }]];
                
                [SpotifyApiManager getAlbumInfoForCities:finalCities completion:^{
                    [self dropPinsForCities:finalCities];
                    
                    [self setModel:finalCities];
                    [self.loadview finish];
                }];
            }];
    
        }];
    
}

- (void)setModel:(NSArray <LocationInfoObject *> *)cities {
    [self.modelData removeAllObjects];
    self.modelData = [cities mutableCopy];
    [self.tableView reloadData];

}

- (void)dropPinsForCities:(NSArray*)cities {
    
    for (LocationInfoObject *city in cities) {
        if (city.artists.count == 0) {
           
        }
        else{
            CLLocation *location = city.location;
            CLLocationCoordinate2D location2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
            CustomPin *pin = [CustomPin alloc];
            pin.city = city;
            pin.coordinate = location2D;
            
            [self.roadTripMapView addAnnotation:pin];
            
        }
        
    }
}

//- (void)dropPinsForCities:(NSArray*)cities {
//    
//    for (LocationInfoObject *city in cities) {
//
//        CLLocation *location = city.location;
//        CLLocationCoordinate2D location2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
//        MKPlacemark *placeMark = [[MKPlacemark alloc]initWithCoordinate:location2D addressDictionary:nil];
//        [self.roadTripMapView addAnnotation:placeMark];
//        
//    }
//}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    [self.locationManager stopUpdatingLocation];
    
}

#pragma mark - TableView Stuff

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    // section text
    header.textLabel.textColor = [UIColor colorWithRed:(251/255.f) green:(66/255.f) blue:(7/255.f) alpha:1]; // orange color
    header.textLabel.font = [UIFont fontWithName:@"Varela" size:18];
    CGRect headerFrame = self.tableView.tableHeaderView.frame;
    headerFrame.size.height = self.tableView.frame.size.height;
    header.textLabel.frame = headerFrame;
    header.textLabel.textAlignment = NSTextAlignmentLeft;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchResultsTableView) {
        return @"";
    }
    else if (self.modelData.count < 1 ){
        return @" ";
    }
    else{
        LocationInfoObject * currentCity = [self.modelData objectAtIndex:section];
        return [NSString stringWithFormat:@"%@, %@", currentCity.SubAdministrativeArea, currentCity.State];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchResultsTableView) {
        return 1;
    }
    else{
        return self.modelData.count;
    }
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.searchResultsTableView) {
        return self.autoCompleteSearchResults.count;
    }
    else{
        LocationInfoObject * currentCity = [self.modelData objectAtIndex:section];
        return [currentCity.artists count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchResultsTableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mySearchCellIdentifier"];
        HNKGooglePlacesAutocompletePlace *place = [self.autoCompleteSearchResults objectAtIndex:indexPath.row];
        cell.textLabel.text = place.name;
        return cell;
    }
    else{
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
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.searchResultsTableView) {
        [self.startSearchBar setShowsCancelButton:NO animated:YES];
        [self.startSearchBar resignFirstResponder];
        [self.endSearchBar setShowsCancelButton:NO animated:YES];
        [self.endSearchBar resignFirstResponder];
        
        HNKGooglePlacesAutocompletePlace *place = [self.autoCompleteSearchResults objectAtIndex:indexPath.row];
        

        
        if (self.startEdit) {
            self.startSearchBar.text = place.name;
            [CLPlacemark hnk_placemarkFromGooglePlace:place apiKey:self.searchQuery.apiKey completion:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
                self.start = placemark.location;
            }];
            
        }
        else{
            self.endSearchBar.text = place.name;
            [CLPlacemark hnk_placemarkFromGooglePlace:place apiKey:self.searchQuery.apiKey completion:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
                self.end = placemark.location;
            }];
        }
        
    }

}
- (IBAction)routeClicked:(UIButton *)sender {
    
    MKPlacemark *placeMarkStart = [[MKPlacemark alloc]initWithCoordinate:self.start.coordinate addressDictionary:nil];
    [self.roadTripMapView addAnnotation:placeMarkStart];
    MKMapItem * start= [[MKMapItem alloc]initWithPlacemark:placeMarkStart];
    
    MKPlacemark *placeMarkEnd = [[MKPlacemark alloc]initWithCoordinate:self.end.coordinate addressDictionary:nil];
    [self.roadTripMapView addAnnotation:placeMarkEnd];
    MKMapItem * end= [[MKMapItem alloc]initWithPlacemark:placeMarkEnd];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = start;
    request.destination = end;
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

- (void) doneClicked{

}





@end
