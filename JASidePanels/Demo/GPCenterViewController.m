//
//
//
//  Created by Garrett Parrish on 1/15/14.
//  Copyright (c) 2014 Gampets. All rights reserved.
//
//
//

#import "GPCenterViewController.h"
#import "GPLogInViewController.h"
#import "GPSignUpViewController.h"
#import "GPAppDelegate.h"
#import "GPBattle.h"
#import "GPBattleUIParticipant.h"

static const int BATTLE_QUEUE_SIZE = 5;

@interface GPCenterViewController ()
{
    NSMutableArray *battleQueue;
    BOOL filledQueue;
    NSMutableArray *battleViews;

    GPBattle *currentBattle;
    GPBattleUIParticipant *battleParticipant1;
    GPBattleUIParticipant *battleParticipant2;
}

@end

@implementation GPCenterViewController

- (id) init
{
    if (self = [super init])
    {
        self.title = @"Home";
    }
    
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor orangeColor];
    
    [self checkForUser];

    filledQueue = false;
    
    battleQueue = [[NSMutableArray alloc] init];
    
    if ([PFUser currentUser])
    {
        [self requestBattle];
        
        if (filledQueue)
        {
            NSLog(@"Current battle queue: %@", battleQueue);
        }
    }
}

- (void) requestBattle
{
    NSLog(@"Requesting battle.");

    [PFCloud callFunctionInBackground:@"requestBattle"
                       withParameters:@{@"Matrix" :@"movie"}
                                block:^(NSString *response, NSError *error) {
                                    if (!error)
                                    {
                                        NSLog(@"Battle ID: %@", response);

                                        [battleQueue addObject:response];
                                        
                                        // Only happens on first time screen loads
                                        // subsequent battles load at end of current ones
                                        
                                        if ([battleQueue count] == 1)
                                        {
                                            [self makeNewBattle:response];
                                        }
                                        
                                        // Fill queue if needed
                                        [self fillQueueIfNeeded];
                                    }
                                    else
                                    {
                                        NSLog(@"Error Receiving Battle: %@", error);
                                    }
                                }];
}

- (void) fillQueueIfNeeded
{
    if ([battleQueue count] < BATTLE_QUEUE_SIZE)
    {
        [self requestBattle];
    }
    else
    {
        NSLog(@"Current battle queue: %@", battleQueue);
    }
}

/// Query helper methods
- (void) makeNewBattle: (NSString *) battleID
{
    NSLog(@"Creating new battle.");
    
    currentBattle = [[GPBattle alloc] initWithBattleId:battleID];
    
    CGFloat viewHeight = self.view.frame.size.height;
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat height = viewHeight * .4f;
    CGFloat width = viewWidth * .95f;

    battleParticipant1 = [[GPBattleUIParticipant alloc] initWithFrame:CGRectMake(0.0, 0.0, width, height)];
    [battleParticipant1 setAsUser:@"user_1" inBattle:currentBattle];
    battleParticipant1.center = CGPointMake(viewWidth * .50f, viewHeight * .35f);
    [self.view addSubview:battleParticipant1];

    battleParticipant2 = [[GPBattleUIParticipant alloc] initWithFrame:CGRectMake(0.0, 0.0, width, height)];
    [battleParticipant2 setAsUser:@"user_2" inBattle:currentBattle];
    battleParticipant2.center = CGPointMake(viewWidth * .50f, viewHeight * .80f);
    [self.view addSubview:battleParticipant2];
}

- (void) battleFinished
{
    // Move battle ids upwards
    for (int i = 1; i < BATTLE_QUEUE_SIZE; i ++)
    {
        battleQueue[i - 1] = battleQueue[i];
    }
    
    // Remove last battle
    [battleQueue removeObject:battleQueue[BATTLE_QUEUE_SIZE - 1]];

    // Load a new battle ID
    [self requestBattle];
}

- (void) checkForUser
{
    NSLog(@"CHECKING FOR USER");
    
    // Check if user is logged in
    if (![PFUser currentUser])
    {
        // Customize the Log In View Controller
        GPLogInViewController *logInViewController = [[GPLogInViewController alloc] init];
        logInViewController.delegate = self;
        logInViewController.facebookPermissions = @[@"friends_about_me", @"email", @"uid", @"user_friends", @"user_photos"];
        logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsTwitter | PFLogInFieldsFacebook | PFLogInFieldsSignUpButton | PFLogInFieldsDismissButton;
        
        // Customize the Sign Up View Controller
        GPSignUpViewController *signUpViewController = [[GPSignUpViewController alloc] init];
        signUpViewController.delegate = self;
        signUpViewController.fields = PFSignUpFieldsDefault | PFSignUpFieldsAdditional;
        logInViewController.signUpController = signUpViewController;
        
        // Present Log In View Controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
    }
}


#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password
{
    if (username && password && username.length && password.length)
    {
        return YES;
    }
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil)
                                message:NSLocalizedString(@"Make sure you fill out all of the information!", nil)
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:nil] show];
    return NO;
}

// Sent to the delegate when a PFUser is logged in.
- (void) logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    NSLog(@"User Logged In");
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void) logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void) logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController{
    
    NSLog(@"User dismissed the logInViewController");
}


#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL) signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info
{
    BOOL informationComplete = YES;
    for (id key in info)
    {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0)
        {
            informationComplete = NO;
            break;
        }
    }
    
    if (!informationComplete)
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void) signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the sign up attempt fails.
- (void) signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error
{
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void) signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController
{
    NSLog(@"User dismissed the signUpViewController");
}


#pragma mark - ()

- (IBAction) logOutButtonTapAction:(id)sender
{
    [PFUser logOut];
    [self.navigationController popViewControllerAnimated:YES];
}


/// Pull info from facebook

@end
