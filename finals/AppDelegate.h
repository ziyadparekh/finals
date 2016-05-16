//
//  AppDelegate.h
//  finals
//
//  Created by Ziyad Parekh on 12/24/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ZPTabBarController.h"
#import "ZPConstants.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, NSURLConnectionDataDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) ZPTabBarController *tabBarController;

@property (nonatomic, readonly) int networkStatus;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (BOOL)isParseReachable;

- (void)presentTabBarController;
- (void)presentLockSplashController;
- (void)presentLoginViewController;
- (void)presentLoginViewController:(BOOL)animated;

- (void)logOut;

@end

