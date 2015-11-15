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
CLLocationManagerDelegate,
UICollectionViewDelegate,
UICollectionViewDataSource
>

@property(nonatomic) NSMutableArray <LocationInfoObject *> *modelData;
// for collection view
@property (nonatomic) NSMutableArray *array;
@property (nonatomic) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) NSArray *collectionImages; // dummy images


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
    self.modelData = [[NSMutableArray alloc]init];
    self.pinSelected = NO;
    self.annotation = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] objectAtIndex:0];
    
    self.searchResults = [[NSMutableArray alloc] init]; // to store api data
    
    self.nearbyCities = [[NSMutableArray alloc]init];
    self.locationManager = [[CLLocationManager alloc] init];
    
    self.searchBar.delegate = self;
    self.locationManager.delegate = self;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;


    [self setupCollectionView];
    
    //Location manager Stuff
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
    
    [NearbyLocationProcessor findCitiesNearLocation:userLocation completion:^(NSArray *cities) {
        [EchonestAPIManager getArtistInfoForCities:cities completion:^{
            [SpotifyApiManager getAlbumInfoForCities:cities completion:^{
                [self setModelAndReloadCollectionView:cities];
            }];
        }];
    }];
    
}

- (void)setModelAndReloadCollectionView:(NSArray <LocationInfoObject *> *)cities {
    [self.modelData removeAllObjects];
    self.modelData = [cities mutableCopy];
    
    //NSLog(@"%@", self.modelData[0].artists[0].albumArtURL);
}



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

#pragma mark - collection view methods:

- (void)setupCollectionView {
    
    // dummy data for collection view:
    //self.array = [[NSMutableArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", nil];
    
    // collection view dummy info:
    self.collectionImages = [NSArray arrayWithObjects:@"destroyer.png", @"drake.png", @"talking_heads.png", @"sleater_kinney.png", @"run_the_jewels.png", nil];
    
    // for carousel
    // grab references to first and last items
    id firstItem = [self.collectionImages firstObject];
    id secondItem = [self.collectionImages objectAtIndex:1];
    id thirdItem = [self.collectionImages objectAtIndex:2];
    
    id nextToNextToLastItem = [self.collectionImages objectAtIndex: [self.collectionImages count] - 3];
    id nextToLastItem = [self.collectionImages objectAtIndex: [self.collectionImages count] - 2];
    id lastItem = [self.collectionImages lastObject];
    
    NSMutableArray *workingArray = [self.collectionImages mutableCopy];
    
    // add the copy of the last item to the beginning
    [workingArray insertObject:lastItem atIndex:0];
    [workingArray insertObject:nextToLastItem atIndex:0];
    [workingArray insertObject:nextToNextToLastItem atIndex:0];
    
    // add the copy of the first item to the end
    [workingArray addObject:firstItem];
    [workingArray addObject:secondItem];
    [workingArray addObject:thirdItem];
    //[workingArray insertObject:firstItem atIndex:self.array.count];
    
    // update the collection view's data source property
    self.collectionImages = [NSArray arrayWithArray:workingArray];
    
    // make cells stick in view
    [self.collectionView setPagingEnabled:YES];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.collectionImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"Cell"; // set collection view cell identifier name
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    

    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    UIImageView *collectionImageView = (UIImageView *)[cell viewWithTag:100];
    collectionImageView.image = [UIImage imageNamed:[self.collectionImages objectAtIndex:indexPath.row]];

    
    // round corners
    cell.layer.borderWidth = 1.0;
    cell.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.layer.cornerRadius = 10.0;
    
    return cell;
}
    
- (void)viewWillAppear:(BOOL)animated {
    [self.view layoutIfNeeded];
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:3 inSection:0];
    
    [self.collectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}

#pragma mark - collection view's infinite scrolling:

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.x + scrollView.frame.size.width >= scrollView.contentSize.width - 15) {
        
        // user is scrolling to the right from the last item to the 'fake' item 1.
        // reposition offset to show the 'real' item 1 at the left-hand end of the collection view
        
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:3 inSection:0];
        
        [self.collectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        
    } else if (scrollView.contentOffset.x == 0) {
        
        // user is scrolling to the left from the first item to the fake item
        // reposition offset to show the "real" item at the right end of the collection
        
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:([self.collectionImages count] - 6) inSection:0];
        [self.collectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if (!self.pinSelected) {
        
        [mapView deselectAnnotation:view.annotation animated:YES];
        LocationInfoObject *obj = [self.nearbyCities firstObject];
        self.annotation.cityStateLabel.text = [NSString stringWithFormat:@"%@, %@", obj.SubAdministrativeArea, obj.State];
        [self.annotation setFrame:CGRectMake(view.bounds.origin.x - 55, view.bounds.origin.y - 100, self.annotation.bounds.size.width, self.annotation.bounds.size.height)];
        [view addSubview:self.annotation];
        self.pinSelected = YES;
        
    }
    else{
        [self.annotation removeFromSuperview];
        self.pinSelected = NO;
        
    }
}
//shake function

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        [self showAlert];
    }
}

-(void)showAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hello World" message:@"This is my first app!" delegate:nil cancelButtonTitle:@"Awesome" otherButtonTitles:nil];
    
    [alertView show];
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
