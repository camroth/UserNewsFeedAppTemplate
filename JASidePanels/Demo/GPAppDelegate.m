//
//
//
//  Created by Garrett Parrish on 1/15/14.
//  Copyright (c) 2014 Gampets. All rights reserved.
//
//
//


#import "GPAppDelegate.h"
#import "GPSidePanelController.h"
#import "GPCenterViewController.h"
#import "GPLeftViewController.h"
#import <Parse/Parse.h>

GPAppDelegate* AppDelegate()
{
    return (GPAppDelegate*) [[UIApplication sharedApplication] delegate];
}

@implementation GPAppDelegate

@synthesize window = _window;
@synthesize homeViewController, loginConfigurationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Configure macro-level UI
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // Configure Parse
    [Parse setApplicationId:@"NtSgNr2t4d7cfSYPkWPVFUPCc8SaDBfRTSk2Aepr"
                  clientKey:@"mgPe5YAzQyQW7nIhYohn9Be2kaXo7ESZfMjOzTod"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    // Configure Facebook and Twitter w/ parse
    [PFFacebookUtils initializeFacebook];
    [PFTwitterUtils initializeWithConsumerKey:@"your_twitter_consumer_key" consumerSecret:@"your_twitter_consumer_secret"];

    // Set default ACLs
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];

    // Configure HOME view controller
    homeViewController = [[GPSidePanelController alloc] init];
    homeViewController.shouldDelegateAutorotateToVisiblePanel = NO;
    
    homeViewController.leftPanel = [[GPLeftViewController alloc] init];
    homeViewController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[[GPCenterViewController alloc] init]];

    self.window.rootViewController = self.homeViewController;

    [self.window makeKeyAndVisible];
    
//    [self uploadSamples];
    
    [self _initializeFileSystem];
    return YES;
}

- (void) _initializeFileSystem
{
    [[NSFileManager defaultManager] createDirectoryAtPath:[self videoFileDirectoryPath]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    
    [[PFUser currentUser] setObject:@"us" forKey:@"flag_code"];
    [[PFUser currentUser] setObject:@"Cambridge, MA" forKey:@"location"];
    [[PFUser currentUser] saveInBackground];
}

- (NSURL*) writeVideoData: (NSData*) data toFileName:  (NSString*) filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[self videoFileDirectoryPath]];
    [data writeToFile:path atomically:YES];
    return [NSURL URLWithString:path];
}

- (NSString *) videoFileDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"/videos"];
}

- (void) uploadSamples
{
    // Create a video object
    PFObject *video1 = [PFObject objectWithClassName:@"GPVideo"];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"GPVideo_id000000001" ofType:@"mov"];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    
    PFFile *imageFile = [PFFile fileWithName:@"GPVideo_id000000001" data:fileData];
    [video1 setObject:imageFile forKey:@"file"];
    [video1 saveInBackground];

    PFObject *video2 = [PFObject objectWithClassName:@"GPVideo"];
    filePath = [[NSBundle mainBundle] pathForResource:@"GPVideo_id000000002" ofType:@"mov"];
    fileData = [NSData dataWithContentsOfFile:filePath];
    
    imageFile = [PFFile fileWithName:@"GPVideo_id000000002" data:fileData];
    [video2 setObject:imageFile forKey:@"file"];
    [video2 saveInBackground];

    PFObject *video3 = [PFObject objectWithClassName:@"GPVideo"];
    filePath = [[NSBundle mainBundle] pathForResource:@"GPVideo_id000000003" ofType:@"mov"];
    fileData = [NSData dataWithContentsOfFile:filePath];
    
    imageFile = [PFFile fileWithName:@"GPVideo_id000000003" data:fileData];
    [video3 setObject:imageFile forKey:@"file"];
    [video3 saveInBackground];

    PFObject *video4 = [PFObject objectWithClassName:@"GPVideo"];
    filePath = [[NSBundle mainBundle] pathForResource:@"GPVideo_id000000004" ofType:@"mov"];
    fileData = [NSData dataWithContentsOfFile:filePath];
    
    imageFile = [PFFile fileWithName:@"GPVideo_id000000004" data:fileData];
    [video4 setObject:imageFile forKey:@"file"];
    [video4 saveInBackground];

    PFObject *battle1 = [PFObject objectWithClassName:@"GPBattle"];
    [battle1 setObject:@"ysWALGfT0F" forKey:@"video_1"];
    [battle1 setObject:@"1z1si1cu3l" forKey:@"video_2"];
    [battle1 setObject:@"QmZ6wJQ6U4" forKey:@"user_1"];
    [battle1 setObject:@"WzOoHwfLLW" forKey:@"user_2"];

    PFObject *battle2 = [PFObject objectWithClassName:@"GPBattle"];
    [battle2 setObject:@"bOzQzle64v" forKey:@"video_1"];
    [battle2 setObject:@"AJ2UiOsgwD" forKey:@"video_2"];
    [battle2 setObject:@"WzOoHwfLLW" forKey:@"user_1"];
    [battle2 setObject:@"QmZ6wJQ6U4" forKey:@"user_2"];
    
    [battle1 saveInBackground];
    [battle2 saveInBackground];
    
    if ([PFUser currentUser])
    {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Propic1" ofType:@"jpg"];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        
        PFFile *imageFile = [PFFile fileWithName:@"pro_pic" data:fileData];
        [[PFUser currentUser] setObject:imageFile forKey:@"profile_picture"];
        [[PFUser currentUser] saveInBackground];
    }
}

// Facebook oauth callback
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [PFFacebookUtils handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [PFFacebookUtils handleOpenURL:url];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Handle an interruption during the authorization flow, such as the user clicking the home button.
    [FBSession.activeSession handleDidBecomeActive];
}

@end
