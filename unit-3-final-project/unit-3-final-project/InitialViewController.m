//
//  InitialViewController.m
//  unit-3-final-project
//
//  Created by Shena Yoshida on 11/8/15.
//  Copyright © 2015 Shena Yoshida. All rights reserved.

#import "InitialViewController.h"
#import "CustomPin.h"
#import <AFNetworking/AFNetworking.h>
#import "ArtistInfoData.h"
#import "LocationInfoObject.h"
#import "InfoWindow.h"
#import "NearbyLocationProcessor.h"
#import "EchonestAPIManager.h"
#import "SpotifyApiManager.h"
#import "DetailViewController.h"
#import "HomeScreenTableViewCell.h" // custom cells!

@interface InitialViewController ()
<
MKMapViewDelegate,
CLLocationManagerDelegate,
UITableViewDataSource,
UITableViewDelegate
>

// for model data
@property(nonatomic) NSMutableArray <LocationInfoObject *> *modelData;

// for table view
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// for maps + location services
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) InfoWindow * annotation;
@property(nonatomic) LocationInfoObject * currentCity;
@property (nonatomic) int foundCities;

// for API search results
@property (nonatomic) NSString *spotifyAlbumID;

@end


@implementation InitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentCity = [[LocationInfoObject alloc]init];
    self.modelData = [[NSMutableArray alloc]init];
    self.annotation = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] objectAtIndex:0];
   
    // custom cell setup
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UINib *nib = [UINib nibWithNibName:@"HomeScreenTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"HomeScreenTableViewCellIdentifier"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 40.0;
    // [self.tableView setTableFooterView:[UIView new]]; // hide extra lines in empty tableview cells
    
    // Location manager Stuff
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 500;
    [self.locationManager startUpdatingLocation];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.showsBuildings = YES;
}

#pragma mark - TableView Stuff

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%@, %@", self.currentCity.SubAdministrativeArea, self.currentCity.State];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.currentCity.artists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HomeScreenTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeScreenTableViewCellIdentifier" forIndexPath:indexPath];

    ArtistInfoData *artist = [self.currentCity.artists objectAtIndex:indexPath.row];
    cell.artistNameLabel.text = artist.artistName;
    cell.artistDetailLabel.text = artist.albumTitle; // need spotify api call #1 to use
    
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
    cell.artistImageView.image = artworkImage;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    DetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DVCIdentifier"];;
    
    vc.artist = [self.currentCity.artists objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    [self.locationManager stopUpdatingLocation];
    [self zoomIntoLocation:newLocation andZoom:100000];
    [self getNearbyCitiesWithCoordinate:newLocation];
}

#pragma mark - Maps:

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    userLocation.title = @"Music";
}

- (void)zoomIntoLocation:(CLLocation *)location andZoom:(CLLocationDistance) distance {
    
    CLLocationCoordinate2D location2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    //zoom in
    MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:location2D fromEyeCoordinate:location2D eyeAltitude:distance];
    [self.mapView setCamera:camera animated:YES];
}

- (void)getNearbyCitiesWithCoordinate: (CLLocation *) userLocation {
    
    [NearbyLocationProcessor findCitiesNearLocation:userLocation completion:^(NSArray *cities) {
        
        [EchonestAPIManager getArtistInfoForCities:cities completion:^{
            [SpotifyApiManager getAlbumInfoForCities:cities completion:^{
                [self dropPinsForCities:cities];
                [self setModel:cities];
                [self showDataForCity:[cities firstObject]];
            }];
        }];
    }];
}

- (void)setModel:(NSArray <LocationInfoObject *> *)cities {
    [self.modelData removeAllObjects];
    self.modelData = [cities mutableCopy];
    
    //[self.tableView reloadData];
}

- (void)showDataForCity: (LocationInfoObject *) city {
    
    self.currentCity = city;
    [self.tableView reloadData];
}

