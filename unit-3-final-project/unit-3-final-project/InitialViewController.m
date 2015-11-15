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
#import "InfoWindow.h"
#import "NearbyLocationProcessor.h"
#import "EchonestAPIManager.h"
#import "SpotifyApiManager.h"


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
@property (nonatomic) BOOL pinSelected;
@property (nonatomic) InfoWindow * annotation;
@property (nonatomic) int foundCities;

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
    self.pinSelected = NO;
    self.annotation = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] objectAtIndex:0];
    
    self.searchResults = [[NSMutableArray alloc] init]; // to store api data
    
    self.nearbyCities = [[NSMutableArray alloc]init];
    self.locationManager = [[CLLocationManager alloc] init];
    
    self.searchBar.delegate = self;
    self.locationManager.delegate = self;

    [self setupCollectionView];
    
    //Location manager Stuff
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 500;
    [self.locationManager startUpdatingLocation];
    
    
//    [self artistInfo]; // call echonest api
//    [self passArtistNameToSpotifyWithName:@"Backstreet Boys"]; // call first spotify api
//    [self passAlbumIDToSpotify]; // call second spotify api
    
    


    
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

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    userLocation.title = @"Music";
}

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

    [NearbyLocationProcessor findCitiesNearLocation:userLocation completion:^(NSArray <LocationInfoObject *> *cities) {
        [EchonestAPIManager getArtistInfoForCities:cities completion:^{
            [SpotifyApiManager getAlbumInfoForCities:cities completion:^{
                NSLog(@"display artists on screen");
            }];
        }];
        //
        //            for (artistInfoData *artist in self.searchResults) {
        //                [self passArtistNameToSpotifyWithArtistObject:artist];
        //
        //
        //            }
        //        }
    }];
    
}


//animated pin
- (void)pinWithCoordinate:(CLLocation*)location {
    CLLocationCoordinate2D location2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    CustomPin *pin = [CustomPin alloc];
    pin.coordinate = location2D;
    
    [self.mapView addAnnotation:pin];
}

- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
{
    
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
    
//    [self artistInfo]; // trigger echonest api witih location
//    [self passArtistNameToSpotifyWithName:@"The Beach Boys"];
}


#pragma mark - spotify api call #1

// we will have to loop through the echonest artist name results


#pragma mark - spotify api call #2

- (void)passAlbumIDToSpotifyWithArtistObject:(ArtistInfoData*)artistObject {
    
// pass in album number - get song preview(url) + song name
// https://api.spotify.com/v1/albums/4NnBDxnxiiXiMlssBi9Bsq/tracks?offset=0&limit=50

    

   self.spotifyAlbumID = artistObject.albumID;
        
        if (self.spotifyAlbumID != nil) {
    
    NSString *url2 = [NSString stringWithFormat:@"https://api.spotify.com/v1/albums/%@/tracks?offset=0&limit=50", self.spotifyAlbumID];
            
   // NSLog(@"URL2: %@", url2);
    
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

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if (!self.pinSelected) {

        [mapView deselectAnnotation:view.annotation animated:YES];
        LocationInfoObject *obj = [self.nearbyCities firstObject];
        self.annotation.cityStateLabel.text = [NSString stringWithFormat:@"%@, %@", obj.SubAdministrativeArea, obj.State];
        [self.annotation setFrame:CGRectMake(view.bounds.origin.x+view.bounds.size.width, view.bounds.origin.y - self.annotation.bounds.size.height, self.annotation.bounds.size.width, self.annotation.bounds.size.height)];
        [view addSubview:self.annotation];
        self.pinSelected = YES;
        
    }
    else{
        [self.annotation removeFromSuperview];
        self.pinSelected = NO;
    
    }
    
   
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
