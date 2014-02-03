//
//
//
//  Created by Garrett Parrish on 1/15/14.
//  Copyright (c) 2014 Gampets. All rights reserved.
//
//


#import "GPDebugViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <Parse/Parse.h>

@interface GPCenterViewController : GPDebugViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UILabel *welcomeLabel;

- (IBAction)logOutButtonTapAction:(id)sender;

- (void) checkForUser;

@end
