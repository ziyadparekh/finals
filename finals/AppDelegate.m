//
//  AppDelegate.m
//  finals
//
//  Created by Ziyad Parekh on 12/24/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "AppDelegate.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import <Reachability/Reachability.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4.h>
#import "ParseCrashReporting.h"
#import "ZPWelcomeViewController.h"
#import "ZPHomeViewController.h"
#import "ZPActivityFeedViewController.h"
#import "ZPAccountViewController.h"
#import "UIColor+ZPColors.h"

@interface AppDelegate () {
    BOOL firstLaunch;
}

@property (strong, nonatomic) ZPWelcomeViewController *welcomeViewController;
@property (strong, nonatomic) ZPHomeViewController *homeViewController;
@property (strong, nonatomic) ZPAccountViewController *accountViewController;
@property (strong, nonatomic) ZPActivityFeedViewController *activityViewController;

@property (strong, nonatomic) MBProgressHUD *hud;

- (void)setupAppearance;

@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // **************************************************************************
    // Parse initialization
    [ParseCrashReporting enable];
    [Parse setApplicationId:@"qoyosuJnY2TGESNruabPOIWiEWLPDgmEMF9uwjxo" clientKey:@"RwNlapUUmrZNCBDNs4AWQ8DqKeCohSOju0FHv9SD"];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    // **************************************************************************
    
    // Track app open
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    PFACL *defaultAcl = [PFACL ACL];
    // Enable public read access by default with any newly created PFObjects belonging to current user
    [defaultAcl setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultAcl withAccessForCurrentUser:YES];
    
    [self setupAppearance];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // TODO::
    // Use Reachability to monitor connectivity
    // [self monitorReachability]
    
    self.welcomeViewController = [[ZPWelcomeViewController alloc] init];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.welcomeViewController];
    self.navController.navigationBarHidden = YES;
    
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)presentTabBarController {
    self.tabBarController = [[ZPTabBarController alloc] init];
    self.homeViewController = [[ZPHomeViewController alloc] initWithStyle:UITableViewStylePlain];
    self.accountViewController = [[ZPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    self.activityViewController = [[ZPActivityFeedViewController alloc] initWithStyle:UITableViewStylePlain];
    
    UINavigationController *homeNavigationController = [[UINavigationController alloc] initWithRootViewController:self.homeViewController];
    UINavigationController *activityNavigationController = [[UINavigationController alloc] initWithRootViewController:self.activityViewController];
    UINavigationController *settingsNavigationController = [[UINavigationController alloc] init];
    UINavigationController *emptyNavigationController = [[UINavigationController alloc] init];
    UINavigationController *profileNavigationController = [[UINavigationController alloc] initWithRootViewController:self.accountViewController];
    
    UITabBarItem *homeTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Home", @"Home") image:[[UIImage imageNamed:@"ActivityFeedDefault.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"ActivityFeedSelected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    UITabBarItem *profileTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Profile", @"Profile") image:[[UIImage imageNamed:@"ProfileDefault"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"ProfileSelected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    UITabBarItem *activityTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Notifications", @"Notifications") image:[[UIImage imageNamed:@"NotificationsDefault.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"NotificationsSelected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    UITabBarItem *settingsTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Settings", @"Settings") image:[[UIImage imageNamed:@"SettingsDefault.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"SettingsSelected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

    [homeNavigationController setTabBarItem:homeTabBarItem];
    [activityNavigationController setTabBarItem:activityTabBarItem];
    [profileNavigationController setTabBarItem:profileTabBarItem];
    [settingsNavigationController setTabBarItem:settingsTabBarItem];
    
    self.tabBarController.delegate = self;
    self.tabBarController.viewControllers = @[ homeNavigationController, activityNavigationController, emptyNavigationController, profileNavigationController, settingsNavigationController ];
    
    [self.navController setViewControllers:@[ self.welcomeViewController, self.tabBarController ] animated:NO];
    
}

// Set appearance parameters to achieve custom look and feel
- (void)setupAppearance {
    //[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [[UINavigationBar appearance] setTintColor:[UIColor zp_lightBlueColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor zp_venmoBlueColor]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName: [UIColor whiteColor]
                                                           }];
    
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleColor:[UIColor whiteColor]
     forState:UIControlStateNormal];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName:[UIColor whiteColor]
                                                           }
                                                forState:UIControlStateNormal];
    
    [[UITextView appearance] setTintColor:[UIColor zp_venmoBlueColor]];
    
    [[UISearchBar appearance] setTintColor:[UIColor zp_greyColor]];
    
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    // The empty UITabBarItem behind our camera button should not load a view controller
    return ![viewController isEqual:tabBarController.viewControllers[ZPEmptyTabBarItemIndex]];
}

- (BOOL)isParseReachable {
    return self.networkStatus != NotReachable;
}

- (void)presentLoginViewController:(BOOL)animated {
    [self.welcomeViewController presentLoginViewController:animated];
}

- (void)presentLoginViewController {
    [self presentLoginViewController:YES];
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)logOut {
    // clear cache
    //[[PAPCache sharedCache] clear];
    
    // Clear all caches
    [PFQuery clearAllCachedResults];
    
    // Log out
    [PFUser logOut];
    [FBSDKAccessToken setCurrentAccessToken:nil];
    
    [self.navController popToRootViewControllerAnimated:NO];
    
    [self presentLoginViewController];
    
    self.homeViewController = nil;
    self.accountViewController = nil;
    self.activityViewController = nil;
    
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
    
    [FBSDKAppEvents activateApp];
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
    // The directory the application uses to store the Core Data store file. This code uses a directory named "ZP.finals" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"finals" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"finals.sqlite"];
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
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
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
