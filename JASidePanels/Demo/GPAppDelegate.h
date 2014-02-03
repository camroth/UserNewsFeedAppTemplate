//
//
//
//
//  Created by Garrett Parrish on 1/15/14.
//  Copyright (c) 2014 Gampets. All rights reserved.
//
//
//

#import <UIKit/UIKit.h>

@class GPSidePanelController, GPLogInViewController, GPAppDelegate;

GPAppDelegate* AppDelegate();

@interface GPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) GPSidePanelController *homeViewController;
@property (strong, nonatomic) GPLogInViewController *loginConfigurationController;

- (NSString *) videoFileDirectoryPath;
- (NSURL*) writeVideoData: (NSData*) data toFileName:  (NSString*) filename;

@end
