//
//  InitialViewController.m
//  unit-3-final-project
//
//  Created by Shena Yoshida on 11/8/15.
//  Copyright © 2015 Shena Yoshida. All rights reserved.
//

#import "InitialViewController.h"
#import "CustomPin.h"
#import <AFNetworking/AFNetworking.h>
#import "ArtistInfoData.h"
#import "LocationInfoObject.h"


@interface InitialViewController ()
<
MKMapViewDelegate,
UISearchBarDelegate,
CLLocationManagerDelegate>

// for collection view
@property (nonatomic) NSMutableArray *array;
@property (nonatomic) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


// for maps
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSMutableArray *nearbyCities;

//for API search results
@property (nonatomic) NSMutableArray *searchResults;
@property (nonatomic) NSString *spotifyAlbumID;


//search bar/colleciton view
@property (nonatomic,strong) NSArray *dataSource;
@property (nonatomic,strong) NSArray *dataSourceForSearchResult;
@property (nonatomic) BOOL searchBarActive;

@property (nonatomic,strong) UIRefreshControl   *refreshControl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end


@implementation InitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchResults = [[NSMutableArray alloc] init]; // to store api data
    
    self.nearbyCities = [[NSMutableArray alloc]init];
    self.locationManager = [[CLLocationManager alloc] init];
    
    self.searchBar.delegate = self;
    self.locationManager.delegate = self;

    [self setupCollectionView];
    [self artistInfo]; // call echonest api
    [self passArtistNameToSpotifyWithName:@"Backstreet Boys"]; // call first spotify api
    [self passAlbumIDToSpotify]; // call second spotify api
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 500;
    [self.locationManager startUpdatingLocation];


    
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    [self setUpMapViewAndPin:newLocation];
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - Maps:

//current location
- (void)setUpMapViewAndPin:(CLLocation *)location {
    
    CLLocationCoordinate2D location2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.showsBuildings = YES;
    
    
    //zoom in
    MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:location2D fromEyeCoordinate:location2D eyeAltitude:10000];
    [self.mapView setCamera:camera animated:YES];
    [self getNearbyCitiesWithCoordinate:location];
    
    //add Pin
    [self pinWithCoordinate:location];
    
}

-(void) getNearbyCitiesWithCoordinate: (CLLocation *) userLocation{
    
    double latitude = userLocation.coordinate.latitude;
    double latitudeMin = latitude - 0.2;
    double latMax = latitude + 0.2;
    
    double longitude = userLocation.coordinate.longitude;
    double longitudeMin = longitude - 0.2;
    double longitudeMax = longitude + 0.2;

    BOOL doneLocations = NO;
    
    while(!doneLocations) {
        
        CLLocation * currLocation = [[CLLocation alloc]initWithLatitude:latitudeMin longitude:longitudeMin];
        if([currLocation distanceFromLocation:userLocation]<16093.4){
            [self addReverseGeoCodedLocation:currLocation];
            
        }
        longitudeMin = longitudeMin + 0.005;
        latitudeMin = latitudeMin + 0.005;
        
        if (latitudeMin >= latMax && longitudeMin >= longitudeMax) {
            doneLocations = YES;
        }
        
    }


    
}

- (void) addReverseGeoCodedLocation:(CLLocation*)location{
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location // You can pass aLocation here instead
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       
                       dispatch_async(dispatch_get_main_queue(),^ {
                           // do stuff with placemarks on the main thread
                           BOOL objectExists = NO;
                           CLPlacemark *place = [placemarks firstObject];
                           
                           for(LocationInfoObject* object in self.nearbyCities){
                               if ([[place.addressDictionary objectForKey:@"SubAdministrativeArea"] isEqualToString:object.SubAdministrativeArea]) {
                                   objectExists = YES;
                               }
                           }
                           
                           if (!objectExists) {
                               LocationInfoObject * locObject = [[LocationInfoObject alloc] init];
                               if ([place.addressDictionary objectForKey:@"State"]) {
                                   locObject.State =[place.addressDictionary objectForKey:@"State"];
                                   locObject.SubAdministrativeArea =[place.addressDictionary objectForKey:@"SubAdministrativeArea"];
                                   locObject.Sublocality = [place.addressDictionary objectForKey:@"SubLocality"];
                                   NSLog(@"%@, %@, %@", locObject.SubAdministrativeArea, locObject.State, locObject.Sublocality);
                                   [self.nearbyCities addObject: locObject];
                                   
                               }
                           }

                       });
                       
                   }];

    
}
//annimated pin
- (void)pinWithCoordinate:(CLLocation*)location {
    CLLocationCoordinate2D location2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    CustomPin *pin = [CustomPin alloc];
    pin.coordinate = location2D;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                       
                       dispatch_async(dispatch_get_main_queue(),^ {
                           CLPlacemark *place = [placemarks firstObject];
                           pin.title = [place.addressDictionary objectForKey:@"SubLocality"];
                       });
                       
                   }];
    
    [self.mapView addAnnotation:pin];
}
- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *pinView = nil;
    
    if(annotation != self.mapView.userLocation)
    {
        static NSString *defaultPinID = @"com.invasivecode.pin";
        pinView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil )
            pinView = [[MKAnnotationView alloc]
                       initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        
        pinView.canShowCallout = YES;
        //        [self.customView setBackgroundColor:[UIColor redColor]];
        //        [pinView addSubview:self.customView];
        pinView.image = [UIImage imageNamed:@"Pin.png"];
    }
    else {
        [self.mapView.userLocation setTitle:@"I am here"];
    }
    return pinView;
    
    
}