- (void)dropPinsForCities:(NSArray*)cities {
    
    for (LocationInfoObject *city in cities) {
        if (city.artists.count == 0) {
            NSLog(@"%@, %@", city.SubAdministrativeArea, city.State);
        }
        else{
            CLLocation *location = city.location;
            CLLocationCoordinate2D location2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
            CustomPin *pin = [CustomPin alloc];
            pin.city = city;
            pin.coordinate = location2D;
            
            [self.mapView addAnnotation:pin];
        
        }
        
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    else if ([annotation isKindOfClass:[CustomPin class]]) // use whatever annotation class you used when creating the annotation
    {
        static NSString * const defaultPinID = @"com.invasivecode.pin";
        
        MKAnnotationView* annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        
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
        annotationView.image = [UIImage imageNamed:@"Pin.png"];
        
        return annotationView;
    }
    return nil;
}

#pragma mark - spotify api call #2

- (void)passAlbumIDToSpotifyWithArtistObject:(ArtistInfoData*)artistObject {
    
    // pass in album number - get song preview(url) + song name
    // https://api.spotify.com/v1/albums/4NnBDxnxiiXiMlssBi9Bsq/tracks?offset=0&limit=50
    
    self.spotifyAlbumID = artistObject.albumID;
    
    if (self.spotifyAlbumID != nil) {
        
        NSString *url2 = [NSString stringWithFormat:@"https://api.spotify.com/v1/albums/%@/tracks?offset=0&limit=50", self.spotifyAlbumID];
        
        NSString *encodedString2 = [url2 stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        AFHTTPRequestOperationManager *manager2 =[[AFHTTPRequestOperationManager alloc] init];
        
        [manager2 GET:encodedString2 parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
            NSArray *resultsSpotifySecondCall = responseObject[@"items"];
            
            for (NSDictionary *result in resultsSpotifySecondCall) {
                
                artistObject.songPreview = [result objectForKey:@"preview_url"];
                artistObject.songTitle = [result objectForKey:@"name"];
                
            }
            
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"Error - Spotify #2 API Call: %@", error.localizedDescription);
        }];
        
    }
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    if(![view isKindOfClass:[MKUserLocation class]]){
    [self.annotation removeFromSuperview];
    CustomPin * pin = view.annotation;
    LocationInfoObject *obj = pin.city;

    self.annotation.cityStateLabel.text = [NSString stringWithFormat:@"%@, %@", obj.SubAdministrativeArea, obj.State];
    self.annotation.cityStateLabel.backgroundColor = [UIColor whiteColor];
    [self.annotation setFrame:CGRectMake(view.bounds.origin.x - 55, view.bounds.origin.y - 150, self.annotation.bounds.size.width, self.annotation.bounds.size.height)];
    [view addSubview:self.annotation];
        [self zoomIntoLocation:pin.city.location andZoom:100000];
    self.currentCity = pin.city;
    [self.tableView reloadData];
    }
    
//    if(![view isKindOfClass:[MKUserLocation class]])
//    {
//        CustomPin *selectedPin = view.annotation;
//        selectedPin.selected = YES;
//        
//        //    [mapView deselectAnnotation:view.annotation animated:YES];
//        
//        for (CustomPin *currentPin in [mapView annotations]) {
//            
//            if (currentPin.selected) {
//                NSLog(@"%@", currentPin);
////                LocationInfoObject *obj = pin.city;
////                
////                
////                pin.annotation.cityStateLabel.text = [NSString stringWithFormat:@"%@, %@", obj.SubAdministrativeArea, obj.State];
////                pin.annotation.cityStateLabel.backgroundColor = [UIColor whiteColor];
////                [pin.annotation setFrame:CGRectMake(view.bounds.origin.x - 55, view.bounds.origin.y - 150, pin.annotation.bounds.size.width, pin.annotation.bounds.size.height)];
////                [view addSubview:pin.annotation];
////                
////                self.currentCity = pin.city;
////                [self.tableView reloadData];
//            }
//            else{
//                CustomPin *pin = view.annotation;
//                [pin.annotation removeFromSuperview];
//                
//            }
//        }

//    }
    
}

# pragma mark - shake feature

//- (BOOL)canBecomeFirstResponder
//{
//    return YES;
//}
//
//- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
//{
//    if (motion == UIEventSubtypeMotionShake)
//    {
//        [self showAlert];
//    }
//}
//
//-(void)showAlert
//{
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hello World" message:@"This is my first app!" delegate:nil cancelButtonTitle:@"Awesome" otherButtonTitles:nil];
//    
//    [alertView show];
//}

@end
