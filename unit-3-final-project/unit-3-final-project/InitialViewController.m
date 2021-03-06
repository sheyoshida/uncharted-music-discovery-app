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
#import "HomeScreenTableViewCell.h" // custom cells!
#import <HNKGooglePlacesAutocomplete/HNKGooglePlacesAutocomplete.h>
#import "CLPlacemark+HNKAdditions.h"
#import "Chameleon.h"
#import "MBLoadingIndicator.h"

@import AVFoundation;

#import "CBZSplashView.h"
#import "UIColor+HexString.h"
#import "UIBezierPath+Shapes.h"

static NSString * const kUnchartedIcon = @"unchartedWhiteMap";
static NSString * const kUnchartedColor = @"0099cc";

@interface InitialViewController ()
<
UIGestureRecognizerDelegate,
MKMapViewDelegate,
CLLocationManagerDelegate,
UITableViewDataSource,
UITableViewDelegate,
AVAudioPlayerDelegate,
UISearchBarDelegate
>

@property (nonatomic, strong) CBZSplashView *splashView;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
// for model data
@property(nonatomic) NSMutableArray <LocationInfoObject *> *modelData;

// for table view
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// for maps + location services
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) InfoWindow * annotation;
@property(nonatomic) LocationInfoObject * currentCity;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *autoCompleteTableView;
@property (nonatomic) NSMutableArray *autoCompleteSearchResults;
@property (strong, nonatomic) HNKGooglePlacesAutocompleteQuery *searchQuery;

@property (nonatomic) NSMutableArray *randomLocations; // array of cities
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;


@end

@implementation InitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.randomLocations = [[NSMutableArray alloc]initWithObjects: @{ @"latitude": @18.975, @"longitude": @72.825}, @{ @"latitude": @33.755, @"longitude": @-84.390}, @{ @"latitude": @29.950, @"longitude": @-90.066}, nil];

    //long touch
    UILongPressGestureRecognizer *gesture1 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(celllongpressed:)];
    [gesture1 setDelegate:self];
    [gesture1 setMinimumPressDuration:1];
    [self.tableView addGestureRecognizer: gesture1];

    
    self.currentCity = [[LocationInfoObject alloc]init];
    self.modelData = [[NSMutableArray alloc]init];
    self.annotation = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] objectAtIndex:0];
    
    //autocomplete table view set up
    self.autoCompleteSearchResults = [[NSMutableArray alloc]init];
    self.autoCompleteTableView.delegate = self;
    self.autoCompleteTableView.dataSource = self;
    self.autoCompleteTableView.hidden = YES;
    self.searchQuery = [HNKGooglePlacesAutocompleteQuery sharedQuery];
    
    // custom cell setup
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    UINib *nib = [UINib nibWithNibName:@"HomeScreenTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"HomeScreenTableViewCellIdentifier"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 40.0;

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
    
    // nav bar
    [self.navigationController setHidesNavigationBarHairline:YES];

    self.searchBar.searchBarStyle = UISearchBarStyleMinimal; // remove border from search bar
    for(UIView *subView in self.searchBar.subviews) {
        if ([subView isKindOfClass:[UITextField class]]) {
            UITextField *searchField = (UITextField *)subView;
            searchField.font = [UIFont fontWithName:@"Varela Round" size:16];
        }
    }
    

}

#pragma mark - longPress Stuff
-(void)celllongpressed:(UIGestureRecognizer *)longPress
{
    CGPoint cellPostion = [longPress locationOfTouch:0 inView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:cellPostion];
    HomeScreenTableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (longPress.state == UIGestureRecognizerStateBegan)
    {
        
        ArtistInfoData *artist = [self.currentCity.artists objectAtIndex:indexPath.row];
        NSURL *url = [[NSURL alloc]initWithString:artist.songPreview];
        
        
        NSError *error;
        NSData *data = [NSData dataWithContentsOfURL:url];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
        
        if (error)
        {
            NSLog(@"Error in audioPlayer: %@",
                  [error localizedDescription]);
        } else {
            self.audioPlayer.delegate = self;
            [self.audioPlayer prepareToPlay];
            [self.audioPlayer play];
            if (cell.activityIndicatorView.hidden == YES) {
                cell.activityIndicatorView.hidden = NO;
                [cell.activityIndicator startAnimating];
            } else {
                [cell.activityIndicator startAnimating];
            }
        }
        
    }
    else
    {
        if (longPress.state == UIGestureRecognizerStateCancelled
            || longPress.state == UIGestureRecognizerStateFailed
            || longPress.state == UIGestureRecognizerStateEnded)
        {
            // press ended
            [self.audioPlayer stop];
            [cell.activityIndicator stopAnimating];
            cell.activityIndicatorView.hidden = YES;
            [cell.activityIndicatorView reloadInputViews];
        }
    }
}