#pragma mark - search bar
//- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
//    NSPredicate *resultPredicate    = [NSPredicate predicateWithFormat:@"self contains[c] %@", searchText];
//    self.dataSourceForSearchResult  = [self.dataSource filteredArrayUsingPredicate:resultPredicate];
//}
//
//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
//    // user did type something, check our datasource for text that looks the same
//    if (searchText.length>0) {
//        // search and reload data source
//        self.searchBarActive = YES;
//        [self filterContentForSearchText:searchText
//                                   scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
//                                          objectAtIndex:[self.searchDisplayController.searchBar
//                                                         selectedScopeButtonIndex]]];
//        [self.collectionView reloadData];
//    }else{
//        // if text lenght == 0
//        // we will consider the searchbar is not active
//        self.searchBarActive = NO;
//    }
//}
//
//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
//    [self cancelSearching];
//    [self.collectionView reloadData];
//}
//
//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
//    self.searchBarActive = YES;
//    [self.view endEditing:YES];
//}
//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
//    // we used here to set self.searchBarActive = YES
//    // but we'll not do that any more... it made problems
//    // it's better to set self.searchBarActive = YES when user typed something
//    [self.searchBar setShowsCancelButton:YES animated:YES];
//}
//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
//    // this method is being called when search btn in the keyboard tapped
//    // we set searchBarActive = NO
//    // but no need to reloadCollectionView
//    self.searchBarActive = NO;
//    [self.searchBar setShowsCancelButton:NO animated:YES];
//    
//    [self artistInfo];
//}
//
//-(void)cancelSearching{
//    self.searchBarActive = NO;
//    [self.searchBar resignFirstResponder];
//    self.searchBar.text  = @"";
//}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self.view endEditing:YES];
    
    [self artistInfo]; // trigger echonest api witih location
    [self passArtistNameToSpotifyWithName:@"The Beach Boys"];
}


#pragma mark- Echonest API Request

- (void)artistInfo {
    
    NSMutableArray *cities = [[NSMutableArray alloc] init];
    [cities addObject:@"New York"];
    [cities addObject:@"Brooklyn"];
    [cities addObject:@"Queens"];
    [cities addObject:@"Holbrook"];
    [cities addObject:@"Fort Greene"];
    [cities addObject:@"Ozone Park"];
    [cities addObject:@"Holbrook"];
    [cities addObject:@"Hoboken"];
    [cities addObject:@"Harlem"];
    [cities addObject:@"Flushing"];

    // http://developer.echonest.com/api/v4/artist/search?api_key=MUIMT3R874QGU0AFO&format=json&artist_location=brooklyn+ny&bucket=artist_location&bucket=biographies&bucket=images&bucket=years_active&bucket=genre&bucket=discovery_rank&bucket=familiarity_rank&bucket=hotttnesss_rank
    
    NSString *city = @"brooklyn"; // test city
    NSString *region = @"ny"; // test state/province/territory/etc
    
    NSString *url = [NSString stringWithFormat:@"http://developer.echonest.com/api/v4/artist/search?api_key=MUIMT3R874QGU0AFO&format=json&artist_location=%@+%@&bucket=artist_location&bucket=biographies&bucket=images&bucket=years_active&bucket=genre&bucket=discovery_rank&bucket=familiarity_rank&bucket=hotttnesss_rank", city, region];
    
    NSString *encodedString = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    AFHTTPRequestOperationManager *manager =[[AFHTTPRequestOperationManager alloc] init];
    
    [manager GET:encodedString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSDictionary *results = responseObject[@"response"];
        NSArray *artists = results[@"artists"];
        
        // loop through all json posts
        for (NSDictionary *results in artists) {
            
            // create new post from json
            artistInfoData *data = [[artistInfoData alloc] initWithJSON:results];
            
            // add post to array
            [self.searchResults  addObject:data];
            
           // NSLog(@"search results: %@", self.searchResults); // test it!
            
            // self.albumImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:data.imageURL]]];
            
            //    NSLog(@"This is the artist data: %@",data);
        }
        
        
        // [self.tableView reloadData];
      // NSLog(@"%@", results);
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error.localizedDescription);
        // block();
    }];
}

#pragma mark - spotify api call #1

- (void) getSpotifyData{
//loop through searchResults
//  [self passArtistNameToSpotifyWithName:name]
    
}

