//
//  AppDelegate.m
//  unit-3-final-project
//
//  Created by Shena Yoshida on 11/8/15.
//  Copyright © 2015 Shena Yoshida. All rights reserved.
//

#import "AppDelegate.h"
#import <HNKGooglePlacesAutocomplete/HNKGooglePlacesAutocompleteQuery.h>
#import "User.h"
#import "OnboardingViewController.h"
#import "OnboardingContentViewController.h"


#define ClientID @"8cd3e645d1eb4d3d9040456cb98ce224" // spotify - artur

// original Google Places key: @"AIzaSyAWnqNcCoTk_j7oZabHJkVZW0ULVFg5uZ0"

static NSString *const kHNKDemoGooglePlacesAutocompleteApiKey = @"AIzaSyBsjev2ayvnZcPlaW41UY4RXCheVyAx3Ag"; // NEW key!

static NSString * const kUserHasOnboardedKey = @"user_has_onboarded";


@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[SPTAuth defaultInstance] canHandleURL:url]) {
        [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url callback:^(NSError *error, SPTSession *session) {
            
            if (!error) {
                [[NSUserDefaults standardUserDefaults] setObject:session.accessToken forKey:SPOTIFY_ACCESS_TOKEN_KEY];
                [[NSUserDefaults standardUserDefaults] setObject:session.canonicalUsername forKey:SPOTIFY_USERNAME_KEY];
                
                if ([User currentUser].onLoginCallback) {
                    [User currentUser].onLoginCallback();
                }
            }
            
        }];
        
        return YES;
    }
    
    return NO;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // setup onboarding screens
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor colorWithRed:255/256.0 green:255/256.0 blue:255/256.0 alpha:1.0];

    // determine if the user has onboarded yet or not
    BOOL userHasOnboarded = [[NSUserDefaults standardUserDefaults] boolForKey:kUserHasOnboardedKey];
    
    // if the user has already onboarded, just set up the normal root view controller
    // for the application
    if (userHasOnboarded) {
        [self setupNormalRootViewController];
    }
    // otherwise set the root view controller to the onboarding view controller
    else {
        self.window.rootViewController = [self generateFirstDemoVC];
           }
    
    application.statusBarStyle = UIStatusBarStyleLightContent;
    [self.window makeKeyAndVisible];

    // setup spotify
    [[SPTAuth defaultInstance] setClientID:ClientID];
    [[SPTAuth defaultInstance] setRedirectURL:[NSURL URLWithString:@"spotifyapi://callback"]];
    [[SPTAuth defaultInstance] setRequestedScopes:@[SPTAuthStreamingScope,SPTAuthPlaylistModifyPublicScope]];


    // set Navigation bar properties:
    // blue = 83, 148, 196
    [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
    [[UINavigationBar appearance] setTranslucent:NO]; // remove translucent layer on navigation items
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]]; // set font color
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName: @"Varela Round"}];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor redColor]}];
    [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:256/256.0 green:256/256.0 blue:256/256.0 alpha:1.0]; // set background color
    
    // tab bar properties - remove line
    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc] init]];
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];

    // Add this code to change StateNormal text Color,
    [UITabBarItem.appearance setTitleTextAttributes:
     @{NSForegroundColorAttributeName : [UIColor colorWithRed:128/256.0 green:128/256.0 blue:128/256.0 alpha:1.0]}
                                           forState:UIControlStateNormal]; //grey color
    
    // then if StateSelected should be different, you should add this code
    [UITabBarItem.appearance setTitleTextAttributes:
     @{NSForegroundColorAttributeName : [UIColor colorWithRed:255/256.0 green:92/256.0 blue:26/256.0 alpha:1.0]}
                                           forState:UIControlStateSelected]; // orange color
    
    [HNKGooglePlacesAutocompleteQuery setupSharedQueryWithAPIKey: kHNKDemoGooglePlacesAutocompleteApiKey];
    
    return YES;
}

- (void)setupNormalRootViewController {
    // push to regular tab bar
    self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];

}
- (void)handleOnboardingCompletion { 
    // set that we have completed onboarding so we only do it once...
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserHasOnboardedKey];
    // transition to the main application
    [self setupNormalRootViewController];
}

- (OnboardingViewController *)generateFirstDemoVC {
    OnboardingContentViewController *firstPage = [OnboardingContentViewController contentWithTitle:@"Welcome to Uncharted!" body:@"Here are a few things to help you get started... " image:nil buttonText:nil action:^{
        // block here
            }];
    firstPage.titleFontName = @"Varela Round";
    firstPage.titleFontSize = 50.0;
    firstPage.bodyFontName = @"Varela Round";
    firstPage.bodyFontSize = 25.0;
    firstPage.titleTextColor = [UIColor colorWithRed:83/256.0 green:148/256.0 blue:196/256.0 alpha:1.0];
    firstPage.bodyTextColor = [UIColor colorWithRed:83/256.0 green:148/256.0 blue:196/256.0 alpha:1.0];
    
    OnboardingContentViewController *secondPage = [OnboardingContentViewController contentWithTitle:nil body:@"1. To preview songs, long press on a cell.\n\n 2. You can add individual songs to your Spotify playlist by tapping on the heart button.\n\n 3. To navigate to a random location, just shake your phone." image:nil buttonText:@"OK!" action:^{
        [self handleOnboardingCompletion];
    }];
    secondPage.bodyFontName = @"Varela Round";
    secondPage.bodyFontSize = 25.0;
    secondPage.topPadding = -50.0;
    secondPage.bodyTextColor = [UIColor colorWithRed:83/256.0 green:148/256.0 blue:196/256.0 alpha:1.0];
    

    OnboardingViewController *onboardingVC = [OnboardingViewController onboardWithBackgroundImage:nil contents:@[firstPage, secondPage]];
    onboardingVC.shouldFadeTransitions = YES;
    onboardingVC.fadePageControlOnLastPage = YES;
    onboardingVC.fadeSkipButtonOnLastPage = YES;
    onboardingVC.shouldMaskBackground = NO;
    onboardingVC.fontName = @"Varela Round";
    onboardingVC.buttonTextColor = [UIColor colorWithRed:255/256.0 green:92/256.0 blue:26/256.0 alpha:1.0];
    onboardingVC.buttonFontSize = 35.0;
    onboardingVC.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:83/256.0 green:148/256.0 blue:196/256.0 alpha:1.0];
    onboardingVC.pageControl.pageIndicatorTintColor = [UIColor colorWithRed:144/256.0 green:144/256.0 blue:144/256.0 alpha:1.0];
    
    // Allow skipping the onboarding process, enable skipping and set a block to be executed
    // when the user hits the skip button.
    onboardingVC.allowSkipping = NO;
    onboardingVC.skipHandler = ^{
        [self handleOnboardingCompletion];
    };
    
    return onboardingVC;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "shenayoshida.unit_3_final_project" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"unit_3_final_project" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"unit_3_final_project.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
