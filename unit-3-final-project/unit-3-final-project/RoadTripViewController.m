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


@end

@implementation RoadTripViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.startEdit= NO;
    self.autoCompleteSearchResults = [[NSMutableArray alloc]init];
    self.searchResultsTableView.delegate = self;
    self.searchResultsTableView.dataSource = self;
    self.searchResultsTableView.hidden = YES;
    self.startSearchBar.delegate = self;
    self.endSearchBar.delegate = self;
    
    
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
            
    
            [EchonestAPIManager getArtistInfoForCities:cities andGenre:@" " completion:^{
                NSArray *finalCities = [cities filteredArrayUsingPredicate: [NSPredicate predicateWithBlock:^BOOL(LocationInfoObject* evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                    return evaluatedObject.artists.count > 0;
                }]];
                [self dropPinsForCities:finalCities];
                [SpotifyApiManager getAlbumInfoForCities:finalCities completion:^{
                    [self setModel:finalCities];
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

        CLLocation *location = city.location;
        CLLocationCoordinate2D location2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
        MKPlacemark *placeMark = [[MKPlacemark alloc]initWithCoordinate:location2D addressDictionary:nil];
        [self.roadTripMapView addAnnotation:placeMark];
        
    }
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    [self.locationManager stopUpdatingLocation];
    
}

#pragma mark - TableView Stuff

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchResultsTableView) {
        return @"";
    }
    else{
        LocationInfoObject * currentCity = [self.modelData objectAtIndex:section];
        NSLog(@"%@", currentCity.SubAdministrativeArea);
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