#pragma mark - searchbar delegate methods

- (void)viewWillAppear:(BOOL)animated { // for search bar
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated { // for search bar
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:YES animated:YES];
    [self searchBar:searchBar textDidChange:searchBar.text];
    
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    self.autoCompleteTableView.hidden = YES;
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchBar.text.length > 0) {
        self.autoCompleteTableView.hidden = NO;
        [self.searchQuery fetchPlacesForSearchQuery:searchText completion:^(NSArray *places, NSError *error) {
            if (error) {
                NSLog(@"%@", error);
            }
            else{
                [self.autoCompleteSearchResults removeAllObjects];
                self.autoCompleteSearchResults = [places mutableCopy];
                [self.autoCompleteTableView reloadData];
            }
        }];
        
        
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self.autoCompleteTableView setHidden:YES];
}


#pragma mark - TableView delegate methods

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == self.autoCompleteTableView) {
        return 0;
    }
    else{
        return 40;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    // section text
    header.textLabel.textColor = [UIColor colorWithRed:(251/255.f) green:(66/255.f) blue:(7/255.f) alpha:1]; // orange color
    header.textLabel.font = [UIFont fontWithName:@"Varela Round" size:16];
    CGRect headerFrame = self.tableView.tableHeaderView.frame;
    headerFrame.size.height = self.tableView.frame.size.height;
    header.textLabel.frame = headerFrame;
    header.textLabel.textAlignment = NSTextAlignmentLeft;

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.autoCompleteTableView) {
        return @" ";
    }
    else if (self.modelData.count < 1 ){
        return @" ";
    }
    else{
    return [NSString stringWithFormat:@"%@, %@", self.currentCity.SubAdministrativeArea, self.currentCity.State];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.autoCompleteTableView) {
        return self.autoCompleteSearchResults.count;
    }
    else{
        return self.currentCity.artists.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.autoCompleteTableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"autocompleteCellIdentifier" forIndexPath:indexPath];
        HNKGooglePlacesAutocompletePlace *place = [self.autoCompleteSearchResults objectAtIndex:indexPath.row];
        cell.textLabel.text = place.name;
    
        cell.textLabel.textColor=[UIColor blackColor];
        cell.detailTextLabel.font=[UIFont fontWithName:@"Varela Round" size:16.0];
        
        return cell;
    }
    
    else{
        
        HomeScreenTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeScreenTableViewCellIdentifier" forIndexPath:indexPath];
        ArtistInfoData *artist = [self.currentCity.artists objectAtIndex:indexPath.row];
        cell.artistNameLabel.text = artist.artistName;
        cell.songURI = artist.songURI;
        cell.SongNameLabel.text = artist.songTitle;
        
        // like button
        if (artist.liked == YES) {
            [cell.buttonFavorite setImage:[UIImage imageNamed:@"heart-selected.png"] forState:UIControlStateNormal];
            
        } else {
            [cell.buttonFavorite setImage:[UIImage imageNamed:@"heart-button.png"] forState:UIControlStateNormal];
        }
     
        
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
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (tableView == self.autoCompleteTableView) {
        [self.searchBar setShowsCancelButton:NO animated:YES];
        [self.searchBar resignFirstResponder];
        
        HNKGooglePlacesAutocompletePlace *place = [self.autoCompleteSearchResults objectAtIndex:indexPath.row];
        
        __weak typeof(self) weakSelf = self;
        [CLPlacemark hnk_placemarkFromGooglePlace:place apiKey:self.searchQuery.apiKey completion:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
            weakSelf.searchBar.text = place.name;
            [weakSelf getNearbyCitiesWithCoordinate:placemark.location];
        }];
        


        
    }

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
    
    userLocation.title = @"";
}

- (void)zoomIntoLocation:(CLLocation *)location andZoom:(CLLocationDistance) distance {
    
    CLLocationCoordinate2D location2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    //zoom in
    MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:location2D fromEyeCoordinate:location2D eyeAltitude:distance];
    [self.mapView setCamera:camera animated:YES];
}