// we will have to loop through the echonest artist name results

- (void)passArtistNameToSpotifyWithName:(NSString *) name  {
    // goal: pass in artist name - get artwork, album name, album number

  //  NSString *name = @"The Beach Boys"; // dummy info that we're passing this into the url
    
    NSString *url = [NSString stringWithFormat:@"https://api.spotify.com/v1/search?query=%@&offset=0&limit=20&type=album", name];
    
  
    
    NSString *encodedString = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    AFHTTPRequestOperationManager *manager =[[AFHTTPRequestOperationManager alloc] init];
    
    [manager GET:encodedString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
      //  NSLog(@"response object: %@", responseObject);
        
        NSDictionary *resultsSpotify = responseObject[@"albums"];
        NSArray *artistsSpotify = resultsSpotify[@"items"];
        
         for (NSDictionary *resultsSpotify in artistsSpotify) {
              artistInfoData *dataSpotify = [[artistInfoData alloc] initWithJSON:resultsSpotify];
    
              [self.searchResults  addObject:dataSpotify];
             
         }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"Error - Spotify #1 API Call: %@", error.localizedDescription);
    }];
}

#pragma mark - spotify api call #2
    
    - (void)passAlbumIDToSpotify {
    
// pass in album number - get song preview(url) + song name
// https://api.spotify.com/v1/albums/4NnBDxnxiiXiMlssBi9Bsq/tracks?offset=0&limit=50

   self.spotifyAlbumID = @"4NnBDxnxiiXiMlssBi9Bsq";
        
        if (self.spotifyAlbumID != nil) {
    
    NSString *url2 = [NSString stringWithFormat:@"https://api.spotify.com/v1/albums/%@/tracks?offset=0&limit=50", self.spotifyAlbumID];
            
    NSLog(@"URL2: %@", url2);
    
    NSString *encodedString2 = [url2 stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    AFHTTPRequestOperationManager *manager2 =[[AFHTTPRequestOperationManager alloc] init];
    
    [manager2 GET:encodedString2 parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSArray *resultsSpotifySecondCall = responseObject[@"items"];
        
        for (NSDictionary *result in resultsSpotifySecondCall) {
            //NSLog(@"%@", [result objectForKey:@"preview_url"]);
            artistInfoData *dataSpotifySecondCall = [[artistInfoData alloc] initWithJSON:result];
            
            [self.searchResults  addObject:dataSpotifySecondCall];

        }
      
        
        NSLog(@"results second call: %@", resultsSpotifySecondCall);
        
       //   NSLog(@"hello hello!"); // parse through results to get song preview url and song title
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
          NSLog(@"Error - Spotify #2 API Call: %@", error.localizedDescription);
    }];
    
}
    }

#pragma mark - collection view methods:

- (void)setupCollectionView {
    
    // dummy data for collection view:
    self.array = [[NSMutableArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", nil];
    
    // for carousel
    // grab references to first and last items
    id firstItem = [self.array firstObject];
    id lastItem = [self.array lastObject];
    
    NSMutableArray *workingArray = [self.array mutableCopy];
    
    // add the copy of the last item to the beginning
    [workingArray insertObject:lastItem atIndex:0];
    
    // add the copy of the first item to the end
    [workingArray addObject:firstItem];
    //[workingArray insertObject:firstItem atIndex:self.array.count];
    
    // update the collection view's data source property
    self.dataArray = [NSArray arrayWithArray:workingArray];
    
    // make cells stick in view
    [self.collectionView setPagingEnabled:YES];
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"Cell"; // set collection view cell identifier name
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
   // UIImageView *collectionImageView = (UIImageView *)[cell viewWithTag:100];
 
    
    // round corners
    cell.layer.borderWidth = 1.0;
    cell.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.layer.cornerRadius = 10.0;
    
    return cell;
}

#pragma mark - collection view's infinite scrolling:

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    // calculate where the collection view should be at the right-hand end item
    float contentOffsetWhenFullyScrolledRight = self.collectionView.frame.size.width * ([self.dataArray count] -1);
    
    if (scrollView.contentOffset.x == contentOffsetWhenFullyScrolledRight) {
        
        // user is scrolling to the right from the last item to the 'fake' item 1.
        // reposition offset to show the 'real' item 1 at the left-hand end of the collection view
        
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
        
        [self.collectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        
    } else if (scrollView.contentOffset.x == 0) {
        
        // user is scrolling to the left from the first item to the fake item
        // reposition offset to show the "real" item at the right end of the collection
        
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:([self.dataArray count] -2) inSection:0];
        [self.collectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    UIView *rootView = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] objectAtIndex:0];
    UIView *containerView = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] lastObject];
    [rootView addSubview:containerView];
    
    [view addSubview:containerView];
    
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    UIView *rootView = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] objectAtIndex:0];
    UIView *containerView = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] lastObject];
    [rootView addSubview:containerView];
    
    
    [view willRemoveSubview:containerView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