- (void)getNearbyCitiesWithCoordinate: (CLLocation *) userLocation {
    
    MBLoadingIndicator *indicator = [self showLoadingIndicator];
    
    __weak typeof(self) weakSelf = self;
    
    [weakSelf.annotation removeFromSuperview];
    [weakSelf.mapView removeAnnotations:weakSelf.mapView.annotations];
    
    [NearbyLocationProcessor findCitiesNearLocation:userLocation completion:^(NSArray *cities) {
        
        
        [EchonestAPIManager getArtistInfoForCities:cities andGenre:@" " completion:^{
            
            NSArray *finalCities = [cities filteredArrayUsingPredicate: [NSPredicate predicateWithBlock:^BOOL(LocationInfoObject* evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                return evaluatedObject.artists.count > 0;
            }]];
            
            
            if (finalCities.count > 0) {
                
                [SpotifyApiManager getAlbumInfoForCities:finalCities completion:^{
                    
                    if (finalCities.count>0) {
                        
                        NSArray *finalArtistCities = [finalCities filteredArrayUsingPredicate: [NSPredicate predicateWithBlock:^BOOL(LocationInfoObject* evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                            
                            evaluatedObject.artists = [evaluatedObject.artists filteredArrayUsingPredicate:[ NSPredicate predicateWithBlock:^BOOL(ArtistInfoData* artistObjectEval, NSDictionary<NSString *,id> * _Nullable bindings) {
                                
                                return artistObjectEval.songURI;
                            }]];
                            
                            return evaluatedObject.artists.count > 0;
                        }]];
                        [weakSelf zoomIntoLocation:userLocation andZoom:100000];
                        [weakSelf dropPinsForCities:finalArtistCities];
                        [weakSelf setModel:finalArtistCities];
                        [weakSelf hideLoadingIndicator:indicator];
                    }
                    else{
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No Songs Found" message:@"Sorry, we didn't find any songs for the artists in this city, try another one!" preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"okay" style:UIAlertActionStyleDefault handler:nil];
                        [alertController addAction:ok];
                        
                        [self presentViewController:alertController animated:YES completion:nil];
                        
                    }
                    
                }];
                
            }
            else {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No Artists Found" message:@"Sorry, we didn't find any artists in this city, try another one!" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"okay" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                
                [self presentViewController:alertController animated:YES completion:nil];
                
            }
            
            
        }];
    }];
}

- (MBLoadingIndicator *)showLoadingIndicator {

    MBLoadingIndicator *indicator = [[MBLoadingIndicator alloc] init];
    
    [indicator setLoaderStyle:MBLoaderFullCircle];
    [indicator setLoadedColor: [UIColor colorWithHexString:@"0099cc"]];
    [indicator setWidth:20];
    [indicator setLoaderSize:MBLoaderMedium];
    [indicator setStartPosition:MBLoaderTop];
    [indicator setAnimationSpeed:MBLoaderSpeedFast];
    [indicator offsetCenterXBy:0.0f];
    
    [self.view addSubview:indicator];
    [indicator start];
    [indicator incrementPercentageBy:(arc4random_uniform(30) + 17)];
    
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [weakSelf hideLoadingIndicator:indicator];
    });
    return indicator;
}

- (void)hideLoadingIndicator:(MBLoadingIndicator *)indicator {
    [indicator finish];
}

- (void)setModel:(NSArray <LocationInfoObject *> *)cities {
    [self.modelData removeAllObjects];
    self.modelData = [cities mutableCopy];
    [self showDataForCity:[self.modelData firstObject]];
    //[self.tableView reloadData];
}

- (void)showDataForCity: (LocationInfoObject *) city {
    
    self.currentCity = city;
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
        annotationView.image = [UIImage imageNamed:@"map-pin.png"];
        
        return annotationView;
    }
    return nil;
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
        [self zoomIntoLocation:pin.city.location andZoom:70000];
        self.currentCity = pin.city;
        self.annotation.viewDetail.layer.cornerRadius = 10;

        [self.tableView reloadData];
    }
    
}

# pragma mark - shake feature

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        
        CLLocation *rand = [self generateRandomCity];
        [self getNearbyCitiesWithCoordinate: rand];
    }
}

//-(void)showAlert
//{
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hello World" message:@"This is my first app!" delegate:nil cancelButtonTitle:@"Awesome" otherButtonTitles:nil];
//    
//    [alertView show];
//}


- (CLLocation * )generateRandomCity {
    NSUInteger randomIndex = arc4random() % [self.randomLocations count];
    NSDictionary * location = [self.randomLocations objectAtIndex:randomIndex];
    double latitude = [[location objectForKey:@"latitude"] doubleValue];
    double longitude = [[location objectForKey:@"longitude"] doubleValue];
    
    
    return [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    
}

@end
